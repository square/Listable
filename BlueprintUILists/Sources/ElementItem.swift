//
//  ElementItem.swift
//  BlueprintUILists
//
//  Created by Kyle Van Essen on 9/10/20.
//

import ListableUI
import BlueprintUI


///
/// ⚠️ This method is soft-deprecated! Consider using `myElement.listItem(...)` instead.
///
/// Provides a way to create an `Item` for your Blueprint elements without
/// requiring the creation of a new `BlueprintItemContent` struct.
///
/// Most arguments on this method are not required – you must only
/// provide an input, a key path for the backing identifier value, and an element provider.
///
/// ### Note
/// This initializer is helpful if you have to nest an existing element that needs to be used in
/// a single place, without needing to define an entirely new type.
///
/// If your item is to be used in more than one place, it is recommended that you
/// create a `BlueprintItemContent` struct to share logic to avoid duplicate code.
///
/// ### Example
/// ```swift
/// ElementItem(podcast, id: \.name) { lhs, rhs in
///     lhs.value != rhs.value
/// } element: { podcast, info in
///     PodcastElement(podcast: podcast)
/// } background: { podcast, info in
///     Box(...)
/// } selectedBackground: { podcast, info in
///     Box(...)
/// } configure: { item in
///     item.selectionStyle = .tappable
/// }
/// ```
public func ElementItem<Represented, IdentifierValue:Hashable>(
    _ represented : Represented,
    
    id : KeyPath<Represented, IdentifierValue>,
    
    isEquivalent : @escaping (Represented, Represented) -> Bool,

    element : @escaping (Represented, ApplyItemContentInfo) -> Element,
    background : @escaping (Represented, ApplyItemContentInfo) -> Element? = { _, _ in nil },
    selectedBackground : @escaping (Represented, ApplyItemContentInfo) -> Element? = { _, _ in nil },
    
    configure : (inout Item<ElementItemContent<Represented, IdentifierValue>>) -> () = { _ in }
) -> Item<ElementItemContent<Represented, IdentifierValue>>
{
    Item(
        ElementItemContent(
            represented: represented,
            
            idValueKeyPath: id,
            
            isEquivalentProvider: isEquivalent,
            elementProvider: element,
            backgroundProvider: background,
            selectedBackgroundProvider: selectedBackground
        ),
        configure: configure
    )
}


///
/// ⚠️ This method is soft-deprecated! Consider using `myElement.listItem(...)` instead.
/// 
/// Provides a way to create an `Item` for your Blueprint elements without
/// requiring the creation of a new `BlueprintItemContent` struct.
///
/// Most arguments on this method are not required – you must only
/// provide an input, a key path for the backing identifier value, and an element provider.
///
/// ### Note
/// This initializer is helpful if you have to nest an existing element that needs to be used in
/// a single place, without needing to define an entirely new type.
///
/// If your item is to be used in more than one place, it is recommended that you
/// create a `BlueprintItemContent` struct to share logic to avoid duplicate code.
///
/// ### Example
/// ```swift
/// ElementItem(podcast, id: \.name) { podcast, info in
///     PodcastElement(podcast: podcast)
/// } background: { podcast, info in
///     Box(...)
/// } selectedBackground: { podcast, info in
///     Box(...)
/// } configure: { item in
///     item.selectionStyle = .tappable
/// }
/// ```
public func ElementItem<Represented:Equatable, IdentifierValue:Hashable>(
    _ represented : Represented,
    
    id : KeyPath<Represented, IdentifierValue>,

    element : @escaping (Represented, ApplyItemContentInfo) -> Element,
    background : @escaping (Represented, ApplyItemContentInfo) -> Element? = { _, _ in nil },
    selectedBackground : @escaping (Represented, ApplyItemContentInfo) -> Element? = { _, _ in nil },
    
    configure : (inout Item<ElementItemContent<Represented, IdentifierValue>>) -> () = { _ in }
) -> Item<ElementItemContent<Represented, IdentifierValue>>
{
    Item(
        ElementItemContent(
            represented: represented,
            
            idValueKeyPath: id,
            
            isEquivalentProvider: { $0 == $1 },
            elementProvider: element,
            backgroundProvider: background,
            selectedBackgroundProvider: selectedBackground
        ),
        configure: configure
    )
}


/// The `BlueprintItemContent` type that is used to provide
/// a lightweight way to present an `Element`, without needing to provide an entirely
/// new `BlueprintItemContent` type.
public struct ElementItemContent<Represented, IdentifierValue:Hashable> : BlueprintItemContent
{
    public let represented : Represented

    let idValueKeyPath : KeyPath<Represented, IdentifierValue>
    let isEquivalentProvider : (Represented, Represented) -> Bool
    let elementProvider : (Represented, ApplyItemContentInfo) -> Element
    let backgroundProvider : (Represented, ApplyItemContentInfo) -> Element?
    let selectedBackgroundProvider : (Represented, ApplyItemContentInfo) -> Element?
    
    public var identifierValue: IdentifierValue {
        self.represented[keyPath: self.idValueKeyPath]
    }
    
    public func isEquivalent(to other: Self) -> Bool {
        self.isEquivalentProvider(self.represented, other.represented)
    }
    
    public func element(with info: ApplyItemContentInfo) -> Element {
        self.elementProvider(self.represented, info)
    }
    
    public func backgroundElement(with info: ApplyItemContentInfo) -> Element? {
        self.backgroundProvider(self.represented, info)
    }
    
    public func selectedBackgroundElement(with info: ApplyItemContentInfo) -> Element? {
        self.selectedBackgroundProvider(self.represented, info)
    }
}
