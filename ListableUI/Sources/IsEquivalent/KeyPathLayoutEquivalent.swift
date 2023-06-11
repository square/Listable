//
//  KeyPathLayoutEquivalent.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 5/24/23.
//

import Foundation


/// Used by the list to determine when the content of content has changed; in order to
/// remeasure the content and re-layout the list.
///
/// ## Note
/// If you conform to `Equatable`, your value will receive `LayoutEquivalent`
/// conformance for free.
public protocol KeyPathLayoutEquivalent : LayoutEquivalent {
    
    typealias KeyPaths = [KeyPathLayoutEquivalentKeyPath<Self>]
    typealias Builder = KeyPathLayoutEquivalentBuilder<Self>
    
    ///
    /// Used by the list to determine when the content of content has changed; in order to
    /// remeasure the content and re-layout the list.
    ///
    /// You should return the `KeyPaths` from this method that affect visual appearance
    /// or layout (and in particular, sizing) changes.
    ///
    /// When the values from these `KeyPaths` are not equivalent, it will invalidate
    /// any cached sizing it has stored for the content, and re-measure + re-layout the content.
    ///
    /// ## ⚠️ Important
    /// `isEquivalentKeyPaths` is **not** an identifier check. That is what the `identifierValue`
    /// on your `ItemContent` is for. It is to determine when content has meaningfully changed.
    ///
    /// ## 🤔 Examples & How To
    ///
    /// ```swift
    /// struct MyItemContent : ItemContent, Equatable {
    ///
    ///     var identifierValue : UUID
    ///     var title : String
    ///     var detail : String
    ///     var theme : MyTheme
    ///     var onTapDetail : () -> ()
    ///
    ///     static var isEquivalentKeyPaths : KeyPaths {
    ///         // 🚫 Missing checks for title and detail.
    ///         // If they change, they likely affect sizing,
    ///         // which would result in incorrect item sizing.
    ///
    ///         \.theme
    ///     }
    ///
    ///     static var isEquivalentKeyPaths : KeyPaths {
    ///         // 🚫 Missing check for theme.
    ///         // If the theme changed; its likely that the device's
    ///         // accessibility settings changed; dark mode was enabled,
    ///         // etc. All of these can affect the appearance or sizing
    ///         // of the item.
    ///
    ///         \.title
    ///         \.detail
    ///     }
    ///
    ///    static var isEquivalentKeyPaths : KeyPaths {
    ///         // ✅ Checking all parameters which can affect appearance + layout.
    ///         // 💡 Not checking identifierValue or onTapDetail, since they
    ///         // do not affect appearance + layout.
    ///
    ///         \.theme
    ///         \.title
    ///         \.detail
    ///     }
    /// }
    ///
    /// struct MyItemContent : ItemContent, Equatable {
    ///     // ✅ Nothing else needed!
    ///     // `Equatable` conformance provides `isEquivalent(to:) for free!`
    /// }
    /// ```
    ///
    /// ## Note
    /// If your ``ItemContent`` conforms to ``Equatable``, there is a default
    /// implementation of this method which simply returns `self == other`.
    ///
    @Builder static var isEquivalentKeyPaths : KeyPaths { get }
}


fileprivate var cachedIsEquivalentKeyPaths : [ObjectIdentifier:Any] = [:]

extension KeyPathLayoutEquivalent {
    
    /// Implements `isEquivalent(to:)` based on `isEquivalentKeyPaths`.
    public func isEquivalent(to other: Self) -> Bool {
        
        let keyPaths : KeyPaths = {
            let id = ObjectIdentifier(Self.self)
            
            if let existing = cachedIsEquivalentKeyPaths[id] {
                return existing as! KeyPaths
            } else {
                let new = Self.isEquivalentKeyPaths
                cachedIsEquivalentKeyPaths[id] = new
                return new
            }
        }()
        
        for keyPath in keyPaths {
            if keyPath.compare(self, other) == false {
                return false
            }
        }
        
        return true
    }
}


public struct KeyPathLayoutEquivalentKeyPath<Value> {
    
    let compare : (Value, Value) -> Bool
    
    fileprivate init(_ keyPath : KeyPath<Value, some Equatable>) {
        compare = { lhs, rhs in
            lhs[keyPath: keyPath] == rhs[keyPath: keyPath]
        }
    }
    
    fileprivate init(_ keyPath : KeyPath<Value, some LayoutEquivalent>) {
        compare = { lhs, rhs in
            lhs[keyPath: keyPath].isEquivalent(to: rhs[keyPath: keyPath])
        }
    }
}


@resultBuilder public struct KeyPathLayoutEquivalentBuilder<Value:KeyPathLayoutEquivalent> {
    
    // https://github.com/apple/swift-evolution/blob/main/proposals/0289-result-builders.md
    
    public typealias Component = Value.KeyPaths
    
    public static func buildExpression(
        _ keyPath: KeyPath<Value, some Equatable>
    ) -> Component {
        [.init(keyPath)]
    }
    
    public static func buildExpression(
        _ keyPath: KeyPath<Value, some LayoutEquivalent>
    ) -> Component {
        [.init(keyPath)]
    }
    
    @available(*, unavailable, message: "A KeyPath must conform to Equatable or LayoutEquivalent to be used with `KeyPathLayoutEquivalent`.")
    public static func buildExpression(
        _ keyPath: KeyPath<Value, some Any>
    ) -> Component {
        fatalError()
    }
    
    public static func buildBlock(_ component: Component...) -> Component {
        component.flatMap { $0 }
    }
}
