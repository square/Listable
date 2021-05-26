//
//  ItemContent.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 8/10/19.
//

///
/// An `ItemContent` is a type used to provide the content of an `Item`
/// in a listable section.
///
/// A `ItemContent` that displays text might look like this:
/// ```swift
/// struct MyItemContent : ItemContent, Equatable
/// {
///     var text : String
///     var id : UUID
///
///     var identifier: UUID {
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
public protocol ItemContent where Coordinator.ItemContentType == Self
{
    //
    // MARK: Identification
    //
    
    /// A `Hashable` type which is returned from ``ItemContent/identifier``,
    /// which is used to identify the ``ItemContent`` when it put into a list.
    ///
    /// The identifier is used to unique the item, control its lifetime, and identify it across update operations.
    /// See ``ItemContent/identifier`` for more.
    associatedtype IdentifierType : Hashable
    
    ///
    /// The identifier is used to unique the item, control its lifetime, and identify it across update operations.
    ///
    /// ### Identifier Stability
    /// This value must be stable. Changing the `identifier` will mean that the list will think
    /// the item has been removed from the list (and a new one inserted), which can cause
    /// undesired animations or other undesired behavior when a new view is created and inserted.
    ///
    /// ```swift
    /// struct MyItemContent : ItemContent {
    ///
    ///     var identifier : UUID {
    ///         // 🚫 Wrong; will change every time the item is accessed.
    ///         UUID()
    ///     }
    /// }
    ///
    /// struct MyItemContent : ItemContent {
    ///
    ///     let contentID = UUID()
    ///
    ///     var identifier : UUID {
    ///         // 🚫 Also wrong, will change every time the item is built.
    ///         self.contentID()
    ///     }
    /// }
    ///
    /// struct MyItemContent : ItemContent {
    ///
    ///     var identifier : UUID {
    ///          // ✅ Good! Stable across updates.
    ///         self.data.serverID
    ///     }
    /// }
    /// ```
    ///
    /// This is especially important with items that embed interactive controls, like buttons, sliders,
    /// text fields, etc. The identifier of the control should be stable and independent of the value
    /// the control is currently representing. Including the value the control is currently representing
    /// will cause the list to repeatedly re-create the control, removing the old item and inserting the new one.
    /// ```swift
    /// struct MySearchBarRow : ItemContent {
    ///
    ///     let searchText : String
    ///
    ///     var identifier : searchText {
    ///         // 🚫 Wrong; will change every time the search text changes.
    ///         searchText
    ///     }
    /// }
    ///
    /// struct MySearchBarRow : ItemContent {
    ///
    ///     let searchText : String
    ///     let id : String // Something like "item-search".
    ///
    ///     var identifier : String {
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
    /// server or client UUID here, or some other stable unique identifier from the underlying data model:
    /// ```swift
    /// struct MyItemContent : ItemContent {
    ///
    ///     let model : Model
    ///
    ///     var identifier : UUID {
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
    ///     let model : Model
    ///
    ///     var identifier : UUID {
    ///         // ✅ Good! Very unique.
    ///         self.model.serverID
    ///     }
    /// }
    /// ```
    var identifier : IdentifierType { get }
    
    //
    // MARK: Default Item Properties
    //
    
    /// Default values to assign to various properties on the `Item` which wraps
    /// this `ItemContent`, if those values are not passed to the `Item` initializer.
    var defaultItemProperties : DefaultItemProperties<Self> { get }
    
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
    
    //
    // MARK: Tracking Changes
    //
    
    /**
     Return true if the content's sort changed based on the old value passed into the function.
     
     The list view uses the value of this method to be more intelligent about what has moved within the list.
     
     Note
     ----
     There is a default implementation of this method which simply calls `isEquivalent`.
     */
    func wasMoved(comparedTo other : Self) -> Bool
    
    /**
     Return false if the content' changed based on the old value passed into the function.
     
     If this method returns false, the row representing the content is reloaded.
     
     Note
     ----
     There is a default implementation of this method when `ItemContent ` conforms to `Equatable`
     which returns `self == other`.
     */
    func isEquivalent(to other : Self) -> Bool
    
