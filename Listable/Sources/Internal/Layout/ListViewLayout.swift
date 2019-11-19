//
//  ListViewLayout.swift
//  Listable
//
//  Created by Kyle Van Essen on 9/23/19.
//

import UIKit


protocol ListViewLayoutDelegate : AnyObject
{
    func listViewLayoutUpdatedItemPositions(_ collectionView : UICollectionView)
    
    func heightForItem(at indexPath : IndexPath, in collectionView : UICollectionView, width : CGFloat, layoutDirection : LayoutDirection) -> CGFloat
    func layoutForItem(at indexPath : IndexPath, in collectionView : UICollectionView) -> ItemLayout
    
    func hasListHeader(in collectionView : UICollectionView) -> Bool
    func heightForListHeader(in collectionView : UICollectionView, width : CGFloat, layoutDirection : LayoutDirection) -> CGFloat
    func layoutForListHeader(in collectionView : UICollectionView) -> HeaderFooterLayout
    
    func hasListFooter(in collectionView : UICollectionView) -> Bool
    func heightForListFooter(in collectionView : UICollectionView, width : CGFloat, layoutDirection : LayoutDirection) -> CGFloat
    func layoutForListFooter(in collectionView : UICollectionView) -> HeaderFooterLayout
    
    func layoutFor(section sectionIndex : Int, in collectionView : UICollectionView) -> Section.Layout
    
    func hasHeader(in sectionIndex : Int, in collectionView : UICollectionView) -> Bool
    func heightForHeader(in sectionIndex : Int, in collectionView : UICollectionView, width : CGFloat, layoutDirection : LayoutDirection) -> CGFloat
    func layoutForHeader(in sectionIndex : Int, in collectionView : UICollectionView) -> HeaderFooterLayout
    
    func hasFooter(in sectionIndex : Int, in collectionView : UICollectionView) -> Bool
    func heightForFooter(in sectionIndex : Int, in collectionView : UICollectionView, width : CGFloat, layoutDirection : LayoutDirection) -> CGFloat
    func layoutForFooter(in sectionIndex : Int, in collectionView : UICollectionView) -> HeaderFooterLayout
    
    func columnLayout(for sectionIndex : Int, in collectionView : UICollectionView) -> Section.Columns
}


class ListViewLayout : UICollectionViewLayout
{
    //
    // MARK: Properties
    //
    
    unowned let delegate : ListViewLayoutDelegate
    
    var appearance : Appearance {
        didSet {
            guard oldValue != self.appearance else {
                return
            }
                                    
            self.invalidateEntireLayout()
            
            switch self.appearance.underflow {
            case .alwaysBounceVertical(let bounce):
                switch appearance.direction {
                case .vertical:
                    self.collectionView?.alwaysBounceVertical = bounce
                    self.collectionView?.alwaysBounceHorizontal = false
                case .horizontal:
                    self.collectionView?.alwaysBounceVertical = false
                    self.collectionView?.alwaysBounceHorizontal = bounce
                }
            case .pinTo(_):
                fatalError("Other types of underflow are not yet implemented.")
            }
        }
    }
    
    //
    // MARK: Initialization
    //
    
