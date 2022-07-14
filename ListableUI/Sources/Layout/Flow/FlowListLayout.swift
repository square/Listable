//
//  FlowListLayout.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 11/21/21.
//

import Foundation
import UIKit


extension LayoutDescription {
    
    /// Creates a new `.flow` layout type for a list.
    /// See the `FlowAppearance` documentation for a full discussion.
    public static func flow(
        _ configure : (inout FlowAppearance) -> () = { _ in }
    ) -> Self {
        FlowListLayout.describe(appearance: configure)
    }
}

/// Allows rendering a list in the style of a flow layout. Items in the list flow from one row to the next,
/// with each row containing as many items as will fit. Items can be the same sizes or different sizes.
///
/// You can control the layout both via the `FlowAppearance` parameter
/// passed to `.flow` layout types, plus via the `section.layouts.flow` options on a `Section`.
///
/// To display a flow layout in your list, set its `layout` to a `.flow` type:
/// ```
/// list.layout = .flow { flow in
///     // Customize the flow options.
/// }
/// ```
///
/// ```
/// ┌─────────────────────────────────────────────────────────────────┐
/// │                          padding.top                            │
/// │   ┌─────────────────────────────────────────────────────────┐   │
/// │   │┌───────────────────────────────────────────────────────┐│   │
/// │   ││                                                       ││   │
/// │   ││                      List Header                      ││   │
/// │   ││                                                       ││   │
/// │   │└───────────────────────────────────────────────────────┘│   │
/// │   │                                                         │   │
/// │   │               headerToFirstSectionSpacing               │   │
/// │   │                                                         │   │
/// │   │┌───────────────────────────────────────────────────────┐│   │
/// │   ││                                                       ││   │
/// │   ││                    Section Header                     ││   │
/// │   ││                                                       ││   │
/// │   │└───────────────────────────────────────────────────────┘│   │
/// │   │               sectionHeaderBottomSpacing                │   │
/// │   │┌───────────────┐ ┌───────────────┐ ┌───────────────┐    │   │
/// │   ││               │ │               │ │               │    │   │
/// │   ││     Item      │ │     Item      │ │     Item      │    │   │
/// │   ││               │ │               │ │               │    │   │
/// │   │└───────────────┘ └───────────────┘ └───────────────┘    │   │
/// │   │                    rowSpacing                           │   │
/// │   │┌──────────────────────┐ ┌──────────────────────┐        │   │
/// │   ││                      │ │                      │        │   │
/// │   ││         Item         │ │         Item         │        │   │
/// │   ││                      │ │                      │        │   │
/// │ p │└──────────────────────┘ └──────────────────────┘        │ p │
/// │ a │               itemToSectionFooterSpacing                │ a │
/// │ d │┌───────────────────────────────────────────────────────┐│ d │
/// │ d ││                                                       ││ d │
/// │ i ││                    Section Footer                     ││ i │
/// │ n ││                                                       ││ n │
/// │ g │└───────────────────────────────────────────────────────┘│ g │
/// │ . │                                                         │ . │
/// │ l │             interSectionSpacing.withFooter              │ r │
/// │ e │                                                         │ i │
/// │ f │┌───────────────────────────────────────────────────────┐│ g │
/// │ t ││                                                       ││ h │
/// │   ││                    Section Header                     ││ t │
/// │   ││                                                       ││   │
/// │   │└───────────────────────────────────────────────────────┘│   │
/// │   │               sectionHeaderBottomSpacing                │   │
/// │   │┌──────────────────────┐ ┌─────────────────────────────┐ │   │
/// │   ││                      │ │                             │ │   │
/// │   ││         Item         │ │            Item             │ │   │
/// │   ││                      │ │                             │ │   │
/// │   │└──────────────────────┘ └─────────────────────────────┘ │   │
/// │   │                                                         │   │
/// │   │               lastSectionToFooterSpacing                │   │
/// │   │                                                         │   │
/// │   │┌───────────────────────────────────────────────────────┐│   │
/// │   ││                                                       ││   │
/// │   ││                      List Footer                      ││   │
/// │   ││                                                       ││   │
/// │   │└───────────────────────────────────────────────────────┘│   │
/// │   └─────────────────────────────────────────────────────────┘   │
/// │                         padding.bottom                          │
/// └─────────────────────────────────────────────────────────────────┘
/// ```
public struct FlowAppearance : ListLayoutAppearance {
    
    // MARK: ListLayoutAppearance
    
    /// The default apperance style.
    public static var `default`: FlowAppearance {
        .init()
    }
    
    /// The direction the flow layout will be laid out in.
    public var direction: LayoutDirection

    public var stickyListHeader: Bool
    
    /// If sections should have sticky headers, staying visible until the section is scrolled off screen.
    public var stickySectionHeaders: Bool
    
