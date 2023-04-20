//
//  DefaultSwipeView.swift
//  ListableUI
//
//  Created by Kyle Bashour on 4/17/20.
//

import UIKit

private let haptics = UIImpactFeedbackGenerator(style: .light)

// TODO maybe doesn't need to be public (style does though...)
public final class SwipeActionsView: UIView {
    
    public enum Side: Equatable {
        case left
        case right
    }

    public struct Style: Equatable {
        public enum Shape: Equatable {
            case rectangle(cornerRadius: CGFloat)
        }

        public static let `default` = Style()

        public var actionShape: Shape
        public var interActionSpacing: CGFloat
        public var containerInsets: UIEdgeInsets
        public var containerCornerRadius: CGFloat
        public var equalButtonWidths: Bool
        public var minWidth: CGFloat

        public init(
            actionShape: Shape = .rectangle(cornerRadius: 0),
            interActionSpacing: CGFloat = 0,
            containerInsets: UIEdgeInsets = .zero,
            containerCornerRadius: CGFloat = 0,
            equalButtonWidths: Bool = false,
            minWidth: CGFloat = 0
        ) {
            self.actionShape = actionShape
            self.interActionSpacing = interActionSpacing
            self.containerInsets = containerInsets
            self.containerCornerRadius = containerCornerRadius
            self.equalButtonWidths = equalButtonWidths
            self.minWidth = minWidth
        }

        var cornerRadius: CGFloat {
            switch actionShape {
            case .rectangle(let cornerRadius):
                return cornerRadius
            }
        }
    }

