//
//  ListViewLayout.swift
//  Listable
//
//  Created by Kyle Van Essen on 9/23/19.
//

import UIKit


protocol ListViewLayoutDelegate : AnyObject
{    
    func heightForItem(at indexPath : IndexPath, in collectionView : UICollectionView, width : CGFloat) -> CGFloat
    
    func hasListHeader(in collectionView : UICollectionView) -> Bool
    func heightForListHeader(in collectionView : UICollectionView, width : CGFloat) -> CGFloat
    
    func hasListFooter(in collectionView : UICollectionView) -> Bool
    func heightForListFooter(in collectionView : UICollectionView, width : CGFloat) -> CGFloat
    
    func hasHeader(in sectionIndex : Int, in collectionView : UICollectionView) -> Bool
    func heightForHeader(in sectionIndex : Int, in collectionView : UICollectionView, width : CGFloat) -> CGFloat
    
    func hasFooter(in sectionIndex : Int, in collectionView : UICollectionView) -> Bool
    func heightForFooter(in sectionIndex : Int, in collectionView : UICollectionView, width : CGFloat) -> CGFloat
    
    func columnLayout(for sectionIndex : Int, in collectionView : UICollectionView) -> ListViewLayout.ColumnLayout
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
            case .alwaysBounceVertical(let bounce): self.collectionView?.alwaysBounceVertical = bounce
            case .pinTo(_): fatalError("Other types of underflow are not yet implemented.")
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
        self.neededLayoutType = .fullLayout
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
        
        context.setWidthChanged(old: self.layoutResult.collectionViewWidth, new: view.frame.width)
        
