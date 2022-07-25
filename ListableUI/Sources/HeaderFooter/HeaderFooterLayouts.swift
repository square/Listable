//
//  HeaderFooterLayouts.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 1/22/21.
//

import Foundation

///
/// `HeaderFooterLayouts` allows you to provide `ListLayout`-specific layout configuration for
/// individual headers and footers within a list. Eg, customize the layout for a header when it is in a table, a grid, etc.
///
/// For example, if you want to specify a custom layout for table layouts, you
/// would do the following on your header:
///
/// ```
/// myHeader.layouts.table = .init(
///     width: .fill
/// )
/// ```
///
/// And then, when the `HeaderFooter` is used within a `.table` style
/// list layout, the provided layout will be used.
///
/// If you plan on swapping between multiple `ListLayout` types on your list,
/// you can provide multiple layouts. The correct one will be used at the correct time:
///
/// ```
/// myHeader.layouts.table = .init(
///     width: .fill
/// )
///
/// myHeader.layouts.otherLayout = .init(
///     width: 300,
///     alignment: .left
///     padding: 10
/// )
/// ```
///
/// Note
/// ----
/// When implementing your own custom layout, you should add an extension to `HeaderFooterLayouts`,
/// to provide easier access to your layout-specific `HeaderFooterLayoutsValue` type, like so:
///
/// ```
/// extension HeaderFooterLayouts {
///     public var table : TableAppearance.HeaderFooter.Layout {
///         get { self[TableAppearance.HeaderFooter.Layout.self] }
///         set { self[TableAppearance.HeaderFooter.Layout.self] = newValue }
///     }
/// }
/// ```
public struct HeaderFooterLayouts {
    /// Creates a new instance of the layouts, with an optional `configure`
    /// closure, to allow you to set up styling inline.
    public init(
        _ configure: (inout Self) -> Void = { _ in }
    ) {
        storage = .init()

        configure(&self)
    }

    private var storage: ContentLayoutsStorage

    /// Allows accessing the various `HeaderFooterLayoutValue`s stored within the object.
    /// This method will return the `defaultValue` for a value if none is set.
    ///
    /// Note
    /// ----
    /// When implementing your own custom layout, you should add an extension to `HeaderFooterLayouts`,
    /// to provide easier access to your layout-specific `HeaderFooterLayoutsValue` type.
    ///
    /// ```
    /// extension HeaderFooterLayouts {
    ///     public var table : TableAppearance.HeaderFooter.Layout {
    ///         get { self[TableAppearance.HeaderFooter.Layout.self] }
    ///         set { self[TableAppearance.HeaderFooter.Layout.self] = newValue }
    ///     }
    /// }
    /// ```
    public subscript<ValueType: HeaderFooterLayoutsValue>(_ valueType: ValueType.Type) -> ValueType {
        get { storage.get(valueType, default: ValueType.defaultValue) }
        set { storage.set(valueType, new: newValue) }
    }
}

///
/// The `HeaderFooterLayoutsValue` protocol provides a default value for the different layouts stored
/// within `HeaderFooterLayouts`. Provide a `defaultValue` with reasonable defaults, as the
/// developer should not need to set these values at all times when using your layout.
///
/// ```
/// public struct Layout : Equatable, HeaderFooterLayoutsValue
/// {
///     public var width : CGFloat
///     public var minHeight : CGFloat
///
///     ...
///
///     public static var defaultValue : Self {
///         ...
///     }
/// }
/// ```
public protocol HeaderFooterLayoutsValue {
    /// The default value used when accessing the value, if none is set.
    static var defaultValue: Self { get }
}
