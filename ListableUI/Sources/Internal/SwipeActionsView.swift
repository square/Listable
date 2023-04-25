//
//  DefaultSwipeView.swift
//  ListableUI
//
//  Created by Kyle Bashour on 4/17/20.
//

import UIKit

private let haptics = UIImpactFeedbackGenerator(style: .light)

public final class SwipeActionsView: UIView {
    
    public enum Side: Equatable {
        case left
        case right
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
    
    private var style: SwipeActionsViewStyle {
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
    
    /// The side this swipe actions view will originate from when presented.
    let side: Side

    private var availableButtonWidth: CGFloat {
        guard let superview else {
            return .greatestFiniteMagnitude
        }
        
        return (superview.bounds.width * style.maxWidthRatio) - spacingWidth(numberOfButtons: actionButtons.count)
    }
    
    private var userInterfaceLayoutDirection: UIUserInterfaceLayoutDirection {
        return UIView.userInterfaceLayoutDirection(for: semanticContentAttribute)
    }

    public init(
        side: Side,
        style: SwipeActionsViewStyle,
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

        let insets = style.containerInsets(for: side, layoutDirection: userInterfaceLayoutDirection)
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
            
            func alignLeftEdge() {
                button.frame.origin.x = 0
            }
            
            func alignRightEdge() {
                button.frame.origin.x = wrapperView.frame.width - button.frame.width
            }
            
            // If there's only one action, the button stays aligned with the outer edge
            // while the container stretches.
            // For multiple actions, they stay aligned to the inner edge.
            if wrapperView.frame.width > button.frame.width && buttons.count == 1 {
                switch side {
                case .left:
                    alignLeftEdge()
                case .right:
                    alignRightEdge()
                }
            } else {
                switch side {
                case .left:
                    alignRightEdge()
                case .right:
                    alignLeftEdge()
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
        let spacingWidth = spacingWidth(numberOfButtons: buttons.count)
        
        switch style.buttonSizing {
        case .equalWidth:
            let maxWidth = availableButtonWidth / CGFloat(actionButtons.count)
            let widestWidth = actionButtons
                .map {
                    // Note: The button width may end up being less than `style.minWidth` if the
                    // calculated max width is smaller.
                    let minWidth = max($0.sizeThatFits(UIView.layoutFittingCompressedSize).width, style.minWidth)
                    return min(minWidth, maxWidth)
                }
                .max() ?? .zero
            
            return CGFloat(buttons.count) * widestWidth + spacingWidth

        case .sizeThatFits:
            return buttons.map {
                max($0.sizeThatFits(UIView.layoutFittingCompressedSize).width, style.minWidth)
            }
            .reduce(0, +) + spacingWidth
        }
    }
    
    private func spacingWidth(numberOfButtons: Int) -> CGFloat {
        return (CGFloat(max(0, numberOfButtons - 1)) * style.interActionSpacing)
    }

    public func apply(actions: SwipeActionsConfiguration, style: SwipeActionsViewStyle) {
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
        
        let containerInsets = style.containerInsets(for: side, layoutDirection: userInterfaceLayoutDirection)

        calculatedNaturalWidth = width(ofButtons: actionButtons) + containerInsets.left + containerInsets.right
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
        titleLabel?.lineBreakMode = .byTruncatingTail
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

private extension SwipeActionsViewStyle {
    
    /// The container insets to use for the given side and layout direction.
    func containerInsets(for side: SwipeActionsView.Side, layoutDirection: UIUserInterfaceLayoutDirection) -> UIEdgeInsets {
        
        let directionalInsets: NSDirectionalEdgeInsets
        
        switch (side, layoutDirection) {
        case (.left, .leftToRight):
            directionalInsets = leadingContainerInsets
        case (.right, .leftToRight):
            directionalInsets = trailingContainerInsets
        case (.left, .rightToLeft):
            directionalInsets = trailingContainerInsets
        case (.right, .rightToLeft):
            directionalInsets = leadingContainerInsets
        @unknown default:
            assertionFailure("New UIUserInterfaceLayoutDirection")
            directionalInsets = leadingContainerInsets
        }
        
        return directionalInsets.edgeInsets(for: layoutDirection)
    }
}

private extension NSDirectionalEdgeInsets {
    func edgeInsets(for layoutDirection: UIUserInterfaceLayoutDirection) -> UIEdgeInsets {
        switch layoutDirection {
        case .leftToRight:
            return UIEdgeInsets(top: top, left: leading, bottom: bottom, right: trailing)
        case .rightToLeft:
            return UIEdgeInsets(top: top, left: trailing, bottom: bottom, right: leading)
        @unknown default:
            assertionFailure("New UIUserInterfaceLayoutDirection")
            return UIEdgeInsets(top: top, left: leading, bottom: bottom, right: trailing)
        }
    }
}
