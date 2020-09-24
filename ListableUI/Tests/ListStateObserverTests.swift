//
//  ListStateObserverTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 7/16/20.
//

import XCTest
@testable import ListableUI


class ListStateObserverTests : XCTestCase
{
    func test_perform()
    {
        let listView = ListView()
        
        struct CallbackInfo {}
        
        var factoryCallCount : Int = 0
        var callCount : Int = 0
        
        let callbacks : [(CallbackInfo) -> ()] = [
            { info in callCount += 1 },
            { info in callCount += 1 },
            { info in callCount += 1 },
        ]

        ListStateObserver.perform(callbacks, "Callback Testing", with: listView) { actions in
            factoryCallCount += 1
            XCTAssertEqual(actions.listView, listView)
            return CallbackInfo()
        }
        
        // Callback info factory should only be called once (for performance),
        // and each callback block should be executed.
        
        XCTAssertEqual(factoryCallCount, 1)
        XCTAssertEqual(callCount, 3)
    }
}
