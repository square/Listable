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
    /// You may also provide a background and pressed background as well as tap actions.
    ///
    /// ```swift
    /// MyElement(...)
    ///     .listHeaderFooter { header in
    ///         header.onTap = { ... }
    ///     }
    ///     .background {
    ///         Box(backgroundColor: ...).inset(...)
    ///     }
    ///     .onTap {
    ///         // Handle the tap event.
    ///     } show: {
    ///         Box(backgroundColor: ...).inset(...)
    ///     }
    /// ```
    public func listHeaderFooter(
        configure : (inout HeaderFooter<WrappedHeaderFooterContent<Self>>) -> () = { _ in }
    ) -> HeaderFooter<WrappedHeaderFooterContent<Self>> {
        HeaderFooter(
            WrappedHeaderFooterContent(represented: self),
            configure: configure
        )
    }
}


extension HeaderFooter where Content : _AnyWrappedHeaderFooterContent {
    
    /// TODO
    public func background(_ provider : @escaping () -> Element?) -> Self {
        var copy = self
        copy.content._backgroundProvider = provider
        return copy
    }
    
    /// TODO
    public func onTap(
        _ onTap : @escaping () -> (),
        show background : @escaping () -> Element
    ) -> Self {
        var copy = self
        copy.onTap = onTap
        copy.content._backgroundProvider = background
        return copy
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


/// Ensures that the `EquivalentComparable` initializer for `WrappedHeaderFooterContent` is called.
extension Element where Self:EquivalentComparable {
    
    public func listHeaderFooter(
        configure : (inout HeaderFooter<WrappedHeaderFooterContent<Self>>) -> () = { _ in }
    ) -> HeaderFooter<WrappedHeaderFooterContent<Self>> {
        HeaderFooter(
            WrappedHeaderFooterContent(represented: self),
            configure: configure
        )
    }
}


public struct WrappedHeaderFooterContent<ElementType:Element> : BlueprintHeaderFooterContent, _AnyWrappedHeaderFooterContent
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
    
    init(represented : ElementType) where ElementType:EquivalentComparable {
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
    
    public var _backgroundProvider : () -> Element? = { nil }
    
    public var background: Element? {
        _backgroundProvider()
    }
    
    public var _pressedBackgroundProvider : () -> Element? = { nil }
    
    public var pressedBackground: Element? {
        _pressedBackgroundProvider()
    }
    
    public var reappliesToVisibleView: ReappliesToVisibleView {
        .ifNotEquivalent
    }
}


public protocol _AnyWrappedHeaderFooterContent {
 
    var _backgroundProvider : () -> Element? { get set }
    var _pressedBackgroundProvider : () -> Element? { get set }
    
}