    //
    // MARK: Creating & Providing Swipe Action Views
    //
    
    /// The view type to use to render swipe actions (delete, etc) for this content.
    /// A default implementation, which matches `UITableView`, is provided.
    associatedtype SwipeActionsView: ItemContentSwipeActionsView = DefaultSwipeActionsView
    
    //
    // MARK: Creating & Providing Content Views
    //
    
    /// The content view used to draw the content.
    /// The content view is drawn at the top of the view hierarchy, above the background views.
    associatedtype ContentView:UIView
    

    /// Create and return a new content view used to render the content.
    ///
    /// Note
    /// ----
    /// Do not do configuration in this method that will be changed by your view's theme or appearance – instead
    /// do that work in `apply(to:)`, so the appearance will be updated if the appearance of content changes.
    static func createReusableContentView(frame : CGRect) -> ContentView
    
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
    
    //
    // MARK: Creating & Providing Background Views
    //
    
    /// The background view used to draw the background of the content.
    /// The background view is drawn below the content view.
    ///
    /// Note
    /// ----
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
}


/// The views owned by the item content, passed to the `apply(to:) method to theme and provide content.`
public struct ItemContentViews<Content:ItemContent>
{
    /// The content view of the content.
    public var content : Content.ContentView
    
    /// The background view of the content.
    public var background : Content.BackgroundView
    
    /// The selected background view of the content.
    /// Displayed when the content is highlighted or selected.
    public var selectedBackground : Content.SelectedBackgroundView
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
    
    /// If the item can be reordered.
    /// Use this property to determine if your `ItemContent` should display a reorder control.
    public var isReorderable : Bool
    
    /// The environment of the containing list.
    /// See `ListEnvironment` for usage information.
    public var environment : ListEnvironment
}


/// Provide a default implementation of `isEquivalent(to:)` if the `ItemContent` is `Equatable`.
public extension ItemContent where Self:Equatable
{
    func isEquivalent(to other : Self) -> Bool
    {
        return self == other
    }
}


public extension ItemContent {
    
    /// Creates an ``Identifier`` with the provided value.
    ///
    /// This method allows creating an ``Identifier`` in a type safe manner; enforcing that the
    /// `Represented` and `Value` parameters are of the correct type for the ``ItemContent``:
    /// ```
    /// MyItem.identifier(with: "my-id") // ✅ OK
    /// MyItem.identifier(with: 1)       // 🚫 Error: MyItem's IdentifierType is String.
    /// ```
    /// You can also read the identifier via  ``Item/identifier`` or ``AnyItem/anyIdentifier``.
    ///
    static func identifier(with value : IdentifierType) -> Identifier<Self, IdentifierType> {
        Identifier(value)
    }
}


/// Provides a default implementation of `identifier` when self conforms to Swift's `Identifiable` protocol.
@available(iOS 13.0, *)
public extension ItemContent where Self:Identifiable
{
    var identifier : ID {
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


/// Provide a default implementation of `defaultItemProperties` which returns an
/// empty instance that does not provide any defaults.
public extension ItemContent
{
    var defaultItemProperties : DefaultItemProperties<Self> {
        .init()
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


/// Provide a UIView when no special background view is specified.
public extension ItemContent where BackgroundView == UIView
{
    static func createReusableBackgroundView(frame : CGRect) -> BackgroundView
    {
        BackgroundView(frame: frame)
    }
}


/// Provide a UIView when no special selected background view is specified.
public extension ItemContent where BackgroundView == UIView
{
    static func createReusableSelectedBackgroundView(frame : CGRect) -> SelectedBackgroundView
    {
        SelectedBackgroundView(frame: frame)
    }
}


/// Conform to this protocol to implement a completely custom swipe action view.
///
/// If you do so, you're completely responsible for creating and laying out the actions,
/// as well as updating the layout based on the swipe state.
public protocol ItemContentSwipeActionsView: UIView {

    var swipeActionsWidth: CGFloat { get }

    init(didPerformAction: @escaping SwipeAction.CompletionHandler)

    func apply(actions: SwipeActionsConfiguration)

    func apply(state: SwipeActionState)
}
