//
//  ItemContent.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 8/10/19.
//

import UIKit


///
/// An `ItemContent` is a type used to provide the content of an `Item` in a list section.
///
/// A `ItemContent` that displays text might look like this:
/// ```swift
/// struct MyItemContent : ItemContent, Equatable
/// {
///     var text : String
///     var id : UUID
///
///     var identifierValue: UUID {
///         self.id
///     }
///
///     static func createReusableContentView(frame : CGRect) -> MyContentView {
///         MyContentView(frame: frame)
///     }
///
///     func apply(to views : ItemContentViews<Self>, for reason: ApplyReason, with info : ApplyItemContentInfo) {
///         views.content.text = self.text
///     }
/// }
/// ```
/// If you want to add support for rendering a background view and a selected or highlighted state, you should provide
/// both `createReusableBackgroundView` and `createReusableSelectedBackgroundView` methods,
/// and apply the desired content in your `apply(to:)` method.
///
/// The ordering of the elements by z-index is as follows:
/// z-index 3) `ContentView`
/// z-index 2) `SelectedBackgroundView` (Only if the item supports a `selectionStyle` and is selected or highlighted.)
/// z-index 1) `BackgroundView`
///
public protocol ItemContent : AnyItemConvertible where Coordinator.ItemContentType == Self
{
    //
    // MARK: Identification
    //
    
    /// A `Hashable` type which is returned from ``ItemContent/identifierValue-swift.property``,
    /// which is used to identify the ``ItemContent`` when it put into a list.
    ///
    /// The ``ItemContent/identifierValue-swift.property`` is used to unique the item,
    /// control its lifetime, and identify it across update operations.
    ///
    /// See ``ItemContent/identifierValue-swift.property`` for more.
    associatedtype IdentifierValue : Hashable
    
