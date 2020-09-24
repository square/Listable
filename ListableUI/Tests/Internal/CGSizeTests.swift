//
//  CGSizeTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 11/22/19.
//

import XCTest
@testable import ListableUI


class CGSizeTests: XCTestCase
{
    func test_isEmpty()
    {
        XCTAssertTrue(CGSize(width: 0.0, height: 0.0).isEmpty)
        XCTAssertTrue(CGSize(width: 1.0, height: 0.0).isEmpty)
        XCTAssertTrue(CGSize(width: 0.0, height: 1.0).isEmpty)
        
        XCTAssertFalse(CGSize(width: 1.0, height: 1.0).isEmpty)
    }
}
