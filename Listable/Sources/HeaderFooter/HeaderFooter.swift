//
//  HeaderFooter.swift
//  Listable
//
//  Created by Kyle Van Essen on 8/10/19.
//


public protocol AnyHeaderFooter : AnyHeaderFooter_Internal
{
    var sizing : Sizing { get set }
    var layout : HeaderFooterLayout { get set }
}

public protocol AnyHeaderFooter_Internal
{
    var layout : HeaderFooterLayout { get }
    
    func apply(to headerFooterView : UIView, reason: ApplyReason)
    
    func anyIsEquivalent(to other : AnyHeaderFooter) -> Bool
    
    func newPresentationHeaderFooterState() -> Any
}


public typealias Header<Content:HeaderFooterContent> = HeaderFooter<Content>
public typealias Footer<Content:HeaderFooterContent> = HeaderFooter<Content>

public struct HeaderFooter<Content:HeaderFooterContent> : AnyHeaderFooter
{
    public var content : Content
    
    public var sizing : Sizing
    public var layout : HeaderFooterLayout
    
    public typealias OnTap = (Content) -> ()
    public var onTap : OnTap?
    
    public var debuggingIdentifier : String? = nil
    
    internal let reuseIdentifier : ReuseIdentifier<Content>
    
    //
    // MARK: Initialization
    //
    
    public typealias Build = (inout HeaderFooter) -> ()
    
    public init(
        _ content : Content,
        build : Build
    ) {
        self.init(content)
        
        build(&self)
    }
    
    public init(
        _ content : Content,
        sizing : Sizing? = nil,
        layout : HeaderFooterLayout? = nil,
        onTap : OnTap? = nil
    ) {
        self.content = content
        
        if let sizing = sizing {
            self.sizing = sizing
        } else if let sizing = content.defaultProperties.sizing {
            self.sizing = sizing
        } else {
            self.sizing = .thatFits(.init(.atLeast(.default)))
        }
        
        if let layout = layout {
            self.layout = layout
        } else if let layout = content.defaultProperties.layout {
            self.layout = layout
        } else {
            self.layout = HeaderFooterLayout()
        }
        
        self.onTap = onTap
        
        self.reuseIdentifier = ReuseIdentifier.identifier(for: Content.self)
    }
    
    // MARK: AnyHeaderFooter_Internal
    
    public func apply(to anyView : UIView, reason: ApplyReason)
    {
        let view = anyView as! HeaderFooterContentView<Content>
        
        let views = HeaderFooterContentViews<Content>(
            content: view.content,
            background: view.background,
            pressed: view.pressedBackground
        )
        
        self.content.apply(to: views, reason: reason)
    }
        
    public func anyIsEquivalent(to other : AnyHeaderFooter) -> Bool
    {
        guard let other = other as? HeaderFooter<Content> else {
            return false
        }
        
        return self.content.isEquivalent(to: other.content)
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
        
    public init(
        width : CustomWidth = .default
    ) {
        self.width = width
    }
}


/// Allows specifying default properties to apply to a header/footer when it is initialized,
/// if those values are not provided to the initializer.
/// 
/// Only non-nil values are used – if you do not want to provide a default value,
/// simply leave the property nil.
///
/// The order of precedence used when assigning values is:
/// 1) The value passed to the initializer.
/// 2) The value from `defaultProperties` on the contained `HeaderFooterContent`, if non-nil.
/// 3) A standard, default value.
public struct DefaultHeaderFooterProperties<Content:HeaderFooterContent>
{
    public var sizing : Sizing?
    public var layout : HeaderFooterLayout?
    
    public init(
        sizing : Sizing? = nil,
        layout : HeaderFooterLayout? = nil
    ) {
        self.sizing = sizing
        self.layout = layout
    }
}
