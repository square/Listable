//
//  ItemCellView.swift
//  Listable
//
//  Created by Kyle Van Essen on 3/23/20.
//

import UIKit


extension ItemElementCell
{
    final class ContentView : UIView, SwipeControllerDelegate
    {
        private(set) var contentView : Element.Appearance.ContentView

        private var swipeController: SwipeController?
        private var swipeView : SwipeController.SwipeView?

        override init(frame : CGRect)
        {
            let bounds = CGRect(origin: .zero, size: frame.size)

            self.contentView = Element.Appearance.createReusableItemView(frame: bounds)

            super.init(frame: frame)

            self.addSubview(self.contentView)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) { fatalError() }

        override func layoutSubviews()
        {
            super.layoutSubviews()

            guard let swipeController = self.swipeController, let swipeView = self.swipeView else {
                contentView.frame = self.bounds
                return
            }

            // Set frames if swiping is supported

            switch swipeController.state {

            case .pending:
                self.setFrames(newOrigin: 0)

            case .locked:
                let lowerThreshold = swipeView.preferredSize().width
                self.setFrames(newOrigin: -lowerThreshold)

            case .finished:
                let end = self.bounds.width
                self.setFrames(newOrigin: -end)

            case .swiping(swipeThrough: _):
                let newOrigin = swipeController.calculateNewOrigin(clearTranslation: true)
                self.setFrames(newOrigin: newOrigin.x)
            }

        }

        // MARK: - Swipe

        public func restoreSwipe()
        {
            swipeController = nil
            swipeView?.removeFromSuperview()
            swipeView = nil
        }

        public func prepareForSwipeActions(actions: SwipeActions)
        {
            guard self.swipeController == nil else { return }

            let swipeView = SwipeController.SwipeView(action: actions.actions.first!)

            let swipeController = SwipeController(
                actions: actions,
                contentView: self.contentView,
                containerView: self,
                swipeView: swipeView
            )

            swipeController.configure()
            swipeController.delegate = self

            self.insertSubview(swipeView, belowSubview: self.contentView)

            self.swipeController = swipeController
            self.swipeView = swipeView

            self.setNeedsLayout()
            self.layoutIfNeeded()
        }

        private func setFrames(newOrigin: CGFloat)
        {
            let width = self.bounds.width
            var frame = self.contentView.frame
            frame.origin.x = newOrigin
            self.contentView.frame = frame

            let originX = frame.maxX
            let swipeWidth = width - originX

            self.swipeView?.frame = CGRect(
                x: originX,
                y: frame.origin.y,
                width: swipeWidth,
                height: frame.height
            )
        }

        // MARK: - Swipe Controller Delegate

        func swipeController(panDidMove controller: SwipeController)
        {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }

        func swipeController(panDidEnd controller: SwipeController)
        {
            UIView.animate(withDuration: 0.2) {
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
        }
    }
}

protocol SwipeControllerDelegate: class {

    func swipeController(panDidMove controller: SwipeController)
    func swipeController(panDidEnd controller: SwipeController)

}

class SwipeController: NSObject {

    enum State {
        case pending
        case swiping(swipeThrough: Bool)
        case locked
        case finished
    }

    var state: State = .pending {
        didSet {
            self.swipeView?.state = state
        }
    }

    var actions: SwipeActions
    weak var swipeView: SwipeView?
    weak var contentView: UIView?
    weak var containerView: UIView?

    weak var collectionView: UICollectionView?

    weak var delegate: SwipeControllerDelegate?

    private(set) var gestureRecognizer: UIPanGestureRecognizer

    init(
        actions: SwipeActions,
        contentView: UIView,
        containerView: UIView,
        swipeView: SwipeView)
    {
        self.actions = actions
        self.contentView = contentView
        self.containerView = containerView
        self.gestureRecognizer = UIPanGestureRecognizer()
        self.swipeView = swipeView

        super.init()
    }

