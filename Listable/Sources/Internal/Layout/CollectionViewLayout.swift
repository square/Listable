//
//  CollectionViewLayout.swift
//  Listable
//
//  Created by Kyle Van Essen on 9/23/19.
//

import UIKit


final class CollectionViewLayout : UICollectionViewLayout
{
    //
    // MARK: Properties
    //
    
    unowned let delegate : CollectionViewLayoutDelegate
    
    var appearance : Appearance {
        didSet {
            guard oldValue != self.appearance else {
                return
            }
            
            self.applyAppearance()
        }
    }
    
    private func applyAppearance()
    {
        guard self.collectionView != nil else {
            return
        }
        
        self.neededLayoutType.merge(with: .rebuild)
        self.invalidateLayout()
    }
    
    //
    // MARK: Initialization
    //
    
    init(
        delegate : CollectionViewLayoutDelegate,
        appearance : Appearance
    )
    {
        self.delegate = delegate
        self.appearance = appearance
        
        self.layout = DefaultListLayout()
        self.previousLayout = self.layout
        
        self.changesDuringCurrentUpdate = UpdateItems(with: [])
        
        super.init()
        
        self.applyAppearance()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { listableFatal() }
    
    //
    // MARK: Querying The Layout
    //
    
    func positionForItem(at indexPath : IndexPath) -> ItemPosition
    {
        let item = self.layout.item(at: indexPath)
        
        return item.position
    }
    
    //
    // MARK: Private Properties
    //
    
    private var layout : DefaultListLayout
    private var previousLayout : DefaultListLayout
    
    private var changesDuringCurrentUpdate : UpdateItems
    
    //
    // MARK: Invalidation & Invalidation Contexts
    //
    
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
            self.neededLayoutType = .rebuild
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
            
            let item = self.layout.item(at: from)
            item.liveIndexPath = to
                    
            self.layout.move(from: from, to: to)
            
            if from != to {
                context.performedInteractiveMove = true
                self.layout.reindexLiveIndexPaths()
            }
        }
        
        // Handle View Width Changing
        
        context.widthChanged = self.layout.shouldInvalidateLayoutFor(newCollectionViewSize: view.bounds.size)
        
        // Update Needed Layout Type
                
