//
//  DefaultListLayout.swift
//  Listable
//
//  Created by Kyle Van Essen on 11/19/19.
//

import Foundation


public extension Appearance
{
    var list : ListAppearance {
        get {
            self[ListAppearance.self, default: ListAppearance()]
        }
        
        set {
            self[ListAppearance.self] = newValue
        }
    }
}


public struct ListAppearance : Equatable
{
    public var sizing : Sizing
    public var layout : Layout
    
    public init(sizing : Sizing = Sizing(), layout : Layout = Layout())
    {
        self.sizing = sizing
        self.layout = layout
    }
    
    public struct Sizing : Equatable
    {
        public var itemHeight : CGFloat
        
        public var sectionHeaderHeight : CGFloat
        public var sectionFooterHeight : CGFloat
        
        public var listHeaderHeight : CGFloat
        public var listFooterHeight : CGFloat
        public var overscrollFooterHeight : CGFloat
        
        public var itemPositionGroupingHeight : CGFloat
            
        public init(
            itemHeight : CGFloat = 50.0,
            sectionHeaderHeight : CGFloat = 60.0,
            sectionFooterHeight : CGFloat = 40.0,
            listHeaderHeight : CGFloat = 60.0,
            listFooterHeight : CGFloat = 60.0,
            overscrollFooterHeight : CGFloat = 60.0,
            itemPositionGroupingHeight : CGFloat = 0.0
        )
        {
            self.itemHeight = itemHeight
            self.sectionHeaderHeight = sectionHeaderHeight
            self.sectionFooterHeight = sectionFooterHeight
            self.listHeaderHeight = listHeaderHeight
            self.listFooterHeight = listFooterHeight
            self.overscrollFooterHeight = overscrollFooterHeight
            self.itemPositionGroupingHeight = itemPositionGroupingHeight
        }
        
        public mutating func set(with block: (inout Sizing) -> ())
        {
            var edited = self
            block(&edited)
            self = edited
        }
    }
    

    public struct Layout : Equatable
    {
        public var padding : UIEdgeInsets
        public var width : WidthConstraint

        public var interSectionSpacingWithNoFooter : CGFloat
        public var interSectionSpacingWithFooter : CGFloat
        
        public var sectionHeaderBottomSpacing : CGFloat
        public var itemSpacing : CGFloat
        public var itemToSectionFooterSpacing : CGFloat
                
        public init(
            padding : UIEdgeInsets = .zero,
            width : WidthConstraint = .noConstraint,
            interSectionSpacingWithNoFooter : CGFloat = 0.0,
            interSectionSpacingWithFooter : CGFloat = 0.0,
            sectionHeaderBottomSpacing : CGFloat = 0.0,
            itemSpacing : CGFloat = 0.0,
            itemToSectionFooterSpacing : CGFloat = 0.0
        )
        {
            self.padding = padding
            self.width = width
            
            self.interSectionSpacingWithNoFooter = interSectionSpacingWithNoFooter
            self.interSectionSpacingWithFooter = interSectionSpacingWithFooter
            
            self.sectionHeaderBottomSpacing = sectionHeaderBottomSpacing
            self.itemSpacing = itemSpacing
            self.itemToSectionFooterSpacing = itemToSectionFooterSpacing
        }

        public mutating func set(with block : (inout Layout) -> ())
        {
            var edited = self
            block(&edited)
            self = edited
        }
        
        internal static func width(
            with width : CGFloat,
            padding : HorizontalPadding,
            constraint : WidthConstraint
        ) -> CGFloat
        {
            let paddedWidth = width - padding.left - padding.right
            
            return constraint.clamp(paddedWidth)
        }
    }
}


final class DefaultListLayout : ListLayout
{    
    //
    // MARK: Public Properties
    //
            
    let appearance : Appearance
    let behavior : Behavior
    
    let content : ListLayoutContent
            
    var scrollViewProperties: ListLayoutScrollViewProperties {
        .init(
            isPagingEnabled: false,
            contentInsetAdjustmentBehavior: .automatic,
            allowsBounceVertical: true,
            allowsBounceHorizontal: true,
            allowsVerticalScrollIndicator: true,
            allowsHorizontalScrollIndicator: true
        )
    }
    
    //
    // MARK: Initialization
    //
    
    init()
    {
        self.appearance = Appearance()
        self.behavior = Behavior()
        
        self.content = ListLayoutContent(with: self.appearance)
    }
    
