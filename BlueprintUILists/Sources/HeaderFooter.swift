//
//  HeaderFooter.swift
//  BlueprintUILists
//
//  Created by Kyle Van Essen on 10/9/20.
//

import ListableUI
import BlueprintUI


extension HeaderFooter
{
    ///
    /// Provides a way to create a `HeaderFooter` for your Blueprint elements without
    /// requiring the creation of a new `BlueprintHeaderFooterContent` struct.
    ///
    /// Most arguments on this method are not required – you must only
    /// provide an input and an element provider.
    ///
    /// Note
    /// ----
    /// This initializer is helpful if you have to nest an existing element that needs to be used in
    /// a single place, without needing to define an entirely new type.
    ///
    /// If your header or footer is to be used in more than one place, it is recommended that you
    /// create a `BlueprintHeaderFooterContent` struct to share logic to avoid duplicate code.
    ///
    /// Example
    /// -------
    /// ```
    /// section.header = HeaderFooter(album) { lhs, rhs in
    ///     lhs.value != rhs.value
    /// }, element: { album in
    ///     AlbumElement(...)
    /// }, background: { album in
    ///     ...
    /// }, pressedBackground: album in
    ///     ...
    /// }, configure: { header in
    ///     ...
    /// }
    /// ```
    public init<Represented>(
        _ representing : Represented,
        
        isEquivalent : @escaping (Represented, Represented) -> Bool,
        
        element : @escaping (Represented) -> Element,
        background : @escaping (Represented) -> Element? = { _ in nil },
        pressedBackground : @escaping (Represented) -> Element? = { _ in nil },
        
        configure : (inout HeaderFooter<BlueprintHeaderFooterContentWrapper<Represented>>) -> () = { _ in }
        
    ) where Content == BlueprintHeaderFooterContentWrapper<Represented>
    {
        self.init(
            BlueprintHeaderFooterContentWrapper<Represented>(
                representing: representing,
                isEquivalentProvider: isEquivalent,
                elementProvider: element,
                backgroundProvider: background,
                pressedBackgroundProvider: pressedBackground
            ),
            configure: configure
        )
    }
    
    ///
    /// Provides a way to create a `HeaderFooter` for your Blueprint elements without
    /// requiring the creation of a new `BlueprintHeaderFooterContent` struct.
    ///
    /// Most arguments on this method are not required – you must only
    /// provide an input and an element provider.
    ///
    /// Note
    /// ----
    /// This initializer is helpful if you have to nest an existing element that needs to be used in
    /// a single place, without needing to define an entirely new type.
    ///
    /// If your header or footer is to be used in more than one place, it is recommended that you
    /// create a `BlueprintHeaderFooterContent` struct to share logic to avoid duplicate code.
    ///
    /// Example
    /// -------
    /// ```
    /// section.header = HeaderFooter(album) { album in
    ///     AlbumElement(...)
    /// }, background: { album in
    ///     ...
    /// }, pressedBackground: album in
    ///     ...
    /// }, configure: { header in
    ///     ...
    /// }
    /// ```
    public init<Represented>(
        _ representing : Represented,
                        
        element : @escaping (Represented) -> Element,
        background : @escaping (Represented) -> Element? = { _ in nil },
        pressedBackground : @escaping (Represented) -> Element? = { _ in nil },
        
        configure : (inout HeaderFooter<BlueprintHeaderFooterContentWrapper<Represented>>) -> () = { _ in }
        
    ) where Content == BlueprintHeaderFooterContentWrapper<Represented>, Represented:Equatable
    {
        self.init(
            BlueprintHeaderFooterContentWrapper<Represented>(
                representing: representing,
                isEquivalentProvider: { $0 == $1 },
                elementProvider: element,
                backgroundProvider: background,
                pressedBackgroundProvider: pressedBackground
            ),
            configure: configure
        )
    }
}


/// The `BlueprintHeaderFooterContent` type that is used to provide
/// a lightweight way to present an `Element`, without needing to provide an entirely
/// new `BlueprintHeaderFooterContent` type.
public struct BlueprintHeaderFooterContentWrapper<Represented> : BlueprintHeaderFooterContent
{
    public let representing : Represented

    let isEquivalentProvider : (Represented, Represented) -> Bool
    let elementProvider : (Represented) -> Element
    let backgroundProvider : (Represented) -> Element?
    let pressedBackgroundProvider : (Represented) -> Element?
    
    public func isEquivalent(to other: Self) -> Bool {
        self.isEquivalentProvider(self.representing, other.representing)
    }
    
    public var elementRepresentation : Element {
        self.elementProvider(self.representing)
    }
    
    public var background : Element? {
        self.backgroundProvider(self.representing)
    }
    
    public var pressedBackground : Element? {
        self.pressedBackgroundProvider(self.representing)
    }
}
