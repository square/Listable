//
//  Decoration.swift
//  ListableUI
//
//  Created by Goose on 7/24/25.
//

import UIKit


public struct Decoration<Content:DecorationContent> : AnyDecoration
{
    public var content : Content
    
    public var sizing : Sizing
    public var layouts : DecorationLayouts
    
    public typealias OnTap = () -> ()
    public var onTap : OnTap?
    
    public var onDisplay : OnDisplay.Callback?
    public var onEndDisplay : OnEndDisplay.Callback?
    
    public var debuggingIdentifier : String? = nil
    
    internal let reuseIdentifier : ReuseIdentifier<Content>
    
    //
    // MARK: Initialization
    //
    
    public typealias Configure = (inout Decoration) -> ()
    
    public init(
        _ content : Content,
        configure : Configure
    ) {
        self.init(content)
        
        configure(&self)
    }
    
    public init(
        _ content : Content,
        sizing : Sizing? = nil,
        layouts : DecorationLayouts? = nil,
        onTap : OnTap? = nil,
        onDisplay : OnDisplay.Callback? = nil,
        onEndDisplay : OnEndDisplay.Callback? = nil
    ) {
        assertIsValueType(Content.self)
        
        self.content = content
        
        let defaults = self.content.defaultDecorationProperties
        
        self.sizing = sizing ?? defaults.sizing ?? .thatFits(.noConstraint)
        self.layouts = layouts ?? defaults.layouts ?? .init()
        self.onTap = onTap ?? defaults.onTap
        self.onDisplay = onDisplay
        self.onEndDisplay = onEndDisplay
        self.debuggingIdentifier = defaults.debuggingIdentifier
        
        self.reuseIdentifier = ReuseIdentifier.identifier(for: Content.self)
    }
    
    // MARK: AnyDecoration
    
    public var anyContent: Any {
        self.content
    }
    
    public var reappliesToVisibleView: ReappliesToVisibleView {
        self.content.reappliesToVisibleView
    }
    
    // MARK: AnyDecorationConvertible
    
    public func asAnyDecoration() -> AnyDecoration {
        self
    }
    
    // MARK: AnyDecoration_Internal
    
    public func apply(
        to anyView : UIView,
        for reason : ApplyReason,
        with info : ApplyDecorationContentInfo
    ) {
        let view = anyView as! DecorationContentView<Content>
        
        let views = DecorationContentViews<Content>(view: view)
        
        self.content.apply(
            to: views,
            for: reason,
            with: info
        )
    }
        
    public func anyIsEquivalent(to other : AnyDecoration) -> Bool
    {
        guard let other = other as? Decoration<Content> else {
            return false
        }
        
        return self.content.isEquivalent(to: other.content)
    }
    
    public func newPresentationDecorationState(
        kind : SupplementaryKind,
        performsContentCallbacks : Bool
    ) -> Any
    {
        return PresentationState.DecorationState(
            self,
            kind: kind,
            performsContentCallbacks: performsContentCallbacks
        )
    }
}


extension DecorationContent {
    
    /// Identical to `Decoration.init` which takes in a `DecorationContent`,
    /// except you can call this on the `DecorationContent` itself, instead of wrapping it,
    /// to avoid additional nesting, and to hoist your content up in your code.
    ///
    /// ```
    /// Section("id") { section in
    ///     section.decoration = MyDecorationContent(
    ///         backgroundColor: .red
    ///     )
    ///     .with(
    ///         sizing: .thatFits(.noConstraint),
    ///     )
    ///
    /// struct MyDecorationContent : DecorationContent {
    ///    var backgroundColor : UIColor
    ///    ...
    /// }
    /// ```
    public func with(
        sizing : Sizing? = nil,
        layouts : DecorationLayouts? = nil,
        onTap : Decoration<Self>.OnTap? = nil
    ) -> Decoration<Self>
    {
        Decoration(
            self,
            sizing: sizing,
            layouts: layouts,
            onTap: onTap
        )
    }
}


extension Decoration : SignpostLoggable
{
    var signpostInfo : SignpostLoggingInfo {
        SignpostLoggingInfo(
            identifier: self.debuggingIdentifier,
            instanceIdentifier: nil
        )
    }
}
