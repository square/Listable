//
//  ItemLayouts.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 1/22/21.
//

import Foundation


///
/// `ItemLayouts` allows you to provide `ListLayout`-specific layout configuration for
/// individual items within a list. Eg, customize the layout for an item when it is in a table, a grid, etc.
///
/// For example, if you want to specify a custom layout for table layouts, you
/// would do the following on your item:
///
/// ```
/// myItem.layouts.table = .init(
///     width: .fill
/// )
/// ```
///
/// And then, when the `Item` is used within a `.table` style
/// list layout, the provided layout will be used.
///
/// If you plan on swapping between multiple `ListLayout` types on your list,
/// you can provide multiple layouts. The correct one will be used at the correct time:
///
/// ```
/// myItem.layouts.table = .init(
///     width: .fill
/// )
///
/// myItem.layouts.otherLayout = .init(
///     width: 300,
///     alignment: .left
/// )
/// ```
///
/// Note
/// ----
/// When implementing your own custom layout, you should add an extension to `ItemLayouts`,
/// to provide easier access to your layout-specific `ItemLayoutsValue` type, like so:
///
/// ```
/// extension ItemLayoutsValue {
///     public var table : TableAppearance.Item.Layout {
///         get { self[TableAppearance.Item.Layout.self] }
///         set { self[TableAppearance.Item.Layout.self] = newValue }
///     }
/// }
/// ```
public struct ItemLayouts {
    
    /// Creates a new instance of the layouts, with an optional `configure`
    /// closure, to allow you to set up styling inline.
    public init(
        _ configure : (inout Self) -> () = { _ in }
    ) {
        self.storage = .init()
        
        configure(&self)
    }
    
    private var storage : ContentLayoutsStorage
    
    /// Allows accessing the various `ItemLayoutsValue`s stored within the object.
    /// This method will return the `defaultValue` for a value if none is set.
    ///
    /// Note
    /// ----
    /// When implementing your own custom layout, you should add an extension to `ItemLayouts`,
    /// to provide easier access to your layout-specific `ItemLayoutsValue` type.
    ///
    /// ```
    /// extension ItemLayoutsValue {
    ///     public var table : TableAppearance.Item.Layout {
    ///         get { self[TableAppearance.Item.Layout.self] }
    ///         set { self[TableAppearance.Item.Layout.self] = newValue }
    ///     }
    /// }
    /// ```
    public subscript<ValueType:ItemLayoutsValue>(_ valueType : ValueType.Type) -> ValueType {
        get { self.storage.get(valueType, default: ValueType.defaultValue) }
        set { self.storage.set(valueType, new: newValue) }
    }
}


///
/// The `ItemLayoutsValue` protocol provides a default value for the different layouts stored
/// within `ItemLayouts`. Provide a `defaultValue` with reasonable defaults, as the
/// developer should not need to set these values at all times when using your layout.
///
/// ```
/// public struct Layout : Equatable, ItemLayoutsValue
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
public protocol ItemLayoutsValue {
    
    /// The default value used when accessing the value, if none is set.
    static var defaultValue : Self { get }
}


/// Use this type if you have no `ItemLayout` for your `ListLayout`.
public struct EmptyItemLayoutsValue : ItemLayoutsValue {
    
    public init() {}
    
    public static var defaultValue: EmptyItemLayoutsValue {
        .init()
    }
}
