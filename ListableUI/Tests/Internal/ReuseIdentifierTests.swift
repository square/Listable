//
//  ReuseIdentifierTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 11/22/19.
//

import XCTest
@testable import ListableUI


class ReuseIdentifierTests: XCTestCase
{
    func test_identifier_for()
    {
        let identifier1 = ReuseIdentifier.identifier(for: TypeA.self)
        let identifier2 = ReuseIdentifier.identifier(for: TypeA.self)
        
        let identifier3 = ReuseIdentifier.identifier(for: TypeB.self)
        let identifier4 = ReuseIdentifier.identifier(for: TypeB.self)
        
        XCTAssertTrue(identifier1 === identifier2)
        XCTAssertEqual(identifier1, identifier2)
        
        XCTAssertTrue(identifier3 === identifier4)
        XCTAssertEqual(identifier3, identifier4)
        
        XCTAssertFalse(identifier1 === identifier3)
        
        struct TypeA {}
        struct TypeB {}
    }
}
