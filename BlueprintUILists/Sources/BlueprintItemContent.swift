//
//  BlueprintItemContent.swift
//  BlueprintUILists
//
//  Created by Kyle Van Essen on 10/22/19.
//

import BlueprintUI
import ListableUI
import UIKit


///
/// An `ItemContent` specialized for use with Blueprint. Instead of providing
/// custom views from `createReusable{...}View`, and then updating them in `apply(to:)`,
/// you instead provide Blueprint elements, and `Listable` handles mapping this to an underlying `BlueprintView`.
///
/// A `BlueprintItemContent` that displays text might look like this:
/// ```swift
/// struct MyItemContent : BlueprintItemContent, Equatable
/// {
///     var text : String
///     var id : UUID
///
///     var identifierValue: String {
///         self.id
///     }
///
///     func element(with info : ApplyItemContentInfo) -> Element
///     {
///         Label(text: self.text) {
///             $0.font = .systemFont(ofSize: 16.0, weight: .medium)
///             $0.color = info.state.isActive ? .white : .darkGray
///         }
///         .inset(horizontal: 15.0, vertical: 10.0)
///     }
///
///     func backgroundElement(with info: ApplyItemContentInfo) -> Element?
///     {
///         Box(backgroundColor: .white)
///     }
///
///     func selectedBackgroundElement(with info: ApplyItemContentInfo) -> Element?
///     {
///         Box(backgroundColor: .white(0.2))
///     }
/// }
/// ```
/// Which uses the `backgroundElement` and `selectedBackgroundElement` methods
/// to provide rendering of a background for the item, which will respond to its selection state.
///
/// The ordering of the elements by z-index is as follows:
/// z-index 3) `element`
/// z-index 2) `selectedBackgroundElement` (Only if the item supports a `selectionStyle` and is selected or highlighted.)
/// z-index 1) `backgroundElement`
///
public protocol BlueprintItemContent : ItemContent
    where
    ContentView == BlueprintView,
    BackgroundView == BlueprintView,
    SelectedBackgroundView == BlueprintView,
    OverlayDecorationView == BlueprintView,
    UnderlayDecorationView == BlueprintView
{
    //
    // MARK: Creating Blueprint Element Representations
    //
    
    /// Required. Create and return the Blueprint element used to represent the content.
    ///
    /// You can use the provided `ApplyItemContentInfo` to vary the appearance of the element
    /// based on the current state of the item.
    func element(with info : ApplyItemContentInfo) -> Element
    
    /// Optional. Create and return the Blueprint element used to represent the background of the content.
    /// You usually provide this method alongside `selectedBackgroundElement`, if your content
    /// supports selection or highlighting.
    ///
    /// You can use the provided `ApplyItemContentInfo` to vary the appearance of the element
    /// based on the current state of the item.
    ///
    /// ### Note
    /// The default implementation of this method returns nil, and provides no background.
    func backgroundElement(with info : ApplyItemContentInfo) -> Element?
    
    /// Optional. Create and return the Blueprint element used to represent the background of the content when it is selected or highlighted.
    /// You usually provide this method alongside `backgroundElement`, if your content supports selection or highlighting.
    ///
    /// You can use the provided `ApplyItemContentInfo` to vary the appearance of the element
    /// based on the current state of the item.
    ///
    /// ### Note
    /// The default implementation of this method returns nil, and provides no selected background.
    func selectedBackgroundElement(with info : ApplyItemContentInfo) -> Element?
    
    /// Optional. Create and return the Blueprint element used to represent the overlay decoration of the content.
    /// The overlay decoration appears above all other content, and is not affected by swipe actions.
    ///
    /// You can use the provided `ApplyItemContentInfo` to vary the appearance of the element
    /// based on the current state of the item.
    ///
    /// ### Note
    /// The default implementation of this method returns nil, and provides no decoration.
    func overlayDecorationElement(with info : ApplyItemContentInfo) -> Element?
    
    /// Optional. Create and return the Blueprint element used to represent the underlay decoration of the content.
    /// The underlay decoration appears below all other content, and is not affected by swipe actions.
    ///
    /// You can use the provided `ApplyItemContentInfo` to vary the appearance of the element
    /// based on the current state of the item.
    ///
    /// ### Note
    /// The default implementation of this method returns nil, and provides no decoration.
    func underlayDecorationElement(with info : ApplyItemContentInfo) -> Element?
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
    
    /// By default, content has no overlay decoration.
    func overlayDecorationElement(with info : ApplyItemContentInfo) -> Element? {
        nil
    }
    
    /// By default, content has no underlay decoration.
    func underlayDecorationElement(with info : ApplyItemContentInfo) -> Element? {
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
        views.content.element = element(with: info)
            .wrapInBlueprintEnvironmentFrom(environment: info.environment)
        
        if let element = backgroundElement(with: info)?
            .wrapInBlueprintEnvironmentFrom(environment: info.environment)
        {
            /// Load the `background` view and assign our element update.
            views.background.element = element
        } else {
            /// If there's no element, clear out any past element, but only if the view was loaded.
            views.backgroundIfLoaded?.element = nil
        }
        
        if let element = selectedBackgroundElement(with: info)?
            .wrapInBlueprintEnvironmentFrom(environment: info.environment)
        {
            /// Load the `selectedBackground` view and assign our element update.
            views.selectedBackground.element = element
        } else {
            /// If there's no element, clear out any past element, but only if the view was loaded.
            views.selectedBackgroundIfLoaded?.element = nil
        }
        
        if let element = overlayDecorationElement(with: info)?
            .wrapInBlueprintEnvironmentFrom(environment: info.environment)
        {
            /// Load the `overlayDecoration` view and assign our element update.
            views.overlayDecoration.element = element
        } else {
            /// If there's no element, clear out any past element, but only if the view was loaded.
            views.overlayDecorationIfLoaded?.element = nil
        }
        
        if let element = underlayDecorationElement(with: info)?
            .wrapInBlueprintEnvironmentFrom(environment: info.environment)
        {
            /// Load the `underlayDecoration` view and assign our element update.
            views.underlayDecoration.element = element
        } else {
            /// If there's no element, clear out any past element, but only if the view was loaded.
            views.underlayDecorationIfLoaded?.element = nil
        }
    }
    
    static func createReusableContentView(frame: CGRect) -> ContentView {
        self.newBlueprintView(with: frame)
    }
    
    static func createReusableBackgroundView(frame: CGRect) -> BackgroundView {
        self.newBlueprintView(with: frame)
    }
    
    static func createReusableSelectedBackgroundView(frame: CGRect) -> SelectedBackgroundView {
        self.newBlueprintView(with: frame)
    }
    
    static func createReusableOverlayDecorationView(frame: CGRect) -> OverlayDecorationView {
        self.newBlueprintView(with: frame)
    }
    
    static func createReusableUnderlayDecorationView(frame: CGRect) -> UnderlayDecorationView {
        self.newBlueprintView(with: frame)
    }
    
    private static func newBlueprintView(with frame : CGRect) -> BlueprintView {
        let view = BlueprintView(frame: frame)
        view.backgroundColor = .clear
        
        return view
    }
}
