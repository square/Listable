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
    
    /// Required by every result builder to build combined results from statement blocks.
    @_disfavoredOverload static func buildBlock(_ components: [Element]...) -> Component {
        components.reduce(into: []) { $0 += $1.map { $0.toAnyItemConvertible() } }
    }

    /// If declared, provides contextual type information for statement expressions to translate them into partial results.
    @_disfavoredOverload static func buildExpression(_ expression: Element) -> Component {
        [expression.toAnyItemConvertible()]
    }
    
    /// If declared, provides contextual type information for statement expressions to translate them into partial results.
    @_disfavoredOverload static func buildExpression(_ expression: [Element]) -> Component {
        expression.map { $0.toAnyItemConvertible() }
    }

    /// Enables support for `if` statements that do not have an `else`.
    @_disfavoredOverload static func buildOptional(_ component: [Element]?) -> Component {
        component?.map { $0.toAnyItemConvertible() } ?? []
    }

    /// With buildEither(second:), enables support for 'if-else' and 'switch' statements by folding conditional results into a single result.
    @_disfavoredOverload static func buildEither(first component: [Element]) -> Component {
        component.map { $0.toAnyItemConvertible() }
    }

    /// With buildEither(first:), enables support for 'if-else' and 'switch' statements by folding conditional results into a single result.
    @_disfavoredOverload static func buildEither(second component: [Element]) -> Component {
        component.map { $0.toAnyItemConvertible() }
    }

    /// Enables support for 'for..in' loops by combining the results of all iterations into a single result.
    @_disfavoredOverload static func buildArray(_ components: [[Element]]) -> Component {
        components.flatMap { $0.map { $0.toAnyItemConvertible() } }
    }

    /// If declared, this will be called on the partial result of an `if #available` block to allow the result builder to erase type information.
    @_disfavoredOverload static func buildLimitedAvailability(_ component: [Element]) -> Component {
        component.map { $0.toAnyItemConvertible() }
    }

    /// If declared, this will be called on the partial result from the outermost block statement to produce the final returned result.
    @_disfavoredOverload static func buildFinalResult(_ component: [Element]) -> FinalResult {
        component.map { $0.toAnyItemConvertible() }
    }
}


public extension ListableOptionalBuilder where ContentType == AnyHeaderFooterConvertible {
    
    static func buildBlock(_ content: Element) -> ContentType {
        return content.toHeaderFooterConvertible()
    }
}

