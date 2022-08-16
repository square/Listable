//
//  ListLayout+Layout.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 11/28/21.
//

import Foundation


extension ListProperties {
    
    private static let headerFooterMeasurementCache = ReusableViewCache()
    private static let itemMeasurementCache = ReusableViewCache()
    
    /// **Note**: For testing or measuring content sizes only.
    ///
    /// Uses the properties from the list properties to create a `PresentationState`
    /// instance, a `ListLayout` instance, and then lays out the layout within
    /// the provided `fittingSize`, returning the laid out layout.
    internal func makeLayout(
        in fittingSize : CGSize,
        safeAreaInsets : UIEdgeInsets
    ) -> (AnyListLayout, ListLayoutLayoutContext)
    {
        /// 1) Create an instance of presentation state and the layout we can use to measure the list.
        
        let presentationState = PresentationState(
            forMeasuringOrTestsWith: {
                let zero = IndexPath(item: 0, section: 0)
                
                if let limit = itemLimit(in: fittingSize) {
                    return self.content.sliceTo(indexPath: zero, plus: limit).content
                } else {
                    return self.content
                }
            }(),
            environment: self.environment,
            itemMeasurementCache: Self.itemMeasurementCache,
            headerFooterMeasurementCache: Self.headerFooterMeasurementCache
        )
        
        /// 2) Create the layout used to measure the content.
        
        let layout = self.layout.configuration.createPopulatedLayout(
            appearance: self.appearance,
            behavior: self.behavior,
            content: { _ in
                presentationState.toListLayoutContent(
                    defaults: .init(itemInsertAndRemoveAnimations: .fade),
                    environment: self.environment
                )
            }
        )
        
        /// 2b) Measure the content.
        
        let layoutContext = ListLayoutLayoutContext(
            viewBounds: CGRect(origin: .zero, size: fittingSize),
            safeAreaInsets: safeAreaInsets,
            contentInset: .zero,
            adjustedContentInset: .listAdjustedContentInset(
                with: layout.scrollViewProperties.contentInsetAdjustmentBehavior,
                direction: layout.direction,
                safeAreaInsets: safeAreaInsets,
                contentInset: .zero
            ),
            layoutConstraints: .init(
                maximumValuedHeight: layout.direction.switch(
                    vertical: fittingSize.height,
                    horizontal: fittingSize.width
                )
            ),
            environment: self.environment
        )
        
        try? layout.performLayout(
            with: nil,
            in: layoutContext
        )
        
        return (layout, layoutContext)
    }
    
    internal func itemLimit(in fittingSize : CGSize) -> Int? {
        
        let axis = layout.layoutAppearanceProperties.direction.switch(
            vertical: fittingSize.height,
            horizontal: fittingSize.width
        )
        
        if axis.isFinite {
            return Int(ceil(axis / 30.0)) // Assuming average row is 30pts tall...
        } else {
            return nil
        }
    }
}

extension UIEdgeInsets {
    
    /// Because `ListProperties.makeLayout(...)` does not deal with an actual
    /// `UIScrollView`, we need to calculate `adjustedContentInset` ourselves,
    /// to pass to `layout.performLayout(...)`.
    static func listAdjustedContentInset(
        with contentInsetAdjustmentBehaviour : ContentInsetAdjustmentBehavior,
        direction : LayoutDirection,
        safeAreaInsets : UIEdgeInsets,
        contentInset : UIEdgeInsets
    ) -> UIEdgeInsets
    {
        switch contentInsetAdjustmentBehaviour {
        case .automatic, .always:
            return safeAreaInsets + contentInset
            
        case .scrollableAxes:
            switch direction {
            case .vertical:
                return UIEdgeInsets(
                    top: safeAreaInsets.top + contentInset.top,
                    left: 0,
                    bottom: safeAreaInsets.bottom + contentInset.bottom,
                    right: 0
                )
            case .horizontal:
                return UIEdgeInsets(
                    top: 0,
                    left: safeAreaInsets.left + contentInset.left,
                    bottom: 0,
                    right: safeAreaInsets.right + contentInset.right
                )
            }
        case .never:
            return .zero
        }
    }
}
