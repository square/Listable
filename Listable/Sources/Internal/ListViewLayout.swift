//
//  ListViewLayout.swift
//  Listable
//
//  Created by Kyle Van Essen on 9/23/19.
//

import UIKit


protocol ListViewLayoutDelegate : AnyObject
{    
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
        
        context.widthChanged = self.layoutResult.shouldInvalidateLayoutFor(newCollectionViewSize: view.bounds.size)
                
        self.neededLayoutType.merge(with: context)
    }
    
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext
    {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! InvalidationContext
        
        context.updateHeaders = self.appearance.layout.stickySectionHeaders
        
        return context
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool
    {
        return true
    }
    
    private final class InvalidationContext : UICollectionViewLayoutInvalidationContext
    {
        var updateHeaders : Bool = false
        var widthChanged : Bool = false
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
        
        mutating func update(with success : Bool)
        {
            if success {
                self = .none
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
            case .none: return true
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
    
    private func performHeaderLayout() -> Bool
    {
        self.previousLayoutResult = self.layoutResult
        
        return self.layoutResult.updateHeaders(in: self.collectionView!)
    }
    
    private func performFullLayout() -> Bool
    {
        self.previousLayoutResult = self.layoutResult
        
        self.layoutResult = LayoutInfo(
            delegate: self.delegate,
            layout: self.appearance.layout,
            layoutDirection: self.appearance.direction,
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
}


extension ListViewLayout
{
    enum SupplementaryKind : String
    {
        case listHeader = "Listable.ListViewLayout.ListHeader"
        case listFooter = "Listable.ListViewLayout.ListFooter"
        
        case sectionHeader = "Listable.ListViewLayout.SectionHeader"
        case sectionFooter = "Listable.ListViewLayout.SectionFooter"
        
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


internal extension ListViewLayout
{
    final class LayoutInfo
    {
        //
        // MARK: Public Properties
        //
        
        let collectionViewSize : CGSize
        var contentSize : CGSize
        
        let layout : ListLayout
        let layoutDirection : LayoutDirection
        
        let header : SupplementaryItemLayoutInfo?
        let footer : SupplementaryItemLayoutInfo?
        
        let sections : [SectionLayoutInfo]
        
        //
        // MARK: Initialization
        //
        
        init()
        {
            self.collectionViewSize = .zero
            self.contentSize = .zero

            self.layout = ListLayout()
            self.layoutDirection = .vertical
            
            self.header = nil
            self.footer = nil
            
            self.sections = []
        }
        
        init(
            delegate : ListViewLayoutDelegate,
            layout : ListLayout,
            layoutDirection : LayoutDirection,
            in collectionView : UICollectionView
        )
        {
            let sectionCount = collectionView.numberOfSections
            
            self.collectionViewSize = collectionView.bounds.size
            self.contentSize = .zero

            self.layout = layout
            self.layoutDirection = layoutDirection
            
            self.header = {
                guard delegate.hasListHeader(in: collectionView) else { return nil }
                
                return SupplementaryItemLayoutInfo(
                    kind: SupplementaryKind.listHeader,
                    direction: layoutDirection,
                    layout: delegate.layoutForListHeader(in: collectionView)
                )
            }()
            
            self.footer = {
                guard delegate.hasListFooter(in: collectionView) else { return nil }
                
                return SupplementaryItemLayoutInfo(
                    kind: SupplementaryKind.listFooter,
                    direction: layoutDirection,
                    layout: delegate.layoutForListFooter(in: collectionView)
                )
            }()
                        
            self.sections = sectionCount.mapEach { sectionIndex in
                
                let itemCount = collectionView.numberOfItems(inSection: sectionIndex)
                
                return SectionLayoutInfo(
                    direction: layoutDirection,
                    layout : delegate.layoutFor(section: sectionIndex, in: collectionView),
                    header: {
                        guard delegate.hasHeader(in: sectionIndex, in: collectionView) else { return nil }
                        
                        return SupplementaryItemLayoutInfo(
                            kind: SupplementaryKind.sectionHeader,
                            direction: layoutDirection,
                            layout: delegate.layoutForHeader(in: sectionIndex, in: collectionView)
                        )
                    }(),
                    footer: {
                        guard delegate.hasFooter(in: sectionIndex, in: collectionView) else { return nil }
                        
                        return SupplementaryItemLayoutInfo(
                            kind: SupplementaryKind.sectionFooter,
                            direction: layoutDirection,
                            layout: delegate.layoutForFooter(in: sectionIndex, in: collectionView)
                        )
                    }(),
                    columns: delegate.columnLayout(for: sectionIndex, in: collectionView),
                    items: itemCount.mapEach { itemIndex in
                        ItemLayoutInfo(
                            direction: layoutDirection,
                            layout: delegate.layoutForItem(at: IndexPath(item: itemIndex, section: sectionIndex), in: collectionView)
                        )
                    }
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
        
        func shouldInvalidateLayoutFor(newCollectionViewSize : CGSize) -> Bool
        {
            switch self.layoutDirection {
            case .vertical: return self.collectionViewSize.width != newCollectionViewSize.width
            case .horizontal: return self.collectionViewSize.height != newCollectionViewSize.height
            }
        }
        
        @discardableResult
        func updateHeaders(in collectionView : UICollectionView) -> Bool
        {
            guard collectionView.frame.size.isEmpty == false else {
                return false
            }
            
            guard self.layout.stickySectionHeaders else {
                return true
            }
                                    
            let visibleFrame = CGRect(
                x: collectionView.contentOffset.x + collectionView.lst_safeAreaInsets.left,
                y: collectionView.contentOffset.y + collectionView.lst_safeAreaInsets.top,
                width: collectionView.bounds.size.width,
                height: collectionView.bounds.size.height
            )
            
            self.sections.forEachWithIndex { sectionIndex, isLast, section in
                let sectionMaxY = self.layoutDirection.maxY(for: section.frame)
                
                if let header = section.header {
                    if self.layoutDirection.y(for: header.defaultFrame.origin) < self.layoutDirection.y(for: visibleFrame.origin) {
                        
                        // Make sure the pinned origin stays within the section's frame.
                        header.pinnedY = min(
                            self.layoutDirection.y(for: visibleFrame.origin),
                            sectionMaxY - self.layoutDirection.height(for: header.size)
                        )
                    } else {
                        header.pinnedY = nil
                    }
                }
            }
            
            return true
        }

        func layout(
            delegate : ListViewLayoutDelegate,
            in collectionView : UICollectionView
        ) -> Bool
        {
            guard collectionView.frame.size.isEmpty == false else {
                return false
            }
            
            let viewWidth = self.layoutDirection.width(for: collectionView.bounds.size)
            let viewSize = collectionView.bounds.size
            
            let rootWidth = ListLayout.width(with: viewSize, padding: self.layout.padding, constraint: self.layout.width, layoutDirection: self.layoutDirection)
            
            //
            // Set Frame Origins
            //
            
            var lastSectionMaxY : CGFloat = 0.0
            var lastContentMaxY : CGFloat = 0.0
            
            //
            // Header
            //
            
            if let header = self.header {
                let position = header.layout.width.position(with: viewSize, defaultWidth: rootWidth, layoutDirection: self.layoutDirection)
                let height = delegate.heightForListHeader(in: collectionView, width: position.width, layoutDirection: self.layoutDirection)
                
                header.x = position.origin
                header.size = self.layoutDirection.size(width: position.width, height: height)
                
                header.y = lastContentMaxY
                lastContentMaxY = layoutDirection.maxY(for: header.defaultFrame)
            }
            
            switch self.layoutDirection {
            case .vertical:
                lastSectionMaxY += self.layout.padding.top
                lastContentMaxY += self.layout.padding.top
                
            case .horizontal:
                lastSectionMaxY += self.layout.padding.left
                lastContentMaxY += self.layout.padding.left
            }

            //
            // Sections
            //
            
            self.sections.forEachWithIndex { sectionIndex, isLast, section in
                
                let sectionPosition = section.layout.width.position(with: viewSize, defaultWidth: rootWidth, layoutDirection: self.layoutDirection)
                
                section.x = sectionPosition.origin
                
                //
                // Section Header
                //
                
                if let header = section.header {
                    let width = header.layout.width.merge(with: section.layout.width)
                    let position = width.position(with: viewSize, defaultWidth: sectionPosition.width, layoutDirection: self.layoutDirection)
                    let height = delegate.heightForHeader(in: sectionIndex, in: collectionView, width: position.width, layoutDirection: self.layoutDirection)
                    
                    header.x = position.origin
                    header.size = self.layoutDirection.size(width: position.width, height: height)
                    
                    header.y = lastContentMaxY
                    
                    lastContentMaxY = self.layoutDirection.maxY(for: header.defaultFrame)
                    lastContentMaxY += self.layout.sectionHeaderBottomSpacing
                }
                
                //
                // Section Items
                //
                
                if section.columns.count == 1 {
                    section.items.forEachWithIndex { itemIndex, isLast, item in
                        let indexPath = IndexPath(item: itemIndex, section: sectionIndex)
                        
                        let width = item.layout.width.merge(with: section.layout.width)
                        let itemPosition = width.position(with: viewSize, defaultWidth: sectionPosition.width, layoutDirection: self.layoutDirection)
                        let height = delegate.heightForItem(at: indexPath, in: collectionView, width: itemPosition.width, layoutDirection: self.layoutDirection)
                        
                        item.x = itemPosition.origin
                        item.y = lastContentMaxY
                        
                        item.size = self.layoutDirection.size(width: itemPosition.width, height: height)
                        
                        lastContentMaxY += height
                        
                        if isLast {
                            lastContentMaxY += self.layout.itemToSectionFooterSpacing
                        } else {
                            lastContentMaxY += self.layout.itemSpacing
                        }
                    }
                } else {
                    let itemWidth = round((sectionPosition.width - (section.columns.spacing * CGFloat(section.columns.count - 1))) / CGFloat(section.columns.count))
                    
                    let groupedItems = section.columns.group(values: section.items)
                    
                    groupedItems.forEachWithIndex { rowIndex, isLast, row in
                        var maxHeight : CGFloat = 0.0
                        var columnXOrigin = section.x
                        
                        row.forEachWithIndex { columnIndex, isLast, item in
                            item.value.x = columnXOrigin
                            item.value.y = lastContentMaxY
                            
                            let indexPath = IndexPath(item: item.index, section: sectionIndex)
                            let height = delegate.heightForItem(at: indexPath, in: collectionView, width: itemWidth, layoutDirection: self.layoutDirection)
                            
                            item.value.size = self.layoutDirection.size(width: itemWidth, height: height)
                            
                            maxHeight = max(self.layoutDirection.height(for: item.value.size), maxHeight)
                            columnXOrigin += (self.layoutDirection.width(for: item.value.size) + section.columns.spacing)
                        }
                        
                        lastContentMaxY += maxHeight
                        
                        if isLast {
                            lastContentMaxY += self.layout.itemToSectionFooterSpacing
                        } else {
                            lastContentMaxY += self.layout.itemSpacing
                        }
                    }
                }
                
                //
                // Section Footer
                //
                
                if let footer = section.footer {
                    let width = footer.layout.width.merge(with: section.layout.width)
                    let position = width.position(with: viewSize, defaultWidth: sectionPosition.width, layoutDirection: self.layoutDirection)
                    let height = delegate.heightForFooter(in: sectionIndex, in: collectionView, width: position.width, layoutDirection: self.layoutDirection)
                    
                    footer.size = self.layoutDirection.size(width: position.width, height: height)
                    footer.x = position.origin
                    footer.y = lastContentMaxY
                    
                    lastContentMaxY = self.layoutDirection.maxY(for: footer.defaultFrame)
                }
                
                //
                // Size The Section
                //
                
                section.size = self.layoutDirection.size(width: viewWidth, height: lastContentMaxY - lastSectionMaxY)
                section.y = lastSectionMaxY
                
                lastSectionMaxY = self.layoutDirection.maxY(for: section.frame)
                
                // Add additional padding from config.
                
                if isLast == false {
                    let additionalSectionSpacing = section.footer != nil ? self.layout.interSectionSpacingWithFooter : self.layout.interSectionSpacingWithNoFooter

                    lastSectionMaxY += additionalSectionSpacing
                    lastContentMaxY += additionalSectionSpacing
                }
            }
            
            switch self.layoutDirection {
            case .vertical: lastContentMaxY += self.layout.padding.bottom
            case .horizontal: lastContentMaxY += self.layout.padding.right
            }
            
            //
            // Footer
            //
            
            if let footer = self.footer {
                let position = footer.layout.width.position(with: viewSize, defaultWidth: rootWidth, layoutDirection: self.layoutDirection)
                let height = delegate.heightForListFooter(in: collectionView, width: position.width, layoutDirection: self.layoutDirection)
                
                footer.size = self.layoutDirection.size(width: position.width, height: height)
                
                footer.x = position.origin
                footer.y = lastContentMaxY
                
                lastContentMaxY = self.layoutDirection.maxY(for: footer.defaultFrame)
                lastContentMaxY += self.layout.sectionHeaderBottomSpacing
            }
                        
            self.contentSize = self.layoutDirection.size(width: viewWidth, height: lastContentMaxY)
            
            self.updateHeaders(in: collectionView)
            
            return true
        }
    }
    
    //
    // MARK: Layout Information
    //
    
    final class SectionLayoutInfo
    {
        let direction : LayoutDirection
        let layout : Section.Layout
        
        let header : SupplementaryItemLayoutInfo?
        let footer : SupplementaryItemLayoutInfo?
        
        let columns : Section.Columns
        
        let items : [ItemLayoutInfo]
        
        var size : CGSize = .zero
        var x : CGFloat = .zero
        var y : CGFloat = .zero
        
        var frame : CGRect {
            return CGRect(
                origin: self.direction.point(x: self.x, y: self.y),
                size: self.size
             )
        }
        
        init(
            direction : LayoutDirection,
            layout : Section.Layout,
            header : SupplementaryItemLayoutInfo?,
            footer : SupplementaryItemLayoutInfo?,
            columns : Section.Columns,
            items : [ItemLayoutInfo]
        )
        {
            self.direction = direction
            self.layout = layout
            
            self.header = header
            self.footer = footer
            
            self.columns = columns
            
            self.items = items
        }
        
    }
    
    final class SupplementaryItemLayoutInfo
    {
        let kind : SupplementaryKind
        let direction : LayoutDirection
        let layout : HeaderFooterLayout
                
        var size : CGSize = .zero
        var x : CGFloat = .zero
        var y : CGFloat = .zero
        var pinnedY : CGFloat? = nil
        
        var defaultFrame : CGRect {
            return CGRect(
                origin: self.direction.point(x: self.x, y: self.y),
                size: self.size
             )
        }
        
        var visibleFrame : CGRect {
            return CGRect(
                origin: self.direction.point(x: self.x, y: self.pinnedY ?? self.y),
                size: self.size
            )
        }
        
        init(kind : SupplementaryKind, direction : LayoutDirection, layout : HeaderFooterLayout)
        {
            self.kind = kind
            self.direction = direction
            self.layout = layout
        }
        
        func layoutAttributes(with indexPath : IndexPath) -> UICollectionViewLayoutAttributes
        {
            let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: self.kind.rawValue, with: indexPath)
            
            attributes.frame = self.visibleFrame
            attributes.zIndex = self.kind.zIndex
            
            return attributes
        }
    }
    
    final class ItemLayoutInfo
    {
        let direction : LayoutDirection
        let layout : ItemLayout
        
        var size : CGSize = .zero
        var x : CGFloat = .zero
        var y : CGFloat = .zero
        
        var frame : CGRect {
            return CGRect(
                origin: self.direction.point(x: self.x, y: self.y),
                size: self.size
            )
        }
        
        init(direction : LayoutDirection, layout : ItemLayout)
        {
            self.direction = direction
            self.layout = layout
        }
        
        func layoutAttributes(with indexPath : IndexPath) -> UICollectionViewLayoutAttributes
        {
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            attributes.frame = self.frame
            attributes.zIndex = 0
            
            return attributes
        }
    }
}


fileprivate extension Section.Columns
{
    struct Grouped<Value>
    {
        var value : Value
        var index : Int
    }
    
    func group<Value>(values input : [Value]) -> [[Grouped<Value>]]
    {
        var values : [Grouped<Value>] = input.mapWithIndex { index, _, value in
            return Grouped(value: value, index: index)
        }
        
        var grouped : [[Grouped<Value>]] = []
        
        while values.count > 0 {
            grouped.append(values.safeDropFirst(self.count))
        }
        
        return grouped
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

//
// MARK: Update Information From Collection View Layout
//

fileprivate struct UpdateItems : Equatable
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

