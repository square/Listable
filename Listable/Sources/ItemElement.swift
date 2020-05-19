//
//  ItemElement.swift
//  Listable
//
//  Created by Kyle Van Essen on 8/10/19.
//


public protocol ItemElement
{
    //
    // MARK: Identification
    //
    
    /**
     Identifies the element across updates to the list. This value must remain the same,
     otherwise the element will be considered a new item, and the old one removed from the list.
     
     Does not have to be globally unique – the list will make a "best guess" if there are multiple elements
     with the same identifier. However, diffing of changes will be more correct with a unique identifier.
     
     If you're backing your element with some sort of client or server-provided data, consider using its
     server or client UUID here, or some other unique identifier from the underlying data model.
     */
    var identifier : Identifier<Self> { get }
    
    //
    // MARK: Applying To Displayed View
    //
        
    /**
     Called when rendering the element. This is where you should push data from your
     element into the passed in views.
     
     Do not retain a reference to the passed in views – they are reused by the list.
     */
    func apply(
        to views : ItemElementViews<Self>,
        for reason: ApplyReason,
        with info : ApplyItemElementInfo
    )
    
    //
    // MARK: Tracking Changes
    //
    
    /**
     Return true if the element's sort changed based on the old value passed into the function.
     
     The list view uses the value of this method to be more intelligent about what has moved within the list.
     
     Note
     ----
     There is a default implementation of this method which simply calls `isEquivalent`.
     */
    func wasMoved(comparedTo other : Self) -> Bool
    
    /**
     Return false if the element' changed based on the old value passed into the function.
     
     If this method returns false, the row representing the element is reloaded.
     
     Note
     ----
     There is a default implementation of this method when `ItemElement ` conforms to `Equatable`
     which returns `self == other`.
     */
    func isEquivalent(to other : Self) -> Bool
    
    //
    // MARK: Creating & Providing Swipe Action Views
    //
    
    /**

     */
    associatedtype SwipeActionsView: ItemElementSwipeActionsView = DefaultSwipeActionsView
    
    //
    // MARK: Creating & Providing Content Views
    //
    
    /// The content view used to draw the element.
    /// The content view is drawn at the top of the view hierarchy, above the background views.
    associatedtype ContentView:UIView
    
    /**
     Create and return a new content view used to render the element.
     
     Note
     ----
     Do not do configuration in this method that will be changed by your view's theme or appearance – instead
     do that work in `apply(to:)`, so the appearance will be updated if the appearance of elements changes.
     */
    static func createReusableContentView(frame : CGRect) -> ContentView
    
    //
    // MARK: Content Managers
    //
    
    associatedtype ContentManager : ItemElementContentManager
    
    
    
    //
    // MARK: Creating & Providing Background Views
    //
    
    /// The background view used to draw the background of the element.
    /// The background view is drawn below the content view.
    ///
    /// Note
    /// ----
    /// Defaults to a `UIView` with no drawn appearance or state.
    /// You do not need to provide this `typealias` unless you would like
    /// to draw a background view.
    ///
    associatedtype BackgroundView:UIView = UIView
    
    /**
     Create and return a new background view used to render the element's background.
     
     Note
     ----
     Do not do configuration in this method that will be changed by your view's theme or appearance – instead
     do that work in `apply(to:)`, so the appearance will be updated if the appearance of elements changes.
     */
    static func createReusableBackgroundView(frame : CGRect) -> BackgroundView
    
    /// The selected background view used to draw the background of the element when it is selected or highlighted.
    /// The selected background view is drawn below the content view.
    ///
    /// Note
    /// ----
    /// Defaults to a `UIView` with no drawn appearance or state.
    /// You do not need to provide this `typealias` unless you would like
    /// to draw a selected background view.
    ///
    associatedtype SelectedBackgroundView:UIView = BackgroundView
    
    /**
     Create and return a new background view used to render the element's selected background.
     
     This view is displayed when the element is highlighted or selected.
     
     If your `BackgroundView` and `SelectedBackgroundView` are the same type, this method
     is provided automatically by calling `createReusableBackgroundView`.
     
     Note
     ----
     Do not do configuration in this method that will be changed by your view's theme or appearance – instead
     do that work in `apply(to:)`, so the appearance will be updated if the appearance of elements changes.
     */
    static func createReusableSelectedBackgroundView(frame : CGRect) -> SelectedBackgroundView
}


public protocol ItemElementContentManager
{
    associatedtype ViewType : UIView
    
    var view : ViewType { get set }
        
    func willAppear(animated: Bool)

    func didAppear(animated: Bool)

    func willDisappear(animated: Bool)

    func didDisappear(animated: Bool)
}


/// The views owned by the item element, passed to the `apply(to:) method to theme and provide content.`
public struct ItemElementViews<Element:ItemElement>
{
    /// The content view of the element.
    public var content : Element.ContentView
    
    /// The background view of the element.
    public var background : Element.BackgroundView
    
    /// The selected background view of the element.
    /// Displayed when the element is highlighted or selected.
    public var selectedBackground : Element.SelectedBackgroundView
}


///
/// Information about the current state of the element, which is passed to `apply(to:)`
/// during configuration and preparation for display.
///
/// You can use this information to alter the display of your element, such as changing
/// the background color for highlights and selections, providing different corner styles
/// for different item positions, etc.
///
public struct ApplyItemElementInfo
{
    /// The state of the `Item` currently displaying the element. Is it highlighted, selected, etc.
    public var state : ItemState
    
    /// The position of the item within its section.
    public var position : ItemPosition
    
    /// Provides access to actions to handle re-ordering the element within the list.
    public var reordering : ReorderingActions
}


public extension ItemElement where Self:Equatable
{
    func isEquivalent(to other : Self) -> Bool
    {
        return self == other
    }
}


public extension ItemElement
{
    func wasMoved(comparedTo other : Self) -> Bool
    {
        return self.isEquivalent(to: other) == false
    }
}


public extension ItemElement where BackgroundView == UIView
{
    static func createReusableBackgroundView(frame : CGRect) -> BackgroundView
    {
        BackgroundView(frame: frame)
    }
}


public extension ItemElement where BackgroundView == SelectedBackgroundView
{
    static func createReusableSelectedBackgroundView(frame : CGRect) -> BackgroundView
    {
        self.createReusableBackgroundView(frame: frame)
    }
}

/**
 Conform to this protocol to implement a completely custom swipe action view.

 If you do so, you're completely responsible for creating and laying out the actions,
 as well as updating the layout based on the swipe state.
 */
public protocol ItemElementSwipeActionsView: UIView {

    var swipeActionsWidth: CGFloat { get }

    init(didPerformAction: @escaping SwipeAction.CompletionHandler)

    func apply(actions: SwipeActionsConfiguration)

    func apply(state: SwipeActionState)
}
