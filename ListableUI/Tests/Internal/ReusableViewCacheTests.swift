//
//  ReusableViewCacheTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 11/22/19.
//

import XCTest

@testable import ListableUI


class ReusableViewCacheTests: XCTestCase
{
    func test_push_pop()
    {
        self.testcase("Pop with no view calls create") {
            
            let cache = ReusableViewCache()
            
            var callCount = 0
            
            let view : TestView1 = cache.pop(with: ReuseIdentifier.identifier(for: TestView1.self)) {
                callCount += 1
                
                let view = TestView1()
                view.identifier = "test_id"
                return view
            }

            XCTAssertEqual(callCount, 1)
            XCTAssertEqual(view.identifier, "test_id")
        }
        
        self.testcase("Pop with view does not call create") {
            let cache = ReusableViewCache()
            
            let view = TestView1()
            view.identifier = "pre_pushed"
            cache.push(view, with: ReuseIdentifier.identifier(for: TestView1.self))
            
            var callCount = 0
            
            let poppedView : TestView1 = cache.pop(with: ReuseIdentifier.identifier(for: TestView1.self)) {
                callCount += 1
                return TestView1()
            }

            XCTAssertEqual(callCount, 0)
            XCTAssertEqual(poppedView.identifier, "pre_pushed")
        }
        
        self.testcase("Pop removes last view pushed") {
            let cache = ReusableViewCache()
            
            let view1 = TestView1()
            view1.identifier = "first"
            cache.push(view1, with: ReuseIdentifier.identifier(for: TestView1.self))
            
            let view2 = TestView1()
            view2.identifier = "second"
            cache.push(view2, with: ReuseIdentifier.identifier(for: TestView1.self))
            
            var callCount = 0
            
            let poppedView : TestView1 = cache.pop(with: ReuseIdentifier.identifier(for: TestView1.self)) {
                callCount += 1
                return TestView1()
            }

            XCTAssertEqual(callCount, 0)
            XCTAssertEqual(poppedView.identifier, "second")
        }
    }
    
    func test_use()
    {
        self.testcase("Use with no view calls create") {
            
            let cache = ReusableViewCache()
            
            var createCallCount = 0
            var useCallCount = 0
            
            let result : String = cache.use(with: ReuseIdentifier.identifier(for: TestView1.self), create: {
                createCallCount += 1
                
                let view = TestView1()
                view.identifier = "test_id"
                
                return view
            }, { (view:TestView1) -> String in
                useCallCount += 1
                
                XCTAssertEqual(view.identifier, "test_id")
                
                return "result"
            })
            
            XCTAssertEqual(createCallCount, 1)
            XCTAssertEqual(useCallCount, 1)
            XCTAssertEqual(result, "result")
        }
        
        self.testcase("Use with view does not call create") {
            
            let cache = ReusableViewCache()
            
            let view = TestView1()
            view.identifier = "pre_pushed"
            cache.push(view, with: ReuseIdentifier.identifier(for: TestView1.self))
            
            var createCallCount = 0
            var useCallCount = 0
            
            let result : String = cache.use(with: ReuseIdentifier.identifier(for: TestView1.self), create: {
                createCallCount += 1
                
                let view = TestView1()
                view.identifier = "test_id"
                
                return view
            }, { (view:TestView1) -> String in
                useCallCount += 1
                
                XCTAssertEqual(view.identifier, "pre_pushed")
                
                return "result"
            })
            
            XCTAssertEqual(createCallCount, 0)
            XCTAssertEqual(useCallCount, 1)
            XCTAssertEqual(result, "result")
        }
        
        self.testcase("Use removes last view pushed") {
            
            let cache = ReusableViewCache()
            
            let view1 = TestView1()
            view1.identifier = "pushed_1"
            cache.push(view1, with: ReuseIdentifier.identifier(for: TestView1.self))
            
            let view2 = TestView1()
            view2.identifier = "pushed_2"
            cache.push(view2, with: ReuseIdentifier.identifier(for: TestView1.self))
            
            var createCallCount = 0
            var useCallCount = 0
            
            let result : String = cache.use(with: ReuseIdentifier.identifier(for: TestView1.self), create: {
                createCallCount += 1
                
                let view = TestView1()
                view.identifier = "test_id"
                
                return view
            }, { (view:TestView1) -> String in
                useCallCount += 1
                
                XCTAssertEqual(view.identifier, "pushed_2")
                
                return "result"
            })
            
            XCTAssertEqual(createCallCount, 0)
            XCTAssertEqual(useCallCount, 1)
            XCTAssertEqual(result, "result")
        }
    }
}


fileprivate final class TestView1 : UIView
{
    var identifier : String = ""
}


fileprivate final class TestView2 : UIView
{
    var identifier : String = ""
}
