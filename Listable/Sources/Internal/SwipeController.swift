//
//  SwipeController.swift
//  Listable
//
//  Created by Matthew Faluotico on 4/3/20.
//

import Foundation

protocol SwipeControllerDelegate: class {

    func swipeControllerPanDidMove()
    func swipeControllerPanDidEnd()

}

public enum SwipeControllerState {

    // Docked position without the action view showing
    case closed
    // Viewer panning revealing the actions view, passedSwipeThroughThreshold or not
    case swiping(passedSwipeThroughThreshold: Bool)
    // Pan was released and Actions are visible occupying their required space from preferredSize()
    case open
    // Pan has swiped all the way to the end, only when isSwipeThroughEnabled is true
    case finished

}

final class SwipeController<Appearance: ItemElementSwipeActionsAppearance> {

    private(set) var state: SwipeControllerState = .closed {
        didSet {
            if let swipeView = self.swipeView {
                appearance.apply(swipeControllerState: state, to: swipeView)
            }
        }
    }

    var actions: SwipeActions

    private(set) var appearance: Appearance
    private weak var swipeView: Appearance.ContentView?
    private weak var contentView: UIView?
    private weak var containerView: UIView?
    private var gestureRecognizer: UIPanGestureRecognizer

    weak var delegate: SwipeControllerDelegate?

    private weak var collectionView: UICollectionView?

    init(
        appearance: Appearance,
        swipeView: Appearance.ContentView,
        actions: SwipeActions,
        contentView: UIView,
        containerView: UIView
    ) {
        self.appearance = appearance
        self.swipeView = swipeView
        self.actions = actions
        self.contentView = contentView
        self.containerView = containerView
        self.gestureRecognizer = UIPanGestureRecognizer()
    }

    func configure()
    {
        gestureRecognizer.addTarget(self, action: #selector(onPan(_:)))
        containerView?.addGestureRecognizer(gestureRecognizer)
    }

    deinit
    {
        containerView?.removeGestureRecognizer(self.gestureRecognizer)
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

    @objc func collectionViewPan()
    {
        self.state = .closed
        self.delegate?.swipeControllerPanDidEnd()
        self.collectionView?.panGestureRecognizer.removeTarget(self, action: nil)
        self.collectionView = nil
    }

}

// MARK: - Panning
extension SwipeController {

    func calculateNewOrigin(clearTranslation: Bool = false) -> CGPoint
    {
        guard let containerView = self.containerView, let contentView = self.contentView else {
            return CGPoint.zero
        }

        let translationInContainer: CGPoint = gestureRecognizer.translation(in: containerView)
        let oldPoint = contentView.frame.origin.x

        if clearTranslation {
            gestureRecognizer.setTranslation(.zero, in: containerView)
        }

        return CGPoint(x: oldPoint + translationInContainer.x, y: 0)
    }

    func performSwipeThroughAction()
    {
        if let action = actions.actions.first {
            let _ = action.onTap(action)
        }
    }

    private func panChanged(_ pan: UIPanGestureRecognizer)
    {
        let originInContainer = calculateNewOrigin()
        state = panningState(originInContainer: originInContainer)

        delegate?.swipeControllerPanDidMove()
    }

    private func panEnded(_ pan: UIPanGestureRecognizer)
    {
        let originInContainer = calculateNewOrigin()
        state = endState(originInContainer: originInContainer)

        delegate?.swipeControllerPanDidEnd()

        if case .finished = state, isSwipeThroughEnabled {
            self.performSwipeThroughAction()
        }
    }

    private func panningState(originInContainer: CGPoint) -> SwipeControllerState
    {
        if originInContainer.x > 0 {
            return .closed
        } else
            if originInContainer.x < self.swipeThroughOriginX && isSwipeThroughEnabled {
            return .swiping(passedSwipeThroughThreshold: true)
        } else {
            return .swiping(passedSwipeThroughThreshold: false)
        }
    }

    private func endState(originInContainer: CGPoint) -> SwipeControllerState
    {
        guard let swipeView = swipeView else { fatalError() }

        let holdXPosition = -appearance.preferredSize(for: swipeView).width

        if originInContainer.x < swipeThroughOriginX && isSwipeThroughEnabled  {
            return .finished
        } else if originInContainer.x < holdXPosition {
            return .open
        } else {
            return .closed
        }

    }

}

// MARK: - Helpers
extension SwipeController {

    var isSwipeThroughEnabled: Bool
    {
        return actions.performsFirstOnFullSwipe
    }

    private var swipeThroughOriginX: CGFloat
    {
        guard let containerView = containerView else { fatalError() }
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
