//
//  ContentContext.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 6/10/22.
//

import Foundation

/// An `Equatable` value which represents the overall context for all content presented in a list.
///
/// Eg, you might pass a theme here, the traits for your screen (eg, dark mode, a11y settings, etc), or
/// any other value which when changed, should cause the entire list to re-render.
///
/// If the `ContentContext` changes across list renders, all list measurements will be thrown out
/// and re-measured during the next render pass.
///
/// ```
/// listView.content.context = .init(
///     MyTraits(textSize: .medium)
/// )
///
/// // Changing to large will cause the list to re-render all contents.
/// listView.content.context = .init(
///     MyTraits(textSize: .large)
/// )
/// ```
public struct ContentContext: Equatable {
    private let value: Any
    private let isEqual: (Any) -> Bool

    /// Creates a new context with the provided `Equatable` value.
    public init<Value: Equatable>(_ value: Value) {
        self.value = value
        isEqual = { other in
            guard let other = other as? Value else { return false }

            return value == other
        }
    }

    public static func == (lhs: ContentContext, rhs: ContentContext) -> Bool {
        lhs.isEqual(rhs.value)
    }
}
