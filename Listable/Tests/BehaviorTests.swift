//
//  BehaviorTests.swift
//  Listable-Unit-Tests
//
//  Created by Kyle Van Essen on 11/27/19.
//

import XCTest

@testable import Listable

class BehaviorTests: XCTestCase {
  func test_init() {
    let behavior = Behavior()

    XCTAssertEqual(behavior.dismissesKeyboardOnScroll, false)
  }
}
