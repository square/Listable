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
        
        /// The button sizing algorithm used when laying out swipe actions.
        public enum ButtonSizing {
            /// Each button button receives an equal width
            case equalWidth
            
            /// Each button receives the amount of space required to fit its contents.
            case sizeThatFits
        }

        public static let `default` = Style()

        public var actionShape: Shape
        public var interActionSpacing: CGFloat
        public var containerInsets: UIEdgeInsets
        public var containerCornerRadius: CGFloat
        public var buttonSizing: ButtonSizing
        public var minWidth: CGFloat
        
        /// The percentage of the row content width that is available for laying out swipe action buttons.
        ///
        /// For example, a value of `0.8` represents that the swipe action buttons should occupy no more than
        /// 80% of the row content width when the swipe actions are opened.
        /// - Note: Currently only applicable to `ButtonSizing.equalWidth` mode.
        public var maxWidthRatio: CGFloat

        public init(
            actionShape: Shape = .rectangle(cornerRadius: 0),
            interActionSpacing: CGFloat = 0,
            containerInsets: UIEdgeInsets = .zero,
            containerCornerRadius: CGFloat = 0,
            buttonSizing: ButtonSizing = .sizeThatFits,
            minWidth: CGFloat = 0,
            maxWidthRatio: CGFloat = 0.8
        ) {
            self.actionShape = actionShape
            self.interActionSpacing = interActionSpacing
            self.containerInsets = containerInsets
            self.containerCornerRadius = containerCornerRadius
            self.buttonSizing = buttonSizing
            self.minWidth = minWidth
            self.maxWidthRatio = maxWidthRatio
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
    
    private var availableButtonWidth: CGFloat {
        guard let superview else {
            return .greatestFiniteMagnitude
        }
        
        return (superview.bounds.width * style.maxWidthRatio) - spacingWidth(numberOfButtons: actionButtons.count)
    }

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
        
        container.layer.cornerRadius = style.containerCornerRadius

        // Calculates the x origin for each button based on the width of each button before it
        // and the percent that the actions are slid open for the overlapping parallax effect
        func xOriginForButton(at index: Int) -> CGFloat {
            let previousButtons = Array(actionButtons[0..<index])
            let position = width(ofButtons: previousButtons)
            let percentOpen = bounds.width / swipeActionsWidth
            return percentOpen * position
        }

        for (index, button) in actionButtons.enumerated() {
            button.frame.size.width = width(ofButtons: [button])
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
