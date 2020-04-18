//
//  DefaultSwipeView.swift
//  Listable
//
//  Created by Kyle Bashour on 4/17/20.
//

import UIKit

private let haptics = UIImpactFeedbackGenerator(style: .light)

public final class DefaultSwipeActionsView: UIView, ItemElementSwipeActionsView {

    private var actionButtons: [DefaultSwipeActionButton] = []
    private var calculatedNaturalWidth: CGFloat = 0

    private var firstAction: SwipeAction?
    private var didPerformAction: SwipeAction.CompletionHandler

    public var swipeActionsWidth: CGFloat { calculatedNaturalWidth }

    private var state: SwipeActionState = .closed

    public init(didPerformAction: @escaping SwipeAction.CompletionHandler) {
        self.didPerformAction = didPerformAction
        super.init(frame: .zero)
        clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        func xOriginForButton(at index: Int) -> CGFloat {
            let previousButtons = Array(actionButtons[0..<index])
            let position = width(ofButtons: previousButtons)
            let percentOpen = bounds.width / calculatedNaturalWidth
            return percentOpen * position
        }

        for (index, button) in actionButtons.enumerated() {
            button.sizeToFit()
            button.frame.size.height = bounds.height

            let wrapperView = button.superview!
            wrapperView.frame = button.frame
            wrapperView.frame.origin.x = xOriginForButton(at: index)
            wrapperView.frame.size.width = xOriginForButton(at: index + 1) - xOriginForButton(at: index)

            if wrapperView.frame.width > button.frame.width && actionButtons.count == 1 {
                button.frame.origin.x = wrapperView.frame.width - button.frame.width
            } else {
                button.frame.origin.x = 0
            }
        }

        if state == .swiping(willPerformAction: true) || state == .expandActions {
            actionButtons.last?.superview?.frame = bounds
            actionButtons.last?.frame.origin.x = 0
        }
    }

    private func width(ofButtons buttons: [DefaultSwipeActionButton]) -> CGFloat {
        buttons.reduce(0) { width, button in
            width + button.sizeThatFits(UIView.layoutFittingCompressedSize).width
        }
    }

    public func apply(actions: SwipeActionsConfiguration) {
        if actionButtons.count != actions.actions.count {
            actionButtons.forEach { $0.superview?.removeFromSuperview() }
            actionButtons = actions.actions.map { _ in
                let button = DefaultSwipeActionButton()
                let wrapperView = UIView()
                wrapperView.addSubview(button)
                addSubview(wrapperView)
                return button
            }
        }

        firstAction = actions.actions.first

        for (index, action) in actions.actions.reversed().enumerated() {
            actionButtons[index].set(action: action, didPerformAction: didPerformAction)
            actionButtons[index].superview?.backgroundColor = action.backgroundColor
        }

        calculatedNaturalWidth = width(ofButtons: actionButtons)
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
