//
//  HeaderFooter.swift
//  Listable
//
//  Created by Kyle Van Essen on 8/10/19.
//


public protocol AnyHeaderFooter : AnyHeaderFooter_Internal
{
}

public protocol AnyHeaderFooter_Internal
{
    var layout : HeaderFooterLayout { get }
    
    func apply(to headerFooterView : UIView, reason: ApplyReason)
    
    func anyIsEquivalent(to other : AnyHeaderFooter) -> Bool
    
    func newPresentationHeaderFooterState() -> Any
}


public struct HeaderFooter<Element:HeaderFooterElement> : AnyHeaderFooter
{
    public var element : Element
    
    public var sizing : Sizing
    public var layout : HeaderFooterLayout
    
    public var debuggingIdentifier : String? = nil
    
    internal let reuseIdentifier : ReuseIdentifier<Element>
    
    //
    // MARK: Initialization
    //
    
    public typealias Build = (inout HeaderFooter) -> ()
    
    public init(
        _ element : Element,
        build : Build
        )
    {
        self.init(element)
        
        build(&self)
    }
    
    public init(
        _ element : Element,
        sizing : Sizing = .thatFitsWith(.init(.atLeast(.default))),
        layout : HeaderFooterLayout = HeaderFooterLayout()
    )
    {
        self.element = element
        
        self.sizing = sizing
        self.layout = layout
        
        self.reuseIdentifier = ReuseIdentifier.identifier(for: Element.self)
    }
    
    // MARK: AnyHeaderFooter_Internal
    
    public func apply(to anyView : UIView, reason: ApplyReason)
    {
        let view = anyView as! Element.ContentView
        
        self.element.apply(to: view, reason: reason)
    }
        
    public func anyIsEquivalent(to other : AnyHeaderFooter) -> Bool
    {
        guard let other = other as? HeaderFooter<Element> else {
            return false
        }
        
        return self.element.isEquivalent(to: other.element)
    }
    
    public func newPresentationHeaderFooterState() -> Any
    {
        return PresentationState.HeaderFooterState(self)
    }
}


extension HeaderFooter : SignpostLoggable
{
    var signpostInfo : SignpostLoggingInfo {
        SignpostLoggingInfo(
            identifier: self.debuggingIdentifier,
            instanceIdentifier: nil
        )
    }
}


public struct HeaderFooterLayout : Equatable
{
    public var width : CustomWidth
    
    public init(width : CustomWidth = .default)
    {
        self.width = width
    }
}
