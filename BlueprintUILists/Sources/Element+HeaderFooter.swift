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
    /// ## ⚠️ Performance Considerations
    /// Unless your `Element` conforms to `Equatable` or `IsEquivalentContent`,
    /// it will return `false` for `isEquivalent` for each content update, which can dramatically
    /// hurt performance for longer lists (eg, more than 20 items): it will be re-measured for each content update.
    ///
    /// It is encouraged for these longer lists, you ensure your `Element` conforms to one of these protocols.
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
        
        self.isEquivalent = { _, _ in false }
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