    /// How paging is performed when a drag event ends.
    public var pagingBehavior : ListPagingBehavior
    
    /// The properties of the backing `UIScrollView`.
    public var scrollViewProperties: ListLayoutScrollViewProperties {
        .init(
            isPagingEnabled: false,
            contentInsetAdjustmentBehavior: .scrollableAxes,
            allowsBounceVertical: true,
            allowsBounceHorizontal: true,
            allowsVerticalScrollIndicator: true,
            allowsHorizontalScrollIndicator: true
        )
    }
    
    public func toLayoutDescription() -> LayoutDescription {
        LayoutDescription(layoutType: FlowListLayout.self, appearance: self)
    }
    
    // MARK: Properties
    
    /// How to align the items in a row when they do not take up the full amount of available space.
    public var rowUnderflowAlignment : RowUnderflowAlignment
    
    /// How to align the items in a row when they are not all the same height.
    public var rowItemsAlignment : RowItemsAlignment
    
    /// Controls the sizing / measurement of items within the flow layout.
    public var itemSizing : ItemSizing
    
    /// Controls the padding and maximum width of the flow layout.
    public var bounds : ListContentBounds?
    
    /// Controls the spacing between headers, footers, sections, and items in the flow layout.
    public var spacings : Spacings
    
    /// Creates a new `FlowAppearance`.
    public init(
        direction: LayoutDirection = .vertical,
        stickyListHeader: Bool = false,
        stickySectionHeaders: Bool? = nil,
        pagingBehavior : ListPagingBehavior = .none,
        rowUnderflowAlignment : RowUnderflowAlignment = .leading,
        rowItemsAlignment : RowItemsAlignment = .top,
        itemSizing : ItemSizing = .natural,
        
        bounds : ListContentBounds? = nil,
        spacings : Spacings = .init()
    ) {
        self.direction = direction

        self.stickyListHeader = false

        self.stickySectionHeaders = {
            if let stickySectionHeaders = stickySectionHeaders {
                return stickySectionHeaders
            } else {
                switch direction {
                case .vertical: return true
                case .horizontal: return false
                }
            }
        }()
        
        self.pagingBehavior = pagingBehavior
                
        self.rowUnderflowAlignment = rowUnderflowAlignment
        self.rowItemsAlignment = rowItemsAlignment
        
        self.itemSizing = itemSizing
        
        self.bounds = bounds
        
        self.spacings = spacings
    }
}


extension FlowAppearance {
    
    /// Controls how items in a row are measured and sized.
    public enum ItemSizing : Equatable {
        
        /// The natural value from the `Item.sizing` is used with no changes.
        case natural
        
        /// The width of the item is fixed to this value.
        case fixed(CGFloat)
        
        /// The width of the item is calculated based on the number of columns provided.
        case columns(Int)
    }
    
    /// When there is left over space at the end of a row, `RowUnderflowAlignment` controls
    /// how the extra space is distributed between the items.
    public enum RowUnderflowAlignment : Equatable {
        
        /// The items are leading-aligned, with extra space at the end of the row.
        ///
        /// ```
        /// ┌────────────────────────────────────────────────────────────────┐
        /// │┌────────────┐ ┌────────────┐ ┌────────────┐                    │
        /// ││            │ │            │ │            │                    │
        /// ││    Item    │ │    Item    │ │    Item    │                    │
        /// ││            │ │            │ │            │                    │
        /// │└────────────┘ └────────────┘ └────────────┘                    │
        /// └────────────────────────────────────────────────────────────────┘
        /// ```
        case leading
        
        /// The items are center-aligned, with extra space distributed evenly between
        /// the beginning and end of the row.
        ///
        /// ```
        /// ┌────────────────────────────────────────────────────────────────┐
        /// │          ┌────────────┐ ┌────────────┐ ┌────────────┐          │
        /// │          │            │ │            │ │            │          │
        /// │          │    Item    │ │    Item    │ │    Item    │          │
        /// │          │            │ │            │ │            │          │
        /// │          └────────────┘ └────────────┘ └────────────┘          │
        /// └────────────────────────────────────────────────────────────────┘
        /// ```
        case centered
        
        /// The items are trailing-aligned, with extra space at the beginning of the row.
        ///
        /// ```
        /// ┌────────────────────────────────────────────────────────────────┐
        /// │                    ┌────────────┐ ┌────────────┐ ┌────────────┐│
        /// │                    │            │ │            │ │            ││
        /// │                    │    Item    │ │    Item    │ │    Item    ││
        /// │                    │            │ │            │ │            ││
        /// │                    └────────────┘ └────────────┘ └────────────┘│
        /// └────────────────────────────────────────────────────────────────┘
        /// ```
        case trailing
        