    ///
    /// Used to unique the item, control its lifetime, and identify it across update operations.
    ///
    /// ### Identifier Stability
    /// This value must be stable. Changing the `identifier` will mean that the list will think
    /// the item has been removed from the list (and a new one inserted), which can cause
    /// undesired animations or other undesired behavior when a new view is created and inserted.
    ///
    /// ```swift
    /// struct MyItemContent : ItemContent {
    ///
    ///     var identifierValue : UUID {
    ///         // 🚫 Wrong; will change every time the item is accessed.
    ///         UUID()
    ///     }
    /// }
    ///
    /// struct MyItemContent : ItemContent {
    ///
    ///     let contentID = UUID()
    ///
    ///     var identifierValue : UUID {
    ///         // 🚫 Also wrong, will change every time the item is built.
    ///         self.contentID()
    ///     }
    /// }
    ///
    /// struct MyItemContent : ItemContent {
    ///
    ///     let model : Model // Conforms to Hashable
    ///
    ///     var identifierValue : String {
    ///         // 🚫 Wrong! This will change the value of the identifier
    ///         // any time any value within our content changes.
    ///
    ///         self.model
    ///     }
    /// }
    ///
    /// struct MyItemContent : ItemContent {
    ///
    ///     let model : Model
    ///
    ///     var identifierValue : String {
    ///         // 🚫 Still wrong! Same as above, but with reflection. You should
    ///         // never used a reflecting or describing method to generate an identifier.
    ///
    ///         String(describing/reflecting: self.model)
    ///     }
    /// }
    ///
    /// struct MyItemContent : ItemContent {
    ///
    ///     let model : Model
    ///
    ///     var identifierValue : UUID {
    ///          // ✅ Good! Stable across updates.
    ///         self.model.serverID
    ///     }
    /// }
    /// ```
    ///
    /// Identifier stability is especially important with items that embed interactive controls, like buttons, sliders,
    /// text fields, etc. The identifier of the control should be stable and **independent of the value
    /// the control is currently representing**. Including the value the control is currently representing
    /// in the identifier will cause the list to repeatedly re-create the control, removing the old item and inserting the new one.
    /// ```swift
    /// struct MySearchBarRow : ItemContent {
    ///
    ///     let searchText : String
    ///
    ///     var identifierValue : String {
    ///         // 🚫 Wrong; identifier will change every time the search text changes.
    ///         searchText
    ///     }
    /// }
    ///
    /// struct MySearchBarRow : ItemContent {
    ///
    ///     let searchText : String
    ///     let id : String // Something like "item-search".
    ///
    ///     var identifierValue : String {
    ///         // ✅ Good! Stable across updates.
    ///         id
    ///     }
    /// }
    /// ```
    ///
    /// ### Identifier Uniqueness
    /// While identifiers do need to be _stable_, they do not need to be globally unique – the list will make a
    /// "best guess" if there are multiple items with the same identifier. However, diffing of changes
    /// will be more visually correct with a unique identifier.
    ///
    /// If you are backing your content with some sort of client or server-provided data, consider using its
    /// server or client UUID here, or some other stable unique identifier from the underlying data model.
    ///
    /// Generally, try to use the most stable ID you have access to. Sometimes this will be a server or client ID
    /// as mentioned above. For something without the concept of identity, consider providing a value
    /// based on what the content represents (eg, a row title like "Settings").
    ///
    /// ```swift
    /// struct MyItemContent : ItemContent {
    ///
    ///     let model : Model
    ///
    ///     var identifierValue : UUID {
    ///         // 🚫 Likely wrong. If entered by the user,
    ///         // there could be many items with this name,
    ///         // or multiple items with no name at all, leading
    ///         // to identifier collisions.
    ///
    ///         self.model.name
    ///     }
    /// }
    ///
    /// struct MyItemContent : ItemContent {
    ///
    ///     let setting : Setting
    ///
    ///     var identifierValue : UUID {
    ///         // 🤔 Probably good enough! Since this item
    ///         // represents a setting in a settings screen,
    ///         // returning the title of the row is likely
    ///         // unique enough to guarantee stability.
    ///
    ///         self.setting.name // Something like "Location Services".
    ///     }
    /// }
    ///
    /// struct MyItemContent : ItemContent {
    ///
    ///     let model : Model
    ///
    ///     var identifierValue : UUID {
    ///         // ✅ Good! Very unique.
    ///         self.model.serverID
    ///     }
    /// }
    /// ```
    ///
    /// ### Identifier Leverages The Type System
    /// Your ``ItemContent/identifierValue-swift.property`` gets wrapped up in an `Identifier<YourItemContent, IdentifierValue>`
    /// when it used by the list to unique the item, control its lifetime, and identify it across update operations.  This
    /// additional type information is used to further unique the identifier. You do not need to provide any
    /// additional type-salting and uniquing information in your ``ItemContent/identifierValue-swift.property`` besides the value from your content.
    ///
    /// Even once the ``Identifier`` is type-erased to ``AnyIdentifier``, this type information is retained:
    /// ```swift
    /// let first : AnyIdentifier = Identifier<MyThing, String>("a-value")
    /// let second : AnyIdentifier = Identifier<MyOtherThing, String>("a-value")
    ///
    /// let isEqual = first == second // false
    /// ```
    ///
    /// In practical terms, this means that your ``ItemContent/identifierValue-swift.property`` implementation should be:
    /// ```swift
    /// struct MyItemContent : ItemContent {
    ///
    ///     let model : Model
    ///
    ///     var identifierValue : String {
    ///         // 🚫 Not needed: Type information will be encoded into the Identifier.
    ///         "MyItemContent-\(model.serverID)"
    ///     }
    /// }
    ///
    /// struct MySearchBarRow : ItemContent {
    ///
    ///     let model : Model
    ///
    ///     var identifierValue : searchText {
    ///         // ✅ Good! No need for the string interpolation.
    ///         model.serverID
    ///     }
    /// }
    /// ```
    var identifierValue : IdentifierValue { get }
    
    //
    // MARK: Tracking Changes
    //
    
