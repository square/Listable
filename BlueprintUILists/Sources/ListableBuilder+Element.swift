//
//  ListableBuilder+Element.swift
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
public extension ListableBuilder where ContentType == AnyItemConvertible {

    static func buildExpression<ElementType:Element>(_ expression: ElementType) -> Component {
        [expression.item()]
    }
    
    static func buildExpression<ElementType:Element>(_ expression: ElementType) -> Component where ElementType:Equatable {
        [expression.item()]
    }
    
    static func buildExpression<ElementType:Element>(_ expression: ElementType) -> Component where ElementType:IsEquivalentContent {
        [expression.item()]
    }
}


public extension ListableOptionalBuilder where ContentType == AnyHeaderFooterConvertible {

    static func buildBlock<ElementType:Element>(_ content: ElementType) -> ContentType {
        return content.headerFooter()
    }
    
    static func buildBlock<ElementType:Element>(_ content: ElementType) -> ContentType where ElementType:Equatable {
        return content.headerFooter()
    }
    
    static func buildBlock<ElementType:Element>(_ content: ElementType) -> ContentType where ElementType:IsEquivalentContent {
        return content.headerFooter()
    }
}