        /// The extra space in the row is evenly distributed between the items in the row.
        ///
        /// You can control the fill behavior of the last row via the `FillLastRowAlignment` parameter,
        /// to enable more visually pleasing spacing for rows that contain fewer items. The minimum of
        /// `itemSpacing` and the calculated spacing will be used.
        ///
        /// ```
        /// ┌────────────────────────────────────────────────────────────────┐
        /// │┌────────────┐           ┌────────────┐           ┌────────────┐│
        /// ││            │           │            │           │            ││
        /// ││    Item    │           │    Item    │           │    Item    ││
        /// ││            │           │            │           │            ││
        /// │└────────────┘           └────────────┘           └────────────┘│
        /// └────────────────────────────────────────────────────────────────┘
        /// ```
        case fill(lastRowAlignment : FillLastRowAlignment = .fill)
        
        /// Controls the fill behavior for the last row in a section.
        public enum FillLastRowAlignment : Equatable {
            /// The default behaviour; the row will be filled to fit its maximum allowable width.
            case fill
            
            /// The spacing of the previous row or `itemSpacing` will be used, whichever is smaller.
            case matchPreviousRowSpacing
            
            /// The calculated spacing or `itemSpacing` will be used, whichever is smaller.
            case defaultItemSpacing
        }
    }
    
    /// When items in a row are not the same height, controls the alignment and sizing of the smaller items.
    public enum RowItemsAlignment : Equatable {
        
        /// When items in a row are not the same height, the shorter items will be aligned to the top of the row.
        ///
        /// ```
        /// ┌──────────────────────────────────────────────────────┐
        /// │┌────────────┐ ┌────────────┐ ┌────────────┐          │
        /// ││            │ │            │ │            │          │
        /// ││            │ │            │ │    Item    │          │
        /// ││            │ │    Item    │ │            │          │
        /// ││    Item    │ │            │ └────────────┘          │
        /// ││            │ │            │                         │
        /// ││            │ └────────────┘                         │
        /// ││            │                                        │
        /// │└────────────┘                                        │
        /// └──────────────────────────────────────────────────────┘
        /// ```
        case top
        
        /// When items in a row are not the same height, the shorter items will be center aligned within the row.
        ///
        /// ```
        /// ┌──────────────────────────────────────────────────────┐
        /// │┌────────────┐                                        │
        /// ││            │ ┌────────────┐                         │
        /// ││            │ │            │ ┌────────────┐          │
        /// ││            │ │            │ │            │          │
        /// ││    Item    │ │    Item    │ │    Item    │          │
        /// ││            │ │            │ │            │          │
        /// ││            │ │            │ └────────────┘          │
        /// ││            │ └────────────┘                         │
        /// │└────────────┘                                        │
        /// └──────────────────────────────────────────────────────┘
        /// ```
        case center
        
        /// When items in a row are not the same height, the shorter items will be bottom aligned within the row.
        ///
        /// ```
        /// ┌──────────────────────────────────────────────────────┐
        /// │┌────────────┐                                        │
        /// ││            │                                        │
        /// ││            │ ┌────────────┐                         │
        /// ││            │ │            │                         │
        /// ││    Item    │ │            │ ┌────────────┐          │
        /// ││            │ │    Item    │ │            │          │
        /// ││            │ │            │ │    Item    │          │
        /// ││            │ │            │ │            │          │
        /// │└────────────┘ └────────────┘ └────────────┘          │
        /// └──────────────────────────────────────────────────────┘
        /// ```
        case bottom
        
        /// When items in a row are not the same height, the shorter items will be stretched to be the same
        /// height as the tallest item in the row. In the below diagram, the dotted line represents the additional added space.
        ///
        /// ```
        /// ┌──────────────────────────────────────────────────────┐
        /// │┌────────────┐ ┌────────────┐ ┌────────────┐          │
        /// ││            │ │            │ │            │          │
        /// ││            │ ├ ─ ─ ─ ─ ─ ─│ │            │          │
        /// ││            │ │            │ │─ ─ ─ ─ ─ ─ ┤          │
        /// ││    Item    │ │    Item    │ │    Item    │          │
        /// ││            │ │            │ │            │          │
        /// ││            │ │            │ │            │          │
        /// ││            │ │            │ │            │          │
        /// │└────────────┘ └────────────┘ └────────────┘          │
        /// └──────────────────────────────────────────────────────┘
        /// ```
        case fill
        
        func adjusted(height : CGFloat, forMaxRowHeight maxHeight : CGFloat) -> CGFloat {
            switch self {
            case .top: return height
            case .center: return height
            case .bottom: return height
            case .fill: return maxHeight
            }
        }
    }
    
    /// Controls the layout parameters for a given `Item` when it is displayed within a `.flow` layout.
    public struct ItemLayout : Equatable, ItemLayoutsValue
    {
        /// How to calculate the width of the item within the section.
        public var width : Width
        
        public init(
            width : Width = .natural
        ) {
            self.width = width
        }
        