    ///
    /// Used by the list to determine when the content of the item has changed; in order to
    /// remeasure the item and re-layout the list.
    ///
    /// You should return `false` from this method when any content within your item that
    /// affects visual appearance or layout (and in particular, sizing) changes. When the list
    /// receives `false` back from this method, it will invalidate any cached sizing it has stored
    /// for the item, and re-measure + re-layout the content.
    ///
    /// ```swift
    /// struct MyItemContent : ItemContent, Equatable {
    ///
    ///     var identifierValue : UUID
    ///     var title : String
    ///     var detail : String
    ///     var theme : MyTheme
    ///     var onTapDetail : () -> ()
    ///
    ///     func isEquivalent(to other : MyItemContent) -> Bool {
    ///         // 🚫 Missing checks for title and detail.
    ///         // If they change, they likely affect sizing,
    ///         // which would result in incorrect item sizing.
    ///
    ///         self.theme == other.theme
    ///     }
    ///
    ///     func isEquivalent(to other : MyItemContent) -> Bool {
    ///         // 🚫 Missing check for theme.
    ///         // If the theme changed; its likely that the device's
    ///         // accessibility settings changed; dark mode was enabled,
    ///         // etc. All of these can affect the appearance or sizing
    ///         // of the item.
    ///
    ///         self.title == other.title &&
    ///         self.detail == other.detail
    ///     }
    ///
    ///     func isEquivalent(to other : MyItemContent) -> Bool {
    ///         // ✅ Checking all parameters which can affect appearance + layout.
    ///         // Not checking identifierValue or onTapDetail, since they do not affect appearance + layout.
    ///
    ///         self.theme == other.theme &&
    ///         self.title == other.title &&
    ///         self.detail == other.detail
    ///     }
    /// }
    ///
    /// struct MyItemContent : ItemContent, Equatable {
    ///     // ✅ Nothing else needed!
    ///     // `Equatable` conformance provides `isEquivalent(to:) for free!`
    /// }
    /// ```
    ///
    /// #### Note
    /// If your ``ItemContent`` conforms to ``Equatable``, there is a default
    /// implementation of this method which simply returns `self == other`.
    ///
    func isEquivalent(to other : Self) -> Bool
    
    /// Used by the list view to determine move events during an update's diff operation.
    ///
    /// This function should return `true` if the content's sort changed based on the old value passed into the function.
    /// For example, if your content is sorted based on an `updatedAt` `Date` parameter, you would implement
    /// this method as follows:
    /// ```swift
    /// func wasMoved(comparedTo other : MyContent) -> Bool {
    ///     self.updatedAt != other.updatedAt
    /// }
    /// ```
    ///
    /// #### Note
    /// There is a default implementation of this method which calls `isEquivalent == false`. Unless
    /// your list has an extremely high amount of ordering churn, you should not need to implement this method.
    ///
    func wasMoved(comparedTo other : Self) -> Bool
    
    associatedtype ContentSizingSharingKey : SizingSharingKey = DefaultSizingSharingKey
    
    var sizingSharingKey : ContentSizingSharingKey { get }
    
    //
    // MARK: Default Item Properties
    //
    
    typealias DefaultProperties = DefaultItemProperties<Self>

    
    /// Default values to assign to various properties on the `Item` which wraps
    /// this `ItemContent`, if those values are not passed to the `Item` initializer.
    var defaultItemProperties : DefaultProperties { get }
    
    //
    // MARK: Applying To Displayed View
    //
        
    /**
     Called when rendering the content. This is where you should push data from your
     content into the passed in views.
     
     Do not retain a reference to the passed in views – they are reused by the list.
     */
    func apply(
        to views : ItemContentViews<Self>,
        for reason: ApplyReason,
        with info : ApplyItemContentInfo
    )
    
    /// When the `ItemContent` is on screen, controls how and when to apply updates
    /// to the view.
    ///
    /// Defaults to ``ReappliesToVisibleView/always``.
    ///
    /// See ``ReappliesToVisibleView`` for a full discussion.
    var reappliesToVisibleView : ReappliesToVisibleView { get }
    
    //
    // MARK: Creating & Providing Swipe Action Views
    //

    /// The swipe action style for this content.
    ///
    /// If this is `nil`, the style provided by the ``SwipeActionsViewStyleKey`` environment value will be used.
    var swipeActionsStyle: SwipeActionsViewStyle? { get }

