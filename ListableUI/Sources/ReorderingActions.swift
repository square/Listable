//
//  ReorderingActions.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 11/14/19.
//


public final class ReorderingActions
{
    public private(set) var isMoving : Bool
    
    weak var item : AnyPresentationItemState?
    weak var delegate : ReorderingActionsDelegate?
    
    init()
    {
        self.isMoving = false
    }
    
    public func start() -> Bool
    {
        guard let item = self.item else {
            return false
        }
        
        guard self.isMoving == false else {
            return true
        }
        
        guard let delegate = self.delegate else {
            return false
        }
        
        if delegate.beginReorder(for: item) {
            self.isMoving = true
            
            return true
        } else {
            return false
        }
    }
    
    public func moved(with recognizer : ItemReordering.GestureRecognizer)
    {
        guard self.isMoving else {
            return
        }
        
        guard let item = self.item else {
            return
        }
        
        self.delegate?.updateReorderTargetPosition(with: recognizer, for: item)
    }
    
    public func end(_ result : Result)
    {
        guard self.isMoving else {
            return
        }
        
        guard let item = self.item else {
            return
        }
        
        self.isMoving = false
        
        self.delegate?.endReorder(for: item, with: result)
    }
    
    public func accessibilityMove(direction: AccessibilityMoveDirection) -> Bool {
        guard let item = self.item, let delegate = self.delegate else {
            return false
        }
        return delegate.accessibilityMove(item: item, direction: direction)
    }
    
}


extension ReorderingActions {
    
    public enum Result : Equatable {
        case finished
        case cancelled
    }
}

extension ReorderingActions {
    public enum AccessibilityMoveDirection {
        case up
        case down
    }
}

protocol ReorderingActionsDelegate : AnyObject
{
    func beginReorder(for item : AnyPresentationItemState) -> Bool
    func updateReorderTargetPosition(with recognizer : ItemReordering.GestureRecognizer, for item : AnyPresentationItemState)
    func endReorder(for item : AnyPresentationItemState, with result : ReorderingActions.Result)
    
    // Used by an AccessibilityCustomAction, move the item up or down by one index path position.
    func accessibilityMove(item: AnyPresentationItemState, direction: ReorderingActions.AccessibilityMoveDirection) -> Bool
}
