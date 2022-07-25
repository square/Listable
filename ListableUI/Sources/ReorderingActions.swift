//
//  ReorderingActions.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 11/14/19.
//

public final class ReorderingActions {
    public private(set) var isMoving: Bool

    weak var item: AnyPresentationItemState?
    weak var delegate: ReorderingActionsDelegate?

    init() {
        isMoving = false
    }

    public func start() -> Bool {
        guard let item = item else {
            return false
        }

        guard isMoving == false else {
            return true
        }

        guard let delegate = delegate else {
            return false
        }

        if delegate.beginReorder(for: item) {
            isMoving = true

            return true
        } else {
            return false
        }
    }

    public func moved(with recognizer: ItemReordering.GestureRecognizer) {
        guard isMoving else {
            return
        }

        guard let item = item else {
            return
        }

        delegate?.updateReorderTargetPosition(with: recognizer, for: item)
    }

    public func end(_ result: Result) {
        guard isMoving else {
            return
        }

        guard let item = item else {
            return
        }

        isMoving = false

        delegate?.endReorder(for: item, with: result)
    }

    public func accessibilityMove(direction: AccessibilityMoveDirection) -> Bool {
        guard let item = item, let delegate = delegate else {
            return false
        }
        return delegate.accessibilityMove(item: item, direction: direction)
    }
}

public extension ReorderingActions {
    enum Result: Equatable {
        case finished
        case cancelled
    }
}

public extension ReorderingActions {
    /// Used with the accessibilityMove(item: direction:) delegate method to indicate the direction a selected item should be moved in the collection view.
    enum AccessibilityMoveDirection {
        case up
        case down
    }
}

protocol ReorderingActionsDelegate: AnyObject {
    func beginReorder(for item: AnyPresentationItemState) -> Bool
    func updateReorderTargetPosition(with recognizer: ItemReordering.GestureRecognizer, for item: AnyPresentationItemState)
    func endReorder(for item: AnyPresentationItemState, with result: ReorderingActions.Result)

    // In addition to reordering cells with the standard drag gesture we offer an AccessibilityCustomAction to move a selected cell up or down by a single index path position. This provides an affordance for those who struggle to precisely drag cells about the screen.
    func accessibilityMove(item: AnyPresentationItemState, direction: ReorderingActions.AccessibilityMoveDirection) -> Bool
}
