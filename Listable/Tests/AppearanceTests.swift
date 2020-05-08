//
//  AppearanceTests.swift
//  Listable-Unit-Tests
//
//  Created by Kyle Van Essen on 11/27/19.
//

import XCTest

@testable import Listable


class AppearanceTests: XCTestCase
{
    func test_init()
    {
        let appearance = Appearance()
        
        XCTAssertEqual(appearance.backgroundColor, .white)
        
        XCTAssertEqual(appearance.direction, .vertical)
        
        XCTAssertEqual(appearance.stickySectionHeaders, true)
    }
}