        public static var defaultValue : Self {
            Self.init()
        }
        
        /// Controls how to determine the width of the items within a row.
        ///
        /// ```
        /// ┌───────────────────────────────────┐
        /// │┌────────────┐ ┌────────────┐      │
        /// ││            │ │            │      │
        /// ││  .natural  │ │  .natural  │      │
        /// ││            │ │            │      │
        /// │└────────────┘ └────────────┘      │
        /// │┌────────────────────────────────┐ │
        /// ││            .fillRow            │ │
        /// │└────────────────────────────────┘ │
        /// │┌────────────┐ ┌────────────┐      │
        /// ││            │ │            │      │
        /// ││  .natural  │ │  .natural  │      │
        /// ││            │ │            │      │
        /// │└────────────┘ └────────────┘      │
        /// └───────────────────────────────────┘
        /// ```
        public enum Width : Equatable {
            /// The standard with from the item will be used.
            case natural
            
            /// The full width of the section will be used by the item.
            case fillRow
        }
    }
    
    
    /// Controls the layout parameters for a given `HeaderFooter` when it is displayed within a `.flow` layout.
    public struct HeaderFooterLayout : Equatable, HeaderFooterLayoutsValue
    {
        public init() {}
        
        public static var defaultValue : Self {
            .init()
        }
    }
    
    /// Controls the layout parameters for a given `Section` when it is displayed within a `.flow` layout.
    public struct SectionLayout : Equatable, SectionLayoutsValue
    {
        /// Controls the custom width of the `Section`.
        public var width : CustomWidth
        
        /// Provides a custom underflow alignment for the items in the section.
        public var rowUnderflowAlignment : RowUnderflowAlignment?
        
        /// Provides a custom item alignment for the items in the section.
        public var rowItemsAlignment : RowItemsAlignment?
        
        /// Provides a custom item sizing for the items in the section.
        public var itemSizing : ItemSizing?
        
        /// Provides a custom item spacing for the items in the section.
        public var itemSpacing : CGFloat?
        
        /// Creates a new section layout.
        public init(
            width : CustomWidth = .default,
            rowUnderflowAlignment : RowUnderflowAlignment? = nil,
            rowItemsAlignment : RowItemsAlignment? = nil,
            itemSizing : ItemSizing? = nil,
            itemSpacing : CGFloat? = nil
        ) {
            self.width = width
            self.rowUnderflowAlignment = rowUnderflowAlignment
            self.rowItemsAlignment = rowItemsAlignment
            
            self.itemSizing = itemSizing
            
            self.itemSpacing = itemSpacing
        }
        
        public static var defaultValue : Self {
            Self.init()
        }
    }
    
    /// Layout options for the list.
    public struct Spacings : Equatable
    {
        /// The spacing between the list header and the first section.
        /// Not applied if there is no list header.
        public var headerToFirstSectionSpacing : CGFloat

        /// The spacing to apply between sections.
        public var interSectionSpacing : InterSectionSpacing
        
        /// The spacing to apply below a section header, before its items.
        /// Not applied if there is no section header.
        public var sectionHeaderBottomSpacing : CGFloat
        
        /// The horizontal spacing between individual items within a section.
        public var itemSpacing : CGFloat
        
        /// The vertical spacing between rows in the flow layout.
        public var rowSpacing : CGFloat
        
        /// The spacing between the last row in the section and the footer.
        /// Not applied if there is no section footer.
        public var rowToSectionFooterSpacing : CGFloat
        
        /// The spacing between the last section and the footer of the list.
        /// Not applied if there is no list footer.
        public var lastSectionToFooterSpacing : CGFloat
                
        /// Creates a new `Layout` with the provided options.
        public init(
            headerToFirstSectionSpacing : CGFloat = 0.0,
            interSectionSpacing : InterSectionSpacing = .init(0.0),
            sectionHeaderBottomSpacing : CGFloat = 0.0,
            itemSpacing : CGFloat = 0.0,
            rowSpacing : CGFloat = 0.0,
            rowToSectionFooterSpacing : CGFloat = 0.0,
            lastSectionToFooterSpacing : CGFloat = 0.0
        ) {
            self.headerToFirstSectionSpacing = headerToFirstSectionSpacing
            
            self.interSectionSpacing = interSectionSpacing
            
            self.sectionHeaderBottomSpacing = sectionHeaderBottomSpacing
            
            self.itemSpacing = itemSpacing
            self.rowSpacing = rowSpacing
            
            self.rowToSectionFooterSpacing = rowToSectionFooterSpacing
            
            self.lastSectionToFooterSpacing = lastSectionToFooterSpacing
        }
        
        /// Controls the inter section spacing in a list.
        public struct InterSectionSpacing : Equatable {
            
            /// The spacing used if there is a footer in the proceeding section.
            public var withFooter : CGFloat
            
