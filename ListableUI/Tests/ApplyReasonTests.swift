//
//  ApplyReasonTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 11/27/19.
//

import XCTest

@testable import ListableUI

class ApplyReasonTests: XCTestCase {
    func test_shouldAnimate() {
        XCTAssertEqual(ApplyReason.willDisplay.shouldAnimate, false)
        XCTAssertEqual(ApplyReason.wasUpdated.shouldAnimate, true)
    }
}
