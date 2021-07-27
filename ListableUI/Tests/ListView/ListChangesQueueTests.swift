//
//  ListChangesQueueTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 7/24/21.
//

import XCTest
@testable import ListableUI


class ListChangesQueueTests : XCTestCase {
    
    func test_queue() {
        
        let queue = ListChangesQueue()
        
        XCTAssertFalse(queue.isPaused)
        XCTAssertFalse(queue.isQueuingForReorderEvent)
        
        var calls : [Int] = []
        
        queue.add {
            calls += [1]
        }
        
        XCTAssertEqual(queue.waiting.count, 0)
        XCTAssertEqual(calls, [1])
        
        queue.isQueuingForReorderEvent = true
        
        XCTAssertTrue(queue.isPaused)
        XCTAssertTrue(queue.isQueuingForReorderEvent)
        
        queue.add {
            calls += [2]
        }
        
        queue.add {
            calls += [3]
        }
        
        XCTAssertEqual(queue.waiting.count, 2)
        XCTAssertEqual(calls, [1])
        
        queue.isQueuingForReorderEvent = false
        
        XCTAssertFalse(queue.isPaused)
        XCTAssertFalse(queue.isQueuingForReorderEvent)
        
        XCTAssertEqual(calls, [1, 2, 3])
    }
}
