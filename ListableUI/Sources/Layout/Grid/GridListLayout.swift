//
//  GridListLayout.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 5/2/20.
//

import Foundation

extension LayoutDescription
{
    public static func experimental_grid(_ configure : @escaping (inout GridAppearance) -> () = { _ in }) -> Self
    {
        GridListLayout.describe(appearance: configure)
    }
}


public struct GridAppearance : ListLayoutAppearance
{
    public var bounds : ListContentBounds?
    
    public var sizing : Sizing
    public var layout : Layout
    
    public var direction: LayoutDirection {
        .vertical
    }
    
    public var stickySectionHeaders : Bool
    
    public static var `default`: GridAppearance {
        return self.init()
    }
    
    public init(
        stickySectionHeaders : Bool = true,
        bounds : ListContentBounds? = nil,
        sizing : Sizing = Sizing(),
        layout : Layout = Layout()
    ) {
        self.stickySectionHeaders = stickySectionHeaders
        self.bounds = bounds
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
        ) {
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


extension GridAppearance {
    
    public struct ItemLayout : ItemLayoutsValue {
        
        public static var defaultValue: Self {
            .init()
        }
        
        public init() {
            
        }
    }
    
    
    public struct HeaderFooterLayout : HeaderFooterLayoutsValue {
        
        public var width : CustomWidth
        
        public static var defaultValue: Self {
            .init()
        }
        
        public init(
            width : CustomWidth = .default
        ) {
            self.width = width
        }
    }
    
    
    public struct SectionLayout : SectionLayoutsValue {
        
        public var width : CustomWidth
        
        public static var defaultValue: Self {
            .init()
        }
        
        public init(
            width : CustomWidth = .default
        ) {
            self.width = width
        }
    }
}


extension ItemLayouts {
    public var grid : GridAppearance.ItemLayout {
        get { self[GridAppearance.ItemLayout.self] }
        set { self[GridAppearance.ItemLayout.self] = newValue }
    }
}


extension HeaderFooterLayouts {
    public var grid : GridAppearance.HeaderFooterLayout {
        get { self[GridAppearance.HeaderFooterLayout.self] }
        set { self[GridAppearance.HeaderFooterLayout.self] = newValue }
    }
}

extension SectionLayouts {
    public var grid : GridAppearance.SectionLayout {
        get { self[GridAppearance.SectionLayout.self] }
        set { self[GridAppearance.SectionLayout.self] = newValue }
    }
}


final class GridListLayout : ListLayout
{
    typealias LayoutAppearance = GridAppearance
    
    static var defaults: ListLayoutDefaults {
        .init(itemInsertAndRemoveAnimations: .scaleDown)
    }
    
    var layoutAppearance: GridAppearance
    
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
    
    init(
        layoutAppearance: GridAppearance,
        appearance: Appearance,
        behavior: Behavior,
        content: ListLayoutContent
    ) {
        self.layoutAppearance = layoutAppearance
        self.appearance = appearance
        self.behavior = behavior
        
        self.content = content
    }

    //
    // MARK: Performing Layouts
    //
    
    func updateLayout(in context : ListLayoutLayoutContext)
    {
        
    }
    
    func layout(
        delegate : CollectionViewLayoutDelegate?,
        in context : ListLayoutLayoutContext
    ) {
        let boundsContext = ListContentBounds.Context(
            viewSize: context.viewBounds.size,
            direction: self.direction
        )
        
        let bounds = self.layoutAppearance.bounds ?? context.environment.listContentBounds(in: boundsContext)
        
        
        let direction = self.layoutAppearance.direction
        let layout = self.layoutAppearance.layout
        let sizing = self.layoutAppearance.sizing
        
        let viewSize = context.viewBounds.size
        
        let viewWidth = viewSize.width
        
        let rootWidth = TableAppearance.Layout.width(
            with: viewWidth,
            padding: HorizontalPadding(left: bounds.padding.left, right: bounds.padding.right),
            constraint: bounds.width
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
            
            let position = header.layouts.grid.width.position(with: viewSize, defaultWidth: rootWidth)
            
            let measureInfo = Sizing.MeasureInfo(
                sizeConstraint: CGSize(width: position.width, height: .greatestFiniteMagnitude),
                defaultSize: CGSize(width: 0.0, height: sizing.listHeaderHeight),
                direction: .vertical
            )
            
            let height = header.measurer(measureInfo).height
            
            header.x = position.origin
            header.size = CGSize(width: position.width, height: height)
            header.y = lastContentMaxY
            
            if hasListHeader {
                lastContentMaxY = header.defaultFrame.maxY
            }
        }
        
        switch direction {
        case .vertical:
            lastSectionMaxY += bounds.padding.top
            lastContentMaxY += bounds.padding.top
            
        case .horizontal:
            lastSectionMaxY += bounds.padding.left
            lastContentMaxY += bounds.padding.left
        }
        
        //
        // Sections
        //
        
        self.content.sections.forEachWithIndex { sectionIndex, isLast, section in
            
            let sectionPosition = section.layouts.grid.width.position(with: viewSize, defaultWidth: rootWidth)
            
            //
            // Section Header
            //
            
            let hasSectionHeader = section.header.isPopulated
            let hasSectionFooter = section.footer.isPopulated
            
            performLayout(for: section.header) { header in
                let width = header.layouts.grid.width.merge(with: section.layouts.grid.width)
                let position = width.position(with: viewSize, defaultWidth: sectionPosition.width)
                
                let measureInfo = Sizing.MeasureInfo(
                    sizeConstraint: CGSize(width: position.width, height: .greatestFiniteMagnitude),
                    defaultSize: CGSize(width: 0.0, height: sizing.sectionHeaderHeight),
                    direction: .vertical
                )
                
                let height = header.measurer(measureInfo).height
                
                header.x = position.origin
                header.size = CGSize(width: position.width, height: height)
                header.y = lastContentMaxY
                
                if hasSectionHeader {
                    lastContentMaxY = section.header.defaultFrame.maxY
                    lastContentMaxY += layout.sectionHeaderBottomSpacing
                }
            }
            
            //
            // Section Items
            //
            
            let groupedItems = sizing.itemSize.grouped(within: sectionPosition.width, values: section.items)
            
            groupedItems.grouped.forEachWithIndex { rowIndex, isLast, row in
                
                var xOrigin = sectionPosition.origin
                
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
                let width = footer.layouts.grid.width.merge(with: section.layouts.grid.width)
                let position = width.position(with: viewSize, defaultWidth: sectionPosition.width)
                
                let measureInfo = Sizing.MeasureInfo(
                    sizeConstraint: CGSize(width: position.width, height: .greatestFiniteMagnitude),
                    defaultSize: CGSize(width: 0.0, height: sizing.sectionFooterHeight),
                    direction: .vertical
                )
                
                let height = footer.measurer(measureInfo).height
                
                footer.size = CGSize(width: position.width, height: height)
                footer.x = position.origin
                footer.y = lastContentMaxY
                
                if hasSectionFooter {
                    lastContentMaxY = footer.defaultFrame.maxY
                }
            }
            
            // Add additional padding from config.
            
            if isLast == false {
                let additionalSectionSpacing = hasSectionFooter ? layout.interSectionSpacingWithFooter : layout.interSectionSpacingWithNoFooter
                
                lastSectionMaxY += additionalSectionSpacing
                lastContentMaxY += additionalSectionSpacing
            }
        }
        
        switch direction {
        case .vertical: lastContentMaxY += bounds.padding.bottom
        case .horizontal: lastContentMaxY += bounds.padding.right
        }
        
        //
        // Footer
        //
        
        performLayout(for: self.content.footer) { footer in
            let hasFooter = footer.isPopulated
            
            let position = footer.layouts.grid.width.position(with: viewSize, defaultWidth: rootWidth)
            
            let measureInfo = Sizing.MeasureInfo(
                sizeConstraint: CGSize(width: position.width, height: .greatestFiniteMagnitude),
                defaultSize: CGSize(width: 0.0, height: sizing.listFooterHeight),
                direction: .vertical
            )
            
            let height = footer.measurer(measureInfo).height
            
            footer.size = CGSize(width: position.width, height: height)
            footer.x = position.origin
            footer.y = lastContentMaxY
            
            if hasFooter {
                lastContentMaxY = footer.defaultFrame.maxY
                lastContentMaxY += layout.sectionHeaderBottomSpacing
            }
        }
        
        //
        // Overscroll Footer
        //
                    
        performLayout(for: self.content.overscrollFooter) { footer in

            let position = footer.layouts.grid.width.position(with: viewSize, defaultWidth: rootWidth)
            
            let measureInfo = Sizing.MeasureInfo(
                sizeConstraint: CGSize(width: position.width, height: .greatestFiniteMagnitude),
                defaultSize: CGSize(width: 0.0, height: sizing.overscrollFooterHeight),
                direction: .vertical
            )
            
            let height = footer.measurer(measureInfo).height
            
            footer.x = position.origin
            footer.size = CGSize(width: position.width, height: height)
        }
        
        //
        // Remaining Calculations
        //
        
        self.content.contentSize = CGSize(width: viewWidth, height: lastContentMaxY)
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