    func configure()
    {
        gestureRecognizer.addTarget(self, action: #selector(onPan(_:)))
        containerView?.addGestureRecognizer(self.gestureRecognizer)
    }

    deinit
    {
        self.containerView?.removeGestureRecognizer(self.gestureRecognizer)
    }

    func performSwipeThroughAction()
    {
        if let action = actions.actions.first {
            let _ = action.onTap(action)
        }
    }

    @objc func onPan(_ pan: UIPanGestureRecognizer)
    {
        switch pan.state {
        case .began:
            guard let collectionView = SwipeController.findCollectionView(child: containerView), self.collectionView == nil else { return }
            collectionView.panGestureRecognizer.addTarget(self, action: #selector(collectionViewPan))
            self.collectionView = collectionView
        case .changed:
            panChanged(pan)
        case .failed, .cancelled, .ended:
            panEnded(pan)
        default:
            break
        }
    }

    private func panChanged(_ pan: UIPanGestureRecognizer)
    {
        let originInContainer = self.calculateNewOrigin()
        self.state = self.panningState(originInContainer: originInContainer)

        self.delegate?.swipeController(panDidMove: self)
    }

    private func panEnded(_ pan: UIPanGestureRecognizer)
    {
        let originInContainer = self.calculateNewOrigin()
        self.state = self.endState(originInContainer: originInContainer)

        self.delegate?.swipeController(panDidEnd: self)

        if case .finished = self.state, self.swipeThroughEnabled {
            self.performSwipeThroughAction()
        }
    }

    //

    private func panningState(originInContainer: CGPoint) -> State
    {
        if originInContainer.x > 0 {
            return .pending
        } else
            if originInContainer.x < self.swipeThroughOriginX && self.swipeThroughEnabled {
            return .swiping(swipeThrough: true)
        } else {
            return .swiping(swipeThrough: false)
        }
    }

    private func endState(originInContainer: CGPoint) -> State
    {
        guard let swipeView = self.swipeView else { fatalError() }

        let holdXPosition = -swipeView.preferredSize().width

        if originInContainer.x < self.swipeThroughOriginX && self.swipeThroughEnabled  {
            return .finished
        } else if originInContainer.x < holdXPosition {
            return .locked
        } else {
            return .pending
        }

    }

    // - UICollectionView

    @objc func collectionViewPan()
    {
        self.state = .pending
        self.delegate?.swipeController(panDidEnd: self)
        self.collectionView?.panGestureRecognizer.removeTarget(self, action: nil)
        self.collectionView = nil
    }

    // - Helpers

    func calculateNewOrigin(clearTranslation: Bool = false) -> CGPoint
    {
        let translationInContainer: CGPoint = self.gestureRecognizer.translation(in: containerView!)
        // TODO Factor in Velocity
        let oldPoint = self.contentView!.frame.origin.x
        if clearTranslation {
            self.gestureRecognizer.setTranslation(.zero, in: containerView!)
        }

        return CGPoint(x: oldPoint + translationInContainer.x, y: 0)
    }

    var swipeThroughEnabled: Bool
    {
        return actions.performsFirstOnFullSwipe
    }

    private var swipeThroughOriginX: CGFloat
    {
        guard let containerView = self.containerView else { fatalError() }
        return -(containerView.bounds.width * 0.6)
    }

    private static func findCollectionView(child: UIView?) -> UICollectionView?
    {
        var view: UIView? = child

        while view != nil {
            if let collectionView = view as? UICollectionView {
                return collectionView
            } else {
                view = view?.superview
            }
        }

        return nil

    }
}

extension SwipeController {

    class SwipeView: UIView {

        private static var padding: UIEdgeInsets
        {
            return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        }

        var state: SwipeController.State
        {
            didSet {
                UIView.animate(withDuration: 0.2) {
                    switch self.state {
                    case .pending, .swiping(swipeThrough: false), .locked:
                        self.stackView.alignment = .center
                    case .swiping(swipeThrough: true), .finished:
                        self.stackView.alignment = .leading
                    }
                }
            }
        }

        private var action: SwipeAction

        private var imageView: UIImageView?
        private var titleView: UILabel!
        private var gestureRecognizer: UITapGestureRecognizer!
        private var stackView = UIStackView()

        init(action: SwipeAction)
        {
            self.action = action
            self.state = .pending
            super.init(frame: .zero)

            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
            self.addGestureRecognizer(gestureRecognizer)
            self.gestureRecognizer = gestureRecognizer

            self.backgroundColor = action.backgroundColor ?? .red

            if let title = action.title {
                let titleView = UILabel()
                titleView.text = title
                titleView.textColor = .white
                titleView.lineBreakMode = .byClipping
                self.stackView.addArrangedSubview(titleView)
                self.titleView = titleView
            }

            if let image = action.image {
                let imageView = UIImageView(image: image)
                self.stackView.addArrangedSubview(imageView)
                self.imageView = imageView
            }

            stackView.spacing = 2
            stackView.alignment = .center
            stackView.axis = .vertical
            stackView.distribution = .fill
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.layoutMargins = SwipeView.padding

            self.addSubview(self.stackView)
        }

        required init?(coder: NSCoder)
        {
            fatalError("init(coder:) has not been implemented")
        }

        override func layoutSubviews()
        {
            super.layoutSubviews()
            self.stackView.frame = self.bounds
        }

        func preferredSize() -> CGSize
        {
            var size = self.titleView.sizeThatFits(self.bounds.size)
            size.width += SwipeView.padding.left + SwipeView.padding.right
            return size
        }

        @objc func onTap()
        {
            let _ = self.action.onTap(action)
        }
    }

}