    //
    // MARK: Creating & Providing Content Views
    //
    
    /// The content view used to draw the content.
    /// The content view is drawn at the top of the view hierarchy, above the background views.
    associatedtype ContentView: UIView
    

    /// Create and return a new content view used to render the content.
    ///
    /// ### Note
    /// Do not do configuration in this method that will be changed by your view's theme or appearance – instead
    /// do that work in `apply(to:)`, so the appearance will be updated if the appearance of content changes.
    static func createReusableContentView(frame : CGRect) -> ContentView
    
    /// Describes the properties to configure on the content area view for the item.
    func contentAreaViewProperties(with info : ApplyItemContentInfo) -> ViewProperties
    
    //
    // MARK: Creating & Providing Background Views
    //
    
    /// The background view used to draw the background of the content.
    /// The background view is drawn below the content view.
    ///
    /// ### Note
    /// Defaults to a `UIView` with no drawn appearance or state.
    /// You do not need to provide this `typealias` unless you would like
    /// to draw a background view.
    ///
    associatedtype BackgroundView:UIView = UIView
    
    /// Create and return a new background view used to render the content's background.
    ///
    /// Note
    /// ----
    /// Do not do configuration in this method that will be changed by your view's theme or appearance – instead
    /// do that work in `apply(to:)`, so the appearance will be updated if the appearance of content changes.
    static func createReusableBackgroundView(frame : CGRect) -> BackgroundView
    
    /// The selected background view used to draw the background of the content when it is selected or highlighted.
    /// The selected background view is drawn below the content view.
    ///
    /// Note
    /// ----
    /// Defaults to a `UIView` with no drawn appearance or state.
    /// You do not need to provide this `typealias` unless you would like
    /// to draw a selected background view.
    ///
    associatedtype SelectedBackgroundView:UIView = UIView
    
    
    /// Create and return a new background view used to render the content's selected background.
    ///
    /// This view is displayed when the content is highlighted or selected.
    ///
    /// If your `BackgroundView` and `SelectedBackgroundView` are the same type, this method
    /// is provided automatically by calling `createReusableBackgroundView`.
    ///
    /// Note
    /// ----
    /// Do not do configuration in this method that will be changed by your view's theme or appearance – instead
    /// do that work in `apply(to:)`, so the appearance will be updated if the appearance of content changes.
    static func createReusableSelectedBackgroundView(frame : CGRect) -> SelectedBackgroundView
    
    //
    // MARK: Creating & Providing Decoration Views
    //
    
    /// The content view used to draw the content.
    /// The content view is drawn at the top of the view hierarchy, above the background views.
    associatedtype OverlayDecorationView:UIView = UIView
    
    /// The content view used to draw the content.
    /// The content view is drawn at the bottom of the view hierarchy, above the background views.
    associatedtype UnderlayDecorationView:UIView = UIView
    
    /// Create and return a new overlay decoration view used to render any required decorations over the content.
    /// The decoration view appears above all content, and is not affected by swipe actions.
    ///
    /// ## Note
    /// Do not do configuration in this method that will be changed by your view's theme or appearance – instead
    /// do that work in `apply(to:)`, so the appearance will be updated if the appearance of content changes.
    static func createReusableOverlayDecorationView(frame : CGRect) -> OverlayDecorationView
    
    /// Create and return a new underlay decoration view used to render any required decorations under the content.
    /// The decoration view appears under all content as a background, and is not affected by swipe actions.
    ///
    /// ## Note
    /// Do not do configuration in this method that will be changed by your view's theme or appearance – instead
    /// do that work in `apply(to:)`, so the appearance will be updated if the appearance of content changes.
    static func createReusableUnderlayDecorationView(frame : CGRect) -> UnderlayDecorationView
    
    //
    // MARK: Content Coordination
    //
    
    /// The coordinator type to use to manage the live state of the `Item` and `ItemContent`,
    /// if you need to update content based on signals such as notifications, view state, appearance state,
    /// etc.
    associatedtype Coordinator : ItemContentCoordinator = DefaultItemContentCoordinator<Self>
    
