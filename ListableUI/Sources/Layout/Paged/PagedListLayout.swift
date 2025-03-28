//
//  PagedListLayout.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 6/4/20.
//

import UIKit


public extension LayoutDescription
{
    static func paged(_ configure : (inout PagedAppearance) -> () = { _ in }) -> Self
    {
        PagedListLayout.describe(appearance: configure)
    }
}

/// Describes the available appearance configuration options for a paged list layout.
/// Paged list layouts lay out the headers, footers, and items in a list in a paged layout,
/// similar to how UIPageViewController works.
///
/// You can control the direction via the `direction` property, and you can control
/// the inset on each page via the `itemInsets` property. You may also optionally show
/// the scroll indicators with the `showsScrollIndicators` property.
///
/// Note
/// ----
/// Do not edit this ASCII diagram directly.
/// Edit the `PagedAppearance.monopic` file in this directory using Monodraw.
/// ```
/// ┌─────────────────────────────────┐
/// │          itemInsets.top         │
/// │   ┌─────────────────────────┐ i │
/// │ i │                         │ t │
/// │ t │                         │ e │
/// │ e │                         │ m │
/// │ m │                         │ I │
/// │ I │                         │ n │
/// │ n │                         │ s │
/// │ s │                         │ e │
/// │ e │                         │ t │
/// │ t │                         │ s │
/// │ s │                         │ . │
/// │ . │                         │ r │
/// │ l │                         │ i │
/// │ e │                         │ g │
/// │ f │                         │ h │
/// │ t │                         │ t │
/// │   └─────────────────────────┘   │
/// │        itemInsets.bottom        │
/// └─────────────────────────────────┘
/// ```
public struct PagedAppearance : ListLayoutAppearance
{
    // MARK: ListLayoutAppearance
    
    public static var `default`: PagedAppearance {
        Self.init()
    }
    
    /// The direction the paging layout should occur in. Defaults to `vertical`.
    public var direction: LayoutDirection

    public let listHeaderPosition: ListHeaderPosition = .inline

    public let stickySectionHeaders: Bool = false
    
    public var pagingBehavior: ListPagingBehavior = .none
    
    public var scrollViewProperties: ListLayoutScrollViewProperties {
        
        let pageScrollingBehavior: PageScrollingBehavior = switch pagingSize {
        // When there is no peek, meaning pages span the width of the collection view,
        // use the system's native paging behavior.
        case .inset(let peek): peek.isEmpty ? .full : .peek
        case .fixed: .full
        }
        
        return .init(
            pageScrollingBehavior: pageScrollingBehavior,
            contentInsetAdjustmentBehavior: .never,
            allowsBounceVertical: false,
            allowsBounceHorizontal: false,
            allowsVerticalScrollIndicator: self.showsScrollIndicators,
            allowsHorizontalScrollIndicator: self.showsScrollIndicators
        )
    }
    
    public var bounds: ListContentBounds?
    
    /// This is a proxy to the internal `pagingSize`.
    public var peek: Peek {
        get {
            switch pagingSize {
            case .inset(let peek): peek
            case .fixed: .none
            }
        } set {
            pagingSize = .inset(newValue)
        }
    }
    
    public func toLayoutDescription() -> LayoutDescription {
        LayoutDescription(layoutType: PagedListLayout.self, appearance: self)
    }
    
    // MARK: Properties
    
    /// If scroll indicators should be visible along the scrollable axis.
    public var showsScrollIndicators : Bool
    
    /// Internal property for test harness only.
    internal var pagingSize : PagingSize
    
    public init(
        direction: LayoutDirection = .vertical,
        showsScrollIndicators : Bool = false,
        bounds: ListContentBounds? = nil,
        peek: Peek = .none
    ) {
        self.pagingSize = .inset(peek)
        
        self.direction = direction
        self.showsScrollIndicators = showsScrollIndicators
        self.bounds = bounds
        self.peek = peek
    }
    
    enum PagingSize : Equatable {
        
        /// This will inset the layout's primary dimension using the associated `Peek`.
        case inset(Peek)
        
        case fixed(CGFloat)
        
        func size(for viewSize : CGSize, isFirstItem: Bool, direction : LayoutDirection) -> CGSize {
            switch self {
            case .inset(let peek):
                switch direction {
                case .vertical:
                    return CGSize(
                        width: viewSize.width,
                        height: viewSize.height - peek.totalValue(isFirstItem)
                    )
                case .horizontal:
                    return CGSize(
                        width: viewSize.width - peek.totalValue(isFirstItem),
                        height: viewSize.height
                    )
                }
            case .fixed(let fixed):
                switch direction {
                case .vertical: return CGSize(width: viewSize.width, height: fixed)
                case .horizontal: return CGSize(width: fixed, height: viewSize.height)
                }
            }
        }
    }
}

public extension PagedAppearance {
    
    /// This data model is used to apply an inset to each page, allowing items residing on the
    /// edge of the collection view to "peek" into view.
    struct Peek: Equatable {
        
        /// The main leading and trailing peek value.
        let value: CGFloat
        
        /// Configures the first item's peek, which can be unique from the other peek values.
        let firstItemConfiguration: FirstItemConfiguration
        
