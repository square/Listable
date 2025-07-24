//
//  AnyDecorationConvertible.swift
//  ListableUI
//
//  Created by Goose on 7/24/25.
//

import Foundation


/// A type which can be converted into a `Decoration`, so you
/// do not need to explicitly wrap / convert your `DecorationContent`
/// in a `Decoration` when providing a decoration to a list or section:
///
/// ```
/// Section("id") { section in
///     section.decoration = MyDecorationContent(backgroundColor: .red)
/// }
///
/// struct MyDecorationContent : DecorationContent {
///    var backgroundColor : UIColor
///    ...
/// }
/// ```
///
/// Only two types conform to this protocol:
///
/// ### `Decoration`
/// The `Decoration` conformance simply returns self.
///
/// ### `DecorationContent`
/// The `DecorationContent` conformance returns `Decoration(self)`,
/// utilizing the default values from the `Decoration` initializer.
///
public protocol AnyDecorationConvertible {
    
    /// Converts the object into a type-erased `AnyDecoration` instance.
    func asAnyDecoration() -> AnyDecoration
}
