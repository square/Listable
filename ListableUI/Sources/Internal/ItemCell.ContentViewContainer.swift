//
//  ItemCell.ContentContainerView.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 3/23/20.
//

import UIKit


extension ItemCell {
    
    typealias Side = SwipeActionsView.Side

    final class ContentContainerView : UIView {

        let contentView : Content.ContentView
        
        private var configurations: [Side: SwipeConfiguration] = [:]
        
        private var swipeAccessibilityCustomActions: [Side: [AccessibilitySwipeAction]] = [:] {
            didSet {
                updateAccessibilityCustomActions()
            }
        }

        private (set) var swipeState: SwipeActionState = .closed {
            didSet {
                if oldValue != swipeState {
                    configurations.values.forEach { $0.swipeView.apply(state: swipeState) }
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

            if configurations.isEmpty {
                contentView.frame = bounds
            } else {
                configurations.values.forEach { updateFrames(using: $0) }
            }
        }
        
        func isTouchWithinSwipeActionView(touch: UITouch) -> Bool {
            configurations.values.first { $0.swipeView.contains(touch: touch) } != nil
        }

        private func updateFrames(using configuration: SwipeConfiguration) {
            
            let swipeViewSide = configuration.swipeView.side
            
            guard swipeState.isRelevantFor(side: swipeViewSide) else {
                return
            }
            
            let xOriginOffset: CGFloat

            switch swipeState {

            case .closed:

                xOriginOffset = 0

            case .expandActions:

                switch swipeViewSide {
                case .left:
                    xOriginOffset = bounds.width
                case .right:
                    xOriginOffset = -bounds.width
                }

            case .open:

                switch swipeViewSide {
                case .left:
                    xOriginOffset = configuration.swipeView.swipeActionsWidth
                case .right:
                    xOriginOffset = -configuration.swipeView.swipeActionsWidth
                }

            case .swiping:
                
                let translation = configuration.panGestureRecognizer.translation(in: self)
                configuration.panGestureRecognizer.setTranslation(.zero, in: self)
                
                switch swipeViewSide {
                case .left:
                    xOriginOffset = max(-bounds.width * 0.2, contentView.frame.origin.x + translation.x)
                case .right:
                    xOriginOffset = min(bounds.width * 0.2, contentView.frame.origin.x + translation.x)
                }

            case .willPerformFirstActionAutomatically:

                return
            }

            contentView.frame = bounds
            contentView.frame.origin.x = xOriginOffset
                        
            switch swipeViewSide {
            case .left:
                configuration.swipeView.frame = bounds.divided(atDistance: xOriginOffset, from: .minXEdge).slice
            case .right:
                configuration.swipeView.frame = bounds.divided(atDistance: -xOriginOffset, from: .maxXEdge).slice
            }
        }

        // MARK: - Swipe Registration
        
        // TODO: consolidate with `deregisterSwipeIfNeeded`
        public func deregisterLeadingSwipeIfNeeded() {
            guard let configuration = configurations[.left] else { return }

            removeGestureRecognizer(configuration.panGestureRecognizer)
            configuration.swipeView.removeFromSuperview()

            swipeAccessibilityCustomActions[.left] = nil
            configurations[.left] = nil
            swipeState = .closed

            setNeedsLayout()
        }

        public func deregisterSwipeIfNeeded() {
            guard let configuration = configurations[.right] else { return }

            removeGestureRecognizer(configuration.panGestureRecognizer)
            configuration.swipeView.removeFromSuperview()

            swipeAccessibilityCustomActions[.right] = nil
            configurations[.right] = nil
            swipeState = .closed

            setNeedsLayout()
        }

        public func registerSwipeActionsIfNeeded(actions: SwipeActionsConfiguration, style: SwipeActionsView.Style, reason: ApplyReason) {
            registerSwipeActionsIfNeeded(side: .right, actions: actions, style: style, reason: reason)
        }
        
        public func registerLeadingSwipeActionsIfNeeded(actions: SwipeActionsConfiguration, style: SwipeActionsView.Style, reason: ApplyReason) {
            registerSwipeActionsIfNeeded(side: .left, actions: actions, style: style, reason: reason)
        }
        
        private func registerSwipeActionsIfNeeded(
            side: SwipeActionsView.Side,
            actions: SwipeActionsConfiguration,
            style: SwipeActionsView.Style,
            reason: ApplyReason
        ) {
            if configurations[side] == nil {

                let swipeView = SwipeActionsView(
                    side: side,
                    style: style,
                    didPerformAction: { [weak self] expandActions in
                        self?.didPerformAction(expandActions: expandActions, side: side)
                    }
                )

                insertSubview(swipeView, belowSubview: contentView)
                swipeView.clipsToBounds = true
                
                let panGestureRecognizer = DirectionalPanGestureRecognizer(direction: side.gestureDirection, target: self, action: #selector(handlePan))
                addGestureRecognizer(panGestureRecognizer)

                configurations[side] = SwipeConfiguration(
                    panGestureRecognizer: panGestureRecognizer,
                    swipeView: swipeView,
                    numberOfActions: actions.actions.count,
                    performsFirstActionWithFullSwipe: actions.performsFirstActionWithFullSwipe,
                    side: side
                )
            }

            configurations[side]?.numberOfActions = actions.actions.count
            configurations[side]?.swipeView.apply(actions: actions, style: style)
            configureAccessibilityActions(actions.actions, for: side)

            if reason == .willDisplay {
                set(state: .closed)
            }
        }

        private weak var listView : ListView? = nil

        @objc private func handlePan(sender: UIPanGestureRecognizer) {

            if self.listView == nil {
                self.listView = self.firstSuperview(ofType: ListView.self)
            }
            
            guard let configuration = configurations.values.first(where: {
                $0.panGestureRecognizer == sender
            }) else {
                return
            }
                        
            let side = configuration.swipeView.side
            let offsetMultiplier = configuration.numberOfActions == 1 ? 0.5 : 0.7
            let performActionOffset = frame.width * CGFloat(offsetMultiplier)
            
            let currentSwipeOffset: CGFloat
            switch side {
            case .left:
                currentSwipeOffset = contentView.frame.origin.x
            case .right:
                currentSwipeOffset = -contentView.frame.origin.x
            }
            
            let willPerformAction = currentSwipeOffset > performActionOffset
                && configuration.performsFirstActionWithFullSwipe

            if sender.state == .began {
                self.listView?.liveCells.perform {
                    $0.closeSwipeActions()
                }
            }

            switch sender.state {
            case .began, .changed:

                let swipeState = SwipeActionState.swiping(side, willPerformAction: willPerformAction)
                set(state: swipeState)

            case .ended, .cancelled:

                let velocity = sender.velocity(in: self).x
                
                let isClosing: Bool
                
                switch side {
                case .left:
                    isClosing = velocity <= 0
                case .right:
                    isClosing = velocity >= 0
                }
                
                var swipeState: SwipeActionState
                
                if isClosing {
                    swipeState = .closed
                } else {
                    if willPerformAction {
                        swipeState = .willPerformFirstActionAutomatically(side)
                    } else {
                        swipeState = .open(side)
                    }
                }

                set(state: swipeState, animated: true)

            default:
                set(state: .closed)

            }
        }

        private func didPerformAction(expandActions: Bool, side: SwipeActionsView.Side) {
            if expandActions {
                self.set(state: .expandActions(side), animated: true)
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
            action.action.handler { _ in
                self.didPerformAction(expandActions: false, side: action.side)
            }
            return true
        }

        private func configureAccessibilityActions(_ actions: [SwipeAction], for side: Side) {
            swipeAccessibilityCustomActions[side] = actions.map {
                AccessibilitySwipeAction(action: $0, side: side, target: self, selector: #selector(performAccessibilityAction))
            }
        }
        
        private func updateAccessibilityCustomActions() {
            self.accessibilityCustomActions = swipeAccessibilityCustomActions
                .values
                .flatMap { $0 }
        }
    }

    struct SwipeConfiguration {
        let panGestureRecognizer: UIPanGestureRecognizer
        let swipeView: SwipeActionsView
        var numberOfActions: Int
        var performsFirstActionWithFullSwipe: Bool
        var side: Side
    }
}

private class AccessibilitySwipeAction: UIAccessibilityCustomAction {
    typealias Side = SwipeActionsView.Side
    
    let action: SwipeAction
    let side: SwipeActionsView.Side

    init(action: SwipeAction, side: Side, target: Any?, selector: Selector) {
        self.action = action
        self.side = side
        super.init(name: action.title ?? "", target: target, selector: selector)
    }
}

/// These states dictate the layout of the swipe actions.
public enum SwipeActionState: Equatable {
    public typealias Side = SwipeActionsView.Side
    
    /// The actions are completely collapsed.
    case closed

    /// The actions are open to their natural size.
    case open(Side)

    /// The actions are being swiped and the size is affected by the gesture recognizer.
    case swiping(Side, willPerformAction: Bool)

    /// The actions have been swiped far enough to confirm the first action.
    case willPerformFirstActionAutomatically(Side)

    /// The actions have been asked to completely expand (typically because the item is being deleted).
    case expandActions(Side)
    
    func isRelevantFor(side: Side) -> Bool {
        switch self {
        case .closed:
            return true
        case .open(let stateSide),
                .swiping(let stateSide, _),
                .willPerformFirstActionAutomatically(let stateSide),
                .expandActions(let stateSide):
            return stateSide == side
        }
    }
}

private extension SwipeActionsView.Side {
    
    var gestureDirection: DirectionalPanGestureRecognizer.Direction {
        switch self {
        case .left:
            return .leftToRight
        case .right:
            return .rightToLeft
        }
    }
}
