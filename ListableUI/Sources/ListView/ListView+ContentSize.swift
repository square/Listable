//
//  ListSizing.swift
//  Listable
//
//  Created by Kyle Van Essen on 9/21/20.
//


extension ListView
{
    //
    // MARK: Measuring Lists
    //
    
    static let headerFooterMeasurementCache = ReusableViewCache()
    static let itemMeasurementCache = ReusableViewCache()
    
    public static let defaultContentSizeItemLimit = 50
    
    ///
    /// Returns the size that a list with the provided properties would be, within the given `fittingSize`.
    ///
    /// This method works similarly to `sizeThatFits(_:)` on a `UIView`, returning the size of the
    /// content within the given `fittingSize`.
    ///
    /// - parameters:
    ///     - fittingSize: The size that the content should be measured in. This is the maximum
    ///     size that will be returned from this method.
    ///     - properties: The `ListProperties` which describe the content of the list.
    ///     - itemLimit: How many items from the content should be measured. The lower this number
    ///     (if lower then the count of items in the content), the faster this call will be, at the expense of a smaller
    ///     measurement size. If you know your `fittingSize` is constrained to, eg, the height of a device,
    ///     then relying on the default value of 50 is usually fine.
    ///
    /// Note
    /// ----
    /// This method attempts to be efficient – it does not allocate a `ListView` – instead it creates a layout,
    /// and presentation state – a subset of a usual list. It also re-uses measurement views across method calls
    /// (via static view caching) to further reduce allocations and improve speed and efficiency. Nevertheless,
    /// measuring the vertical or horizontal height of an entire list, especially large ones, can just be slow. You are
    /// encouraged to provide an `itemLimit` to reduce the amount of measurement that has to occur to
    /// calculate a height – especially if the `fittingSize` is known and finite.
    ///
    public static func contentSize(
        in fittingSize : CGSize,
        for properties : ListProperties,
        itemLimit : Int? = ListView.defaultContentSizeItemLimit
    ) -> CGSize {
        
        /// 1) Create an instance of presentation state and the layout we can use to measure the list.
        
        let presentationState = PresentationState(
            content: {
                if let limit = itemLimit {
                    return properties.content.sliceTo(indexPath: IndexPath(item: 0, section: 0), plus: limit).content
                } else {
                    return properties.content
                }
            }(),
            environment: properties.environment,
            itemMeasurementCache: Self.itemMeasurementCache,
            headerFooterMeasurementCache: Self.headerFooterMeasurementCache
        )
        
        /// 2) Create the layout used to measure the content.
        
        let layout = properties.layout.configuration.createPopulatedLayout(
            appearance: properties.appearance,
            behavior: properties.behavior,
            content: { _ in
                presentationState.toListLayoutContent(
                    defaults: .init(itemInsertAndRemoveAnimations: .fade),
                    environment: properties.environment
                )
            }
        )
        
        /// 2b) Measure the content.

        layout.layout(
            delegate: nil,
            in: .init(viewBounds: CGRect(origin: .zero, size: fittingSize), safeAreaInsets: .zero)
        )
        
        /// 3) Constrain the measurement to the `fittingSize`.
        
        let size = layout.content.contentSize
        
        return CGSize(
            width: fittingSize.width > 0 ? min(fittingSize.width, size.width) : size.width,
            height: fittingSize.height > 0 ? min(fittingSize.height, size.height) : size.height
        )
    }
}
