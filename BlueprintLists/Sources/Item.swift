//
//  Item.swift
//  BlueprintLists
//
//  Created by Kyle Van Essen on 10/22/19.
//

import BlueprintUI

import Listable


//
// MARK: Blueprint Elements
//

///
/// An `ItemElement` specialized for use with Blueprint. Instead of providing
/// a custom view from `createReusableContentView`, and then updating it in `apply(to:)`,
/// you instead provide Blueprint element trees, and `Listable` handles mapping this to an underlying `BlueprintView`.
///
public protocol BlueprintItemElement : ItemElement
    where
    ContentView == BlueprintView,
    BackgroundView == BlueprintView,
    SelectedBackgroundView == BlueprintView
{
    //
    // MARK: Creating Blueprint Element Representations
    //
    
    /// Required. Create and return the element used to represent the content of the element.
    ///
    /// You can use the provided `ApplyItemElementInfo` to vary the appearance of your content
    /// based on the current state of the element.
    ///
    func element(with info : ApplyItemElementInfo) -> BlueprintUI.Element
    
    /// Optional. Create and return the element used to represent the background of the element.
    /// You usually provide this method alongside `selectedBackgroundElement`, if your element
    /// supports selection or highlighting.
    ///
    /// You can use the provided `ApplyItemElementInfo` to vary the appearance of your content
    /// based on the current state of the element.
    ///
    /// Note
    /// ----
    /// The default implementation of this method returns nil, and provides no background.
    ///
    func backgroundElement(with info : ApplyItemElementInfo) -> BlueprintUI.Element?
    
    /// Optional. Create and return the element used to represent the background of the element when it is selected or highlighted.
    /// You usually provide this method alongside `backgroundElement`, if your element supports selection or highlighting.
    ///
    /// You can use the provided `ApplyItemElementInfo` to vary the appearance of your content
    /// based on the current state of the element.
    ///
    /// Note
    /// ----
    /// The default implementation of this method returns nil, and provides no selected background.
    ///
    func selectedBackgroundElement(with info : ApplyItemElementInfo) -> BlueprintUI.Element?
}


public extension BlueprintItemElement
{
    //
    // MARK: Default Implementations
    //
    
    /// By default, elements have no background.
    func backgroundElement(with info : ApplyItemElementInfo) -> BlueprintUI.Element?
    {
        nil
    }

    /// By default, elements have no selected background.
    func selectedBackgroundElement(with info : ApplyItemElementInfo) -> BlueprintUI.Element?
    {
        nil
    }
}


public extension BlueprintItemElement
{
    //
    // MARK: ItemElement
    //
    
    /// Maps the `BlueprintItemElement` methods into the underlying `BlueprintView`s used to render the element.
    func apply(to views : ItemElementViews<Self>, for reason: ApplyReason, with info : ApplyItemElementInfo)
    {
        views.content.element = self.element(with: info)
        views.background.element = self.backgroundElement(with: info)
        views.selectedBackground.element = self.selectedBackgroundElement(with: info)
    }
    
    /// Creates the `BlueprintView` used to render the content of the element.
    static func createReusableContentView(frame: CGRect) -> ContentView
    {
        let view = BlueprintView(frame: frame)
        view.backgroundColor = .clear
        
        return view
    }
    
    /// Creates the `BlueprintView` used to render the background of the element.
    static func createReusableBackgroundView(frame: CGRect) -> BackgroundView
    {
        let view = BlueprintView(frame: frame)
        view.backgroundColor = .clear
        
        return view
    }
}

