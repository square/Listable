//
//  Element+Item.swift
//  BlueprintUILists
//
//  Created by Kyle Van Essen on 7/24/22.
//

import BlueprintUI
@_spi(ListableInternal)
import ListableUI


// MARK: Item / ItemContent Extensions

extension Element {
    
    /// Converts the given `Element` into a Listable `Item` with the provided ID. You can use this ID
    /// to scroll to or later access the item through the regular list access APIs.
    ///
    /// You many also optionally configure the item, setting its values such as the `onDisplay` callbacks, etc.
    ///
    /// You can also provide a background or selected background via the `background` and `selectedBackground` modifiers.
    ///
    /// ```swift
    /// MyElement(...)
    ///     .listItem(id: "my-provided-id") { item in
    ///         item.insertAndRemoveAnimations = .scaleUp
    ///     }
    ///     .background {
    ///         Box(backgroundColor: ...).inset(...)
    ///     }
    ///     .selectedBackground(.tappable) {
    ///         Box(backgroundColor: ...).inset(...)
    ///     }
    /// ```
    public func listItem(
        id : AnyHashable? = nil,
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


extension Item where Content : _AnyWrappedElementContent {
    
    /// TODO
    public func background(_ provider : @escaping (ApplyItemContentInfo) -> Element?) -> Self {
        var copy = self
        copy.content._backgroundProvider = provider
        return copy
    }
    
    /// TODO
    public func selectedBackground(
        _ selectionStyle : ItemSelectionStyle,
        selectedBackground : @escaping (ApplyItemContentInfo) -> Element?
    ) -> Self {
        var copy = self
        copy.selectionStyle = selectionStyle
        copy.content._backgroundProvider = selectedBackground
        return copy
    }
}


/// Ensures that the `Equatable` initializer for `WrappedElementContent` is called.
extension Element where Self:Equatable {
    
    public func listItem(
        id : AnyHashable? = nil,
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


/// Ensures that the `EquivalentComparable` initializer for `WrappedElementContent` is called.
extension Element where Self:EquivalentComparable {
    
    public func listItem(
        id : AnyHashable? = nil,
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


public struct WrappedElementContent<ElementType:Element> : BlueprintItemContent, _AnyWrappedElementContent
{
    public let identifierValue: AnyHashable?
    
    public let represented : ElementType
    
    private let isEquivalent : (Self, Self) -> Bool
    
    init(
        identifierValue: AnyHashable?,
        represented: ElementType
    ) {
        self.represented = represented
        self.identifierValue = identifierValue
        
        self.isEquivalent = {
            defaultIsEquivalentImplementation($0.represented, $1.represented)
        }
    }
    
    init(
        identifierValue: AnyHashable?,
        represented: ElementType
    ) where ElementType:Equatable {
        self.represented = represented
        self.identifierValue = identifierValue
        
        self.isEquivalent = {
            $0.represented == $1.represented
        }
    }
    
    init(
        identifierValue: AnyHashable?,
        represented: ElementType
    ) where ElementType:EquivalentComparable {
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
    
    public var _backgroundProvider: (ApplyItemContentInfo) -> Element? = { _ in nil }
    
    public func backgroundElement(with info: ApplyItemContentInfo) -> Element? {
        _backgroundProvider(info)
    }
    
    public var _selectedBackgroundProvider: (ApplyItemContentInfo) -> Element? = { _ in nil }
    
    public func selectedBackgroundElement(with info: ApplyItemContentInfo) -> Element? {
        _selectedBackgroundProvider(info)
    }
    
    public var reappliesToVisibleView: ReappliesToVisibleView {
        .ifNotEquivalent
    }
}


public protocol _AnyWrappedElementContent {
 
    var _backgroundProvider : (ApplyItemContentInfo) -> Element? { get set }
    var _selectedBackgroundProvider : (ApplyItemContentInfo) -> Element? { get set }
    
}
