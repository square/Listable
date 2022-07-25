//
//  Element+Item.swift
//  BlueprintUILists
//
//  Created by Kyle Van Essen on 7/24/22.
//

import BlueprintUI
import ListableUI


// MARK: Item / ItemContent Extensions

extension Element {
        
    /// Converts the given `Element` into a Listable `Item`. You many also optionally
    /// configure the item, setting its values such as the `onDisplay` callbacks, etc.
    ///
    /// ```swift
    /// MyElement(...)
    ///     .item { item in
    ///         item.insertAndRemoveAnimations = .scaleUp
    ///     }
    /// ```
    ///
    /// ## ⚠️ Performance Considerations
    /// Unless your `Element` conforms to `Equatable` or `IsEquivalentContent`,
    /// it will return `false` for `isEquivalent` for each content update, which can dramatically
    /// hurt performance for longer lists (eg, more than 20 items): it will be re-measured for each content update.
    ///
    /// It is encouraged for these longer lists, you ensure your `Element` conforms to one of these protocols.
    public func item(
        configure : (inout Item<WrappedElementContent<Self, ObjectIdentifier>>) -> () = { _ in }
    ) -> Item<WrappedElementContent<Self, ObjectIdentifier>> {
        Item(
            WrappedElementContent(
                represented: self,
                identifierValue: ObjectIdentifier(Self.Type.self)
            ),
            configure: configure
        )
    }
    
    /// Converts the given `Element` into a Listable `Item` with the provided ID. You can use this ID
    /// to scroll to or later access the item through the regular list access APIs.
    /// You many also optionally configure the item, setting its values such as the `onDisplay` callbacks, etc.
    ///
    /// ```swift
    /// MyElement(...)
    ///     .item(id: "my-provided-id") { item in
    ///         item.insertAndRemoveAnimations = .scaleUp
    ///     }
    /// ```
    ///
    /// ## ⚠️ Performance Considerations
    /// Unless your `Element` conforms to `Equatable` or `IsEquivalentContent`,
    /// it will return `false` for `isEquivalent` for each content update, which can dramatically
    /// hurt performance for longer lists (eg, more than 20 items): it will be re-measured for each content update.
    ///
    /// It is encouraged for these longer lists, you ensure your `Element` conforms to one of these protocols.
    public func item<ID:Hashable>(
        id : ID,
        configure : (inout Item<WrappedElementContent<Self, ID>>) -> () = { _ in }
    ) -> Item<WrappedElementContent<Self, ID>> {
        Item(
            WrappedElementContent(
                represented: self,
                identifierValue: id
            ),
            configure: configure
        )
    }
}


public struct WrappedElementContent<ElementType:Element, IdentifierValue:Hashable> : BlueprintItemContent
{
    public let represented : ElementType

    public let identifierValue: IdentifierValue
    
    public func isEquivalent(to other: Self) -> Bool {
        false
    }
    
    public func element(with info: ApplyItemContentInfo) -> Element {
        represented
    }
}


extension WrappedElementContent where ElementType : Equatable {
    
    public func isEquivalent(to other: Self) -> Bool {
        represented == other.represented
    }
    
    public var reappliesToVisibleView: ReappliesToVisibleView {
        .ifNotEquivalent
    }
}


extension WrappedElementContent where ElementType : IsEquivalentContent {
    
    public func isEquivalent(to other: Self) -> Bool {
        represented.isEquivalent(to: other.represented)
    }
    
    public var reappliesToVisibleView: ReappliesToVisibleView {
        .ifNotEquivalent
    }
}