    init(
        delegate : CollectionViewLayoutDelegate,
        appearance : Appearance,
        behavior : Behavior,
        in collectionView : UICollectionView
        )
    {
        self.appearance = appearance
        self.behavior = behavior
        
        self.content = ListLayoutContent(
            delegate: delegate,
            appearance: appearance,
            in: collectionView
        )
    }
    
    //
    // MARK: Performing Layouts
    //
    
    @discardableResult
    func updateLayout(in collectionView : UICollectionView) -> Bool
    {
        guard collectionView.frame.size.isEmpty == false else {
            return false
        }
        
        self.updateHeaderPositions(in: collectionView)
        self.updateOverscrollFooterPosition(in: collectionView)
        
        return true
    }
    
    func layout(
        delegate : CollectionViewLayoutDelegate,
        in collectionView : UICollectionView
        ) -> Bool
    {
        guard collectionView.frame.size.isEmpty == false else {
            return false
        }
        
        let direction = self.appearance.direction
        let layout = self.appearance.list.layout
        let sizing = self.appearance.list.sizing
        
        let viewSize = collectionView.bounds.size
        
        let viewWidth = direction.width(for: collectionView.bounds.size)
        
        let rootWidth = ListAppearance.Layout.width(
            with: direction.width(for: viewSize),
            padding: direction.horizontalPadding(with: layout.padding),
            constraint: layout.width
        )
                
        //
        // Item Positioning
        //
                
        /**
         Item positions are set and sent to the delegate first,
         in case the position affects the height calculation later in the layout pass.
         */
        self.setItemPositions()
        
        delegate.listViewLayoutUpdatedItemPositions(collectionView)
        
        //
        // Set Frame Origins
        //
        
        var lastSectionMaxY : CGFloat = 0.0
        var lastContentMaxY : CGFloat = 0.0
        
        //
        // Header
        //
        
        performLayout(for: self.content.header) { header in
            let hasListHeader = self.content.header.isPopulated
            
            let position = header.layout.width.position(with: viewSize, defaultWidth: rootWidth, layoutDirection: direction)
            
            let height : CGFloat
            
            if hasListHeader {
                height = delegate.sizeForListHeader(
                    in: collectionView,
                    measuredIn: CGSize(width: position.width, height: .greatestFiniteMagnitude),
                    defaultSize: CGSize(width: 0.0, height: sizing.listHeaderHeight),
                    layoutDirection: direction
                ).height
            } else {
                height = 0.0
            }
            
            header.x = position.origin
            header.size = direction.size(width: position.width, height: height)
            header.y = lastContentMaxY
            
            if hasListHeader {
                lastSectionMaxY = direction.maxY(for: header.defaultFrame)
                lastContentMaxY = direction.maxY(for: header.defaultFrame)
            }
        }
        
        switch direction {
        case .vertical:
            lastSectionMaxY += layout.padding.top
            lastContentMaxY += layout.padding.top
            
        case .horizontal:
            lastSectionMaxY += layout.padding.left
            lastContentMaxY += layout.padding.left
        }
        
        //
        // Sections
        //
        
        self.content.sections.forEachWithIndex { sectionIndex, isLast, section in
            
            let sectionPosition = section.layout.width.position(with: viewSize, defaultWidth: rootWidth, layoutDirection: direction)
            
            section.x = sectionPosition.origin
            
            //
            // Section Header
            //
            
            let hasSectionHeader = section.header.isPopulated
            let hasSectionFooter = section.footer.isPopulated
            
            performLayout(for: section.header) { header in
                let width = header.layout.width.merge(with: section.layout.width)
                let position = width.position(with: viewSize, defaultWidth: sectionPosition.width, layoutDirection: direction)
                let height : CGFloat
                
                if hasSectionHeader {
                    height = delegate.sizeForHeader(
                        in: sectionIndex,
                        in: collectionView,
                        measuredIn: CGSize(width: position.width, height: .greatestFiniteMagnitude),
                        defaultSize: CGSize(width: 0.0, height: sizing.sectionHeaderHeight),
                        layoutDirection: direction
                    ).height
                } else {
                    height = 0.0
                }
                
                header.x = position.origin
                header.size = direction.size(width: position.width, height: height)
                header.y = lastContentMaxY
                
                if hasSectionHeader {
                    lastContentMaxY = direction.maxY(for: section.header.defaultFrame)
                    lastContentMaxY += layout.sectionHeaderBottomSpacing
                }
            }
            
            //
            // Section Items
            //
            
            if section.columns.count == 1 {
                section.items.forEachWithIndex { itemIndex, isLast, item in
                    let indexPath = item.liveIndexPath
                    
                    let width = item.layout.width.merge(with: section.layout.width)
                    let itemPosition = width.position(with: viewSize, defaultWidth: sectionPosition.width, layoutDirection: direction)
                    
                    let height = delegate.sizeForItem(
                        at: indexPath,
                        in: collectionView,
                        measuredIn: CGSize(width: itemPosition.width, height: .greatestFiniteMagnitude),
                        defaultSize: CGSize(width: 0.0, height: sizing.itemHeight),
                        layoutDirection: direction
                    ).height
                    
                    item.x = itemPosition.origin
                    item.y = lastContentMaxY
                    item.size = direction.size(width: itemPosition.width, height: height)
                    
                    lastContentMaxY += height

                    if isLast {
                        if hasSectionFooter {
                            lastContentMaxY += item.layout.itemToSectionFooterSpacing ?? layout.itemToSectionFooterSpacing
                        }
                    } else {
                        lastContentMaxY += item.layout.itemSpacing ?? layout.itemSpacing
                    }
                }
            } else {
                let itemWidth = round((sectionPosition.width - (section.columns.spacing * CGFloat(section.columns.count - 1))) / CGFloat(section.columns.count))
                
                let groupedItems = section.columns.group(values: section.items)
                
                groupedItems.forEachWithIndex { rowIndex, isLast, row in
                    var maxHeight : CGFloat = 0.0
                    var maxItemSpacing : CGFloat = 0.0
                    var maxItemToSectionFooterSpacing : CGFloat = 0.0
                    var columnXOrigin = section.x
                    
                    row.forEachWithIndex { columnIndex, isLast, item in
                        item.x = columnXOrigin
                        item.y = lastContentMaxY
                        
                        let indexPath = item.liveIndexPath
                                                
                        let height = delegate.sizeForItem(
                            at: indexPath,
                            in: collectionView,
                            measuredIn: CGSize(width: itemWidth, height: .greatestFiniteMagnitude),
                            defaultSize: CGSize(width: 0.0, height: sizing.itemHeight),
                            layoutDirection: direction
                        ).height
                        
                        let itemSpacing = item.layout.itemSpacing ?? layout.itemSpacing
                        let itemToSectionFooterSpacing = item.layout.itemToSectionFooterSpacing ?? layout.itemToSectionFooterSpacing
                        
                        item.size = direction.size(width: itemWidth, height: height)
                        
                        maxHeight = max(height, maxHeight)
                        maxItemSpacing = max(itemSpacing, maxItemSpacing)
                        maxItemToSectionFooterSpacing = max(itemToSectionFooterSpacing, maxItemToSectionFooterSpacing)
                        
                        columnXOrigin += (itemWidth + section.columns.spacing)
                    }
                    
                    lastContentMaxY += maxHeight
                    
                    if isLast {
                        if hasSectionFooter {
                            lastContentMaxY += maxItemToSectionFooterSpacing
                        }
                    } else {
                        lastContentMaxY += maxItemSpacing
                    }
                }
            }
            
            //
            // Section Footer
            //
            
            performLayout(for: section.footer) { footer in
                let width = footer.layout.width.merge(with: section.layout.width)
                let position = width.position(with: viewSize, defaultWidth: sectionPosition.width, layoutDirection: direction)
                
                let height : CGFloat
                
                if hasSectionFooter {
                    height = delegate.sizeForFooter(
                        in: sectionIndex,
                        in: collectionView,
                        measuredIn: CGSize(width: position.width, height: .greatestFiniteMagnitude),
                        defaultSize: CGSize(width: 0.0, height: sizing.sectionFooterHeight),
                        layoutDirection: direction
                    ).height
                } else {
                    height = 0.0
                }
                
                footer.size = direction.size(width: position.width, height: height)
                footer.x = position.origin
                footer.y = lastContentMaxY
                
                if hasSectionFooter {
                    lastContentMaxY = direction.maxY(for: footer.defaultFrame)
                }
            }
            
            //
            // Size The Section
            //
            
            section.size = direction.size(width: viewWidth, height: lastContentMaxY - lastSectionMaxY)
            section.y = lastSectionMaxY
            
            lastSectionMaxY = direction.maxY(for: section.frame)
            
            // Add additional padding from config.
            
            if isLast == false {
                let additionalSectionSpacing: CGFloat
                if let customInterSectionSpacing = section.layout.customInterSectionSpacing {
                    additionalSectionSpacing = customInterSectionSpacing
                } else {
                    additionalSectionSpacing = hasSectionFooter
                        ? layout.interSectionSpacingWithFooter
                        : layout.interSectionSpacingWithNoFooter
                }
                
                lastSectionMaxY += additionalSectionSpacing
                lastContentMaxY += additionalSectionSpacing
            }
        }
        
        switch direction {
        case .vertical: lastContentMaxY += layout.padding.bottom
        case .horizontal: lastContentMaxY += layout.padding.right
        }
        
        //
        // Footer
        //
        
        performLayout(for: self.content.footer) { footer in
            let hasFooter = footer.isPopulated
            
            let position = footer.layout.width.position(with: viewSize, defaultWidth: rootWidth, layoutDirection: direction)
            
            let height : CGFloat
            
            if hasFooter {
                height = delegate.sizeForListFooter(
                    in: collectionView,
                    measuredIn: CGSize(width: position.width, height: .greatestFiniteMagnitude),
                    defaultSize: CGSize(width: 0.0, height: sizing.listFooterHeight),
                    layoutDirection: direction
                ).height
            } else {
                height = 0.0
            }
            
            footer.size = direction.size(width: position.width, height: height)
            footer.x = position.origin
            footer.y = lastContentMaxY
            
            if hasFooter {
                lastContentMaxY = direction.maxY(for: footer.defaultFrame)
                lastContentMaxY += layout.sectionHeaderBottomSpacing
            }
        }
        
        //
        // Overscroll Footer
        //
                    
        performLayout(for: self.content.overscrollFooter) { footer in
            let hasFooter = footer.isPopulated

            let position = footer.layout.width.position(with: viewSize, defaultWidth: rootWidth, layoutDirection: direction)
            
            let height : CGFloat
            
            if hasFooter {
                height = delegate.sizeForOverscrollFooter(
                    in: collectionView,
                    measuredIn: CGSize(width: position.width, height: .greatestFiniteMagnitude),
                    defaultSize: CGSize(width: 0.0, height: sizing.overscrollFooterHeight),
                    layoutDirection: direction
                ).height
            } else {
                height = 0.0
            }
            
            footer.x = position.origin
            footer.size = direction.size(width: position.width, height: height)
        }
        
        //
        // Remaining Calculations
        //
        
        self.content.contentSize = direction.size(width: viewWidth, height: lastContentMaxY)
        
        return true
    }
    
