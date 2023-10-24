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
    
    public let pagingBehavior: ListPagingBehavior = .none
    
    public var scrollViewProperties: ListLayoutScrollViewProperties {
        .init(
            isPagingEnabled: self.pagingSize == .view,
            contentInsetAdjustmentBehavior: .never,
            allowsBounceVertical: false,
            allowsBounceHorizontal: false,
            allowsVerticalScrollIndicator: self.showsScrollIndicators,
            allowsHorizontalScrollIndicator: self.showsScrollIndicators
        )
    }
    
    public var bounds: ListContentBounds?
    
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
        bounds: ListContentBounds? = nil
    ) {
        self.pagingSize = .view
        
        self.direction = direction
        self.showsScrollIndicators = showsScrollIndicators
        self.bounds = bounds
    }
    
    enum PagingSize : Equatable {
        case view
        case fixed(CGFloat)
        
        func size(for viewSize : CGSize, direction : LayoutDirection) -> CGSize {
            switch self {
            case .view: return viewSize
            case .fixed(let fixed):
                switch direction {
                case .vertical: return CGSize(width: viewSize.width, height: fixed)
                case .horizontal: return CGSize(width: fixed, height: viewSize.height)
                }
            }
        }
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
        
        /// The size of each page to use during the layout.
        /// Defaults to the size of the view, but some cases (eg tests) override.
        
        let pageSize = self.layoutAppearance.pagingSize.size(
            for: context.viewBounds.size,
            direction: self.direction
        )
        
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
        
        let itemPosition = itemWidth.position(
            with: pageSize.width,
            defaultWidth: bounds.width.clamp(pageSize.width)
        )
        
        var lastMaxY : CGFloat = 0
        
        for item in content.all {
            
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
        
        return .init(
            contentSize: direction.switch(
                vertical: CGSize(width: viewSize.width, height: lastMaxY),
                horizontal: CGSize(width: lastMaxY, height: viewSize.height)
            ),
            naturalContentWidth: nil
        )
    }
}
