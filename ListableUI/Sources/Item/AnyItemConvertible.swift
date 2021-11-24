//
//  AnyItemConvertible.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 6/10/21.
//


/// A type which can be converted into a `AnyItem`, so you
/// do not need to explicitly wrap / convert your `ItemContent`
/// in an `Item` when providing it to a `Section`.
///
/// ```
/// Section("id") {
///     MyItemContent(text: "Hello, World!")
/// }
///
/// struct MyItemContent : ItemContent {
///    var text : String
///    ...
/// }
/// ```
///
/// Only two types conform to this protocol:
///
/// ### `Item`
/// The `Item` conformance simply returns self.
///
/// ### `ItemContent`
/// The `ItemContent` conformance returns `Item(self)`,
/// utilizing the default values from the `Item` initializer.
///
public protocol AnyItemConvertible {
    
    /// Converts the object into a type-erased  list of `AnyItem`s.
    func toAnyItem() -> [AnyItem]
}


extension Array where Element == AnyItemConvertible {
    
    func flattenToAnyItems() -> [AnyItem] {
        self.map { $0.toAnyItem() }.flatMap { $0 }
    }
}
