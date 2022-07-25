//
//  HeaderFooterContentView.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 8/11/20.
//

import UIKit

final class HeaderFooterContentView<Content: HeaderFooterContent>: UIView {
    //

    // MARK: Properties

    //

    typealias OnTap = () -> Void

    var onTap: OnTap? {
        didSet { updateIsTappable() }
    }

    let content: Content.ContentView
    let background: Content.BackgroundView
    let pressedBackground: Content.PressedBackgroundView

    private let pressRecognizer: PressGestureRecognizer

    //

    // MARK: Initialization

    //

    override init(frame: CGRect) {
        let bounds = CGRect(origin: .zero, size: frame.size)

        content = Content.createReusableContentView(frame: bounds)
        background = Content.createReusableBackgroundView(frame: bounds)
        pressedBackground = Content.createReusablePressedBackgroundView(frame: bounds)

        pressRecognizer = PressGestureRecognizer()
        pressRecognizer.minimumPressDuration = 0.0
        pressRecognizer.allowableMovementAfterBegin = 5.0

        super.init(frame: frame)

        pressRecognizer.addTarget(self, action: #selector(pressStateChanged))

        addSubview(background)
        addSubview(pressedBackground)
        addSubview(content)

        updateIsTappable()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError() }

    //

    // MARK: UIView

    //

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        content.sizeThatFits(size)
    }

    override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        content.systemLayoutSizeFitting(targetSize)
    }

    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        content.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: verticalFittingPriority
        )
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        content.frame = bounds
        background.frame = bounds
        pressedBackground.frame = bounds
    }

    //

    // MARK: Tap Handling

    //

    private func updateIsTappable() {
        removeGestureRecognizer(pressRecognizer)

        if onTap != nil {
            accessibilityTraits = [.header, .button]

            pressedBackground.isHidden = false
            pressedBackground.alpha = 0.0

            addGestureRecognizer(pressRecognizer)
        } else {
            accessibilityTraits = [.header]

            pressedBackground.isHidden = true
        }
    }

    @objc private func pressStateChanged() {
        let state = pressRecognizer.state

        switch state {
        case .possible:
            break

        case .began, .changed:
            pressedBackground.alpha = 1.0

        case .ended, .cancelled, .failed:
            let didEnd = state == .ended

            UIView.animate(withDuration: didEnd ? 0.1 : 0.0) {
                self.pressedBackground.alpha = 0.0
            }

            if didEnd {
                onTap?()
            }

        @unknown default: break
        }
    }
}

private final class PressGestureRecognizer: UILongPressGestureRecognizer {
    var allowableMovementAfterBegin: CGFloat = 0.0

    private var initialPoint: CGPoint?

    override func reset() {
        super.reset()

        initialPoint = nil
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)

        initialPoint = location(in: view)
    }

    override func canPrevent(_ gesture: UIGestureRecognizer) -> Bool {
        // We want to allow the pan gesture of our containing scroll view to continue to track
        // when the user moves their finger vertically or horizontally, when we are cancelled.

        if let panGesture = gesture as? UIPanGestureRecognizer, panGesture.view is UIScrollView {
            return false
        }

        return super.canPrevent(gesture)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)

        if let initialPoint = initialPoint {
            let currentPoint = location(in: view)

            let distance = sqrt(pow(abs(initialPoint.x - currentPoint.x), 2) + pow(abs(initialPoint.y - currentPoint.y), 2))

            if distance > allowableMovementAfterBegin {
                state = .failed
            }
        }
    }
}
