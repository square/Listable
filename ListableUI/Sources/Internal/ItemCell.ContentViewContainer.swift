//
//  ItemCell.ContentContainerView.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 3/23/20.
//

import UIKit


extension ItemCell {

    final class ContentContainerView : UIView {

        let contentView : Content.ContentView

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

            self.contentView = Content.createReusableContentView(frame: bounds)

            super.init(frame: frame)

            self.addSubview(self.contentView)
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
                // No actions exist to the left, so limit overscrolling to the right to 20% of the width.
                xOriginOffset = min(bounds.width / 5.0, contentView.frame.origin.x + translation.x)

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

                let swipeView = Content.SwipeActionsView(didPerformAction: self.didPerformAction)

                insertSubview(swipeView, belowSubview: contentView)
                swipeView.clipsToBounds = true

                let panGestureRecognizer = HorizontalPanGestureRecognizer(target: self, action: #selector(handlePan))
                addGestureRecognizer(panGestureRecognizer)

                swipeConfiguration = SwipeConfiguration(
                    panGestureRecognizer: panGestureRecognizer,
                    swipeView: swipeView,
                    numberOfActions: actions.actions.count,
                    performsFirstActionWithFullSwipe: actions.performsFirstActionWithFullSwipe
                )
            }

            swipeConfiguration?.numberOfActions = actions.actions.count
            swipeConfiguration?.swipeView.apply(actions: actions)
            configureAccessibilityActions(for: actions.actions)

            if reason == .willDisplay {
                set(state: .closed)
            }
        }

        private weak var listView : ListView? = nil

        @objc private func handlePan(sender: UIPanGestureRecognizer) {

            if self.listView == nil {
                self.listView = self.firstSuperview(ofType: ListView.self)
            }

            guard let configuration = swipeConfiguration else { return }

            let velocity = sender.velocity(in: self).x
            let offsetMultiplier = configuration.numberOfActions == 1 ? 0.5 : 0.7
            let performActionOffset = frame.width * CGFloat(offsetMultiplier)
            let currentSwipeOffset = -contentView.frame.origin.x
            let willPerformAction = currentSwipeOffset > performActionOffset
                && configuration.performsFirstActionWithFullSwipe

            if sender.state == .began {
                self.listView?.liveCells.perform {
                    $0.closeSwipeActions()
                }
            }

            switch sender.state {
            case .began, .changed:

                if swipeState == .closed && velocity > 0 {
                    // The cell is closed and this is a swipe to the right. Ignore the swipe.
                    sender.setTranslation(.zero, in: self)
                } else {
                    let swipeState = SwipeActionState.swiping(willPerformAction: willPerformAction)
                    set(state: swipeState)
                }

            case .ended, .cancelled:

                let swipeActionsWidth = configuration.swipeView.swipeActionsWidth
                let keepOpenOffset = swipeActionsWidth / 2

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

        func performAnimatedClose() {
            self.set(state: .closed, animated: true)
        }

        private func set(state: SwipeActionState, animated: Bool = false) {

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

        @objc private func performAccessibilityAction(_ action: AccessibilitySwipeAction) -> Bool {
            action.action.handler(self.didPerformAction)
            return true
        }

        private func configureAccessibilityActions(for actions: [SwipeAction]) {
            self.accessibilityCustomActions = actions.map {
                AccessibilitySwipeAction(action: $0, target: self, selector: #selector(performAccessibilityAction))
            }
        }
    }

    struct SwipeConfiguration {
        let panGestureRecognizer: UIPanGestureRecognizer
        let swipeView: Content.SwipeActionsView
        var numberOfActions: Int
        var performsFirstActionWithFullSwipe: Bool
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
