//
//  IdentifierTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 11/27/19.
//

import XCTest
@testable import ListableUI


class IdentifierTests: XCTestCase
{
    func test_debugDescription()
    {
        XCTAssertEqual(
            Identifier<TestingType, String>("The Value").debugDescription,
            "Identifier<TestingType, String>: \"The Value\""
        )
        
        XCTAssertEqual(
            Identifier<TestingType, Int>(123).debugDescription,
            "Identifier<TestingType, Int>: 123"
        )
    }
}


fileprivate struct TestingType { }
