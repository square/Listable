//
//  ItemElement.swift
//  Listable
//
//  Created by Kyle Van Essen on 8/10/19.
//

public protocol ItemElement {
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
  var identifier: Identifier<Self> { get }

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
  associatedtype SwipeActionsAppearance: ItemElementSwipeActionsAppearance =
    EmptyItemElementSwipeActionsAppearance

  //
  // MARK: Applying To Displayed View
  //

  /**
     Called when rendering the element. This is where you should push data from your
     element into the passed in views.
     
     Do not retain a reference to the passed in views – they are reused by the list.
     */
  func apply(
    to view: Appearance.ContentView, for reason: ApplyReason, with info: ApplyItemElementInfo)

  //
  // MARK: Tracking Changes
  //

  /**
     Return true if the element's sort changed based on the old value passed into the function.
     
     The list view uses the value of this method to be more intelligent about what has moved within the list.
     
     There is a default implementation of this method which checks the equality of `content`.
     */
  func wasMoved(comparedTo other: Self) -> Bool

  /**
     Return false if the element' changed based on the old value passed into the function.
     
     If this method returns false, the row representing the element is reloaded.
     
     There is a default implementation of this method when `ItemElement ` conforms to `Equatable`
     which returns `self == other`.
     */
  func isEquivalent(to other: Self) -> Bool
}

extension ItemElement {
  public func wasMoved(comparedTo other: Self) -> Bool {
    return self.isEquivalent(to: other) == false
  }
}

extension ItemElement where Self: Equatable {
  public func isEquivalent(to other: Self) -> Bool {
    return self == other
  }
}

/// Represents how your ItemElement should be rendered on screen by the list.
/// 
/// The appearance conforms to Equatable – this is so apply(to:) is only called
/// when the appearance of an element changes, versus on each display.
public protocol ItemElementAppearance {
  //
  // MARK: Creating & Providing Views
  //

  /// The type of the content view of the element.
  /// The content view is drawn at the top of the view hierarchy, above everything else,
  associatedtype ContentView: UIView

  /**
     Create and return a new set of views to be used to render the element.
     
     These views are reused by the list view, similar to collection view or table view cell recycling.
     
     Do not do configuration in this method that will be changed by your app's theme or appearance – instead
     do that work in apply(to:), so the appearance will be updated if the appearance of elements changes.
     */
  static func createReusableItemView(frame: CGRect) -> ContentView

  //
  // MARK: Updating View State
  //

  /**
     Called to apply the appearance to a given set of views before they are displayed on screen, or when an item position changes.
     
     Eg, this is where you would set fonts, spacing, colors, etc, to apply your app's theme.
     */
  func apply(to view: ContentView, with info: ApplyItemElementInfo)

  //
  // MARK: Tracking Changes
  //

  func isEquivalent(to other: Self) -> Bool
}

extension ItemElementAppearance where Self: Equatable {
  public func isEquivalent(to other: Self) -> Bool {
    return self == other
  }
}

/// Currently unsupported. Custom implementation for the swipe action views. 
public protocol ItemElementSwipeActionsAppearance {
  //
  // MARK: Creating & Providing Views
  //

  /// The type of the content view of the swipe action view behind the element.
  /// The content view is drawn under the elements ContentView
  associatedtype ContentView: UIView

  /**
    Create and return a new set of views to be used to render the element.

    These views are reused by the list view, similar to collection view or table view cell recycling.

    Do not do configuration in this method that will be changed by your app's theme or appearance – instead
    do that work in apply(to:), so the appearance will be updated if the appearance of elements changes.
    */
  static func createView(frame: CGRect) -> ContentView

  //
  // MARK: Updating View State
  //

  /**

     Called to apply the actions appearance to a given set of views before they are displayed on screen, or when an item position changes.

     Eg, this is where you would set fonts, spacing, colors, etc, actions, to apply your app's theme.
     */
  func apply(swipeActions: SwipeActions, to view: ContentView)

  /**

    Called to apply the current SwipeControllerState to the underlying view.

    Eg, the default iOS action view changes the title label alignment at different states in the swipe animation.
    */
  func apply(swipeControllerState: SwipeControllerState, to view: ContentView)

  /**

    Called to apply the actions appearance to a given set of views before they are displayed on screen, or when an item position changes.

    Eg, this is where you would set fonts, spacing, colors, etc, actions, to apply your app's theme.
    */
  func preferredSize(for view: ContentView) -> CGSize
}

public struct EmptyItemElementSwipeActionsAppearance: ItemElementSwipeActionsAppearance {
  public init() {}

  // MARK: ItemElementSwipeActionsAppearance

  public typealias ContentView = UIView

  public static func createView(frame: CGRect) -> UIView {
    return UIView(frame: frame)
  }

  public func apply(swipeActions: SwipeActions, to view: UIView) {
    // Nothing.
  }

  public func apply(swipeControllerState: SwipeControllerState, to view: UIView) {
    // no op
  }

  public func preferredSize(for view: UIView) -> CGSize {
    return .zero
  }
}

public struct ApplyItemElementInfo {
  public var state: ItemState
  public var position: ItemPosition
  public var reordering: ReorderingActions
}
