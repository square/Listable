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
        safeAreaInsets : UIEdgeInsets,
        itemLimit : Int?
    ) -> AnyListLayout
    {
        /// 1) Create an instance of presentation state and the layout we can use to measure the list.
        
        let presentationState = PresentationState(
            forMeasuringOrTestsWith: {
                if let limit = itemLimit {
                    let zero = IndexPath(item: 0, section: 0)
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
        
        layout.layout(
            delegate: nil,
            in: .init(
                viewBounds: CGRect(origin: .zero, size: fittingSize),
                safeAreaInsets: safeAreaInsets,
                environment: self.environment
            )
        )
        
        return layout
    }
}
