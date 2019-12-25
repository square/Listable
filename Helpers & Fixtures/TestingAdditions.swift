//
//  TestingAdditions.swift
//  Listable-Unit-Tests
//
//  Created by Kyle Van Essen on 11/22/19.
//

import XCTest

@testable import Listable


extension XCTestCase
{
    func testcase(_ name : String = "", _ block : () -> ())
    {
        block()
    }
    
    func assertThrowsError(test : () throws -> (), verify : (Error) -> ())
    {
        var thrown = false
        
        do {
            try test()
        } catch {
            thrown = true
            verify(error)
        }
        
        XCTAssertTrue(thrown, "Expected an error to be thrown but one was not.")
    }
    
    func waitFor(timeout : TimeInterval = 10.0, predicate : () -> Bool)
    {
        let runloop = RunLoop.main
        let timeout = Date(timeIntervalSinceNow: timeout)
        
        while Date() < timeout {
            if predicate() {
                return
            }
            
            runloop.run(mode: .default, before: Date(timeIntervalSinceNow: 0.001))
        }
        
        XCTFail("waitUntil timed out waiting for a check to pass.")
    }
    
    func waitFor(duration : TimeInterval)
    {
        let end = Date(timeIntervalSinceNow: abs(duration))
        
        self.waitFor(predicate: {
            Date() >= end
        })
    }
    
    func waitForOneRunloop()
    {
        let runloop = RunLoop.main
        runloop.run(mode: .default, before: Date(timeIntervalSinceNow: 0.001))
    }
    
    func waitFor(timeout : TimeInterval = 10.0, block : (() -> ()) -> ())
    {
        var isDone : Bool = false
        
        self.waitFor(timeout: timeout, predicate: {
            block({ isDone = true })
            return isDone
        })
    }
}


extension Array where Element == Section
{
    func mapElements<ItemElementType:ItemElement, Mapped>(as type : ItemElementType.Type, map : (ItemElementType) -> Mapped) -> [[Mapped]]
    {
        let items : [[Item<ItemElementType>]] = self.map {
            $0.items as! [Item<ItemElementType>]
        }
        
        let elements : [[ItemElementType]] = items.map {
            $0.map { $0.element }
        }
        
        return elements.map {
            $0.map { map($0) }
        }
    }
}


extension Array where Element == PresentationState.SectionState
{
    func mapElements<ItemElementType:ItemElement, Mapped>(as type : ItemElementType.Type, map : (ItemElementType) -> Mapped) -> [[Mapped]]
    {
        let items : [[PresentationState.ItemState<ItemElementType>]] = self.map {
            $0.items as! [PresentationState.ItemState<ItemElementType>]
        }
        
        let elements : [[ItemElementType]] = items.map {
            $0.map { $0.model.element }
        }
        
        return elements.map {
            $0.map { map($0) }
        }
    }
}


final class ReorderingDelegate_Stub : ReorderingActionsDelegate
{
    func beginInteractiveMovementFor(item: AnyPresentationItemState) -> Bool { return false }
    
    func updateInteractiveMovementTargetPosition(with recognizer: UIPanGestureRecognizer) {}
    
    func endInteractiveMovement() {}
    
    func cancelInteractiveMovement() {}
}
