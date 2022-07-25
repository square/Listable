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
public struct ListReorderGesture: Element {
    public enum Begins {
        case onTap
        case onLongPress
    }

    /// The element which is being wrapped by the reorder gesture.
    public var element: Element

    /// If the gesture is enabled or not.
    public var isEnabled: Bool

    /// Condition to start the reorder gesture
    public var begins: Begins

    let actions: ReorderingActions

    /// The acccessibility Label of the item that will be reordered.
    /// This will be set as the gesture's accessibilityValue to provide a richer VoiceOver utterance.
    public var reorderItemAccessibilityLabel: String?

    /// Creates a new re-order gesture which wraps the provided element.
    ///
    /// This element on its own has no visual appearance. Thus, you should
    /// still render your own reorder dragger / handle / etc in the passed in element.
    public init(
        isEnabled: Bool = true,
        actions: ReorderingActions,
        begins: Begins = .onTap,
        wrapping element: Element
    ) {
        self.isEnabled = isEnabled

        self.actions = actions

        self.begins = begins

        self.element = element
    }

    //

    // MARK: Element

    //

    public var content: ElementContent {
        ElementContent(child: element)
    }

    public func backingViewDescription(with context: ViewDescriptionContext) -> ViewDescription? {
        ViewDescription(View.self) { config in
            config.builder = {
                View(frame: context.bounds, wrapping: self)
            }

            config.apply { view in
                view.isAccessibilityElement = true
                view.accessibilityLabel = ListableLocalizedStrings.ReorderGesture.accessibilityLabel
                view.accessibilityValue = reorderItemAccessibilityLabel
                view.accessibilityHint = ListableLocalizedStrings.ReorderGesture.accessibilityHint
                view.accessibilityTraits.formUnion(.button)
                view.accessibilityCustomActions = accessibilityActions()

                view.recognizer.isEnabled = self.isEnabled

                view.recognizer.apply(actions: self.actions)

                view.recognizer.minimumPressDuration = begins == .onLongPress ? 0.5 : 0.0
            }
        }
    }
}

public extension Element {
    /// Wraps the element in a re-order gesture.
    func listReorderGesture(
        with actions: ReorderingActions,
        isEnabled: Bool = true,
        begins: ListReorderGesture.Begins = .onTap
    ) -> Element {
        ListReorderGesture(isEnabled: isEnabled, actions: actions, begins: begins, wrapping: self)
    }
}

private extension ListReorderGesture {
    private final class View: UIView {
        let recognizer: ItemReordering.GestureRecognizer

        init(frame: CGRect, wrapping _: ListReorderGesture) {
            recognizer = .init()

            super.init(frame: frame)

            isOpaque = false
            clipsToBounds = false
            backgroundColor = .clear

            addGestureRecognizer(recognizer)
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            listableInternalFatal()
        }
    }
}

private extension ListReorderGesture {
    func accessibilityActions() -> [UIAccessibilityCustomAction]? {
        if #available(iOS 13.0, *) {
            let up = UIAccessibilityCustomAction(name: ListableLocalizedStrings.ReorderGesture.accessibilityMoveUp) { _ in
                self.actions.accessibilityMove(direction: .up)
            }
            let down = UIAccessibilityCustomAction(name: ListableLocalizedStrings.ReorderGesture.accessibilityMoveDown) { _ in
                self.actions.accessibilityMove(direction: .down)
            }
            return [up, down]
        } else {
            return nil
        }
    }
}