            /// The spacing used if there is no footer in the proceeding section.
            public var noFooter : CGFloat
            
            /// Provides a new intersection spacing value.
            public init(withFooter: CGFloat, noFooter: CGFloat) {
                self.withFooter = withFooter
                self.noFooter = noFooter
            }
            
            /// Provides a new intersection spacing value.
            public init(_ value : CGFloat) {
                self.withFooter = value
                self.noFooter = value
            }
        }
    }
}


extension ItemLayouts {
    
    /// Allows customization of an `Item`'s layout when it is presented within a `.flow` style layout.
    public var flow : FlowAppearance.ItemLayout {
        get { self[FlowAppearance.ItemLayout.self] }
        set { self[FlowAppearance.ItemLayout.self] = newValue }
    }
}


extension HeaderFooterLayouts {
    
    /// Allows customization of a `HeaderFooter`'s layout when it is presented within a `.flow` style layout.
    public var flow : FlowAppearance.HeaderFooterLayout {
        get { self[FlowAppearance.HeaderFooterLayout.self] }
        set { self[FlowAppearance.HeaderFooterLayout.self] = newValue }
    }
}


extension SectionLayouts {
    
    /// Allows customization of a `Section`'s layout when it is presented within a `.flow` style layout.
    public var flow : FlowAppearance.SectionLayout {
        get { self[FlowAppearance.SectionLayout.self] }
        set { self[FlowAppearance.SectionLayout.self] = newValue }
    }
}


final class FlowListLayout : ListLayout {
    
    typealias LayoutAppearance = FlowAppearance
    
    static var defaults: ListLayoutDefaults {
        .init(itemInsertAndRemoveAnimations: .scaleUp)
    }
    
    var layoutAppearance: FlowAppearance
    
    let appearance: Appearance
    let behavior: Behavior
    
    let content: ListLayoutContent
    
    init(
        layoutAppearance : LayoutAppearance,
        appearance : Appearance,
        behavior : Behavior,
        content : ListLayoutContent
    ) {
        self.layoutAppearance = layoutAppearance
        self.appearance = appearance
        self.behavior = behavior
        self.content = content
    }
    
    func updateLayout(in context: ListLayoutLayoutContext) {
        /// No updates needed outside the regular `layout` method.
    }
    
