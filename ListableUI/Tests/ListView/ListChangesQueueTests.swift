//
//  ListChangesQueueTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 7/24/21.
//

import XCTest
@testable import ListableUI


class ListChangesQueueTests : XCTestCase {
    
    func test_pausing() {
        
        let queue = ListChangesQueue()
        
        XCTAssertFalse(queue.isPaused)
        XCTAssertFalse(queue.isQueuingForReorderEvent)
        
        var calls : [Int] = []
        
        queue.add {
            calls += [1]
        }
        
        XCTAssertEqual(calls, [1])
        
        queue.add { completion in
            calls += [2]
            
            completion.finish()
        }
        
        XCTAssertEqual(queue.count, 0)
        XCTAssertEqual(calls, [1, 2])
        
        queue.isQueuingForReorderEvent = true
        
        XCTAssertTrue(queue.isPaused)
        XCTAssertTrue(queue.isQueuingForReorderEvent)
        
        queue.add {
            calls += [3]
        }
                
        queue.add {
            calls += [4]
        }
        
        queue.add { completion in
            calls += [5]
            
            completion.finish()
        }
        
        XCTAssertEqual(queue.count, 3)
        XCTAssertEqual(calls, [1, 2])
        
        queue.isQueuingForReorderEvent = false
        
        XCTAssertFalse(queue.isPaused)
        XCTAssertFalse(queue.isQueuingForReorderEvent)
        
        waitFor {
            queue.isEmpty
        }
        
        XCTAssertEqual(calls, [1, 2, 3, 4, 5])
    }
    
    func test_synchronous() {
        
        let queue = ListChangesQueue()
        
        var calls : [Int] = []
        
        queue.add {
            calls += [1]
        }
        
        queue.add {
            calls += [2]
        }
        
        queue.add {
            calls += [3]
        }
        
        queue.add {
            calls += [4]
        }
        
        XCTAssertEqual(calls, [1, 2, 3, 4])
        XCTAssertEqual(queue.count, 0)
    }
    
    
    func test_asynchronous() {
        
        let queue = ListChangesQueue()
        
        var calls : [Int] = []
        
        /// Add the events in reverse timing order,
        /// to guarantee that they're executed in order of addition.

        queue.add { completion in
            XCTAssertEqual(calls, [])
            
            calls += [1]
        
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                completion.finish()
            }
        }
        
        queue.add { completion in
            XCTAssertEqual(calls, [1])

            calls += [2]
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(66)) {
                completion.finish()
            }
        }
        
        queue.add { completion in
            XCTAssertEqual(calls, [1, 2])
            
            calls += [3]
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(33)) {
                completion.finish()
            }
        }
        
        
        queue.add { completion in
            
            XCTAssertEqual(calls, [1, 2, 3])
            
            calls += [4]
            
            completion.finish()
        }
        
        waitFor {
            calls == [1, 2, 3, 4]
        }
        
        waitFor {
            queue.isEmpty
        }
    }
    
    func test_both() {
        
        let queue = ListChangesQueue()
        
        var calls : [Int] = []
        
        /// Add the async events in reverse timing order,
        /// to guarantee that they're executed in order of addition.
        
        queue.add {
            calls += [1]
        }

        queue.add { completion in
            calls += [2]
        
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                completion.finish()
            }
        }
        
        queue.add {
            calls += [3]
        }
        
        queue.add { completion in
            calls += [4]
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(66)) {
                completion.finish()
            }
        }
        
        queue.add {
            calls += [5]
        }
        
        queue.add { completion in
            calls += [6]
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(33)) {
                completion.finish()
            }
        }
        
        queue.add {
            calls += [7]
        }
        
        queue.add { completion in
            calls += [8]
            
            completion.finish()
        }
        
        queue.add {
            calls += [9]
        }
        
        waitFor {
            calls == [1, 2, 3, 4, 5, 6, 7, 8, 9]
        }
        
        waitFor {
            queue.isEmpty
        }
    }
    
    func test_flattenedChildren() {
        
        let queue = ListChangesQueue()
        queue.runIDs = []
        
        queue.add(1) {
            queue.add(2) {
                queue.add(3) {}
            }
            
            queue.add(4) {
                queue.add(5) { }
            }
        }
        
        XCTAssertEqual(
            queue.runIDs,
            [1, 2, 3, 4, 5]
        )
    }
    
    func test_nesting() {
        
        let queue = ListChangesQueue()
        
        var events : [Int] = []
        
        queue.add {
            queue.add {
                queue.add { operation in
                    
                }
            }
            
            queue.add { operation in
                queue.add { operation in
                    
                }
            }
            
            queue.add { operation in
                queue.add {
                    queue.add {
                        
                    }
                }
            }
        }
        
        queue.add { operation in
            
            queue.add { operation in
                
            }
            
            queue.add {
                
            }
        }

        waitFor {
            queue.isEmpty
        }
        
        XCTAssertEqual(
            events,
            []
        )
    }
    
    func test_fuzzing() {
        
        let queue = ListChangesQueue()
        
        var calls : [Int] = []
        
        var values : [Int] = (1...1000).map { $0 }.reversed()
        
        while values.isEmpty == false {
            
            if let value = values.popLast() {
                queue.add {
                    calls += [value]
                }
            }
            
            if let value = values.popLast() {
                queue.add { completion in
                    calls += [value]
                
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2)) {
                        completion.finish()
                    }
                }
            }
            
            if let value = values.popLast() {
                queue.add { completion in
                    calls += [value]
                
                    completion.finish()
                }
            }
        }
        
        waitFor {
            queue.isEmpty
        }
        
        XCTAssertEqual(
            calls,
            (1...1000).map { $0 }
        )
    }
}
