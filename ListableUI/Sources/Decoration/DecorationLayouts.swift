//
//  DecorationLayouts.swift
//  ListableUI
//
//  Created by Goose on 7/24/25.
//

import Foundation


///
/// `DecorationLayouts` allows you to provide `ListLayout`-specific layout configuration for
/// individual decorations within a list. Eg, customize the layout for a decoration when it is in a table, a grid, etc.
///
/// For example, if you want to specify a custom layout for table layouts, you
/// would do the following on your decoration:
///
/// ```
/// myDecoration.layouts.table = .init(
///     width: .fill
/// )
/// ```
///
/// And then, when the `Decoration` is used within a `.table` style
/// list layout, the provided layout will be used.
///
/// If you plan on swapping between multiple `ListLayout` types on your list,
/// you can provide multiple layouts. The correct one will be used at the correct time:
///
/// ```
/// myDecoration.layouts.table = .init(
///     width: .fill
/// )
///
/// myDecoration.layouts.otherLayout = .init(
///     width: 300,
///     alignment: .left
///     padding: 10
/// )
/// ```
///
/// Note
/// ----
/// When implementing your own custom layout, you should add an extension to `DecorationLayouts`,
/// to provide easier access to your layout-specific `DecorationLayoutsValue` type, like so:
///
/// ```
/// extension DecorationLayouts {
///     public var table : TableAppearance.Decoration.Layout {
///         get { self[TableAppearance.Decoration.Layout.self] }
///         set { self[TableAppearance.Decoration.Layout.self] = newValue }
///     }
/// }
/// ```
public struct DecorationLayouts {
    
    /// Creates a new instance of the layouts, with an optional `configure`
    /// closure, to allow you to set up styling inline.
    public init(
        _ configure : (inout Self) -> () = { _ in }
    ) {
        self.storage = .init()
        
        configure(&self)
    }
    
    private var storage : ContentLayoutsStorage
    
    /// Allows accessing the various `DecorationLayoutValue`s stored within the object.
    /// This method will return the `defaultValue` for a value if none is set.
    ///
    /// ### Note
    /// When implementing your own custom layout, you should add an extension to `DecorationLayouts`,
    /// to provide easier access to your layout-specific `DecorationLayoutsValue` type.
    ///
    /// ```
    /// extension DecorationLayouts {
    ///     public var table : TableAppearance.Decoration.Layout {
    ///         get { self[TableAppearance.Decoration.Layout.self] }
    ///         set { self[TableAppearance.Decoration.Layout.self] = newValue }
    ///     }
    /// }
    /// ```
    public subscript<ValueType:DecorationLayoutsValue>(_ valueType : ValueType.Type) -> ValueType {
        get { self.storage.get(valueType, default: ValueType.defaultValue) }
        set { self.storage.set(valueType, new: newValue) }
    }
}


///
/// The `DecorationLayoutsValue` protocol provides a default value for the different layouts stored
/// within `DecorationLayouts`. Provide a `defaultValue` with reasonable defaults, as the
/// developer should not need to set these values at all times when using your layout.
///
/// ```
/// public struct Layout : Equatable, DecorationLayoutsValue
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
public protocol DecorationLayoutsValue {

    /// The default value used when accessing the value, if none is set.
    static var defaultValue : Self { get }
}


/// Use this type if you have no `DecorationLayout` for your `ListLayout`.
public struct EmptyDecorationLayoutsValue : DecorationLayoutsValue {
    
    public init() {}
    
    public static var defaultValue: EmptyDecorationLayoutsValue {
        .init()
    }
}
