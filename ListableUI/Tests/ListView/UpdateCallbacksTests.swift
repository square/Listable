//
//  UpdateCallbacksTests.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 8/19/20.
//

@testable import ListableUI
import XCTest


class UpdateCallbacksTests : XCTestCase
{
    func test_add_and_perform() {
        
        self.testcase("shouldPerform is false") {
            let callbacks = UpdateCallbacks(.immediate, wantsAnimations: false)
            
            var callCount : Int = 0
            
            callbacks.add(if: false) {
                callCount += 1
            }
            
            XCTAssertEqual(callCount, 0)
            XCTAssertEqual(callbacks.calls.count, 0)
        }
        
        self.testcase("immediate") {
            let callbacks = UpdateCallbacks(.immediate, wantsAnimations: false)
            
            var callCount : Int = 0
            
            callbacks.add(if: true) {
                callCount += 1
            }
            
            XCTAssertEqual(callCount, 1)
            XCTAssertEqual(callbacks.calls.count, 0)
            
            callbacks.perform()
            
            XCTAssertEqual(callCount, 1)
            XCTAssertEqual(callbacks.calls.count, 0)
        }
        
        self.testcase("queued") {
            let callbacks = UpdateCallbacks(.queue, wantsAnimations: false)
            
            var callCount : Int = 0
            
            callbacks.add(if: true) {
                callCount += 1
            }
            
            XCTAssertEqual(callCount, 0)
            XCTAssertEqual(callbacks.calls.count, 1)
            
            callbacks.perform()
            
            XCTAssertEqual(callCount, 1)
            XCTAssertEqual(callbacks.calls.count, 0)
        }
    }
    
    func test_performAnimation() {
        
        self.testcase("not animated") {
            let callbacks = UpdateCallbacks(.immediate, wantsAnimations: false)
            
            callbacks.performAnimation {
                XCTAssertEqual(UIView.inheritedAnimationDuration, 0.0)
            }
        }
        
        self.testcase("animated") {
            let callbacks = UpdateCallbacks(.immediate, wantsAnimations: true)
            
            callbacks.performAnimation {
                XCTAssertEqual(UIView.inheritedAnimationDuration, 0.2)
            }
        }
    }
}
