//
//  TestingAdditions.swift
//  Listable-Unit-Tests
//
//  Created by Kyle Van Essen on 11/22/19.
//

import XCTest

@testable import Listable


extension Section
{
}

extension Array
{
    func typedMap<TypedElement, Contained>(_ type : TypedElement.Type, map : (TypedElement) -> Contained) -> [Contained]
    {
        return self.map {
            let item = $0 as! TypedElement
            return map(item)
        }
    }
}

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
    
    func waitFor(timeout : TimeInterval = 10.0, block : (() -> ()) -> ())
    {
        var isDone : Bool = false
        
        self.waitFor(timeout: timeout, predicate: {
            block({ isDone = true })
            return isDone
        })
    }
}