        self.neededLayoutType.merge(with: context)
    }
    
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext
    {
        let view = self.collectionView!
        
        let context = super.invalidationContext(forBoundsChange: newBounds) as! InvalidationContext
        
        if newBounds.width == view.bounds.width {
            context.setUpdateHeaders()
        }
        
        return context
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool
    {
        return true
    }
    
    private final class InvalidationContext : UICollectionViewLayoutInvalidationContext
    {
        private(set) var updateHeaders : Bool = false
        
        private(set) var widthChanged : Bool = false
        
        func setUpdateHeaders()
        {
            guard self.updateHeaders == false else { return }
            
            self.updateHeaders = true
        }
        
        func setWidthChanged(old : CGFloat, new : CGFloat)
        {
            let changed = old != new
            
            self.widthChanged = self.widthChanged || changed
        }
    }
    
    //
    // MARK: Preparing For Layouts
    //
    
    private enum NeededLayoutType {
        case none
        case updateHeaders
        case fullLayout
        
        mutating func merge(with context : UICollectionViewLayoutInvalidationContext)
        {
            let context = context as! InvalidationContext
                        
            let needsFullLayout : Bool = context.invalidateEverything || context.invalidateDataSourceCounts || context.widthChanged
            
            switch self {
            case .none:
                if needsFullLayout {
                    self = .fullLayout
                } else if context.updateHeaders {
                    self = .updateHeaders
                }
            case .updateHeaders:
                if needsFullLayout {
                    self = .fullLayout
                }
                
            case .fullLayout: break
            }
        }
        
        mutating func update(with layoutResult : LayoutInfo.LayoutResult)
        {
            switch layoutResult {
            case .completed: self = .none
            case .skipped: break
            }
        }
    }
    
    private var neededLayoutType : NeededLayoutType = .fullLayout
        
    override func prepare()
    {
        super.prepare()

        self.changesDuringCurrentUpdate = UpdateItems(with: [])
        
        self.neededLayoutType.update(with: {
            switch self.neededLayoutType {
            case .none: return .completed
            case .updateHeaders: return self.performHeaderLayout()
            case .fullLayout: return self.performFullLayout()
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
    
    private func performHeaderLayout() -> LayoutInfo.LayoutResult
    {
        self.previousLayoutResult = self.layoutResult
        
        return self.layoutResult.updateHeaders(
            delegate: self.delegate,
            contentLayout: self.appearance.contentLayout,
            in: self.collectionView!
        )
    }
    
    private func performFullLayout() -> LayoutInfo.LayoutResult
    {
        self.previousLayoutResult = self.layoutResult
        
        self.layoutResult = LayoutInfo(
            delegate: self.delegate,
            contentLayout: self.appearance.contentLayout,
            in: self.collectionView!
        )
        
        return self.layoutResult.layout(
            delegate: self.delegate,
            contentLayout: self.appearance.contentLayout,
            in: self.collectionView!
        )
    }
    
    //
    // MARK: UICollectionViewLayout Methods
    //
    
    override var collectionViewContentSize : CGSize
    {
        return self.layoutResult.size
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        return self.layoutResult.elements(in: rect)
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        return self.layoutResult.element(at: indexPath)
    }
    
    public override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        return self.layoutResult.supplementaryElement(of: elementKind, at: indexPath)
    }
    
    //
    // MARK: UICollectionViewLayout Methods: Insertions & Removals
    //

    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        let wasInserted = self.changesDuringCurrentUpdate.insertedItems.contains(.init(newIndexPath: itemIndexPath))

        if wasInserted {
            let attributes = self.layoutResult.element(at: itemIndexPath)
            
            attributes.frame.origin.y -= attributes.frame.size.height
            attributes.alpha = 0.0

            return attributes
        } else {
            return super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        }
    }

    public override func initialLayoutAttributesForAppearingSupplementaryElement(ofKind elementKind: String, at elementIndexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        return super.initialLayoutAttributesForAppearingSupplementaryElement(ofKind: elementKind, at: elementIndexPath)
    }

    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        let wasDeleted = self.changesDuringCurrentUpdate.deletedItems.contains(.init(oldIndexPath: itemIndexPath))

        if wasDeleted {
            let attributes = self.previousLayoutResult.element(at: itemIndexPath)

            attributes.frame.origin.y -= attributes.frame.size.height
            attributes.alpha = 0.0

            return attributes
        } else {
            return super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
        }
    }

    public override func finalLayoutAttributesForDisappearingSupplementaryElement(ofKind elementKind: String, at elementIndexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        return super.finalLayoutAttributesForDisappearingSupplementaryElement(ofKind: elementKind, at: elementIndexPath)
    }
}


extension ListViewLayout
{
    enum SupplementaryKind : String
    {
        case listHeader = "Listable.ListViewLayout.ListHeader"
        case listFooter = "Listable.ListViewLayout.ListFooter"
        
        case sectionHeader = "Listable.TableLayout.SectionHeader"
        case sectionFooter = "Listable.TableLayout.SectionFooter"
        
        var zIndex : Int {
            switch self {
            case .listHeader: return 1
            case .listFooter: return 1
                
            case .sectionHeader: return 2
            case .sectionFooter: return 1
            }
        }
        
        func indexPath(in section : Int) -> IndexPath
        {
            switch self {
            case .listHeader: return IndexPath(item: 0, section: 0)
            case .listFooter: return IndexPath(item: 0, section: 0)
                
            case .sectionHeader: return IndexPath(item: 0, section: section)
            case .sectionFooter: return IndexPath(item: 0, section: section)
            }
        }
    }
}


extension ListViewLayout
{
    struct ColumnLayout : Equatable
    {
        var columns : Int
        var spacing : CGFloat
        
        init(columns : Int, spacing : CGFloat)
        {
            precondition(columns >= 1, "Columns must be greater than or equal to 1.")
            precondition(spacing >= 0.0, "Spacing must be greater than or equal to 0.")
            
            self.columns = columns
            self.spacing = spacing
        }
        
        fileprivate struct Grouped<Value>
        {
            var value : Value
            
            var index : Int
        }
        
        fileprivate func group<Value>(values input : [Value]) -> [[Grouped<Value>]]
        {
            var values : [Grouped<Value>] = input.mapWithIndex { index, value in
                return Grouped(value: value, index: index)
            }
            
            var grouped : [[Grouped<Value>]] = []
            
            while values.count > 0 {
                grouped.append(values.safeDropFirst(self.columns))
            }
            
            return grouped
        }
    }
}


fileprivate extension Array
{
    mutating func safeDropFirst(_ count : Int) -> [Element]
    {
        let safeCount = Swift.min(self.count, count)
        let values = self[0..<safeCount]
        
        self.removeFirst(safeCount)
        
        return Array(values)
    }
}


fileprivate extension ListViewLayout
{
    struct LayoutInfo
    {
        //
        // MARK: Public Properties
        //
        
        var collectionViewWidth : CGFloat
        
        var header : SupplementaryItemLayoutInfo?
        var footer : SupplementaryItemLayoutInfo?
        
        var sections : [SectionLayoutInfo]
        
        var size : CGSize
        
        //
        // MARK: Initialization
        //
        
        init()
        {
            self.collectionViewWidth = 0.0
            
            self.sections = []
            
            self.size = .zero
        }
        
        init(
            delegate : ListViewLayoutDelegate,
            contentLayout : ListContentLayout,
            in collectionView : UICollectionView
        )
        {
            let sectionCount = collectionView.numberOfSections
            
            self.collectionViewWidth = 0.0
            self.size = .zero
            
            let hasHeader = delegate.hasListHeader(in: collectionView)
            let hasFooter = delegate.hasListFooter(in: collectionView)
            
            self.header = hasHeader ? SupplementaryItemLayoutInfo(kind: SupplementaryKind.listHeader) : nil
            self.footer = hasFooter ? SupplementaryItemLayoutInfo(kind: SupplementaryKind.listFooter) : nil
                        
            self.sections = sectionCount.mapEach { sectionIndex in
                
                let hasHeader = delegate.hasHeader(in: sectionIndex, in: collectionView)
                let hasFooter = delegate.hasFooter(in: sectionIndex, in: collectionView)
                
                let itemCount = collectionView.numberOfItems(inSection: sectionIndex)
                
                return SectionLayoutInfo(
                    header: hasHeader ? SupplementaryItemLayoutInfo(kind: SupplementaryKind.sectionHeader) : nil,
                    footer: hasFooter ? SupplementaryItemLayoutInfo(kind: SupplementaryKind.sectionFooter) : nil,
                    frame: .zero,
                    items: Array(repeating: ItemLayoutInfo(), count: itemCount)
                )
            }
        }
        
        //
        // MARK: Fetching Elements
        //
        
        func elements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]
        {
            var attributes = [UICollectionViewLayoutAttributes]()
                        
            if let header = self.header {
                if rect.intersects(header.visibleFrame) {
                    attributes.append(header.layoutAttributes(with: SupplementaryKind.listHeader.indexPath(in: 0)))
                }
            }
            
            for (sectionIndex, section) in self.sections.enumerated() {
                
                guard rect.intersects(section.frame) else {
                    continue
                }
                                
                if let header = section.header {
                    if rect.intersects(header.visibleFrame) {
                        attributes.append(header.layoutAttributes(with: SupplementaryKind.sectionHeader.indexPath(in: sectionIndex)))
                    }
                }
                
                for (itemIndex, item) in section.items.enumerated() {
                    if rect.intersects(item.frame) {
                        let indexPath = IndexPath(item: itemIndex, section: sectionIndex)
                        attributes.append(item.layoutAttributes(with: indexPath))
                    }
                }
                
                if let footer = section.footer {
                    if rect.intersects(footer.visibleFrame) {
                        attributes.append(footer.layoutAttributes(with: SupplementaryKind.sectionFooter.indexPath(in: sectionIndex)))
                    }
                }
            }
            
            if let footer = self.footer {
                if rect.intersects(footer.visibleFrame) {
                    attributes.append(footer.layoutAttributes(with: SupplementaryKind.listFooter.indexPath(in: 0)))
                }
            }
            
            return attributes
        }
        
        func element(at indexPath : IndexPath) -> UICollectionViewLayoutAttributes
        {
            let item = self.sections[indexPath.section].items[indexPath.item]
            
            return item.layoutAttributes(with: indexPath)
        }
        
        func supplementaryElement(of kind : String, at indexPath : IndexPath) -> UICollectionViewLayoutAttributes?
        {
            let section = self.sections[indexPath.section]

            switch SupplementaryKind(rawValue: kind)! {
            case .listHeader: return self.header?.layoutAttributes(with: indexPath)
            case .listFooter: return self.footer?.layoutAttributes(with: indexPath)
                
            case .sectionHeader: return section.header?.layoutAttributes(with: indexPath)
            case .sectionFooter: return section.footer?.layoutAttributes(with: indexPath)
            }
        }
        
        //
        // MARK: Peforming Layouts
        //
        
        enum LayoutResult
        {
            case completed
            case skipped
        }
        
        @discardableResult
        mutating func updateHeaders(
            delegate : ListViewLayoutDelegate,
            contentLayout : ListContentLayout,
            in collectionView : UICollectionView
        ) -> LayoutResult
        {
            guard collectionView.frame.size.isEmpty == false else {
                return .skipped
            }
            
            guard contentLayout.sectionHeadersPinToVisibleBounds else {
                return .completed
            }
                        
            let visibleFrame = CGRect(
                x: 0.0,
                y: collectionView.contentOffset.y + collectionView.lst_safeAreaInsets.top,
                width: collectionView.bounds.size.width,
                height: collectionView.bounds.size.height
            )
            
            self.sections = self.sections.map { section in
                guard var header = section.header else {
                    return section
                }
                
                if header.baseFrame.origin.y < visibleFrame.origin.y {
                    // Make sure the pinned origin stays within the section's frame.
                    header.pinnedOrigin = min(
                        visibleFrame.origin.y,
                        section.frame.maxY - header.baseFrame.height
                    )
                } else {
                    header.pinnedOrigin = nil
                }
                
                var section = section
                section.header = header
                
                return section
            }
            
            return .completed
        }
        
        mutating func layout(
            delegate : ListViewLayoutDelegate,
            contentLayout : ListContentLayout,
            in collectionView : UICollectionView
        ) -> LayoutResult
        {
            guard collectionView.frame.size.isEmpty == false else {
                return .skipped
            }
                                    
            var lastSectionMaxY : CGFloat = 0.0
            var lastContentMaxY : CGFloat = 0.0
            
            let totalWidth = collectionView.bounds.size.width
            let paddedWidth = totalWidth - contentLayout.padding.left - contentLayout.padding.right
            
            let contentWidth = contentLayout.width.clamp(paddedWidth)
            let xOrigin = round((totalWidth - contentWidth) / 2.0)
            
            self.collectionViewWidth = totalWidth
            
            if var header = self.header {
                let height = delegate.heightForListHeader(in: collectionView, width: contentWidth)
                
                header.baseFrame = CGRect(x: 0.0, y: lastContentMaxY, width: totalWidth, height: height)

                self.header = header

                lastContentMaxY = header.baseFrame.maxY
                lastContentMaxY += contentLayout.sectionHeaderBottomSpacing
            }
            
            lastSectionMaxY += contentLayout.padding.top
            lastContentMaxY += contentLayout.padding.top
            
            self.sections = self.sections.mapWithIndex { sectionIndex, section in
                
                let isLastSection = (sectionIndex == self.sections.count - 1)
                
                var section = section
                
                // Header
                
                if var header = section.header {
                    let height = delegate.heightForHeader(in: sectionIndex, in: collectionView, width: contentWidth)
                    header.baseFrame = CGRect(x: xOrigin, y: lastContentMaxY, width: contentWidth, height: height)

                    section.header = header

                    lastContentMaxY = header.baseFrame.maxY
                    lastContentMaxY += contentLayout.sectionHeaderBottomSpacing
                }
                
                // Section Items
                
                let columnLayout = delegate.columnLayout(for: sectionIndex, in: collectionView)
                let itemWidth = round((contentWidth - (columnLayout.spacing * CGFloat(columnLayout.columns - 1))) / CGFloat(columnLayout.columns))
                
                var groupedItems = columnLayout.group(values: section.items)
                
                groupedItems = groupedItems.mapWithIndex { rowIndex, row in
                    
                    let isLastRow = rowIndex == groupedItems.count - 1
                    
                    var columnXOrigin = xOrigin
                    var maxHeight : CGFloat = 0.0
                    
                    let row : [ColumnLayout.Grouped<ItemLayoutInfo>] = row.mapWithIndex { columnIndex, item in
                        
                        let indexPath = IndexPath(item: item.index, section: sectionIndex)
                        
                        var item = item
                        
                        let height = delegate.heightForItem(at: indexPath, in: collectionView, width: itemWidth)
                        item.value.frame = CGRect(x: columnXOrigin, y: lastContentMaxY, width: itemWidth, height: height)
                        
                        maxHeight = max(height, maxHeight)
                        
                        columnXOrigin = item.value.frame.maxX + columnLayout.spacing
                        
                        return item
                    }
                    
                    lastContentMaxY += maxHeight
                    
                    if isLastRow {
                        lastContentMaxY += contentLayout.rowToSectionFooterSpacing
                    } else {
                        lastContentMaxY += contentLayout.rowSpacing
                    }
                    
                    return row
                }
                
                section.items = groupedItems.flatMap { $0.map { $0.value } }
                
                // Footer
                
                if var footer = section.footer {
                    let height = delegate.heightForFooter(in: sectionIndex, in: collectionView, width: contentWidth)
                    footer.baseFrame = CGRect(x: xOrigin, y: lastContentMaxY, width: contentWidth, height: height)

                    section.footer = footer

                    lastContentMaxY = footer.baseFrame.maxY
                }
                
                section.frame = CGRect(x: xOrigin, y: lastSectionMaxY, width: contentWidth, height: lastContentMaxY - lastSectionMaxY)
                
                lastSectionMaxY = section.frame.maxY
                
                // Add additional padding from config.
                
                if isLastSection == false {
                    let additionalSectionSpacing = section.footer != nil ? contentLayout.interSectionSpacingWithFooter : contentLayout.interSectionSpacingWithNoFooter

                    lastSectionMaxY += additionalSectionSpacing
                    lastContentMaxY += additionalSectionSpacing
                }
                
                return section
            }
            
            lastContentMaxY += contentLayout.padding.bottom
            
            if var footer = self.footer {
                let height = delegate.heightForListFooter(in: collectionView, width: contentWidth)
                
                footer.baseFrame = CGRect(x: 0.0, y: lastContentMaxY, width: totalWidth, height: height)

                self.footer = footer

                lastContentMaxY = footer.baseFrame.maxY
                lastContentMaxY += contentLayout.sectionHeaderBottomSpacing
            }
                        
            self.size = CGSize(width: totalWidth, height: lastContentMaxY)
            
            self.updateHeaders(
                delegate: delegate,
                contentLayout: contentLayout,
                in: collectionView
            )
            
            return .completed
        }
    }
    
    //
    // MARK: Layout Information
    //
    
    struct SectionLayoutInfo
    {
        var header : SupplementaryItemLayoutInfo?
        var footer : SupplementaryItemLayoutInfo?

        var frame : CGRect = .zero
        
        var items : [ItemLayoutInfo] = []
    }
    
    struct SupplementaryItemLayoutInfo
    {
        let kind : SupplementaryKind
                
        var baseFrame : CGRect = .zero
        
        var pinnedOrigin : CGFloat? = nil
        
        var visibleFrame : CGRect {
            var frame = self.baseFrame
            
            if let pinnedOrigin = self.pinnedOrigin {
                frame.origin.y = pinnedOrigin
            }
            
            return frame
        }
        
        init(kind : SupplementaryKind)
        {
            self.kind = kind
        }
        
        func layoutAttributes(with indexPath : IndexPath) -> UICollectionViewLayoutAttributes
        {
            let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: self.kind.rawValue, with: indexPath)
            
            attributes.frame = self.visibleFrame
            attributes.zIndex = self.kind.zIndex
            
            return attributes
        }
    }
    
    struct ItemLayoutInfo
    {
        var frame : CGRect = .zero
        
        func layoutAttributes(with indexPath : IndexPath) -> UICollectionViewLayoutAttributes
        {
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            attributes.frame = self.frame
            attributes.zIndex = 0
            
            return attributes
        }
    }
}