    /// The actions passed to the coordinator.
    typealias CoordinatorActions = ItemContentCoordinatorActions<Self>
    /// The info passed to the coordinator.
    typealias CoordinatorInfo = ItemContentCoordinatorInfo<Self>
    
    /// Creates a new coordinator with the provided actions and info.
    func makeCoordinator(actions : CoordinatorActions, info : CoordinatorInfo) -> Coordinator
}


public extension ItemContent {
    
     func toAnyItem() -> AnyItem {
        Item(self)
    }
}


/// The views owned by the item content, passed to the `apply(to:) method to theme and provide content.`
public struct ItemContentViews<Content:ItemContent>
{
    let cell : ItemCell<Content>
    
    /// The content view of the content.
    public var content : Content.ContentView {
        cell.contentContainer.contentView
    }
    
    /// The background view of the content.
    public var background : Content.BackgroundView {
        cell.background
    }
    
    /// The background view of the content, if it has been loaded.
    public var backgroundIfLoaded : Content.BackgroundView? {
        cell.backgroundIfLoaded
    }
    
    /// The selected background view of the content.
    /// Displayed when the content is highlighted or selected.
    public var selectedBackground : Content.SelectedBackgroundView {
        cell.selectedBackground
    }
    
    /// The selected background view of the content, if it has been loaded.
    /// Displayed when the content is highlighted or selected.
    public var selectedBackgroundIfLoaded : Content.SelectedBackgroundView? {
        cell.selectedBackgroundIfLoaded
    }
    
    /// The overlay decoration view of the content.
    /// Always displayed over the content, and does not react to swipe actions.
    public var overlayDecoration : Content.OverlayDecorationView {
        cell.overlayDecoration.content
    }
    
    /// The overlay decoration view of the content, if it has been loaded.
    /// Always displayed over the content, and does not react to swipe actions.
    public var overlayDecorationIfLoaded : Content.OverlayDecorationView? {
        cell.overlayDecorationIfLoaded?.content
    }

    /// The underlay decoration view of the content.
    /// Always displayed under the content, and does not react to swipe actions.
    public var underlayDecoration : Content.UnderlayDecorationView {
        cell.underlayDecoration.content
    }
    
    /// The underlay decoration view of the content, if it has been loaded.
    /// Always displayed under the content, and does not react to swipe actions.
    public var underlayDecorationIfLoaded : Content.UnderlayDecorationView? {
        cell.underlayDecorationIfLoaded?.content
    }
}


/// Information about the current state of the content, which is passed to `apply(to:for:with:)`
/// during configuration and preparation for display.
///
/// You can use this information to alter the display of your content, such as changing
/// the background color for highlights and selections, providing different corner styles
/// for different item positions, etc.
///
/// TODO: Rename to `ApplyItemContext`
public struct ApplyItemContentInfo
{
    /// The state of the `Item` currently displaying the content. Is it highlighted, selected, etc.
    public var state : ItemState
    
    /// The position of the item within its section.
    public var position : ItemPosition
    
    /// Provides access to actions to handle re-ordering the content within the list.
    public var reorderingActions : ReorderingActions
    
    /// When invoked, will show the leading swipe actions.
    public var showLeadingSwipeActions : () -> ()
    
    /// When invoked, will show the trailing swipe actions.
    public var showTrailingSwipeActions : () -> ()
    
    /// If the item can be reordered.
    /// Use this property to determine if your `ItemContent` should display a reorder control.
    public var isReorderable : Bool
    
    /// The environment of the containing list.
    /// See `ListEnvironment` for usage information.
    public var environment : ListEnvironment
}

public extension ItemContent {
    var swipeActionsStyle: SwipeActionsViewStyle? {
        return nil
    }
}

public extension ItemContent where Self:Equatable
{
    /// If your `ItemContent` is `Equatable`, `isEquivalent` is based on the `Equatable` implementation.
    func isEquivalent(to other : Self) -> Bool {
        self == other
    }
}


public extension ItemContent {
    
