//
//  ReappliesToVisibleView.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 6/3/21.
//

import Foundation

/// A rule to determine when an ``ItemContent`` or ``HeaderFooterContent`` should be re-applied
/// to the visible view currently representing the content on screen. If the content is not on
/// screen, then no application is done regardless of the rule (because there is no view).
///
/// The default value is ``ReappliesToVisibleView/always``.  You may want to change the value to
/// ``ReappliesToVisibleView/ifNotEquivalent`` if applying your content is expensive. However,
/// keep in mind that your `isEquivalent(to:)` method will then need to check any potentially embedded references
/// to objects, eg references in a callback closure, to ensure a reference does not become out of date:
///
/// ```
///  struct MyContent : BlueprintItemContent {
///
///     var theme : MyTheme
///     var title : String
///     var myController : MyController
///
///     func element(with info : ApplyItemContentInfo) -> Element {
///         MyLabel(text: self.title, style: theme.labelStyle)
///         .inset(uniform: 20.0)
///         .onLongPress {
///             myController.didLongPress()
///         }
///     }
///
///     func isEquivalent(to other : Self) -> Bool {
///         theme == other.theme &&
///         title == other.title &&
///         myController === other.myController
///     }
///  }
/// ```
///
/// ### Note
/// When using `.ifNotEquivalent` it is not recommended that your content holds onto closures
/// directly – there is no way for you to check them for equivalency, and thus, only the `.always`
/// application method will be correct. Instead, model callbacks explicitly by taking in an object or
/// class-bound protocol that you can then perform callbacks on, so you can compare the identity of the object.
///
/// Further, for tappable items in a list, leverage ``Item/onSelect-swift.property`` on your `Item`,
/// instead of implementing tappable items manually (which is a common source of callback closures in item content).
///
public enum ReappliesToVisibleView {
    /// The visible view will always be re-applied during updates, regardless of the result of ``ItemContent/isEquivalent(to:)``.
    case always

    /// The visible view will only have its contents re-applied during updates if ``ItemContent/isEquivalent(to:)`` returns false.
    case ifNotEquivalent

    func shouldReapply(comparing other: Self, isEquivalent: Bool) -> Bool {
        switch self {
        case .always:
            return true

        case .ifNotEquivalent:
            switch other {
            case .always:
                return true

            case .ifNotEquivalent:
                return isEquivalent == false
            }
        }
    }
}
