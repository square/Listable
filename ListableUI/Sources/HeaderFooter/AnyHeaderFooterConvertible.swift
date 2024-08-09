//
//  AnyHeaderFooterConvertible.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 9/28/21.
//

import Foundation


/// A type which can be converted into a `HeaderFooter`, so you
/// do not need to explicitly wrap / convert your `HeaderFooterContent`
/// in a `HeaderFooter` when providing an header or footer to a list or section:
///
/// ```
/// Section("id") { section in
///     section.header = MyHeaderContent(title: "Hello, World!")
/// }
///
/// struct MyHeaderContent : HeaderFooterContent {
///    var title : String
///    ...
/// }
/// ```
///
/// Only two types conform to this protocol:
///
/// ### `HeaderFooter`
/// The `HeaderFooter` conformance simply returns self.
///
/// ### `HeaderFooterContent`
/// The `HeaderFooterContent` conformance returns `HeaderFooter(self)`,
/// utilizing the default values from the `HeaderFooter` initializer.
///
public protocol AnyHeaderFooterConvertible {
    
    /// Converts the object into a type-erased `AnyHeaderFooter` instance.
    func asAnyHeaderFooter() -> AnyHeaderFooter
}


/// A result builder that creates and returns a header or footer convertible value.
public typealias AnyHeaderFooterBuilder = ListableOptionalBuilder<AnyHeaderFooterConvertible>
