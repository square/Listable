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
    public func item(
        id : AnyHashable = ObjectIdentifier(Self.Type.self),
        configure : (inout Item<WrappedElementContent<Self>>) -> () = { _ in }
    ) -> Item<WrappedElementContent<Self>> {
        Item(
            WrappedElementContent(
                identifierValue: id,
                represented: self
            ),
            configure: configure
        )
    }
}


/// Ensures that the `Equatable` initializer for `WrappedElementContent` is called.
extension Element where Self:Equatable {
    
    public func item(
        id : AnyHashable = ObjectIdentifier(Self.Type.self),
        configure : (inout Item<WrappedElementContent<Self>>) -> () = { _ in }
    ) -> Item<WrappedElementContent<Self>> {
        Item(
            WrappedElementContent(
                identifierValue: id,
                represented: self
            ),
            configure: configure
        )
    }
}


/// Ensures that the `IsEquivalentContent` initializer for `WrappedElementContent` is called.
extension Element where Self:IsEquivalentContent {
    
    public func item(
        id : AnyHashable = ObjectIdentifier(Self.Type.self),
        configure : (inout Item<WrappedElementContent<Self>>) -> () = { _ in }
    ) -> Item<WrappedElementContent<Self>> {
        Item(
            WrappedElementContent(
                identifierValue: id,
                represented: self
            ),
            configure: configure
        )
    }
}


public struct WrappedElementContent<ElementType:Element> : BlueprintItemContent
{
    public let identifierValue: AnyHashable
    
    public let represented : ElementType
    
    private let isEquivalent : (Self, Self) -> Bool
    
    init(
        identifierValue: AnyHashable,
        represented: ElementType
    ) {
        self.represented = represented
        self.identifierValue = identifierValue
        
        self.isEquivalent = { _, _ in false }
    }
    
    init(
        identifierValue: AnyHashable,
        represented: ElementType
    ) where ElementType:Equatable {
        self.represented = represented
        self.identifierValue = identifierValue
        
        self.isEquivalent = {
            $0.represented == $1.represented
        }
    }
    
    init(
        identifierValue: AnyHashable,
        represented: ElementType
    ) where ElementType:IsEquivalentContent {
        self.represented = represented
        self.identifierValue = identifierValue
        
        self.isEquivalent = {
            $0.represented.isEquivalent(to: $1.represented)
        }
    }
    
    public func isEquivalent(to other: Self) -> Bool {
        isEquivalent(self, other)
    }
    
    public func element(with info: ApplyItemContentInfo) -> Element {
        represented
    }
    
    public var reappliesToVisibleView: ReappliesToVisibleView {
        .ifNotEquivalent
    }
}
