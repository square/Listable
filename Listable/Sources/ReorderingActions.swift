//
//  ReorderingActions.swift
//  Listable
//
//  Created by Kyle Van Essen on 11/14/19.
//


public final class ReorderingActions
{
    public private(set) var isMoving : Bool
    
    internal weak var item : AnyPresentationItemState?
    internal weak var listView : ListView?
    
    init()
    {
        self.isMoving = false
    }
    
    public func beginMoving() -> Bool
    {
        guard self.isMoving == false else {
            return true
        }
        
        self.isMoving = true
        
        if let listView = self.listView, let item = self.item {
            return listView.beginInteractiveMovementFor(item: item)
        } else {
            return false
        }
    }
    
    public func moved(with recognizer : UIPanGestureRecognizer)
    {
        guard self.isMoving else {
            return
        }
        
        self.listView?.updateInteractiveMovementTargetPosition(with: recognizer)
    }
    
    public func end()
    {
        guard self.isMoving else {
            return
        }
        
        self.isMoving = false
        
        self.listView?.endInteractiveMovement()
    }
}