        /// The leading peek value before the first item.
        var firstItemLeadingValue: CGFloat {
            switch firstItemConfiguration {
            case .uniform: value
            case .customLeading(let customValue): customValue
            }
        }
        
        /// Houses the various configuration options for the first item's peek value.
        public enum FirstItemConfiguration: Equatable {
            
            /// The first item's leading peek is equal to the `Peek.value`. This will keep the first
            /// item centered within the layout and will keep page sizes consistent.
            case uniform
            
            /// The first item's leading peek is equal to the associated value. This will offset the
            /// first item, giving it a larger page size than the rest of the items.
            ///
            /// Note: this value should be smaller than `Peek.value`. If a first item leading peek that
            /// is larger than the rest of the peeks becomes a business requirement, add a new
            /// `ListPagingBehavior` case to support trailing/bottom alignment on the first item.
            case customLeading(CGFloat)
        }
        
        /// This returns the combined leading and trailing peek, accounting for a custom leading value
        /// when `isFirstItem` is true.
        func totalValue(_ isFirstItem: Bool) -> CGFloat {
            (isFirstItem ? firstItemLeadingValue : value) + value
        }
        
        /// This is `true` if there are no peek values.
        public var isEmpty: Bool {
            value == 0 && firstItemLeadingValue == 0
        }
        
        /// Creates a new `Peek` with the specified peek value and first item configuration. By default,
        /// this initializer creates an empty `Peek`, so that items consume the layout's full width.
        /// - Parameters:
        ///   - value: The peek value applied to the leading and trailing side of items.
        ///   - firstItemConfiguration: The custom peek configuration for the layout's first item.
        public init(value: CGFloat = 0, firstItemConfiguration: FirstItemConfiguration = .uniform) {
            self.value = value
            self.firstItemConfiguration = firstItemConfiguration
        }
        
        /// This represents no peeking functionality.
        public static var none: Self { .init() }
    }
}


final class PagedListLayout : ListLayout
{
    typealias ItemLayout = EmptyItemLayoutsValue
    typealias HeaderFooterLayout = EmptyHeaderFooterLayoutsValue
    typealias SectionLayout = EmptySectionLayoutsValue
    
    public typealias LayoutAppearance = PagedAppearance
    
    static var defaults: ListLayoutDefaults {
        .init(itemInsertAndRemoveAnimations: .scaleDown)
    }
    
    var layoutAppearance: PagedAppearance
    
    let appearance: Appearance
    let behavior: Behavior
    let content: ListLayoutContent
    
    //
    // MARK: Initialization
    //
    
    init(
        layoutAppearance: PagedAppearance,
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
        // Nothing needed.
    }
    
    func layout(
        delegate : CollectionViewLayoutDelegate?,
        in context : ListLayoutLayoutContext
    ) -> ListLayoutResult
    {
        let bounds = self.resolvedBounds(in: context)
        
        /// The size of the containing view.
        
        let viewSize = context.viewBounds.size
        
        let itemWidth = CustomWidth.custom(.init(
            padding: HorizontalPadding(
                leading: bounds.padding.left,
                trailing: bounds.padding.right
            ),
            width: bounds.width,
            alignment: .center
        ))
        
        
        /// Apply the leading peek to the first item's position.
        
        var lastMaxY : CGFloat = layoutAppearance.peek.firstItemLeadingValue
        
        content.all.forEachWithIndex { index, _, item in
            
            /// The size of each page to use during the layout.
            /// Tests override this, but it's typically either the size of the view, with
            /// optional peeking insets applied.
            
            let pageSize = self.layoutAppearance.pagingSize.size(
                for: context.viewBounds.size,
                isFirstItem: index == 0,
                direction: self.direction
            )
            
            let itemPosition = itemWidth.position(
                with: pageSize.width,
                defaultWidth: bounds.width.clamp(pageSize.width)
            )
            
            var itemFrame : CGRect = direction.switch {
                CGRect(
                    x: itemPosition.origin,
                    y: lastMaxY,
                    width: itemPosition.width,
                    height: pageSize.height
                )
            } horizontal: {
                CGRect(
                    x: lastMaxY + itemPosition.origin,
                    y: 0,
                    width: itemPosition.width,
                    height: pageSize.height
                )
            }
            
            itemFrame = itemFrame.inset(
                by: bounds.padding.masked(
                    by: [.top, .bottom]
                )
            )

            item.x = itemFrame.origin.x
            item.y = itemFrame.origin.y
            item.size = itemFrame.size
            
            lastMaxY += direction.switch(
                vertical: pageSize.height,
                horizontal: pageSize.width
            )
        }
        
        /// Add the remaining bounds padding to the bottom of the collection view.
        
        lastMaxY += direction.switch(
            vertical: bounds.padding.bottom,
            horizontal: bounds.padding.right
        )
        
        /// Add the final peek value to the last item.
        
        lastMaxY += layoutAppearance.peek.value
        
        return .init(
            contentSize: direction.switch(
                vertical: CGSize(width: viewSize.width, height: lastMaxY),
                horizontal: CGSize(width: lastMaxY, height: viewSize.height)
            ),
            naturalContentWidth: nil
        )
    }
}
