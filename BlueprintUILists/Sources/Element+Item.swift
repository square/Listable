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
    ///     .listItem(id: "my-provided-id", selection: .tappable) { item in
    ///         item.insertAndRemoveAnimations = .scaleUp
    ///     } background: { _ in
    ///         Box(backgroundColor: ...).inset(...)
    ///     } selectedBackground: { _ in
    ///         Box(backgroundColor: ...).inset(...)
    ///     }
    /// ```
    public func listItem(
        id : AnyHashable? = nil,
        selection: ItemSelectionStyle = .notSelectable,
        background : @escaping (ApplyItemContentInfo) -> Element? = { _ in nil },
        selectedBackground : @escaping (ApplyItemContentInfo) -> Element? = { _ in nil },
        configure : (inout Item<WrappedElementContent<Self>>) -> () = { _ in }
    ) -> Item<WrappedElementContent<Self>> {
        Item(
            WrappedElementContent(
                identifierValue: id,
                represented: self,
                background: background,
                selectedBackground: selectedBackground
            ),
            configure: {
                $0.selectionStyle = selection
                
                configure(&$0)
            }
        )
    }
}


/// Ensures that the `Equatable` initializer for `WrappedElementContent` is called.
extension Element where Self:Equatable {
    
    public func listItem(
        id : AnyHashable? = nil,
        selection: ItemSelectionStyle = .notSelectable,
        background : @escaping (ApplyItemContentInfo) -> Element? = { _ in nil },
        selectedBackground : @escaping (ApplyItemContentInfo) -> Element? = { _ in nil },
        configure : (inout Item<WrappedElementContent<Self>>) -> () = { _ in }
    ) -> Item<WrappedElementContent<Self>> {
        Item(
            WrappedElementContent(
                identifierValue: id,
                represented: self,
                background: background,
                selectedBackground: selectedBackground
            ),
            configure: {
                $0.selectionStyle = selection
                
                configure(&$0)
            }
        )
    }
}


/// Ensures that the `EquivalentComparable` initializer for `WrappedElementContent` is called.
extension Element where Self:EquivalentComparable {
    
    public func listItem(
        id : AnyHashable? = nil,
        selection: ItemSelectionStyle = .notSelectable,
        background : @escaping (ApplyItemContentInfo) -> Element? = { _ in nil },
        selectedBackground : @escaping (ApplyItemContentInfo) -> Element? = { _ in nil },
        configure : (inout Item<WrappedElementContent<Self>>) -> () = { _ in }
    ) -> Item<WrappedElementContent<Self>> {
        Item(
            WrappedElementContent(
                identifierValue: id,
                represented: self,
                background: background,
                selectedBackground: selectedBackground
            ),
            configure: {
                $0.selectionStyle = selection
                
                configure(&$0)
            }
        )
    }
}


public struct WrappedElementContent<ElementType:Element> : BlueprintItemContent
{
    public let identifierValue: AnyHashable?
    
    public let represented : ElementType
    
    private let isEquivalent : (Self, Self) -> Bool
    
    init(
        identifierValue: AnyHashable?,
        represented: ElementType,
        background : @escaping (ApplyItemContentInfo) -> Element?,
        selectedBackground : @escaping (ApplyItemContentInfo) -> Element?
    ) {
        self.represented = represented
        self.identifierValue = identifierValue
        
        self.backgroundProvider = background
        self.selectedBackgroundProvider = selectedBackground
        
        self.isEquivalent = {
            defaultIsEquivalentImplementation($0.represented, $1.represented)
        }
    }
    
    init(
        identifierValue: AnyHashable?,
        represented: ElementType,
        background : @escaping (ApplyItemContentInfo) -> Element?,
        selectedBackground : @escaping (ApplyItemContentInfo) -> Element?
    ) where ElementType:Equatable
    {
        self.represented = represented
        self.identifierValue = identifierValue
        
        self.backgroundProvider = background
        self.selectedBackgroundProvider = selectedBackground
        
        self.isEquivalent = {
            $0.represented == $1.represented
        }
    }
    
    init(
        identifierValue: AnyHashable?,
        represented: ElementType,
        background : @escaping (ApplyItemContentInfo) -> Element?,
        selectedBackground : @escaping (ApplyItemContentInfo) -> Element?
    ) where ElementType:EquivalentComparable
    {
        self.represented = represented
        self.identifierValue = identifierValue
        
        self.backgroundProvider = background
        self.selectedBackgroundProvider = selectedBackground
        
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
    
    var backgroundProvider: (ApplyItemContentInfo) -> Element?
    
    public func backgroundElement(with info: ApplyItemContentInfo) -> Element? {
        backgroundProvider(info)
    }
    
    var selectedBackgroundProvider: (ApplyItemContentInfo) -> Element?
    
    public func selectedBackgroundElement(with info: ApplyItemContentInfo) -> Element? {
        selectedBackgroundProvider(info)
    }
    
    public var reappliesToVisibleView: ReappliesToVisibleView {
        .ifNotEquivalent
    }
}
