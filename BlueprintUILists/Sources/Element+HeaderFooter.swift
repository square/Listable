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
    ///     .headerFooter { header in
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
    public func headerFooter(
        configure : (inout HeaderFooter<WrappedHeaderFooterContent<Self>>) -> () = { _ in }
    ) -> HeaderFooter<WrappedHeaderFooterContent<Self>> {
        HeaderFooter(
            WrappedHeaderFooterContent(
                represented: self
            ),
            configure: configure
        )
    }
    
    /// Used by internal Listable methods to  convert type-erased `Element` instances into `Item` instances.
    func toHeaderFooterConvertible() -> AnyHeaderFooterConvertible {
        /// We use `type(of:)` to ensure we get the actual type, not just `Element`.
        WrappedHeaderFooterContent(
            represented: self
        )
    }
}


public struct WrappedHeaderFooterContent<ElementType:Element> : BlueprintHeaderFooterContent
{
    public let represented : ElementType
    
    public func isEquivalent(to other: Self) -> Bool {
        false
    }
    
    public var elementRepresentation: Element {
        represented
    }
}


extension WrappedHeaderFooterContent where ElementType : Equatable {
    
    public func isEquivalent(to other: Self) -> Bool {
        represented == other.represented
    }
    
    public var reappliesToVisibleView: ReappliesToVisibleView {
        .ifNotEquivalent
    }
}


extension WrappedHeaderFooterContent where ElementType : IsEquivalentContent {
    
    public func isEquivalent(to other: Self) -> Bool {
        represented.isEquivalent(to: other.represented)
    }
    
    public var reappliesToVisibleView: ReappliesToVisibleView {
        .ifNotEquivalent
    }
}