        self.neededLayoutType.merge(with: context)
    }
    
    override func invalidationContextForEndingInteractiveMovementOfItems(
        toFinalIndexPaths indexPaths: [IndexPath],
        previousIndexPaths: [IndexPath],
        movementCancelled: Bool
    ) -> UICollectionViewLayoutInvalidationContext
    {
        listablePrecondition(movementCancelled == false, "Cancelling moves is currently not supported.")
        
        self.layout.reindexLiveIndexPaths()
        self.layout.reindexDelegateProvidedIndexPaths()
                                
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
        var widthChanged : Bool = false
        
        var performedInteractiveMove : Bool = false
    }
    
    //
    // MARK: Preparing For Layouts
    //
    
    private enum NeededLayoutType {
        case none
        case relayout
        case rebuild
        
        mutating func merge(with context : UICollectionViewLayoutInvalidationContext)
        {
            let context = context as! InvalidationContext
            
            let requeryDataSourceCounts = context.invalidateEverything || context.invalidateDataSourceCounts
            let needsRelayout = context.widthChanged || context.performedInteractiveMove
            
            if requeryDataSourceCounts {
                self.merge(with: .rebuild)
            } else if needsRelayout {
                self.merge(with: .relayout)
            }
        }
        
        mutating func merge(with new : NeededLayoutType)
        {
            if new.priority > self.priority {
                self = new
            }
        }
        
        private var priority : Int {
            switch self {
            case .none: return 0
            case .relayout: return 1
            case .rebuild: return 2
            }
        }
        
        mutating func update(with success : Bool)
        {
            if success {
                self = .none
            }
        }
    }
    
    private var neededLayoutType : NeededLayoutType = .rebuild
        
    override func prepare()
    {
        super.prepare()

        self.changesDuringCurrentUpdate = UpdateItems(with: [])
        
        self.neededLayoutType.update(with: {
            switch self.neededLayoutType {
            case .none: return true
            case .relayout: return self.performRelayout()
            case .rebuild: return self.performRebuild()
            }
        }())
        
        self.performUpdateHeaders()
        self.performUpdateOverscroll()
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
    
    private func performUpdateHeaders()
    {
        self.layout.updateHeaders(in: self.collectionView!)
    }
    
    private func performUpdateOverscroll()
    {
        self.layout.updateOverscrollPosition(in: self.collectionView!)
    }
    
    private func performRelayout() -> Bool
    {
        return self.layout.layout(
            delegate: self.delegate,
            in: self.collectionView!
        )
    }
    
    private func performRebuild() -> Bool
    {
        self.previousLayout = self.layout
        
        self.layout = DefaultListLayout(
            delegate: self.delegate,
            appearance: self.appearance,
            in: self.collectionView!
        )
        
        return self.layout.layout(
            delegate: self.delegate,
            in: self.collectionView!
        )
    }
    
    //
    // MARK: UICollectionViewLayout Methods
    //
    
    override var collectionViewContentSize : CGSize
    {
        return self.layout.contentSize
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        return self.layout.layoutAttributes(in: rect)
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        return self.layout.layoutAttributes(at: indexPath)
    }
    
    public override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        return self.layout.supplementaryLayoutAttributes(of: elementKind, at: indexPath)
    }
    
    //
    // MARK: UICollectionViewLayout Methods: Insertions & Removals
    //

    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        let wasInserted = self.changesDuringCurrentUpdate.insertedItems.contains(.init(newIndexPath: itemIndexPath))

        if wasInserted {
            let attributes = self.layout.layoutAttributes(at: itemIndexPath)
            
            attributes.frame.origin.y -= attributes.frame.size.height
            attributes.alpha = 0.0

            return attributes
        } else {
            let wasSectionInserted = self.changesDuringCurrentUpdate.insertedSections.contains(.init(newIndex: itemIndexPath.section))
            
            let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
            
            if wasSectionInserted == false {
                attributes?.alpha = 1.0
            }
            
            return attributes
        }
    }

    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        let wasItemDeleted = self.changesDuringCurrentUpdate.deletedItems.contains(.init(oldIndexPath: itemIndexPath))
        
        if wasItemDeleted {
            let attributes = self.previousLayout.layoutAttributes(at: itemIndexPath)

            attributes.frame.origin.y -= attributes.frame.size.height
            attributes.alpha = 0.0

            return attributes
        } else {
            let wasSectionDeleted = self.changesDuringCurrentUpdate.deletedSections.contains(.init(oldIndex: itemIndexPath.section))
            
            let attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
            
            if wasSectionDeleted == false {
                attributes?.alpha = 1.0
            }
            
            return attributes
        }
    }
    
    override func initialLayoutAttributesForAppearingSupplementaryElement(ofKind elementKind: String, at elementIndexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        let wasInserted = self.changesDuringCurrentUpdate.insertedSections.contains(.init(newIndex: elementIndexPath.section))
        let attributes = super.initialLayoutAttributesForAppearingSupplementaryElement(ofKind: elementKind, at: elementIndexPath)
        
        if wasInserted == false {
            attributes?.alpha = 1.0
        }
        
        return attributes
    }
    
    override func finalLayoutAttributesForDisappearingSupplementaryElement(ofKind elementKind: String, at elementIndexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        let wasDeleted = self.changesDuringCurrentUpdate.deletedSections.contains(.init(oldIndex: elementIndexPath.section))
        let attributes = super.finalLayoutAttributesForDisappearingSupplementaryElement(ofKind: elementKind, at: elementIndexPath)
        
        if wasDeleted == false {
            attributes?.alpha = 1.0
        }
        
        return attributes
    }
    
    //
    // MARK: UICollectionViewLayout Methods: Moving Items
    //
    
    override func layoutAttributesForInteractivelyMovingItem(at indexPath: IndexPath, withTargetPosition position: CGPoint) -> UICollectionViewLayoutAttributes
    {
        let defaultAttributes = self.layout.layoutAttributes(at: indexPath)
        let attributes = super.layoutAttributesForInteractivelyMovingItem(at: indexPath, withTargetPosition: position)
        
        attributes.center.x = defaultAttributes.center.x
        
        return attributes
    }
}


//
// MARK: Delegate For Layout Information
//


protocol CollectionViewLayoutDelegate : AnyObject
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
    
    func hasOverscrollFooter(in collectionView : UICollectionView) -> Bool
    func heightForOverscrollFooter(in collectionView : UICollectionView, width : CGFloat, layoutDirection : LayoutDirection) -> CGFloat
    func layoutForOverscrollFooter(in collectionView : UICollectionView) -> HeaderFooterLayout
    
    func layoutFor(section sectionIndex : Int, in collectionView : UICollectionView) -> Section.Layout
    
    func hasHeader(in sectionIndex : Int, in collectionView : UICollectionView) -> Bool
    func heightForHeader(in sectionIndex : Int, in collectionView : UICollectionView, width : CGFloat, layoutDirection : LayoutDirection) -> CGFloat
    func layoutForHeader(in sectionIndex : Int, in collectionView : UICollectionView) -> HeaderFooterLayout
    
    func hasFooter(in sectionIndex : Int, in collectionView : UICollectionView) -> Bool
    func heightForFooter(in sectionIndex : Int, in collectionView : UICollectionView, width : CGFloat, layoutDirection : LayoutDirection) -> CGFloat
    func layoutForFooter(in sectionIndex : Int, in collectionView : UICollectionView) -> HeaderFooterLayout
    
    func columnLayout(for sectionIndex : Int, in collectionView : UICollectionView) -> Section.Columns
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
                
            @unknown default: listableFatal()
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
