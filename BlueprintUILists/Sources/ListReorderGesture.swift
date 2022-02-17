//
//  ListReorderGesture.swift
//  BlueprintUILists
//
//  Created by Kyle Van Essen on 11/14/19.
//

import BlueprintUI
import ListableUI
import UIKit


///
/// An element that wraps your provided element, to enable support
/// for user-driven re-ordering in a list view.
///
/// If you do not support reordering items, you do not need
/// to add this element anywhere in your hierarchy.
///
/// This element on its own has no visual appearance. Thus, you should
/// still render your own reorder dragger / handle / etc in the passed in element.
///
/// In the below example, we see how to set up the content of a simple item, which contains
/// a text label and a reorder grabber.
///
/// ```
/// func element(with info : ApplyItemContentInfo) -> Element
/// {
///     Row { row in
///         row.add(child: Label(text: "..."))
///
///         row.add(child: ListReorderGesture(actions: info.actions, wrapping: MyReorderGrabber()))
///
///         // Could also be written as:
///         row.add(child: MyReorderGrabber().listReorderGesture(with: info.reorderingActions))
///     }
/// }
/// ```
public struct ListReorderGesture : Element
{
    public enum Begins {
        case onTap
        case onLongPress
    }

    /// The element which is being wrapped by the reorder gesture.
    public var element : Element
    
    /// If the gesture is enabled or not.
    public var isEnabled : Bool

    /// Condition to start the reorder gesture
    public var begins: Begins
    
    let actions : ReorderingActions
    
    /// The acccessibility Label of the item that will be reordered.
    /// This will be set as the gesture's accessibilityValue to provide a richer VoiceOver utterance.
    public var reorderItemAccessibilityLabel : String? = nil
    
    /// Creates a new re-order gesture which wraps the provided element.
    /// 
    /// This element on its own has no visual appearance. Thus, you should
    /// still render your own reorder dragger / handle / etc in the passed in element.
    public init(
        isEnabled : Bool = true,
        actions : ReorderingActions,
        begins: Begins = .onTap,
        wrapping element : Element
    ) {
        self.isEnabled =  isEnabled
        
        self.actions = actions

        self.begins = begins
        
        self.element = element
    }

    //
    // MARK: Element
    //
    
    public var content: ElementContent {
        ElementContent(child: self.element)
    }
    
    public func backingViewDescription(with context: ViewDescriptionContext) -> ViewDescription?
    {
        return ViewDescription(View.self) { config in
            config.builder = {
                View(frame: context.bounds, wrapping: self)
            }
            
            config.apply { view in
                view.isAccessibilityElement = true
                view.accessibilityLabel = ListReorderGesture.Strings.accessibilityLabel
                view.accessibilityValue = reorderItemAccessibilityLabel
                view.accessibilityHint = ListReorderGesture.Strings.accessibilityHint
                view.accessibilityTraits.formUnion(.button)
                view.accessibilityCustomActions = accessibilityActions()
                
                view.recognizer.isEnabled = self.isEnabled
                
                view.recognizer.apply(actions: self.actions)
                
                view.recognizer.minimumPressDuration = begins == .onLongPress ? 0.5 : 0.0
                if UIAccessibility.isVoiceOverRunning {
                    // Voiceover already uses a long press when moving items. We shouldn't add our own.
                    view.recognizer.minimumPressDuration = 0.0
                }
            }
        }
    }

}


public extension Element
{
    /// Wraps the element in a re-order gesture.
    func listReorderGesture(
        with actions : ReorderingActions,
        isEnabled : Bool = true,
        begins: ListReorderGesture.Begins = .onTap
    ) -> Element {
        ListReorderGesture(isEnabled: isEnabled, actions: actions, begins: begins, wrapping: self)
    }
}


fileprivate extension ListReorderGesture
{
    private final class View : UIView
    {
        let recognizer : ItemReordering.GestureRecognizer
        
        init(frame: CGRect, wrapping : ListReorderGesture)
        {
            self.recognizer = .init()
            
            super.init(frame: frame)
            
            self.isOpaque = false
            self.clipsToBounds = false
            self.backgroundColor = .clear
            
            self.addGestureRecognizer(self.recognizer)
        }
        
        @available(*, unavailable)
        required init?(coder aDecoder: NSCoder) {
            listableInternalFatal()
        }
    }
}


fileprivate extension ListReorderGesture {
    func accessibilityActions() -> [UIAccessibilityCustomAction]? {
        if #available(iOS 13.0, *) {
            let up = UIAccessibilityCustomAction(name: Strings.moveUp) { _  in
                return self.actions.accessibilityMove(direction: .up)
            }
            let down = UIAccessibilityCustomAction(name: Strings.moveDown) { _  in
                return self.actions.accessibilityMove(direction: .down)
            }
            return [up, down]
        } else {
            return nil
        }
    }
}


fileprivate extension ListReorderGesture
{
    struct Strings{
        static var accessibilityLabel = NSLocalizedString("Reorder", comment: "Accessibility label for the reorder control on an item")
        static var accessibilityHint = NSLocalizedString("Double tap and hold, wait for the sound, then drag to rearrange.", comment: "Accessibility hint for the reorder control in an item")
        static var moveUp = "Move up"
        static var moveDown = "Move down"
    }
}