    init(
        delegate : ListViewLayoutDelegate,
        appearance : Appearance
    )
    {
        self.delegate = delegate
        self.appearance = appearance
        
        self.layoutResult = LayoutInfo()
        self.previousLayoutResult = self.layoutResult
        
        self.changesDuringCurrentUpdate = UpdateItems(with: [])
        
        super.init()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    //
    // MARK: Querying The Layout
    //
    
    func positionForItem(at indexPath : IndexPath) -> ItemPosition
    {
        let item = self.layoutResult.item(at: indexPath)
        
        return item.position
    }
    
    //
    // MARK: Private Properties
    //
    
    private var layoutResult : LayoutInfo
    private var previousLayoutResult : LayoutInfo
    
    private var changesDuringCurrentUpdate : UpdateItems
    
    //
    // MARK: Invalidation & Invalidation Contexts
    //
    
    func invalidateEntireLayout()
    {
        self.neededLayoutType = .requeryDataSourceCounts
    }
    
    private(set) var shouldAskForItemSizesDuringLayoutInvalidation : Bool = false
    
    func setShouldAskForItemSizesDuringLayoutInvalidation()
    {
        self.shouldAskForItemSizesDuringLayoutInvalidation = true
    }
    
    override class var invalidationContextClass: AnyClass {
        return InvalidationContext.self
    }
    
    override func invalidateLayout()
    {
        super.invalidateLayout()
        
        if self.shouldAskForItemSizesDuringLayoutInvalidation {
            self.invalidateEntireLayout()
            self.shouldAskForItemSizesDuringLayoutInvalidation = false
        }
    }
    
    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext)
    {
        let view = self.collectionView!
        let context = context as! InvalidationContext
        
        super.invalidateLayout(with: context)
        
        // Handle Moved Items
        
        if
            let from = context.previousIndexPathsForInteractivelyMovingItems,
            let to = context.targetIndexPathsForInteractivelyMovingItems
        {
            let from = from[0]
            let to = to[0]
            
            let item = self.layoutResult.item(at: from)
            item.liveIndexPath = to
                    
            self.layoutResult.move(from: from, to: to)
            
            if from != to {
                context.performedInteractiveMove = true
                self.layoutResult.reindexLiveIndexPaths()
            }
        }
        
        // Handle View Width Changing
        
        context.widthChanged = self.layoutResult.shouldInvalidateLayoutFor(newCollectionViewSize: view.bounds.size)
        
        // Update Needed Layout Type
                
        self.neededLayoutType.merge(with: context)
    }
    
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext
    {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! InvalidationContext
        
        context.updateHeaders = self.appearance.layout.stickySectionHeaders
        
        return context
    }
    
    override func invalidationContextForEndingInteractiveMovementOfItems(
        toFinalIndexPaths indexPaths: [IndexPath],
        previousIndexPaths: [IndexPath],
        movementCancelled: Bool
    ) -> UICollectionViewLayoutInvalidationContext
    {
        precondition(movementCancelled == false, "Cancelling moves is currently not supported.")
        
        self.layoutResult.reindexLiveIndexPaths()
        self.layoutResult.reindexDelegateProvidedIndexPaths()
                                
        return super.invalidationContextForEndingInteractiveMovementOfItems(
            toFinalIndexPaths: indexPaths,
            previousIndexPaths: previousIndexPaths,
            movementCancelled: movementCancelled
        )
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool
    {
        return true
    }
    
    private final class InvalidationContext : UICollectionViewLayoutInvalidationContext
    {
        var updateHeaders : Bool = false
        var widthChanged : Bool = false
        
        var performedInteractiveMove : Bool = false
    }
    
    //
    // MARK: Preparing For Layouts
    //
    
    private enum NeededLayoutType {
        case none
        case updateHeaders
        case relayout
        case requeryDataSourceCounts
        
        mutating func merge(with context : UICollectionViewLayoutInvalidationContext)
        {
            let context = context as! InvalidationContext
            
            let requeryDataSourceCounts = context.invalidateEverything || context.invalidateDataSourceCounts
            let needsRelayout = context.widthChanged || context.performedInteractiveMove
            
            if requeryDataSourceCounts {
                self = .requeryDataSourceCounts
            } else if needsRelayout {
                switch self {
                case .none, .updateHeaders: self = .relayout
                case .relayout, .requeryDataSourceCounts: break
                }
            } else if context.updateHeaders {
                switch self {
                case .none: self = .updateHeaders
                case .updateHeaders, .relayout, .requeryDataSourceCounts: break
                }
            }
        }
        
        mutating func update(with success : Bool)
        {
            if success {
                self = .none
            }
        }
    }
    
    private var neededLayoutType : NeededLayoutType = .requeryDataSourceCounts
        
    override func prepare()
    {
        super.prepare()

        self.changesDuringCurrentUpdate = UpdateItems(with: [])
        
        self.neededLayoutType.update(with: {
            switch self.neededLayoutType {
            case .none: return true
            case .updateHeaders: return self.performHeaderLayout()
            case .relayout: return self.performRelayout()
            case .requeryDataSourceCounts: return self.performRequeryDataSourceCountsAndLayout()
            }
        }())
    }
    
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem])
    {
        super.prepare(forCollectionViewUpdates: updateItems)
        
        self.changesDuringCurrentUpdate = UpdateItems(with: updateItems)
    }
    
    //
    // MARK: Finishing Layouts
    //
    
    override func finalizeCollectionViewUpdates()
    {
        super.finalizeCollectionViewUpdates()
        
        self.changesDuringCurrentUpdate = UpdateItems(with: [])
    }
    
    //
    // MARK: Performing Layouts
    //
    
    private func performHeaderLayout() -> Bool
    {
        return self.layoutResult.updateHeaders(in: self.collectionView!)
    }
    
    private func performRelayout() -> Bool
    {
        return self.layoutResult.layout(
            delegate: self.delegate,
            in: self.collectionView!
        )
    }
    
    private func performRequeryDataSourceCountsAndLayout() -> Bool
    {
        self.previousLayoutResult = self.layoutResult
        
        self.layoutResult = LayoutInfo(
            delegate: self.delegate,
            appearance: self.appearance,
            in: self.collectionView!
        )
        
        return self.layoutResult.layout(
            delegate: self.delegate,
            in: self.collectionView!
        )
    }
    
    //
    // MARK: UICollectionViewLayout Methods
    //
    
    override var collectionViewContentSize : CGSize
    {
        return self.layoutResult.contentSize
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        return self.layoutResult.layoutAttributes(in: rect)
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        return self.layoutResult.layoutAttributes(at: indexPath)
    }
    
    public override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        return self.layoutResult.supplementaryLayoutAttributes(of: elementKind, at: indexPath)
    }
    
    //
    // MARK: UICollectionViewLayout Methods: Insertions & Removals
    //

    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        let wasInserted = self.changesDuringCurrentUpdate.insertedItems.contains(.init(newIndexPath: itemIndexPath))

        if wasInserted {
            let attributes = self.layoutResult.layoutAttributes(at: itemIndexPath)
            
            attributes.frame.origin.y -= attributes.frame.size.height
            attributes.alpha = 0.0

            return attributes
        } else {
            return super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        }
    }

    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        let wasDeleted = self.changesDuringCurrentUpdate.deletedItems.contains(.init(oldIndexPath: itemIndexPath))

        if wasDeleted {
            let attributes = self.previousLayoutResult.layoutAttributes(at: itemIndexPath)

            attributes.frame.origin.y -= attributes.frame.size.height
            attributes.alpha = 0.0

            return attributes
        } else {
            return super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
        }
    }
    
    //
    // MARK: UICollectionViewLayout Methods: Moving Items
    //
    
    override func layoutAttributesForInteractivelyMovingItem(at indexPath: IndexPath, withTargetPosition position: CGPoint) -> UICollectionViewLayoutAttributes
    {
        let defaultAttributes = self.layoutResult.layoutAttributes(at: indexPath)
        let attributes = super.layoutAttributesForInteractivelyMovingItem(at: indexPath, withTargetPosition: position)
        
        attributes.center.x = defaultAttributes.center.x
        
        return attributes
    }
}