    /// The `Identifier` type for the item.
    ///
    /// For example, if your ``ItemContent`` was `MyContent`, and your `IdentifierValue` was `UUID`,
    /// this variable will provide an `Identifier<MyContent, UUID>`.
    ///
    typealias Identifier = ListableUI.Identifier<Self, IdentifierValue>
    
    /// The `Identifier` for the item.
    ///
    /// For example, if your ``ItemContent`` was `MyContent`, and your `IdentifierValue` was `UUID`,
    /// this variable will provide an `Identifier<MyContent, UUID>`.
    ///
    var identifier : Identifier {
        Self.identifier(with: self.identifierValue)
    }
    
    /// Creates an ``Identifier`` with the provided value.
    ///
    /// This method allows creating an ``Identifier`` in a type safe manner; enforcing that the
    /// `Represented` and `Value` parameters are of the correct type for the ``ItemContent``:
    /// ```
    /// MyItem.identifier(with: "my-id") // ✅ OK
    /// MyItem.identifier(with: 1)       // 🚫 Error: MyItem's IdentifierValue is String.
    /// ```
    /// You can also read the identifier via  ``ItemContent/identifier``, ``Item/identifier`` or ``AnyItem/anyIdentifier``.
    ///
    static func identifier(with value : IdentifierValue) -> Identifier {
        Identifier(value)
    }
}


/// Provides a default implementation of `identifierValue` when self conforms to Swift's `Identifiable` protocol.
public extension ItemContent where Self:Identifiable
{    
    var identifierValue : ID {
        self.id
    }
}


/// Implement `wasMoved` in terms of `isEquivalent(to:)` by default.
public extension ItemContent
{
    func wasMoved(comparedTo other : Self) -> Bool
    {
        return self.isEquivalent(to: other) == false
    }
}


/// Provide a default implementation of `reappliesToVisibleView` which returns `.always`.
public extension ItemContent
{
    var reappliesToVisibleView : ReappliesToVisibleView {
        .always
    }
}


/// Provide a default implementation of `defaultItemProperties` which returns an
/// empty instance that does not provide any defaults.
public extension ItemContent
{
    var defaultItemProperties : DefaultProperties {
        .init()
    }
}


public extension ItemContent where ContentSizingSharingKey == DefaultSizingSharingKey
{
    var sizingSharingKey : ContentSizingSharingKey {
        DefaultSizingSharingKey()
    }
}


/// Provides a default coordinator for items without a specified coordinator.
public extension ItemContent where Coordinator == DefaultItemContentCoordinator<Self>
{
    func makeCoordinator(actions : ItemContentCoordinatorActions<Self>, info : ItemContentCoordinatorInfo<Self>) -> Coordinator
    {
        DefaultItemContentCoordinator(actions: actions, info: info)
    }
}

/// Provides a default implementation of `ViewProperties` which configure no options.
public extension ItemContent {
    
    func contentAreaViewProperties(with info : ApplyItemContentInfo) -> ViewProperties {
        .init()
    }
}


/// Provide a UIView when no special background view is specified.
public extension ItemContent where BackgroundView == UIView
{
    static func createReusableBackgroundView(frame : CGRect) -> BackgroundView
    {
        BackgroundView(frame: frame)
    }
}


/// Provide a UIView when no special selected background view is specified.
public extension ItemContent where SelectedBackgroundView == UIView
{
    static func createReusableSelectedBackgroundView(frame : CGRect) -> SelectedBackgroundView
    {
        SelectedBackgroundView(frame: frame)
    }
}


/// Provide a UIView when no special overlay decoration view is specified.
public extension ItemContent where OverlayDecorationView == UIView
{
    static func createReusableOverlayDecorationView(frame : CGRect) -> OverlayDecorationView
    {
        OverlayDecorationView(frame: frame)
    }
}


/// Provide a UIView when no special underlay decoration view is specified.
public extension ItemContent where UnderlayDecorationView == UIView
{
    static func createReusableUnderlayDecorationView(frame : CGRect) -> UnderlayDecorationView
    {
        UnderlayDecorationView(frame: frame)
    }
}
