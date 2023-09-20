//
//  SwipeActions.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 8/10/19.
//

import Foundation
import UIKit


/// Use SwipeActionsConfiguration to configure an item with SwipeActions.
/// These are actions that are revealed when swiping on the cell.
public struct SwipeActionsConfiguration {

    /// The actions to display when the cell is swiped.
    public var actions : [SwipeAction]

    /// Whether the first action is performed automatically with a full swipe.
    public var performsFirstActionWithFullSwipe : Bool
    
    /// Creates a new configuration with the provided action.
    public init(
        performsFirstActionWithFullSwipe : Bool = false,
        action : SwipeAction
    ) {
        self.performsFirstActionWithFullSwipe = performsFirstActionWithFullSwipe
        self.actions = [action]
    }
    
    /// Creates a new configuration with the provided actions.
    public init(
        performsFirstActionWithFullSwipe : Bool = false,
        actions : [SwipeAction]
    ) {
        self.performsFirstActionWithFullSwipe = performsFirstActionWithFullSwipe
        self.actions = actions
    }
    
    /// Creates a new configuration with the provided actions.
    public init(
        performsFirstActionWithFullSwipe : Bool = false,
        @ListableBuilder<SwipeAction> actions : () -> [SwipeAction]
    ) {
        self.performsFirstActionWithFullSwipe = performsFirstActionWithFullSwipe
        self.actions = actions()
    }
}


/// Create SwipeActions to define actions that can be performed in a SwipeActionsConfiguration.
public struct SwipeAction {

    /// The completion handler to call after performing the swipe action.
    ///
    /// Pass in `true` to expand the actions (typically only used when deleting the row)
    /// or `false` to collapse them.
    public typealias OnDidPerformAction = (OnDidPerformActionAnimation) -> Void

    /// The completion handler called when the action is tapped.
    public typealias OnTap = (@escaping OnDidPerformAction) -> Void

    public var title: String?
    
    public var accessibilityLabel : String?
    public var accessibilityValue : String?
    public var accessibilityHint : String?
    
    public var backgroundColor: UIColor?
    /// Sets the text and image (image must use the template rendering mode) color.
    public var tintColor: UIColor
    public var image: UIImage?

    public var onTap: OnTap
    
    /// Creates a new swipe action with the provided options.
    public init(
        title: String?,
        accessibilityLabel: String? = nil,
        accessibilityValue: String? = nil,
        accessibilityHint: String? = nil,
        backgroundColor: UIColor,
        tintColor: UIColor = .white,
        image: UIImage? = nil,
        onTap: @escaping OnTap
    ) {
        if title == nil || title?.isEmpty == true {
            precondition(
                accessibilityLabel?.isEmpty == false,
                "You must provide a title or an accessibilityLabel to a SwipeAction to ensure proper VoiceOver support."
            )
        }
        
        self.title = title
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityValue = accessibilityValue
        self.accessibilityHint = accessibilityHint
        
        self.backgroundColor = backgroundColor
        self.tintColor = tintColor
        self.image = image
        self.onTap = onTap
    }
    
    /// The animation to perform when the action is completed.
    public enum OnDidPerformActionAnimation : Equatable {
        
        /// The swipe actions will be closed.
        case closeActions
        
        /// The swipe actions will be expanded, revealing the last swipe action.
        /// You usually use this option when performing the action will remove the
        /// row from the list, eg during a deletion, archive, etc.
        case expandActions
    }
}
