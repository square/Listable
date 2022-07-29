//
//  Element+HeaderFooter.swift
//  BlueprintUILists
//
//  Created by Kyle Van Essen on 7/24/22.
//

import BlueprintUI
@_spi(ListableInternal)
import ListableUI


// MARK: HeaderFooter / HeaderFooterContent Extensions


extension Element {
        
    /// Converts the given `Element` into a Listable `HeaderFooter`. You many also optionally
    /// configure the header / footer, setting its values such as the `onTap` callbacks, etc.
    ///
    /// ```swift
    /// MyElement(...)
    ///     .listHeaderFooter { header in
    ///         header.onTap = { ... }
    ///     }
    /// ```
    ///
    public func listHeaderFooter(
        configure : (inout HeaderFooter<WrappedHeaderFooterContent<Self>>) -> () = { _ in }
    ) -> HeaderFooter<WrappedHeaderFooterContent<Self>> {
        HeaderFooter(
            WrappedHeaderFooterContent(represented: self),
            configure: configure
        )
    }
}


/// Ensures that the `Equatable` initializer for `WrappedHeaderFooterContent` is called.
extension Element where Self:Equatable {
    
    public func listHeaderFooter(
        configure : (inout HeaderFooter<WrappedHeaderFooterContent<Self>>) -> () = { _ in }
    ) -> HeaderFooter<WrappedHeaderFooterContent<Self>> {
        HeaderFooter(
            WrappedHeaderFooterContent(represented: self),
            configure: configure
        )
    }
}


/// Ensures that the `IsEquivalentContent` initializer for `WrappedHeaderFooterContent` is called.
extension Element where Self:IsEquivalentContent {
    
    public func listHeaderFooter(
        configure : (inout HeaderFooter<WrappedHeaderFooterContent<Self>>) -> () = { _ in }
    ) -> HeaderFooter<WrappedHeaderFooterContent<Self>> {
        HeaderFooter(
            WrappedHeaderFooterContent(represented: self),
            configure: configure
        )
    }
}


public struct WrappedHeaderFooterContent<ElementType:Element> : BlueprintHeaderFooterContent
{
    public let represented : ElementType
    
    private let isEquivalent : (Self, Self) -> Bool
    
    init(represented : ElementType) {
        self.represented = represented
        
        self.isEquivalent = {
            defaultIsEquivalentImplementation($0.represented, $1.represented)
        }
    }
    
    init(represented : ElementType) where ElementType:Equatable {
        self.represented = represented
        
        self.isEquivalent = {
            $0.represented == $1.represented
        }
    }
    
    init(represented : ElementType) where ElementType:IsEquivalentContent {
        self.represented = represented
        
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
}

