//
//  ListReorderGesture.swift
//  BlueprintUILists
//
//  Created by Kyle Van Essen on 11/14/19.
//

import Accessibility
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
    
    /// The acccessibility label for the reorder element. Defaults  to "Reorder".
    public var accessibilityLabel : String?
    
    /// The acccessibility identifier for the reorder element.
    public var accessibilityIdentifier : String?
    
    /// Creates a new re-order gesture which wraps the provided element.
    /// 
    /// This element on its own has no visual appearance. Thus, you should
    /// still render your own reorder dragger / handle / etc in the passed in element.
    public init(
        isEnabled : Bool = true,
        actions : ReorderingActions,
        begins: Begins = .onTap,
        accessibilityLabel: String? = nil,
        accessibilityIdentifier: String? = nil,
        wrapping element : Element
    ) {
        self.isEnabled =  isEnabled
        
        self.actions = actions

        self.begins = begins
        
        self.accessibilityLabel = accessibilityLabel
        
        self.accessibilityIdentifier = accessibilityIdentifier
        
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
            config.contentView = { $0.containerView }
            
            config.apply { view in
                view.apply(self)
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
        begins: ListReorderGesture.Begins = .onTap,
        accessibilityLabel: String? = nil,
        accessibilityIdentifier: String? = nil
    ) -> Element {
        ListReorderGesture(isEnabled: isEnabled,
                           actions: actions,
                           begins: begins,
                           accessibilityLabel: accessibilityLabel,
                           accessibilityIdentifier: accessibilityIdentifier,
                           wrapping: self)
    }
}


fileprivate extension ListReorderGesture
{
    private final class View : UIView
    {
        
        let containerView = UIView()
        let recognizer : ItemReordering.GestureRecognizer
        private lazy var proxyElement = UIAccessibilityElement(accessibilityContainer: self)
        private var minimumPressDuration: TimeInterval = 0.0 {
            didSet {
                updateGesturePressDuration()
            }
        }
        
        @objc private func updateGesturePressDuration() {
            self.recognizer.minimumPressDuration = UIAccessibility.isVoiceOverRunning ? 0.0 : self.minimumPressDuration
        }
        
        init(frame: CGRect, wrapping : ListReorderGesture)
        {
            self.recognizer = .init()
            
            super.init(frame: frame)
            recognizer.accessibilityProxy = proxyElement
            NotificationCenter.default.addObserver(self, selector: #selector(updateGesturePressDuration) , name: UIAccessibility.voiceOverStatusDidChangeNotification, object: nil)

            self.isOpaque = false
            self.clipsToBounds = false
            self.backgroundColor = .clear
            
            self.addGestureRecognizer(self.recognizer)
            
            self.isAccessibilityElement = false
            
            containerView.isOpaque = false
            containerView.backgroundColor = .clear
            addSubview(containerView)
        }
        
        @available(*, unavailable)
        required init?(coder aDecoder: NSCoder) {
            listableInternalFatal()
        }
        
        func apply(_ model: ListReorderGesture) {
            proxyElement.accessibilityLabel = model.accessibilityLabel ?? ListableLocalizedStrings.ReorderGesture.accessibilityLabel
            proxyElement.accessibilityHint = ListableLocalizedStrings.ReorderGesture.accessibilityHint
            proxyElement.accessibilityIdentifier = model.accessibilityIdentifier
            proxyElement.accessibilityTraits.formUnion(.button)
            proxyElement.accessibilityCustomActions = model.accessibilityActions()
            
            recognizer.isEnabled = model.isEnabled
            
            recognizer.apply(actions: model.actions)
            minimumPressDuration = model.begins == .onLongPress ? 0.5 : 0.0
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            containerView.frame = bounds
        }
        
        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            if UIAccessibility.isVoiceOverRunning,
               UIAccessibility.focusedElement(using: .notificationVoiceOver) as? NSObject == proxyElement {
                // Intercept touch events to avoid activating contained elements.
                return self
            }
            
            return super.hitTest(point, with: event)
        }
        
        override var accessibilityElements: [Any]? {
            get {
                guard recognizer.isEnabled else { return super.accessibilityElements }
                proxyElement.accessibilityFrame = self.accessibilityFrame
                proxyElement.accessibilityActivationPoint = self.accessibilityActivationPoint
                return [containerView, proxyElement]
            }
            set {
                fatalError("Cannot set accessibility elements directly")
            }
        }
    }
}


fileprivate extension ListReorderGesture {
    func accessibilityActions() -> [UIAccessibilityCustomAction]? {
        let up = UIAccessibilityCustomAction(name: ListableLocalizedStrings.ReorderGesture.accessibilityMoveUp) { _  in
            return self.actions.accessibilityMove(direction: .up)
        }
        let down = UIAccessibilityCustomAction(name: ListableLocalizedStrings.ReorderGesture.accessibilityMoveDown) { _  in
            return self.actions.accessibilityMove(direction: .down)
        }
        
        return [up, down]
    }
}
