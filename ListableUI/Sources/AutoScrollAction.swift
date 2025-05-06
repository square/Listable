//
//  AutoScrollAction.swift
//  ListableUI
//
//  Created by Kyle Bashour on 3/30/20.
//

import Foundation


/// Options for auto-scrolling to items when the list is updated.
public enum AutoScrollAction {
    
    /// The list never automatically scrolls.
    case none

    /// Scrolls to the specified item when the list is updated if the item was inserted in this update.
    case scrollToItem(onInsertOf: OnInsertedItem)

    /// Scrolls to the specified item when the list is updated. Similar to `scrollToItem`, except it doesn't rely on item insertion to determine when scrolling is appropriate.
    case pin(to: Pin)

    /// Scrolls to the specified item when the list is updated if the item was inserted in this update.
    ///
    /// If you would like to control if this scroll should occur on insert, pass a `shouldPerform` closure,
    /// which will be called when the item is inserted, to give you a chance to confirm or reject the scroll
    /// action. The `ListScrollPositionInfo` passed to your closure provides the current state of the list,
    /// including visible content edges and visible items. If you do not pass a `shouldPerform` closure,
    /// the action will be performed on insert.
    ///
    /// ### Example
    /// ```
    /// // ID of item which should trigger a scroll event (eg the last item in the list).
    /// let identifier = myItem.identifier
    ///
    /// let action = .scrollTo(
    ///     .lastItem,
    ///     onInsertOf: identifier,
    ///     position: .init(position: .bottom),
    ///     animation: .default
    /// ) { info in
    ///    // Only scroll to the item if the bottom of the list is already visible.
    ///    state.isLastItemVisible
    /// } didPerform : { info in
    ///     // Called when the scroll action occurs.
    /// }
    /// ```
    /// - Parameters:
    ///    - destination: Where the list should scroll to on insert. If not specified, the value passed to `onInsertOf` will be used.
    ///    - onInsertOf: The identifier which should trigger the action.
    ///    - position: The position to scroll the list to.
    ///    - animation: The animation type to perform. Note: Will only animate if the list update itself is animated.
    ///    - shouldPerform: A block which lets you control if the auto scroll action should be performed based on the state of the list.
    ///    - didPerform: A block which is called when the action is performed. If the item causing insertion is inserted multiple times,
    ///     this block will be called multiple times.
    ///
    public static func scrollTo(
        _ destination : ScrollDestination? = nil,
        onInsertOf insertedIdentifier: AnyIdentifier,
        position: ScrollPosition,
        animated : Bool = false,
        shouldPerform : @escaping (ListScrollPositionInfo) -> Bool = { _ in true },
        didPerform : @escaping (ListScrollPositionInfo) -> () = { _ in }
    ) -> AutoScrollAction
    {
        .scrollToItem(
            onInsertOf: .init(
                destination: destination ?? .item(insertedIdentifier),
                insertedIdentifier: insertedIdentifier,
                position: position,
                animated: animated,
                shouldPerform: shouldPerform,
                didPerform: didPerform
            )
        )
    }

    /// Scrolls to the specified item when the list is updated. Similar to `scrollTo`, except it doesn't
    /// rely on item insertion to determine when scrolling is appropriate.
    ///
    /// If you would like to control if this scroll should occur on insert, pass a `shouldPerform` closure,
    /// which will be called when the item is inserted, to give you a chance to confirm or reject the scroll
    /// action. The `ListScrollPositionInfo` passed to your closure provides the current state of the list,
    /// including visible content edges and visible items. If you do not pass a `shouldPerform` closure,
    /// the action will be performed on insert.
    ///
    /// ### Example
    /// ```
    /// let pin = Pin(
    ///     .lastItem,
    ///     position: .init(position: .bottom),
    ///     animation: .default
    /// ) { info in
    ///    // Only scroll to the item if the bottom of the list is already visible.
    ///    state.isLastItemVisible
    /// } didPerform : { info in
    ///     // Called when the scroll action occurs.
    /// }
    /// let action = .pin(to: pin)
    /// ```
    /// - Parameters:
    ///    - destination: Where the list should scroll to on insert. If not specified, the value passed to `onInsertOf` will be used.
    ///    - position: The position to scroll the list to.
    ///    - animation: The animation type to perform. Note: Will only animate if the list update itself is animated.
    ///    - shouldPerform: A block which lets you control if the auto scroll action should be performed based on the state of the list.
    ///    - didPerform: A block which is called when the action is performed. If the item causing insertion is inserted multiple times,
    ///     this block will be called multiple times.
    ///
    public static func pin(
        _ destination : ScrollDestination,
        position: ScrollPosition,
        animated : Bool = false,
        shouldPerform : @escaping (ListScrollPositionInfo) -> Bool = { _ in true },
        didPerform : @escaping (ListScrollPositionInfo) -> () = { _ in }
    ) -> AutoScrollAction
    {
        .pin(
            to: .init(
                destination: destination,
                position: position,
                animated: animated,
                shouldPerform: shouldPerform,
                didPerform: didPerform
            )
        )
    }
}


extension AutoScrollAction
{
    /// Where to scroll as a result of an `AutoScrollAction`.
    public enum ScrollDestination : Equatable
    {
        /// Scroll to the first item in the list.
        case firstItem
        
        /// Scroll to the last item in the list.
        case lastItem
        
        /// Scroll to the item with the specified identifier.
        case item(AnyIdentifier)
        
        func destination(with content : Content) -> AnyIdentifier? {
            switch self {
            case .firstItem: return content.firstItem?.anyIdentifier
            case .lastItem: return content.lastItem?.anyIdentifier
            case .item(let identifier): return identifier
            }
        }
    }
    
    /// This protocol allows `ListView` to treat the `OnInsertedItem` and `Pin` behaviors
    /// in a similar fashion.
    public protocol Behavior {
        
        /// The item in the list to scroll to.
        var destination : ScrollDestination { get set }
        
        /// The desired scroll position.
        var position : ScrollPosition { get set }
        
        /// If the change should be animated.
        ///
        /// ### Note
        /// The action will only be animated if it is animated, **and** the list update itself is
        /// animated. Otherwise, no animation occurs.
        var animated : Bool { get set }
        
        /// An additional check you may provide to approve or reject the scroll action.
        var shouldPerform : (ListScrollPositionInfo) -> Bool { get set }
        
        /// Called when the list performs the insertion.
        var didPerform : (ListScrollPositionInfo) -> () { get set }
    }
    
    /// Values used to configure the `scrollToItem(onInsertOf:)` action.
    public struct OnInsertedItem: AutoScrollAction.Behavior
    {
        /// The item in the list to scroll to when the `insertedIdentifier` is inserted.
        public var destination : ScrollDestination
        
        /// The identifier of the item for which the `AutoScrollAction` should be performed.
        public var insertedIdentifier : AnyIdentifier
        
        public var position : ScrollPosition
        
        public var animated : Bool
        
        public var shouldPerform : (ListScrollPositionInfo) -> Bool
        
        public var didPerform : (ListScrollPositionInfo) -> ()
    }

    /// Values used to configure the `pin(to:)` action.
    public struct Pin: AutoScrollAction.Behavior
    {
        public var destination : ScrollDestination

        public var position : ScrollPosition
        
        public var animated : Bool
        
        public var shouldPerform : (ListScrollPositionInfo) -> Bool
        
        public var didPerform : (ListScrollPositionInfo) -> ()
    }
}
