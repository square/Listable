//
//  AppearanceTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 11/27/19.
//

import XCTest

@testable import ListableUI


class AppearanceTests: XCTestCase
{
    func test_init()
    {
        let appearance = Appearance()
        
        XCTAssertEqual(appearance.backgroundColor.resolvedColor(with: .init(userInterfaceStyle: .dark)), .black)
        XCTAssertEqual(appearance.backgroundColor.resolvedColor(with: .init(userInterfaceStyle: .light)), .white)
        
        XCTAssertEqual(appearance.showsScrollIndicators, true)
    }
    
    func test_equatable() {
        // Verify that the default values pass equality.
        // We use a dynamic color provider for the background color,
        // so ensure equality still passes.
        
        XCTAssertEqual(Appearance(), Appearance())
    }
}