    func layout(
        delegate: CollectionViewLayoutDelegate?,
        in context: ListLayoutLayoutContext
    ) -> ListLayoutResult
    {
        // 1) Calculate the base values used to drive the layout.
        
        let boundsContext = ListContentBounds.Context(
            viewSize: context.viewBounds.size,
            safeAreaInsets: context.safeAreaInsets,
            direction: self.direction
        )
        
        let bounds = self.layoutAppearance.bounds ?? context.environment.listContentBounds(in: boundsContext)
        
        let spacings = self.layoutAppearance.spacings
        
        let viewWidth = self.direction.width(for: context.viewBounds.size)
        
        let rootWidth = CustomWidth.custom(.init(
            padding: self.direction.switch(
                vertical: HorizontalPadding(leading: bounds.padding.left, trailing: bounds.padding.right),
                horizontal: HorizontalPadding(leading: bounds.padding.top, trailing: bounds.padding.bottom)
            ),
            width: bounds.width,
            alignment: .center
        ))
        
        let defaultWidth = rootWidth.position(
            with: viewWidth,
            defaultWidth: viewWidth
        ).width
        
        var contentBottom : CGFloat = 0.0
        
        //
        // Container Header
        //
        
        self.layout(
            headerFooter: self.content.containerHeader,
            width: .fill,
            viewWidth: viewWidth,
            defaultWidth: defaultWidth,
            contentBottom: contentBottom,
            after: { headerFooter in
                if headerFooter.isPopulated {
                    contentBottom = self.direction.maxY(for: headerFooter.defaultFrame)
                }
            }
        )
        
        //
        // Set Frame Origins
        //
        
        contentBottom += self.direction.switch(
            vertical: bounds.padding.top,
            horizontal: bounds.padding.left
        )
        
        //
        // Header
        //
        
        self.layout(
            headerFooter: self.content.header,
            width: rootWidth,
            viewWidth: viewWidth,
            defaultWidth: defaultWidth,
            contentBottom: contentBottom,
            after: { headerFooter in
                if headerFooter.isPopulated {
                    contentBottom = self.direction.maxY(for: headerFooter.defaultFrame)
                    
                    if self.content.sections.isEmpty == false {
                        contentBottom += spacings.headerToFirstSectionSpacing
                    }
                }
            }
        )
        
        //
        // Sections
        //
        
        self.content.sections.forEachWithIndex { sectionIndex, isLast, section in
            
            if section.all.isEmpty { return }
            
            let sectionLayout = section.layouts.flow
            
            let sectionWidth = sectionLayout.width.merge(with: rootWidth)
            
            let sectionPosition = sectionWidth.position(
                with: viewWidth,
                defaultWidth: defaultWidth
            )
            
            //
            // Section Header
            //
            
            let hasSectionFooter = section.footer.isPopulated
            
            self.layout(
                headerFooter: section.header,
                width: sectionWidth,
                viewWidth: viewWidth,
                defaultWidth: sectionPosition.width,
                contentBottom: contentBottom,
                after: { header in
                    if header.isPopulated {
                        contentBottom = self.direction.maxY(for: header.defaultFrame)
                        
                        if section.items.isEmpty == false {
                            contentBottom += spacings.sectionHeaderBottomSpacing
                        }
                    }
                }
            )
            
            //
            // Section Items
            //
            
            // 1) Measure all the items so we have their size to flow to rows.
            
            let itemSizing = sectionLayout.itemSizing ?? layoutAppearance.itemSizing
            let itemSpacing = sectionLayout.itemSpacing ?? spacings.itemSpacing
            
            for item in section.items {
                item.size = itemSizing.size(
                    for: item,
                    direction: direction,
                    maxWidth: sectionPosition.width,
                    itemSpacing: itemSpacing
                )
            }
            
            // 2) Split the items into rows. The flow layout works by, well, "flowing"
            // the available items to the end of each row, and then making a new row
            // below that one once it is full.
            
            let rows = self.rows(
                with: section.items,
                maxWidth: sectionPosition.width
            )
            
            var lastRowItemSpacing = spacings.itemSpacing
            
            // 3) Now that we have each row, lay them all out. X and Y values are
            // handled separately because they are entirely independent.
            
            rows.forEachWithIndex { rowIndex, isLast, row in
                
                lastRowItemSpacing = self.setX(
                    for: row,
                    isLastRow: isLast,
                    sectionPosition: sectionPosition,
                    itemSpacing: itemSpacing,
                    lastRowItemSpacing: lastRowItemSpacing,
                    alignment: sectionLayout.rowUnderflowAlignment ?? layoutAppearance.rowUnderflowAlignment
                )
                
                contentBottom += self.setY(
                    for: row,
                    baseYPosition: contentBottom,
                    alignment: sectionLayout.rowItemsAlignment ?? layoutAppearance.rowItemsAlignment
                )
                
                if isLast {
                    if hasSectionFooter {
                        contentBottom += spacings.rowToSectionFooterSpacing
                    }
                } else {
                    contentBottom += spacings.rowSpacing
                }
            }
            
            //
            // Section Footer
            //
            
            self.layout(
                headerFooter: section.footer,
                width: sectionWidth,
                viewWidth: viewWidth,
                defaultWidth: sectionPosition.width,
                contentBottom: contentBottom,
                after: { footer in
                    if footer.isPopulated {
                        contentBottom = self.direction.maxY(for: footer.defaultFrame)
                    }
                }
            )
            
            // Add additional padding from config.
            
            if isLast {
                if self.content.footer.isPopulated {
                    contentBottom += spacings.lastSectionToFooterSpacing
                }
            } else {
                contentBottom += hasSectionFooter
                    ? spacings.interSectionSpacing.withFooter
                    : spacings.interSectionSpacing.noFooter
            }
        }
        
        //
        // Footer
        //
        
        self.layout(
            headerFooter: self.content.footer,
            width: rootWidth,
            viewWidth: viewWidth,
            defaultWidth: defaultWidth,
            contentBottom: contentBottom,
            after: { footer in
                if footer.isPopulated {
                    contentBottom = self.direction.maxY(for: footer.defaultFrame)
                }
            }
        )
        
        contentBottom += self.direction.switch(
            vertical: bounds.padding.bottom,
            horizontal: bounds.padding.right
        )
        
        //
        // Overscroll Footer
        //
        
        self.layout(
            headerFooter: self.content.overscrollFooter,
            width: rootWidth,
            viewWidth: viewWidth,
            defaultWidth: defaultWidth,
            contentBottom: contentBottom,
            after: { _ in }
        )
        
        //
        // Remaining Calculations
        //
        
        return .init(
            contentSize: direction.size(for: CGSize(width: viewWidth, height: contentBottom)),
            naturalContentWidth: nil
        )
    }
    
