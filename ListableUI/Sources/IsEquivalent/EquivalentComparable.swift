//
//  EquivalentComparable.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 11/28/21.
//

import Foundation


/// Used by the list to determine when the content of content has changed; in order to
/// remeasure the content and re-layout the list.
///
/// ## Note
/// You should rarely need to implement ``EquivalentComparable/isEquivalent(to:)-15tcq``
/// yourself. By default, Listable will...
/// - For regular objects, compare all `Equatable` properties on your object to see if they changed.
/// - For `Equatable` objects, check to see if the object is equal.
///
/// If you do need to implement this method yourself (eg, your object has no equatable properties,
/// or cannot conform to `Equatable`, see ``EquivalentComparable/isEquivalent(to:)-15tcq``
/// for a full discussion of correct (and incorrect) implementations.
///
public protocol EquivalentComparable {
    
    ///
    /// Used by the list to determine when the content of content has changed; in order to
    /// remeasure the content and re-layout the list.
    ///
    /// You should return `false` from this method when any values within your content that
    /// affects visual appearance or layout (and in particular, sizing) changes. When the list
    /// receives `false` back from this method, it will invalidate any cached sizing it has stored
    /// for the content, and re-measure + re-layout the content.
    ///
    /// ## ⚠️ Important
    /// `isEquivalent(to:)` is **not** an identifier check. That is what the `identifierValue`
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
    ///     func isEquivalent(to other : MyItemContent) -> Bool {
    ///         // 🚫 Missing checks for title and detail.
    ///         // If they change, they likely affect sizing,
    ///         // which would result in incorrect item sizing.
    ///
    ///         self.theme == other.theme
    ///     }
    ///
    ///     func isEquivalent(to other : MyItemContent) -> Bool {
    ///         // 🚫 Missing check for theme.
    ///         // If the theme changed; its likely that the device's
    ///         // accessibility settings changed; dark mode was enabled,
    ///         // etc. All of these can affect the appearance or sizing
    ///         // of the item.
    ///
    ///         self.title == other.title &&
    ///         self.detail == other.detail
    ///     }
    ///
    ///     func isEquivalent(to other : MyItemContent) -> Bool {
    ///         // ✅ Checking all parameters which can affect appearance + layout.
    ///         // 💡 Not checking identifierValue or onTapDetail, since they do not affect appearance + layout.
    ///
    ///         self.theme == other.theme &&
    ///         self.title == other.title &&
    ///         self.detail == other.detail
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
    func isEquivalent(to other : Self) -> Bool
}


public extension EquivalentComparable
{
    /// Our default implementation compares the `Equatable` properties of the
    /// provided `Element` to approximate an `isEquivalent` or `Equatable` implementation.
    /// 
    func isEquivalent(to other : Self) -> Bool {
        defaultIsEquivalentImplementation(self, other)
    }
}


public extension EquivalentComparable where Self:Equatable
{
    /// If your content is `Equatable`, `isEquivalent` is based on the `Equatable` implementation.
    func isEquivalent(to other : Self) -> Bool {
        self == other
    }
}


@_spi(ListableInternal)
/// Our default implementation compares the `Equatable` properties of the
/// provided `Element` to approximate an `isEquivalent` or `Equatable` implementation.
public func defaultIsEquivalentImplementation<Value>(_ lhs : Value, _ rhs : Value) -> Bool {
    let result = areEquatablePropertiesEqual(lhs, rhs)
    
    switch result {
    case .equal:
        return true
        
    case .notEqual:
        return false
        
    case .hasNoFields:
        return true
        
    case .error(let error):
        
        switch error {
        case .noEquatableProperties:
            assertionFailure(
                """
                FAILURE: The default `isEquivalent(to:)` implementation could not find any `Equatable` properties \
                on \(Value.self). In release versions, `isEquivalent(to:)` will always return false, which \
                will affect performance. You should implement `isEquivalent(to:)` and check the relevant \
                sub-properties to provide proper conformance:
                
                ```
                func isEquivalent(to other : Self) -> Bool {
                    myVar.subProperty == other.myVar.subProperty && ...
                }
                ```
                """
            )
        }
        
        return false
    }
}
