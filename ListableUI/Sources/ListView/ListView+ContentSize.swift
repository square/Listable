//
//  ListView+ContentSize.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 9/21/20.
//

import UIKit


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
    ///    - fittingSize: The size that the content should be measured in. This is the maximum
    ///     size that will be returned from this method.
    ///    - properties: The `ListProperties` which describe the content of the list.
    ///    - safeAreaInsets: The safe area to include when performing the layout.
    ///    - itemLimit: How many items from the content should be measured. The lower this number
    ///     (if lower then the count of items in the content), the faster this call will be, at the expense of a smaller
    ///     measurement size. If you know your `fittingSize` is constrained to, eg, the height of a device,
    ///     then relying on the default value of 50 is usually fine.
    ///
    /// ### Note
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
        safeAreaInsets : UIEdgeInsets,
        itemLimit : Int? = ListView.defaultContentSizeItemLimit
    ) -> MeasuredListSize
    {
        let (layout, layoutContext) = properties.makeLayout(
            in: fittingSize,
            safeAreaInsets: safeAreaInsets,
            itemLimit: itemLimit
        )
        
        let contentSize = layout.content.contentSize
        let contentInset = layoutContext.adjustedContentInset
        
        let totalSize = CGSize(
            width: contentSize.width + contentInset.left + contentInset.right,
            height: contentSize.height + contentInset.top + contentInset.bottom
        )
        
        return .init(
            contentSize: CGSize(
                width: fittingSize.width > 0 ? min(fittingSize.width, totalSize.width) : totalSize.width,
                height: fittingSize.height > 0 ? min(fittingSize.height, totalSize.height) : totalSize.height
            ),
            naturalWidth: layout.content.naturalContentWidth,
            layoutDirection: layout.direction
        )
    }
}


/// Provides sizing and width information about the measurement of a list's content.
public struct MeasuredListSize : Equatable {
    
    /// The content size of the list.
    public var contentSize : CGSize
    
    /// If it supports it, this value will contain the "natural" width of the list's
    /// content. For example, if you give a table layout 1000pts of width to lay out, but
    /// its content only requires 200pts of width to lay out, this value will be 200pt.
    ///
    /// ### Note
    /// Not all layouts support or provide a natural width. For example, a `.flow` layout
    /// cannot provide a natural width because it takes up as much space as it as given.
    public var naturalWidth : CGFloat?
    
    /// The layout direction of the list.
    public var layoutDirection : LayoutDirection
    
    public init(
        contentSize: CGSize,
        naturalWidth: CGFloat?,
        layoutDirection : LayoutDirection
    ) {
        self.contentSize = contentSize
        self.naturalWidth = naturalWidth
        self.layoutDirection = layoutDirection
    }
}
