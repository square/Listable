//
//  FlowListLayout.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 11/21/21.
//

import Foundation
import UIKit


public struct FlowAppearance : ListLayoutAppearance {
    
    public static var `default`: FlowAppearance {
        .init()
    }
    
    public var direction: LayoutDirection
    
    public var stickySectionHeaders: Bool
    
    public var layout : Layout
}


extension FlowAppearance {
    
    /// Layout options for the list.
    public struct Layout : Equatable
    {
        /// The spacing between the list header and the first section.
        /// Not applied if there is no list header.
        public var headerToFirstSectionSpacing : CGFloat

        /// The spacing to apply between sections, if the previous section has no footer.
        public var interSectionSpacingWithNoFooter : CGFloat
        /// The spacing to apply between sections, if the previous section has a footer.
        public var interSectionSpacingWithFooter : CGFloat
        
        /// The spacing to apply below a section header, before its items.
        /// Not applied if there is no section header.
        public var sectionHeaderBottomSpacing : CGFloat
        /// The spacing between individual items within a section in a list.
        public var itemSpacing : CGFloat
        /// The spacing between the last item in the section and the footer.
        /// Not applied if there is no section footer.
        public var itemToSectionFooterSpacing : CGFloat
        
        /// The spacing between the last section and the footer of the list.
        /// Not applied if there is no list footer.
        public var lastSectionToFooterSpacing : CGFloat
                
        /// Creates a new `Layout` with the provided options.
        public init(
            headerToFirstSectionSpacing : CGFloat = 0.0,
            interSectionSpacingWithNoFooter : CGFloat = 0.0,
            interSectionSpacingWithFooter : CGFloat = 0.0,
            sectionHeaderBottomSpacing : CGFloat = 0.0,
            itemSpacing : CGFloat = 0.0,
            itemToSectionFooterSpacing : CGFloat = 0.0,
            lastSectionToFooterSpacing : CGFloat = 0.0
        )
        {
            self.headerToFirstSectionSpacing = headerToFirstSectionSpacing
            
            self.interSectionSpacingWithNoFooter = interSectionSpacingWithNoFooter
            self.interSectionSpacingWithFooter = interSectionSpacingWithFooter
            
            self.sectionHeaderBottomSpacing = sectionHeaderBottomSpacing
            self.itemSpacing = itemSpacing
            self.itemToSectionFooterSpacing = itemToSectionFooterSpacing
            
            self.lastSectionToFooterSpacing = lastSectionToFooterSpacing
        }

        /// Easily mutate the `Layout` in place.
        public mutating func set(with block : (inout Layout) -> ())
        {
            var edited = self
            block(&edited)
            self = edited
        }
        
        /// Provides a width for layout.
        internal static func width(
            with width : CGFloat,
            padding : HorizontalPadding,
            constraint : WidthConstraint
        ) -> CGFloat
        {
            let paddedWidth = width - padding.leading - padding.trailing
            
            return constraint.clamp(paddedWidth)
        }
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
    
    var scrollViewProperties: ListLayoutScrollViewProperties {
        .init(
            isPagingEnabled: false,
            contentInsetAdjustmentBehavior: .scrollableAxes,
            allowsBounceVertical: true,
            allowsBounceHorizontal: true,
            allowsVerticalScrollIndicator: true,
            allowsHorizontalScrollIndicator: true
        )
    }
    
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
        
    }
    
    func layout(
        delegate: CollectionViewLayoutDelegate?,
        in context: ListLayoutLayoutContext
    ) {
        
    }
    
    private func layout(
        headerFooter : ListLayoutContent.SupplementaryItemInfo,
        width : CustomWidth,
        viewWidth : CGFloat,
        defaultWidth : CGFloat,
        defaultHeight : CGFloat,
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
            defaultSize: self.direction.size(for: CGSize(width: 0.0, height: defaultHeight)),
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
}
