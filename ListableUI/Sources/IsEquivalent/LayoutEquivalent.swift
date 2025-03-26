//
//  LayoutEquivalent.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 11/28/21.
//

import Foundation


/// Used by the list to determine when the content of content has changed; in order to
/// remeasure the content and re-layout the list.
///
/// ## Note
/// If you conform to `Equatable`, your value will receive `LayoutEquivalent`
/// conformance for free. If you need to implement `LayoutEquivalent` manually,
/// consider using `KeyPathLayoutEquivalent` as a more declarative way to denote
/// which key paths should be used in the `isEquivalent(to:)` comparison.
public protocol LayoutEquivalent {
    
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


public extension LayoutEquivalent where Self:Equatable
{
    /// If your content is `Equatable`, `isEquivalent` is based on the `Equatable` implementation.
    func isEquivalent(to other : Self) -> Bool {
        self == other
    }
}
