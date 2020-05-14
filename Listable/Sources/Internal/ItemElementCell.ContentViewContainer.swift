//
//  ItemCellView.swift
//  Listable
//
//  Created by Kyle Van Essen on 3/23/20.
//

import UIKit


extension ItemElementCell {

    final class ContentContainerView : UIView {

        let contentView : Element.Appearance.ContentView

        private var swipeConfiguration: SwipeConfiguration?
        private var swipeState: SwipeActionState = .closed {
            didSet {
                if oldValue != swipeState {
                    swipeConfiguration?.swipeView.apply(state: swipeState)
                }
            }
        }

        override init(frame : CGRect) {
            let bounds = CGRect(origin: .zero, size: frame.size)

            self.contentView = Element.Appearance.createReusableItemView(frame: bounds)

            super.init(frame: frame)

            isAccessibilityElement = true

            self.addSubview(self.contentView)

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(didReceiveCloseNotification),
                name: .closeSwipeActions, object: nil
            )
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) { fatalError() }

        override func layoutSubviews() {
            super.layoutSubviews()

            if let configuration = swipeConfiguration {
                updateFrames(using: configuration)
            } else {
                contentView.frame = bounds
            }
        }

        private func updateFrames(using configuration: SwipeConfiguration) {

            let xOriginOffset: CGFloat

            switch swipeState {

            case .closed:

                xOriginOffset = 0

            case .expandActions:

                xOriginOffset = -bounds.width

            case .open:

                xOriginOffset = -configuration.swipeView.swipeActionsWidth

            case .swiping:

                let translation = configuration.panGestureRecognizer.translation(in: self)
                xOriginOffset = contentView.frame.origin.x + translation.x

                configuration.panGestureRecognizer.setTranslation(.zero, in: self)

            case .willPerformFirstActionAutomatically:

                return

            }

            contentView.frame = bounds
            contentView.frame.origin.x = xOriginOffset
            configuration.swipeView.frame = bounds.divided(atDistance: -xOriginOffset, from: .maxXEdge).slice
        }

        // MARK: - Swipe Registration

        public func deregisterSwipeIfNeeded() {
            guard let configuration = swipeConfiguration else { return }

            removeGestureRecognizer(configuration.panGestureRecognizer)
            configuration.swipeView.removeFromSuperview()

            accessibilityCustomActions = nil
            swipeConfiguration = nil
            swipeState = .closed

            setNeedsLayout()
        }

        public func registerSwipeActionsIfNeeded(actions: SwipeActionsConfiguration, reason: ApplyReason) {
            if swipeConfiguration == nil {

                let swipeView = Element.SwipeActionsView(didPerformAction: self.didPerformAction)

                insertSubview(swipeView, belowSubview: contentView)
                swipeView.clipsToBounds = true

                let panGestureRecognizer = HorizontalPanGestureRecognizer(target: self, action: #selector(handlePan))
                addGestureRecognizer(panGestureRecognizer)

                swipeConfiguration = SwipeConfiguration(
                    panGestureRecognizer: panGestureRecognizer,
                    swipeView: swipeView,
                    numberOfActions: actions.actions.count
                )
            }

            swipeConfiguration?.numberOfActions = actions.actions.count
            swipeConfiguration?.swipeView.apply(actions: actions)
            configureAccessibilityActions(for: actions.actions)

            if reason == .willDisplay {
                set(state: .closed)
            }
        }

        @objc private func handlePan(sender: UIPanGestureRecognizer) {
            guard let configuration = swipeConfiguration else { return }

            let offsetMultiplier = configuration.numberOfActions == 1 ? 0.5 : 0.7
            let performActionOffset = frame.width * CGFloat(offsetMultiplier)
            let currentSwipeOffset = -contentView.frame.origin.x
            let willPerformAction = currentSwipeOffset > performActionOffset

            if sender.state == .began {
                let notification = Notification(name: .closeSwipeActions, object: self)
                NotificationCenter.default.post(notification)
            }

            switch sender.state {
            case .began, .changed:

                let swipeState = SwipeActionState.swiping(willPerformAction: willPerformAction)
                set(state: swipeState)

            case .ended, .cancelled:

                let swipeActionsWidth = configuration.swipeView.swipeActionsWidth
                let keepOpenOffset = swipeActionsWidth / 2
                let velocity = sender.velocity(in: self).x

                var swipeState: SwipeActionState

                if velocity < 0 {

                    if willPerformAction {
                        swipeState = .willPerformFirstActionAutomatically
                    } else {
                        swipeState = .open
                    }

                } else if velocity > 0 {

                    swipeState = .closed

                } else {

                    if willPerformAction {
                        swipeState = .willPerformFirstActionAutomatically
                    } else if currentSwipeOffset > keepOpenOffset {
                        swipeState = .open
                    } else {
                        swipeState = .closed
                    }

                }

                set(state: swipeState, animated: true)


            default:

                set(state: .closed)

            }
        }

        private func didPerformAction(expandActions: Bool) {
            if expandActions {
                self.set(state: .expandActions, animated: true)
            } else {
                self.set(state: .closed, animated: true)
            }
        }

        private func set(state: SwipeActionState, animated: Bool = false) {
            
            guard swipeState != state else {
                return
            }
            
            swipeState = state

            if animated {
                UIViewPropertyAnimator {
                    self.setNeedsLayout()
                    self.layoutIfNeeded()
                }.startAnimation()
            } else {
                setNeedsLayout()
            }
        }

        @objc private func didReceiveCloseNotification(notification: Notification) {
            if notification.object as AnyObject? !== self {
                set(state: .closed, animated: true)
            }
        }

        @objc private func performAccessibilityAction(_ action: AccessibilitySwipeAction) {
            action.action.handler(self.didPerformAction)
        }

        private func configureAccessibilityActions(for actions: [SwipeAction]) {
            self.accessibilityCustomActions = actions.map {
                AccessibilitySwipeAction(action: $0, target: self, selector: #selector(performAccessibilityAction))
            }
        }
    }

    struct SwipeConfiguration {
        let panGestureRecognizer: UIPanGestureRecognizer
        let swipeView: Element.SwipeActionsView
        var numberOfActions: Int
    }
}

private class AccessibilitySwipeAction: UIAccessibilityCustomAction {
    let action: SwipeAction

    init(action: SwipeAction, target: Any?, selector: Selector) {
        self.action = action
        super.init(name: action.title ?? "", target: target, selector: selector)
    }
}

/// These states dictate the layout of the swipe actions.
public enum SwipeActionState: Equatable {
    /// The actions are completely collapsed.
    case closed

    /// The actions are open to their natural size.
    case open

    /// The actions are being swiped and the size is affected by the gesture recognizer.
    case swiping(willPerformAction: Bool)

    /// The actions have been swiped far enough to confirm the first action.
    case willPerformFirstActionAutomatically

    /// The actions have been asked to completely expand (typically because the item is being deleted).
    case expandActions
}
