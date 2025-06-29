//
//  Element+HeaderFooter.swift
//  BlueprintUILists
//
//  Created by Kyle Van Essen on 7/24/22.
//

import BlueprintUI
import ListableUI


// MARK: HeaderFooter / HeaderFooterContent Extensions


extension Element {
    
    /// Ensures that a well-formed error is presented when a non-Equatable or non-LayoutEquivalent element is provided.
    @available(*, unavailable, message: "To be directly added to a List, an Element must conform to Equatable or LayoutEquivalent.")
    public func listHeaderFooter(
        background : @escaping () -> Element? = { nil },
        pressedBackground : @escaping () -> Element? = { nil },
        configure : (inout HeaderFooter<WrappedHeaderFooterContent<Self>>) -> () = { _ in }
    ) -> HeaderFooter<WrappedHeaderFooterContent<Self>> {
        fatalError()
    }
}

/// Ensures that the `Equatable` initializer for `WrappedHeaderFooterContent` is called.
extension Element where Self:Equatable {
    
    public func listHeaderFooter(
        background : @escaping () -> Element? = { nil },
        pressedBackground : @escaping () -> Element? = { nil },
        configure : (inout HeaderFooter<WrappedHeaderFooterContent<Self>>) -> () = { _ in }
    ) -> HeaderFooter<WrappedHeaderFooterContent<Self>> {
        HeaderFooter(
            WrappedHeaderFooterContent(
                represented: self,
                background: background,
                pressedBackground: pressedBackground
            ),
            configure: configure
        )
    }
}


/// Ensures that the `LayoutEquivalent` initializer for `WrappedHeaderFooterContent` is called.
extension Element where Self:LayoutEquivalent {
    
    @_disfavoredOverload
    public func listHeaderFooter(
        background : @escaping () -> Element? = { nil },
        pressedBackground : @escaping () -> Element? = { nil },
        configure : (inout HeaderFooter<WrappedHeaderFooterContent<Self>>) -> () = { _ in }
    ) -> HeaderFooter<WrappedHeaderFooterContent<Self>> {
        HeaderFooter(
            WrappedHeaderFooterContent(
                represented: self,
                background: background,
                pressedBackground: pressedBackground
            ),
            configure: configure
        )
    }
}


public struct WrappedHeaderFooterContent<ElementType:Element> : BlueprintHeaderFooterContent
{
    public let represented : ElementType
    
    private let isEquivalent : (Self, Self) -> Bool
    
    init(
        represented : ElementType,
        background : @escaping () -> Element?,
        pressedBackground : @escaping () -> Element?
    ) where ElementType:Equatable
    {
        self.represented = represented
        
        self.backgroundProvider = background
        self.pressedBackgroundProvider = pressedBackground
        
        self.isEquivalent = {
            $0.represented == $1.represented
        }
    }
    
    init(
        represented : ElementType,
        background : @escaping () -> Element?,
        pressedBackground : @escaping () -> Element?
    ) where ElementType:LayoutEquivalent
    {
        self.represented = represented
        
        self.backgroundProvider = background
        self.pressedBackgroundProvider = pressedBackground
        
        self.isEquivalent = {
            $0.represented.isEquivalent(to: $1.represented)
        }
    }
    
    public func isEquivalent(to other: Self) -> Bool {
        isEquivalent(self, other)
    }
    
    public var elementRepresentation: Element {
        represented
    }
    
    var backgroundProvider : () -> Element? = { nil }
    
    public var background: Element? {
        backgroundProvider()
    }
    
    var pressedBackgroundProvider : () -> Element? = { nil }
    
    public var pressedBackground: Element? {
        pressedBackgroundProvider()
    }
}
