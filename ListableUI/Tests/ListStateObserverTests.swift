//
//  ListStateObserverTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 7/16/20.
//

@testable import ListableUI
import XCTest

class ListStateObserverTests: XCTestCase {
    func test_perform() {
        let listView = ListView()

        struct CallbackInfo {}

        var factoryCallCount = 0
        var callCount = 0

        let callbacks: [(CallbackInfo) -> Void] = [
            { _ in callCount += 1 },
            { _ in callCount += 1 },
            { _ in callCount += 1 },
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
