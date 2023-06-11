//
//  ListableArrayBuilder+Element.swift
//  BlueprintUILists
//
//  Created by Kyle Van Essen on 7/24/22.
//

import BlueprintUI
import ListableUI


/// Adds `Element` support when building `AnyItemConvertible` arrays, which allows:
///
/// ```swift
/// Section("3") { section in
///     TestContent1() // An ItemContent
///
///     Element1() // An Element
///     Element2() // An Element
/// }
/// ```
public extension ListableArrayBuilder where ContentType == AnyItemConvertible {

    /// Ensures that a well-formed error is presented when a non-Equatable or non-LayoutEquivalent element is provided.
    @available(*, unavailable, message: "To be directly added to a List, an Element must conform to Equatable or LayoutEquivalent.")
    static func buildExpression<ElementType:Element>(_ element: ElementType) -> Component {
        fatalError()
    }
    
    /// Ensures that the `Equatable`version of `.listItem()` is called.
    static func buildExpression<ElementType:Element>(_ element: ElementType) -> Component where ElementType:Equatable {
        [element.listItem()]
    }
    
    /// Ensures that the `LayoutEquivalent`version of `.listItem()` is called.
    @_disfavoredOverload
    static func buildExpression<ElementType:Element>(_ element: ElementType) -> Component where ElementType:LayoutEquivalent {
        [element.listItem()]
    }
    
    @available(*, deprecated, message: "Cannot add a ListElementNonConvertible to a list. See the type's `listElementNonConvertibleFatal` implementation for the correct type to use instead.")
    static func buildExpression<ElementType:Element>(_ element: ElementType) -> Component where ElementType:ListElementNonConvertible {
        element.listElementNonConvertibleFatal()
    }
}


public extension ListableOptionalBuilder where ContentType == AnyHeaderFooterConvertible {

    /// Ensures that a well-formed error is presented when a non-Equatable or non-LayoutEquivalent element is provided.
    @available(*, unavailable, message: "To be directly added to a List, an Element must conform to Equatable or LayoutEquivalent.")
    static func buildBlock<ElementType:Element>(_ element: ElementType) -> ContentType {
        fatalError()
    }
    
    /// Ensures that the `Equatable`version of `.listHeaderFooter()` is called.
    static func buildBlock<ElementType:Element>(_ element: ElementType) -> ContentType where ElementType:Equatable {
        return element.listHeaderFooter()
    }
    
    /// Ensures that the `LayoutEquivalent`version of `.listHeaderFooter()` is called.
    @_disfavoredOverload
    static func buildBlock<ElementType:Element>(_ element: ElementType) -> ContentType where ElementType:LayoutEquivalent {
        return element.listHeaderFooter()
    }
    
    @available(*, deprecated, message: "Cannot add a ListElementNonConvertible to a list. See the type's `listElementNonConvertibleFatal` implementation for the correct type to use instead.")
    static func buildBlock<ElementType:Element>(_ element: ElementType) -> ContentType where ElementType:ListElementNonConvertible {
        element.listElementNonConvertibleFatal()
    }
}


/// Conform to this protocol if you have an `Element` which should not be implicitly converted into an `Item` or `HeaderFooter`.
public protocol ListElementNonConvertible {
    
    /// Implement this method to provide a more specific error for why the element
    /// cannot be implicitly converted to an `Item` or `HeaderFooter`.
    ///
    /// ```
    /// func listElementNonConvertibleFatal() -> Never {
    ///     fatalError(
    ///     "`MarketRow` should not be directly used within a list. Please use `MarketListRow` instead."
    ///     )
    /// }
    /// ```
    func listElementNonConvertibleFatal() -> Never
}
