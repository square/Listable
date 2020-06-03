//
//  IdentifierTests.swift
//  Listable-Unit-Tests
//
//  Created by Kyle Van Essen on 11/27/19.
//

import XCTest
import Listable


class AnyIdentifierTests: XCTestCase
{
    func test_debugDescription()
    {
        XCTAssertEqual(
            Identifier<TestingType>("The Value").toAny.debugDescription,
            "Identifier<TestingType>: \"The Value\""
        )
        
        XCTAssertEqual(
            Identifier<TestingType>(123).toAny.debugDescription,
            "Identifier<TestingType>: 123"
        )
    }
}


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