//
// MARK: Update Information From Collection View Layout
//

fileprivate struct UpdateItems : Equatable
{
    let insertedSections : Set<InsertSection>
    let deletedSections : Set<DeleteSection>
    
    let insertedItems : Set<InsertItem>
    let deletedItems : Set<DeleteItem>
    
    init(with updateItems : [UICollectionViewUpdateItem])
    {
       var insertedSections = Set<InsertSection>()
       var deletedSections = Set<DeleteSection>()

       var insertedItems = Set<InsertItem>()
       var deletedItems = Set<DeleteItem>()

       for item in updateItems {
            switch item.updateAction {
            case .insert:
                let indexPath = item.indexPathAfterUpdate!
                
                if indexPath.item == NSNotFound {
                    insertedSections.insert(.init(newIndex: indexPath.section))
                } else {
                    insertedItems.insert(.init(newIndexPath: indexPath))
                }
                
            case .delete:
                let indexPath = item.indexPathBeforeUpdate!
                
                if indexPath.item == NSNotFound {
                    deletedSections.insert(.init(oldIndex: indexPath.section))
                } else {
                    deletedItems.insert(.init(oldIndexPath: indexPath))
                }
                
            case .move: break
            case .reload: break
            case .none: break
                
            @unknown default: fatalError()
            }
        }
        
        self.insertedSections = insertedSections
        self.deletedSections = deletedSections
        
        self.insertedItems = insertedItems
        self.deletedItems = deletedItems
    }
    
    struct InsertSection : Hashable
    {
        var newIndex : Int
    }
    
    struct DeleteSection : Hashable
    {
        var oldIndex : Int
    }
    
    struct InsertItem : Hashable
    {
        var newIndexPath : IndexPath
    }
    
    struct DeleteItem : Hashable
    {
        var oldIndexPath : IndexPath
    }
}

