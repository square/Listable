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
    // MARK: Converting To Views For Display
    //
    
    /**
     How the element should be rendered within the list view.
     
     You provide an instance of the Appearance when initializing the Item<Element> object.
     
     If you have multiple elements with similar or identical appearances,
     they should likely share an ItemElementAppearance to reduce code duplication.
     */
    associatedtype Appearance: ItemElementAppearance
    
    /**

     */
    associatedtype SwipeActionsView: ItemElementSwipeActionsView = DefaultSwipeActionsView
    
    //
    // MARK: Applying To Displayed View
    //
        
    /**
     Called when rendering the element. This is where you should push data from your
     element into the passed in views.
     
     Do not retain a reference to the passed in views – they are reused by the list.
     */
    func apply(to view : Appearance.ContentView, for reason: ApplyReason, with info : ApplyItemElementInfo)
    
    //
    // MARK: Tracking Changes
    //
    
    /**
     Return true if the element's sort changed based on the old value passed into the function.
     
     The list view uses the value of this method to be more intelligent about what has moved within the list.
     
     There is a default implementation of this method which checks the equality of `content`.
     */
    func wasMoved(comparedTo other : Self) -> Bool
    
    /**
     Return false if the element' changed based on the old value passed into the function.
     
     If this method returns false, the row representing the element is reloaded.
     
     There is a default implementation of this method when `ItemElement ` conforms to `Equatable`
     which returns `self == other`.
     */
    func isEquivalent(to other : Self) -> Bool
}

public extension ItemElement
{
    func wasMoved(comparedTo other : Self) -> Bool
    {
        return self.isEquivalent(to: other) == false
    }
}


public extension ItemElement where Self:Equatable
{
    func isEquivalent(to other : Self) -> Bool
    {
        return self == other
    }
}


/**
 Represents how your ItemElement should be rendered on screen by the list.
 
 The appearance conforms to Equatable – this is so apply(to:) is only called
 when the appearance of an element changes, versus on each display.
 */
public protocol ItemElementAppearance
{
    //
    // MARK: Creating & Providing Views
    //
    
    /// The type of the content view of the element.
    /// The content view is drawn at the top of the view hierarchy, above everything else,
    associatedtype ContentView:UIView
    
    /**
     Create and return a new set of views to be used to render the element.
     
     These views are reused by the list view, similar to collection view or table view cell recycling.
     
     Do not do configuration in this method that will be changed by your app's theme or appearance – instead
     do that work in apply(to:), so the appearance will be updated if the appearance of elements changes.
     */
    static func createReusableItemView(frame : CGRect) -> ContentView
    
    //
    // MARK: Updating View State
    //
    
    /**
     Called to apply the appearance to a given set of views before they are displayed on screen, or when an item position changes.
     
     Eg, this is where you would set fonts, spacing, colors, etc, to apply your app's theme.
     */
    func apply(to view : ContentView, with info : ApplyItemElementInfo)
    
    //
    // MARK: Tracking Changes
    //
    
    func isEquivalent(to other : Self) -> Bool
}


public extension ItemElementAppearance where Self:Equatable
{
    func isEquivalent(to other : Self) -> Bool
    {
        return self == other
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

public struct ApplyItemElementInfo
{
    public var state : ItemState
    public var position : ItemPosition
    public var reordering : ReorderingActions
}

