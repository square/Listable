//
//  DefaultSwipeView.swift
//  ListableUI
//
//  Created by Kyle Bashour on 4/17/20.
//

import UIKit

private let haptics = UIImpactFeedbackGenerator(style: .light)

public final class DefaultSwipeActionsView: UIView, ItemContentSwipeActionsView {

    public struct Style: Equatable {
        public enum Shape: Equatable {
            case rectangle(cornerRadius: CGFloat)
        }

        public static let `default` = Style()

        public var actionShape: Shape
        public var interActionSpacing: CGFloat
        public var containerInsets: UIEdgeInsets

        public init(
            actionShape: Shape = .rectangle(cornerRadius: 0),
            interActionSpacing: CGFloat = 0,
            containerInsets: UIEdgeInsets = .zero
        ) {
            self.actionShape = actionShape
            self.interActionSpacing = interActionSpacing
            self.containerInsets = containerInsets
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
    private let style: Style

    public var swipeActionsWidth: CGFloat {
        calculatedNaturalWidth + safeAreaInsets.right
    }

    private var state: SwipeActionState = .closed

    public init(
        style: Style,
        didPerformAction: @escaping SwipeAction.CompletionHandler
    ) {
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

        // Calculates the x origin for each button based on the width of each button before it
        // and the percent that the actions are slid open for the overlapping parallax effect
        func xOriginForButton(at index: Int) -> CGFloat {
            let previousButtons = Array(actionButtons[0..<index])
            let position = width(ofButtons: previousButtons)
            let percentOpen = bounds.width / swipeActionsWidth
            return percentOpen * position
        }

        for (index, button) in actionButtons.enumerated() {
            // Size each button to its natural size, but always match the height
            button.sizeToFit()
            button.frame.size.height = container.bounds.height

            // Each button is wrapped in a container that enables the parallax effect.
            // They're positioned using the function above, and the width is based on
            // the space available before the next button.
            let wrapperView = button.superview!
            wrapperView.frame = button.frame
            wrapperView.frame.origin.x = xOriginForButton(at: index) + CGFloat(index) * style.interActionSpacing
            wrapperView.frame.size.width = max(0, xOriginForButton(at: index + 1) - xOriginForButton(at: index))

            // If there's only one action, the button stays right-aligned while the container stretches.
            // For multiple actions, they stay left-aligned.
            if wrapperView.frame.width > button.frame.width && actionButtons.count == 1 {
                button.frame.origin.x = wrapperView.frame.width - button.frame.width
            } else {
                button.frame.origin.x = 0
            }
        }

        // Adjust the last button container view to fill the safe area space
        if let lastButtonContainer = actionButtons.last?.superview {
            lastButtonContainer.frame.size.width = max(0, container.bounds.width - lastButtonContainer.frame.origin.x)
        }

        // If the last action will be automatically performed or the state is set to expand the actions
        // for performing the last action, have the last action fill the available space.
        if state == .swiping(willPerformAction: true) || state == .expandActions {
            actionButtons.last?.superview?.frame = container.bounds
            actionButtons.last?.frame.origin.x = 0
        }
    }

    private func width(ofButtons buttons: [DefaultSwipeActionButton]) -> CGFloat {
        buttons.reduce(0) { width, button in
            width + button.sizeThatFits(UIView.layoutFittingCompressedSize).width
        } + CGFloat(max(0, buttons.count - 1)) * style.interActionSpacing
    }

    public func apply(actions: SwipeActionsConfiguration) {
        if actionButtons.count != actions.actions.count {
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

    public func apply(state: SwipeActionState) {
        haptics.prepare()

        switch (state, self.state) {
        case (.swiping, .swiping) where state != self.state:

            self.state = state

            haptics.impactOccurred()

            UIViewPropertyAnimator {
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }.startAnimation()

        case (.willPerformFirstActionAutomatically, _):

            firstAction.flatMap { action in
                action.handler(didPerformAction)
            }

        default:

            self.state = state

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
        tintColor = .white
        contentEdgeInsets = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        addTarget(self, action: #selector(onTap), for: .primaryActionTriggered)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(action: SwipeAction, didPerformAction: @escaping SwipeAction.CompletionHandler) {
        self.action = action
        self.didPerformAction = didPerformAction
        backgroundColor = action.backgroundColor
        setTitle(action.title, for: .normal)
        setImage(action.image, for: .normal)
    }

    @objc private func onTap() {
        guard let action = action, let didPerformAction = didPerformAction else { return }
        action.handler(didPerformAction)
    }
}
