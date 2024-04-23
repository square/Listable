//
//  CarouselListLayout.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 6/4/20.
//

import UIKit


public extension LayoutDescription
{
    static func carousel(_ configure : (inout CarouselAppearance) -> () = { _ in }) -> Self
    {
        CarouselListLayout.describe(appearance: configure)
    }
}


public struct CarouselAppearance : ListLayoutAppearance
{
    // MARK: ListLayoutAppearance
    
    public static var `default`: CarouselAppearance {
        Self.init()
    }
    
    public let direction: LayoutDirection = .horizontal

    public let listHeaderPosition: ListHeaderPosition = .inline

    public let stickySectionHeaders: Bool = false
    
    public let pagingBehavior: ListPagingBehavior = .firstVisibleItemCentered
    
    public var scrollViewProperties: ListLayoutScrollViewProperties {
        .init(
            isPagingEnabled: false,
            contentInsetAdjustmentBehavior: .never,
            allowsBounceVertical: false,
            allowsBounceHorizontal: false,
            allowsVerticalScrollIndicator: self.showsScrollIndicators,
            allowsHorizontalScrollIndicator: self.showsScrollIndicators
        )
    }
    
    public var bounds: ListContentBounds?
    
    public func toLayoutDescription() -> LayoutDescription {
        LayoutDescription(layoutType: CarouselListLayout.self, appearance: self)
    }
    
    // MARK: Properties
    
    /// If scroll indicators should be visible along the scrollable axis.
    public var showsScrollIndicators : Bool
    
    public init(
        showsScrollIndicators : Bool = false,
        bounds: ListContentBounds? = nil
    ) {
        self.showsScrollIndicators = showsScrollIndicators
        self.bounds = bounds
    }
}


final class CarouselListLayout : ListLayout
{
    typealias ItemLayout = EmptyItemLayoutsValue
    typealias HeaderFooterLayout = EmptyHeaderFooterLayoutsValue
    typealias SectionLayout = EmptySectionLayoutsValue
    
    public typealias LayoutAppearance = CarouselAppearance
    
    static var defaults: ListLayoutDefaults {
        .init(itemInsertAndRemoveAnimations: .scaleDown)
    }
    
    var layoutAppearance: CarouselAppearance
    
    let appearance: Appearance
    let behavior: Behavior
    let content: ListLayoutContent
    
    //
    // MARK: Initialization
    //
    
    init(
        layoutAppearance: CarouselAppearance,
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
        
        /// The size of the containing view.
        
        let viewSize = context.viewBounds.size
        
        let pageSize = CGSize(width: viewSize.width * 0.6, height: viewSize.height * 0.6)
        
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
        
        var lastMaxY : CGFloat = (viewSize.width - pageSize.width) / 2
        
        for section in content.sections {
            for item in section.items {
                
                var itemFrame = CGRect(
                    x: lastMaxY + itemPosition.origin,
                    y: (viewSize.height - item.size.height) / 2,
                    width: itemPosition.width,
                    height: pageSize.height
                )
                
                itemFrame = itemFrame.inset(
                    by: bounds.padding.masked(
                        by: [.top, .bottom]
                    )
                )

                item.x = itemFrame.origin.x
                item.y = itemFrame.origin.y
                item.size = itemFrame.size
                
//                // Determine how far the cell's center is from the center of the visible rect.
//                let distanceFromCenter = abs(center - attributes.center.x)
//                // Define the point at which cells no longer scale.
//                let maxDistance = (collectionView.bounds.width / 2) + (attributes.size.width / 2)
//                // Normalize the distance to a factor between 0 and 1.
//                let normalizedDistance = min(distanceFromCenter / maxDistance, 1)
//                // Define the minimum scale factor (e.g., no cell will be smaller than 70% of its original size).
//                let minimumScaleFactor: CGFloat = 0.7
//                // Calculate the scale factor based on the cell's distance from the center.
//                let scaleFactor = 1 - (1 - minimumScaleFactor) * normalizedDistance
//                // Scale the height of the cell
//                attributes.transform3D = CATransform3DMakeScale(1, scaleFactor, 1)
                
                let visibleCenter = context.viewBounds.origin.x + (context.viewBounds.width / 2)
                
                let distanceFromCenter = abs(visibleCenter - item.center.x)
                
                let maxDistance = (context.viewBounds.width / 2)
                
                let minScale = 0.7
                
                let scaleFactor = (distanceFromCenter / maxDistance) * minScale
                
                item.transform = CATransform3DMakeScale(scaleFactor, scaleFactor, 0.0)
                
                lastMaxY += pageSize.width
            }
        }
        
        /// Add the remaining bounds padding to the bottom of the collection view.
        
        lastMaxY += bounds.padding.right
        
        return .init(
            contentSize: CGSize(width: lastMaxY, height: viewSize.height),
            naturalContentWidth: nil
        )
    }
}
