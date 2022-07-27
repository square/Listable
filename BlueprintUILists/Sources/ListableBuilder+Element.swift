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
///
/// ## Note
/// Takes advantage of `@_disfavoredOverload` to avoid ambiguous method resolution with the default implementations.
/// See more here: https://github.com/apple/swift/blob/main/docs/ReferenceGuides/UnderscoredAttributes.md#_disfavoredoverload
///
public extension ListableArrayBuilder where ContentType == AnyItemConvertible {

    static func buildExpression<ElementType:Element>(_ element: ElementType) -> Component {
        [element.listItem()]
    }
    
    /// Ensures that the `Equatable`version of `.listItem()` is called.
    static func buildExpression<ElementType:Element>(_ element: ElementType) -> Component where ElementType:Equatable {
        [element.listItem()]
    }
    
    /// Ensures that the `IsEquivalentContent`version of `.listItem()` is called.
    static func buildExpression<ElementType:Element>(_ element: ElementType) -> Component where ElementType:IsEquivalentContent {
        [element.listItem()]
    }
    
    static func buildExpression<ElementType:Element>(_ element: ElementType) -> Component where ElementType:ListElementNonConvertible {
        element.listElementNonConvertibleFatal()
    }
}


public extension ListableValueBuilder where ContentType == AnyHeaderFooterConvertible {

    static func buildBlock<ElementType:Element>(_ element: ElementType) -> ContentType {
        return element.listHeaderFooter()
    }
    
    /// Ensures that the `Equatable`version of `.listHeaderFooter()` is called.
    static func buildBlock<ElementType:Element>(_ element: ElementType) -> ContentType where ElementType:Equatable {
        return element.listHeaderFooter()
    }
    
    /// Ensures that the `IsEquivalentContent`version of `.listHeaderFooter()` is called.
    static func buildBlock<ElementType:Element>(_ element: ElementType) -> ContentType where ElementType:IsEquivalentContent {
        return element.listHeaderFooter()
    }
    
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