    private func setItemPositions()
    {
        self.content.sections.forEach { section in
            section.setItemPositions(with: self.appearance)
        }
    }
}


fileprivate extension ListLayoutContent.SectionInfo
{
    func setItemPositions(with appearance : Appearance)
    {
        if self.columns.count == 1 {
            let groups = ListLayoutContent.SectionInfo.grouped(
                items: self.items,
                groupingHeight: appearance.list.sizing.itemPositionGroupingHeight,
                appearance: appearance
            )
            
            groups.forEach { group in
                let itemCount = group.count
                
                group.forEachWithIndex { index, isLast, item in
                    
                    if itemCount == 1 {
                        item.position = .single
                    } else {
                        if index == 0 {
                            item.position = .first
                        } else if isLast {
                            item.position = .last
                        } else {
                            item.position = .middle
                        }
                    }
                }
            }
        } else {
            // If we have columns, every item will receive "single" positioning for now.
            // Depending on use, we may want to make this smarter.
            
            self.items.forEach { $0.position = .single }
        }
    }
    
    private static func grouped(items : [ListLayoutContent.ItemInfo], groupingHeight : CGFloat, appearance : Appearance) -> [[ListLayoutContent.ItemInfo]]
    {
        var all = [[ListLayoutContent.ItemInfo]]()
        var current = [ListLayoutContent.ItemInfo]()
        
        var lastSpacing : CGFloat = 0.0
        
        items.forEachWithIndex { index, isLast, item in
            let inNewGroup = groupingHeight == 0.0 ? lastSpacing > 0.0 : lastSpacing > groupingHeight
            
            if inNewGroup {
                all.append(current)
                current = []
            }
            
            current.append(item)
            
            lastSpacing = item.layout.itemSpacing ?? appearance.list.layout.itemSpacing
        }
        
        if current.isEmpty == false {
            all.append(current)
        }
        
        return all
    }

}


fileprivate extension Section.Columns
{
    func group<Value>(values : [Value]) -> [[Value]]
    {
        var values = values
        
        var grouped : [[Value]] = []
        
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


fileprivate func performLayout<Input>(for input : Input, _ block : (Input) -> ())
{
    block(input)
}