    private var actionButtons: [DefaultSwipeActionButton] = []
    private let container: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }()
    private var calculatedNaturalWidth: CGFloat = 0

    private var firstAction: SwipeAction?
    private var didPerformAction: SwipeAction.CompletionHandler
    
    private var style: Style {
        didSet {
            if style != oldValue {
                setNeedsLayout()
            }
        }
    }

    public var swipeActionsWidth: CGFloat {
        calculatedNaturalWidth + safeAreaInsets.right
    }

    private var state: SwipeActionState = .closed
    
    var side: Side

    public init(
        side: Side,
        style: Style,
        didPerformAction: @escaping SwipeAction.CompletionHandler
    ) {
        self.side = side
        self.style = style
        self.didPerformAction = didPerformAction
        super.init(frame: .zero)
        clipsToBounds = true

        addSubview(container)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        let insets = style.containerInsets
        container.frame.origin.y = insets.top
        container.frame.origin.x = insets.left
        container.frame.size.width = max(0, bounds.size.width - insets.left - insets.right)
        container.frame.size.height = max(0, bounds.size.height - insets.top - insets.bottom)
        
        container.layer.cornerRadius = style.containerCornerRadius
        
        let buttons: [DefaultSwipeActionButton]
        switch side {
        case .left:
            buttons = actionButtons.reversed()
        case .right:
            buttons = actionButtons
        }
        
        // Calculates the x origin for each button based on the width of each button before it
        // and the percent that the actions are slid open for the overlapping parallax effect
        func xOriginForButton(at index: Int) -> CGFloat {
            let previousButtons = Array(buttons[0..<index])
            let position = width(ofButtons: previousButtons)
            let percentOpen = bounds.width / swipeActionsWidth
            return percentOpen * position
        }
        
        for (index, button) in buttons.enumerated() {
            button.frame.size.width = width(ofButtons: [button])
            button.frame.size.height = container.bounds.height

            // Each button is wrapped in a container that enables the parallax effect.
            // They're positioned using the function above, and the width is based on
            // the space available before the next button.
            let wrapperView = button.superview!
            wrapperView.frame = button.frame
            wrapperView.frame.origin.x = xOriginForButton(at: index) + CGFloat(index) * style.interActionSpacing
            wrapperView.frame.size.width = max(0, xOriginForButton(at: index + 1) - xOriginForButton(at: index))

            switch side {
            case .left:
                if wrapperView.frame.width > button.frame.width && buttons.count == 1 {
                    button.frame.origin.x = 0
                } else {
                    button.frame.origin.x = wrapperView.frame.width - button.frame.width
                }
            case .right:
                // If there's only one action, the button stays right-aligned while the container stretches.
                // For multiple actions, they stay left-aligned.
                if wrapperView.frame.width > button.frame.width && buttons.count == 1 {
                    button.frame.origin.x = wrapperView.frame.width - button.frame.width
                } else {
                    button.frame.origin.x = 0
                }
            }
        }

        // Adjust the last button container view to fill the safe area space
        if let lastButtonContainer = buttons.last?.superview {
            lastButtonContainer.frame.size.width = max(0, container.bounds.width - lastButtonContainer.frame.origin.x)
        }

        // If the last action will be automatically performed or the state is set to expand the actions
        // for performing the last action, have the last action fill the available space.
        if state == .swiping(side, willPerformAction: true) || state == .expandActions(side) {
            actionButtons.last?.superview?.frame = container.bounds
            
            switch side {
            case .left:
                actionButtons.last?.frame.origin.x = container.bounds.maxX - (actionButtons.last?.frame.width ?? 0)
            case .right:
                actionButtons.last?.frame.origin.x = 0
            }
            
        }
    }

    private func width(ofButtons buttons: [DefaultSwipeActionButton]) -> CGFloat {
        let spacingWidth = (CGFloat(max(0, buttons.count - 1)) * style.interActionSpacing)
        
        if style.equalButtonWidths {
            let widest = actionButtons
                .map { $0.sizeThatFits(UIView.layoutFittingCompressedSize) }
                .max { $0.width < $1.width } ?? .zero
            return CGFloat(buttons.count) * max(widest.width, style.minWidth) + spacingWidth
        } else {
            return buttons.reduce(0) { width, button in
                width + max(button.sizeThatFits(UIView.layoutFittingCompressedSize).width, style.minWidth)
            } + spacingWidth
        }
    }

    public func apply(actions: SwipeActionsConfiguration, style: Style) {
        let styleUpdateRequired = style != self.style
        
        self.style = style
                
        if actionButtons.count != actions.actions.count || styleUpdateRequired {
            actionButtons.forEach { $0.superview?.removeFromSuperview() }
            actionButtons = actions.actions.map { _ in
                let button = DefaultSwipeActionButton()
                button.layer.cornerRadius = style.cornerRadius
                let wrapperView = UIView()
                wrapperView.addSubview(button)
                wrapperView.layer.cornerRadius = style.cornerRadius
                container.addSubview(wrapperView)
                return button
            }
        }

        firstAction = actions.actions.first

        for (index, action) in actions.actions.reversed().enumerated() {
            actionButtons[index].set(action: action, didPerformAction: didPerformAction)
            actionButtons[index].superview?.backgroundColor = action.backgroundColor
        }

        calculatedNaturalWidth = width(ofButtons: actionButtons) + style.containerInsets.left + style.containerInsets.right
    }

    public func apply(state newState: SwipeActionState) {
        let priorState = state
        state = newState
        
        guard newState.isRelevantFor(side: side) else {
            return
        }
        
        haptics.prepare()

        switch (newState, priorState) {
        case (.swiping, .swiping) where newState != priorState:

            haptics.impactOccurred()
            
            UIViewPropertyAnimator {
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }.startAnimation()

        case (.willPerformFirstActionAutomatically, _):

            firstAction?.handler(didPerformAction)

        default:

            setNeedsLayout()

        }
    }
}

private class DefaultSwipeActionButton: UIButton {

    private let inset: CGFloat = 16
    private var action: SwipeAction?
    private var didPerformAction: ((Bool) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        contentEdgeInsets = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        addTarget(self, action: #selector(onTap), for: .primaryActionTriggered)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(action: SwipeAction, didPerformAction: @escaping SwipeAction.CompletionHandler) {
        self.action = action
        
        self.didPerformAction = didPerformAction
        
        // Note: We intentionally _do not_ set the background color here.
        // The superview wrapper's background color is set instead.
        // If we do both, then transparent colors will end up being stacked which leads to
        // an incorrect visual appearance.
        
        tintColor = action.tintColor
        
        setTitle(action.title, for: .normal)
        setTitleColor(action.tintColor, for: .normal)
        setImage(action.image, for: .normal)
        
        accessibilityLabel = action.accessibilityLabel
        accessibilityValue = action.accessibilityValue
        accessibilityHint = action.accessibilityHint
    }

    @objc private func onTap() {
        guard let action = action, let didPerformAction = didPerformAction else { return }
        action.handler(didPerformAction)
    }
}

extension ListEnvironment {
    
    public var swipeActionsViewStyle : SwipeActionsView.Style {
        get { self[SwipeActionsViewStyleKey.self] }
        set { self[SwipeActionsViewStyleKey.self] = newValue }
    }
}

public enum SwipeActionsViewStyleKey: ListEnvironmentKey {
    
    public static var defaultValue: SwipeActionsView.Style {
        .default
    }
}