    /// Sets the x value for each item in a row, returning the item spacing used for the row.
    private func setX(
        for row : Row,
        isLastRow : Bool,
        sectionPosition : CustomWidth.Position,
        itemSpacing : CGFloat,
        lastRowItemSpacing : CGFloat,
        alignment : FlowAppearance.RowUnderflowAlignment
    ) -> CGFloat
    {
        switch alignment {
        case .leading, .centered, .trailing:
            
            /// 1) Set up our items as if they are `.leading`.
            
            var maxX : CGFloat = sectionPosition.origin
            
            row.items.forEachWithIndex { index, isLast, item in
                direction.switch {
                    item.x = maxX
                } horizontal: {
                    item.y = maxX
                }
                
                maxX += direction.width(for: item.size)
                
                if isLast == false {
                    maxX += itemSpacing
                }
            }
            
            let additional : CGFloat = {
                let leftover = sectionPosition.width - (maxX - sectionPosition.origin)

                switch alignment {
                case .leading: return 0.0
                case .centered: return round(leftover / 2.0)
                case .trailing: return leftover
                    
                case .fill: fatalError()
                }
            }()
            
            row.items.forEach { item in
                direction.switch {
                    item.x += additional
                } horizontal: {
                    item.y += additional
                }
            }
            
            return itemSpacing

        case .fill(let lastRowAlignment):
            let leftover = sectionPosition.width - row.items.reduce(0.0) { width, item in
                width + direction.width(for: item.size)
            }
            
            var maxX : CGFloat = sectionPosition.origin
            
            leftover.sliceIntoSpacings(with: row.items) { spacing, item in
                direction.switch {
                    item.x = maxX
                } horizontal: {
                    item.y = maxX
                }
                
                switch spacing {
                case .value(let spacing):
                    maxX += direction.width(for: item.size)
                    
                    if isLastRow {
                        switch lastRowAlignment {
                        case .fill:
                            maxX += spacing
                        case .matchPreviousRowSpacing:
                            maxX += min(spacing, lastRowItemSpacing)
                        case .defaultItemSpacing:
                            maxX += min(spacing, itemSpacing)
                        }
                    } else {
                        maxX += spacing
                    }
                    
                case .last: break
                }
            }
            
            if row.items.count > 1 {
                return leftover / CGFloat(row.items.count - 1)
            } else {
                return leftover
            }
        }
    }
    
    /// Sets the y value for each item in a row, returning the new bottom of content.
    private func setY(
        for row : Row,
        baseYPosition : CGFloat,
        alignment : FlowAppearance.RowItemsAlignment
    ) -> CGFloat {
                
        let heights = row.items.map {
            direction.height(for: $0.size)
        }
        
        let maxHeight : CGFloat = heights.max(by: <) ?? 0.0
        
        for item in row.items {
            let height = direction.height(for: item.size)

            let offset : CGFloat = {
                switch alignment {
                case .top: return 0.0
                case .center: return round((maxHeight - height) / 2.0)
                case .bottom: return maxHeight - height
                case .fill: return 0.0
                }
            }()

            direction.switch {
                item.y = baseYPosition + offset
                item.size.height = alignment.adjusted(height: height, forMaxRowHeight: maxHeight)
            } horizontal: {
                item.x = baseYPosition + offset
                item.size.width = alignment.adjusted(height: height, forMaxRowHeight: maxHeight)
            }
        }
        
        return maxHeight
    }
    
    /// Breaks the given items into rows for the flow layout. A new row is created when an item does not
    /// fit into the last row (item spacing included).
    private func rows(with items : [ListLayoutContentItem], maxWidth : CGFloat) -> [Row] {
        
        if items.isEmpty { return [] }
        
        var items = items
        var rows = [Row]()
        
        while items.isEmpty == false {
            
            var lastMaxX : CGFloat = 0.0
            
            let rowItems = items.popPassing { item in
                let width = direction.width(for: item.size)
                
                let maxX = lastMaxX + width
                
                if maxX <= maxWidth {
                    lastMaxX = maxX + layoutAppearance.spacings.rowSpacing
                    return true
                } else {
                    return false
                }
            }
            
            rows.append(Row(items: rowItems))
        }
        
        return rows
    }
    
    /// Lays out the given header / footer.
    private func layout(
        headerFooter : ListLayoutContent.SupplementaryItemInfo,
        width : CustomWidth,
        viewWidth : CGFloat,
        defaultWidth : CGFloat,
        contentBottom : CGFloat,
        after : (ListLayoutContent.SupplementaryItemInfo) -> ()
    ) {
        let position = width.position(
            with: viewWidth,
            defaultWidth: defaultWidth
        )

        // The constraints we'll use to measure the content.
        
        let measureInfo = Sizing.MeasureInfo(
            sizeConstraint: self.direction.size(for: CGSize(width: position.width, height: .greatestFiniteMagnitude)),
            direction: self.direction
        )
        
        // Measure the size of the content.

        let size = headerFooter.measurer(measureInfo)
        
        // Write the measurement and position out to the header/footer.
        
        self.direction.switch(
            vertical: {
                headerFooter.x = position.origin
                headerFooter.size = CGSize(width: position.width, height: size.height)
                headerFooter.y = contentBottom
            },
            horizontal: {
                headerFooter.y = position.origin
                headerFooter.size = CGSize(width: size.width, height: position.width)
                headerFooter.x = contentBottom
            }
        )
        
        after(headerFooter)
    }
    
