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
    
    public let pagingBehavior: ListPagingBehavior = .firstVisibleItemCentered
    
    public var scrollViewProperties: ListLayoutScrollViewProperties {
        
        let pagingStyle: PagingStyle = switch pagingSize {
        // When there is no peek, meaning pages span the width of the collection view,
        // use the system's native paging behavior.
        case .inset(let peek): peek.isEmpty ? .native : .custom
        case .fixed: .native
        }
        
        return .init(
            pagingStyle: pagingStyle,
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
            case .fixed: .zero
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
        peek: Peek = .zero
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
        
        public enum Leading: Equatable {
            
            /// The leading peek is consistent across all items. The page sizes will also be consistent.
            case uniform( CGFloat)
            
            /// The first item's peek is unique from the rest. This can be used to remove the leading
            /// peek and make the item full width.
            case disjointed(firstItem: CGFloat, subsequentItems: CGFloat)
        }
        
        public var leading: Leading
        
        public var trailing: CGFloat
        
        public var leadingFirstItem: CGFloat {
            get {
                switch leading {
                case .uniform(let value): value
                case .disjointed(let firstItem, _): firstItem
                }
            } set {
                switch leading {
                case .uniform(let value): leading = .disjointed(firstItem: newValue, subsequentItems: value)
                case .disjointed(_, let subsequentItems): leading = .disjointed(firstItem: newValue, subsequentItems: subsequentItems)
                }
            }
        }
        
        public var leadingSubsequentItem: CGFloat {
            get {
                switch leading {
                case .uniform(let value): value
                case .disjointed(_, let subsequentItems): subsequentItems
                }
            } set {
                switch leading {
                case .uniform: leading = .uniform(newValue)
                case .disjointed(let firstItem, _): leading = .disjointed(firstItem: firstItem, subsequentItems: newValue)
                }
            }
        }
        
        /// This returns the total peek, taking int account a disjointed leading first item value.
        func totalValue(_ isFirstItem: Bool) -> CGFloat {
            (isFirstItem ? leadingFirstItem : leadingSubsequentItem) + trailing
        }
        
        /// This is `true` if there are no associated peek values.
        var isEmpty: Bool {
            leadingFirstItem == 0 && leadingSubsequentItem == 0 && trailing == 0
        }
        
        public init(leading: Leading = .uniform(0), trailing: CGFloat = 0) {
            self.leading = leading
            self.trailing = trailing
        }
        
        /// This represents no peeking functionality.
        public static var zero: Self { .init() }
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
        
        var lastMaxY : CGFloat = layoutAppearance.peek.leadingFirstItem
        
        for (index, item) in content.all.enumerated() {
            
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
        
        lastMaxY += layoutAppearance.peek.trailing
        
        return .init(
            contentSize: direction.switch(
                vertical: CGSize(width: viewSize.width, height: lastMaxY),
                horizontal: CGSize(width: lastMaxY, height: viewSize.height)
            ),
            naturalContentWidth: nil
        )
    }
}
