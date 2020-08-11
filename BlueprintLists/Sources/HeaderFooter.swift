//
//  HeaderFooter.swift
//  BlueprintLists
//
//  Created by Kyle Van Essen on 10/22/19.
//

import BlueprintUI
import Listable


public typealias BlueprintHeaderContent = BlueprintHeaderFooterContent
public typealias BlueprintFooterContent = BlueprintHeaderFooterContent


public protocol BlueprintHeaderFooterContent : HeaderFooterContent
where
    ContentView == BlueprintView,
    BackgroundView == BlueprintView,
    PressedBackgroundView == BlueprintView
{
    //
    // MARK: Creating Blueprint Element Representations
    //
    
    /// Required. Create and return the Blueprint element used to represent the content.
    var elementRepresentation : Element { get }
    
    /// Optional. Create and return the Blueprint element used to represent the background of the content.
    /// You usually provide this method alongside `pressedBackground`, if your content
    /// supports an `onTap` handler.
    ///
    /// Note
    /// ----
    /// The default implementation of this method returns nil, and provides no background.
    ///
    var background : Element? { get }
    
    /// Optional. Create and return the Blueprint element used to represent the background of the content when it is pressed.
    /// You usually provide this method alongside `background`, if your content supports an `onTap` handler.
    ///
    /// Note
    /// ----
    /// The default implementation of this method returns nil, and provides no selected background.
    ///
    var pressedBackground : Element? { get }
}


public extension BlueprintHeaderFooterContent
{
    //
    // MARK: BlueprintHeaderFooterContent
    //
    
    var background : Element? {
        nil
    }
    
    var pressedBackground : Element? {
        nil
    }
    
    //
    // MARK: HeaderFooterContent
    //
    
    func apply(to views: HeaderFooterContentViews<Self>, reason: ApplyReason)
    {
        views.content.element = self.elementRepresentation
        views.background.element = self.background
        views.pressed.element = self.pressedBackground
    }
    
    static func createReusableContentView(frame: CGRect) -> ContentView
    {
        let view = BlueprintView(frame: frame)
        view.backgroundColor = .clear
        
        return view
    }
    
    static func createReusableBackgroundView(frame: CGRect) -> BackgroundView
    {
        let view = BlueprintView(frame: frame)
        view.backgroundColor = .clear
        
        return view
    }
    
    static func createReusablePressedBackgroundView(frame: CGRect) -> PressedBackgroundView
    {
        let view = BlueprintView(frame: frame)
        view.backgroundColor = .clear
        
        return view
    }
}

