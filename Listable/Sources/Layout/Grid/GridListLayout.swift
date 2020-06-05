//
//  GridListLayout.swift
//  Listable
//
//  Created by Kyle Van Essen on 5/2/20.
//

import Foundation


public extension Appearance
{
    var grid : GridAppearance {
        get {
            self[GridAppearance.self, default: GridAppearance()]
        }
        
        set {
            self[GridAppearance.self] = newValue
        }
    }
}


public struct GridAppearance : Equatable
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
        public var itemSize : ItemSize
        
        public enum ItemSize : Equatable {
            case fixed(CGSize)
        }
        
        public var sectionHeaderHeight : CGFloat
        public var sectionFooterHeight : CGFloat
        
        public var listHeaderHeight : CGFloat
        public var listFooterHeight : CGFloat
        public var overscrollFooterHeight : CGFloat
            
        public init(
            itemSize : ItemSize = .fixed(CGSize(width: 100.0, height: 100.0)),
            sectionHeaderHeight : CGFloat = 60.0,
            sectionFooterHeight : CGFloat = 40.0,
            listHeaderHeight : CGFloat = 60.0,
            listFooterHeight : CGFloat = 60.0,
            overscrollFooterHeight : CGFloat = 60.0
        )
        {
            self.itemSize = itemSize
            self.sectionHeaderHeight = sectionHeaderHeight
            self.sectionFooterHeight = sectionFooterHeight
            self.listHeaderHeight = listHeaderHeight
            self.listFooterHeight = listFooterHeight
            self.overscrollFooterHeight = overscrollFooterHeight
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
        public var itemToSectionFooterSpacing : CGFloat
                
        public init(
            padding : UIEdgeInsets = .zero,
            width : WidthConstraint = .noConstraint,
            interSectionSpacingWithNoFooter : CGFloat = 0.0,
            interSectionSpacingWithFooter : CGFloat = 0.0,
            sectionHeaderBottomSpacing : CGFloat = 0.0,
            itemToSectionFooterSpacing : CGFloat = 0.0
        )
        {
            self.padding = padding
            self.width = width
            
            self.interSectionSpacingWithNoFooter = interSectionSpacingWithNoFooter
            self.interSectionSpacingWithFooter = interSectionSpacingWithFooter
            
            self.sectionHeaderBottomSpacing = sectionHeaderBottomSpacing
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


final class GridListLayout : ListLayout
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
    func updateLayout(in collectionView: UICollectionView) -> Bool
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
        let layout = self.appearance.grid.layout
        let sizing = self.appearance.grid.sizing
        
        let viewSize = collectionView.bounds.size
        
        let viewWidth = direction.width(for: collectionView.bounds.size)
        
        let rootWidth = ListAppearance.Layout.width(
            with: direction.width(for: viewSize),
            padding: direction.horizontalPadding(with: layout.padding),
            constraint: layout.width
        )
        
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
            
            let groupedItems = sizing.itemSize.grouped(within: sectionPosition.width, values: section.items)
            
            groupedItems.grouped.forEachWithIndex { rowIndex, isLast, row in
                
                var xOrigin = section.x
                
                row.forEachWithIndex { columnIndex, isLast, item in
                    item.x = xOrigin
                    item.y = lastContentMaxY
                    
                    item.size = groupedItems.itemSize
                    
                    xOrigin = item.frame.maxX
                }
                
                lastContentMaxY += groupedItems.itemSize.height
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
                let additionalSectionSpacing = hasSectionFooter ? layout.interSectionSpacingWithFooter : layout.interSectionSpacingWithNoFooter
                
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
}


fileprivate extension GridAppearance.Sizing.ItemSize {
    
    struct Grouped<Value>
    {
        var itemsInRowSpacing : CGFloat
        var itemSize : CGSize
        var grouped : [[Value]]
    }
    
    func grouped<Value>(within width : CGFloat, values : [Value]) -> Grouped<Value>
    {
        switch self {
        case .fixed(let itemSize):
            let itemsPerRow = Int(max(1, floor(width / itemSize.width)))
            
            return Grouped(
                itemsInRowSpacing: (width - (itemSize.width * CGFloat(itemsPerRow))) / CGFloat(itemsPerRow - 1 == 0 ? 1 : itemsPerRow - 1),
                itemSize: itemSize,
                grouped: self.group(values: values, into: itemsPerRow)
            )
        }
    }
    
    private func group<Value>(values : [Value], into itemsPerRow : Int) -> [[Value]]
    {
        var values = values
        
        var grouped : [[Value]] = []
        
        while values.count > 0 {
            grouped.append(values.safeDropFirst(itemsPerRow))
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
