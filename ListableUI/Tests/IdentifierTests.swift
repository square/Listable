//
//  IdentifierTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 11/27/19.
//

import XCTest
import ListableUI


class IdentifierTests: XCTestCase
{
    func test_debugDescription()
    {
        XCTAssertEqual(
            Identifier<TestingType>("The Value").debugDescription,
            "Identifier<TestingType>: \"The Value\""
        )
        
        XCTAssertEqual(
            Identifier<TestingType>(123).debugDescription,
            "Identifier<TestingType>: 123"
        )
    }
}


fileprivate struct TestingType { }
