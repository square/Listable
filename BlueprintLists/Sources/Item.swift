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
/// An `ItemContent` specialized for use with Blueprint. Instead of providing
/// a custom view from `createReusableContentView`, and then updating it in `apply(to:)`,
/// you instead provide Blueprint element trees, and `Listable` handles mapping this to an underlying `BlueprintView`.
///
public protocol BlueprintItemContent : ItemContent
    where
    ContentView == BlueprintView,
    BackgroundView == BlueprintView,
    SelectedBackgroundView == BlueprintView
{
    //
    // MARK: Creating Blueprint Element Representations
    //
    
    /// Required. Create and return the Blueprint element used to represent the content.
    ///
    /// You can use the provided `ApplyItemContentInfo` to vary the appearance of the element
    /// based on the current state of the item.
    ///
    func element(with info : ApplyItemContentInfo) -> Element
    
    /// Optional. Create and return the Blueprint element used to represent the background of the content.
    /// You usually provide this method alongside `selectedBackgroundElement`, if your content
    /// supports selection or highlighting.
    ///
    /// You can use the provided `ApplyItemContentInfo` to vary the appearance of the element
    /// based on the current state of the item.
    ///
    /// Note
    /// ----
    /// The default implementation of this method returns nil, and provides no background.
    ///
    func backgroundElement(with info : ApplyItemContentInfo) -> Element?
    
    /// Optional. Create and return the Blueprint element used to represent the background of the content when it is selected or highlighted.
    /// You usually provide this method alongside `backgroundElement`, if your content supports selection or highlighting.
    ///
    /// You can use the provided `ApplyItemContentInfo` to vary the appearance of the element
    /// based on the current state of the item.
    ///
    /// Note
    /// ----
    /// The default implementation of this method returns nil, and provides no selected background.
    ///
    func selectedBackgroundElement(with info : ApplyItemContentInfo) -> Element?
}


public extension BlueprintItemContent
{
    //
    // MARK: Default Implementations
    //
    
    /// By default, content has no background.
    func backgroundElement(with info : ApplyItemContentInfo) -> Element?
    {
        nil
    }

    /// By default, content has no selected background.
    func selectedBackgroundElement(with info : ApplyItemContentInfo) -> Element?
    {
        nil
    }
}


public extension BlueprintItemContent
{
    //
    // MARK: ItemContent
    //
    
    /// Maps the `BlueprintItemContent` methods into the underlying `BlueprintView`s used to render the element.
    func apply(to views : ItemContentViews<Self>, for reason: ApplyReason, with info : ApplyItemContentInfo)
    {
        views.content.element = self.element(with: info)
        views.background.element = self.backgroundElement(with: info)
        views.selectedBackground.element = self.selectedBackgroundElement(with: info)
    }
    
    /// Creates the `BlueprintView` used to render the content of the item.
    static func createReusableContentView(frame: CGRect) -> ContentView
    {
        let view = BlueprintView(frame: frame)
        view.backgroundColor = .clear
        
        return view
    }
    
    /// Creates the `BlueprintView` used to render the background of the item.
    static func createReusableBackgroundView(frame: CGRect) -> BackgroundView
    {
        let view = BlueprintView(frame: frame)
        view.backgroundColor = .clear
        
        return view
    }
}