//
// MARK: Update Information From Collection View Layout
//

struct UpdateItems : Equatable
{
    let insertedSections : Set<InsertSection>
    let deletedSections : Set<DeleteSection>
    
    let insertedItems : Set<InsertItem>
    let deletedItems : Set<DeleteItem>
    let movedItems : Set<MoveItem>
    
    let reloadedItems : Set<OverlappingItem>
    let noneItems : Set<OverlappingItem>
    
    init(with updateItems : [UICollectionViewUpdateItem])
    {
       var insertedSections = Set<InsertSection>()
       var deletedSections = Set<DeleteSection>()

       var insertedItems = Set<InsertItem>()
       var deletedItems = Set<DeleteItem>()
       var movedItems = Set<MoveItem>()

       var reloadedItems = Set<OverlappingItem>()
       var noneItems = Set<OverlappingItem>()

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
                
            case .move:
                let oldIndexPath = item.indexPathBeforeUpdate!
                let newIndexPath = item.indexPathAfterUpdate!
                
                let deleteItem = DeleteItem(oldIndexPath: oldIndexPath)
                let insertItem = InsertItem(newIndexPath: newIndexPath)
                
                deletedItems.insert(deleteItem)
                insertedItems.insert(insertItem)
                
                movedItems.insert(.init(deleteItem: deleteItem, insertItem: insertItem))
                
            case .reload:
                let oldIndexPath = item.indexPathBeforeUpdate!
                let newIndexPath = item.indexPathAfterUpdate!
                
                reloadedItems.insert(.init(oldIndexPath: oldIndexPath, newIndexPath: newIndexPath))
                
            case .none:
                let oldIndexPath = item.indexPathBeforeUpdate!
                let newIndexPath = item.indexPathAfterUpdate!
                
                noneItems.insert(.init(oldIndexPath: oldIndexPath, newIndexPath: newIndexPath))
                
            @unknown default: fatalError()
            }
        }
        
        self.insertedSections = insertedSections
        self.deletedSections = deletedSections
        
        self.insertedItems = insertedItems
        self.deletedItems = deletedItems
        self.movedItems = movedItems
        self.reloadedItems = reloadedItems
        self.noneItems = noneItems
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
    
    struct MoveItem : Hashable
    {
        var deleteItem : DeleteItem
        var insertItem : InsertItem
    }
    
    struct OverlappingItem : Hashable
    {
        var oldIndexPath : IndexPath
        var newIndexPath : IndexPath
    }
}


fileprivate extension UIView
{
    var lst_safeAreaInsets : UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return self.safeAreaInsets
        } else {
            return .zero
        }
    }
}


fileprivate extension CGSize
{
    var isEmpty : Bool {
        return self.width == 0.0 || self.height == 0.0
    }
}


fileprivate extension Int
{
    func mapEach<Mapped>(_ block : (Int) -> Mapped) -> [Mapped]
    {
        var mapped = [Mapped]()
        
        for index in 0..<self {
            mapped.append(block(index))
        }
        
        return mapped
    }
}