    /// Represents a row within a section within the flow layout.
    private struct Row {
        let items : [ListLayoutContentItem]
    }
}


extension FlowAppearance.ItemSizing {
    
    /// Calculates the size of the given item within the constraints of the `ItemSizing` value.
    func size(
        for item : ListLayoutContent.ItemInfo,
        direction : LayoutDirection,
        maxWidth : CGFloat,
        itemSpacing : CGFloat
    ) -> CGSize
    {
        func measure(in width : CGFloat) -> CGSize {
            let measureInfo = Sizing.MeasureInfo(
                sizeConstraint: direction.size(
                    for: CGSize(
                        width: min(width, maxWidth),
                        height: .greatestFiniteMagnitude
                    )
                ),
                direction: direction
            )
            
            return item.measurer(measureInfo)
        }
        
        switch item.layouts.flow.width {
        case .natural:
            switch self {
            case .natural:
                return measure(in: maxWidth)
                
            case .fixed(let fixed):
                let size = measure(in: fixed)
                
                return direction.switch {
                    CGSize(width: fixed, height: size.height)
                } horizontal: {
                    CGSize(width: size.width, height: fixed)
                }
                
            case .columns(let columns):
                precondition(columns >= 1, "Must provide one or more columns.")
                
                let totalSpacing = itemSpacing * CGFloat(columns - 1)
                let columnWidth = floor((maxWidth - totalSpacing) / CGFloat(columns))
                
                let size = measure(in: columnWidth)
                
                return direction.switch {
                    CGSize(width: columnWidth, height: size.height)
                } horizontal: {
                    CGSize(width: size.width, height: columnWidth)
                }
            }
            
        case .fillRow:
            let size = measure(in: maxWidth)
            
            return direction.switch {
                CGSize(width: maxWidth, height: size.height)
            } horizontal: {
                CGSize(width: size.width, height: maxWidth)
            }
        }
    }
}


extension CGFloat {
    
    /// For fill layouts, ensures that the left over spacing to be distributed between items
    /// is entirely used, calling the given `block` with each spacing. The last call to the
    /// block will pass a `SliceSpacing` of `.last`, to indicate the item is the last item in the row.
    func sliceIntoSpacings<Element>(
        with items : [Element],
        using block : (SliceSpacing, Element) -> ()
    ) {
        if items.isEmpty { return }
        
        let spacings = self.sliceIntoSpacings(for: items.count)
        
        precondition(spacings.count == items.count - 1)
        
        items.forEachWithIndex { index, isLast, item in
            if isLast {
                block(.last, item)
            } else {
                block(.value(spacings[index]), item)
            }
        }
    }
    
    /// For fill layouts, ensures that the left over spacing is entirely distributed, avoiding
    /// rounding of a value dropping some amount of precision.
    ///
    /// Eg: If you have `10` points of spacing left to distribute between 4 items (which have
    /// 3 gutters of spacing between them), doing a normal `round` on `10/3` would result
    /// in either `3,3,3 = 9` (rounding down), or `4, 4, 4 = 12` (rounding up), which
    /// does not match the original `10`. This method progresively calculates each spacing,
    /// ensuring the entire value is used: `3, 4, 3 = 10`.
    func sliceIntoSpacings(for count : Int) -> [CGFloat] {
        
        let range = 0..<(count - 1)
        
        var remaining = self
        var remainingCount : Int = count - 1
        
        return range.map { _ in
            let slice = (remaining / CGFloat(remainingCount)).rounded()
            
            remaining -= slice
            remainingCount -= 1
            
            return slice
        }
    }
    
    enum SliceSpacing : Equatable {
        case value(CGFloat)
        case last
    }
}


extension FlowAppearance.RowUnderflowAlignment {
    
    static let allTestCases : [(value:Self, description:String)] = [
        (.leading, "RowUnderflowAlignment.leading"),
        (.centered, "RowUnderflowAlignment.centered"),
        (.trailing, "RowUnderflowAlignment.trailing"),
        (.fill(lastRowAlignment: .fill), "RowUnderflowAlignment.fill(lastRowAlignment: .fill)"),
        (.fill(lastRowAlignment: .matchPreviousRowSpacing), "RowUnderflowAlignment.fill(lastRowAlignment: .matchPreviousRowSpacing)"),
        (.fill(lastRowAlignment: .defaultItemSpacing), "RowUnderflowAlignment.fill(lastRowAlignment: .defaultItemSpacing)"),
    ]
}


extension FlowAppearance.RowItemsAlignment {
    
    static let allTestCases : [(value:Self, description:String)] = [
        (.top, "RowItemsAlignment.top"),
        (.center, "RowItemsAlignment.center"),
        (.bottom, "RowItemsAlignment.bottom"),
        (.fill, "RowItemsAlignment.fill")
    ]
}
