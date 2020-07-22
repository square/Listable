//
//  ItemPreviewAppearanceTests.swift
//  Listable-Unit-Tests
//
//  Created by Kyle Van Essen on 6/14/20.
//

import XCTest
@testable import Listable


class ItemPreviewAppearanceTests : XCTestCase
{
    func test_init()
    {
        let appearance = ItemPreviewAppearance()
        
        XCTAssertEqual(appearance.padding, 20.0)
        XCTAssertEqual(appearance.backgroundColor, .white)
    }
    
    func test_configure()
    {
        let previewAppearance = ItemPreviewAppearance(
            padding: 33.0,
            backgroundColor: .black
        )
        
        var appearance = Appearance()
        
        previewAppearance.configure(listAppearance: &appearance)
        
        XCTAssertEqual(appearance.backgroundColor, .black)
        XCTAssertEqual(appearance.list.layout.padding, UIEdgeInsets(top: 33.0, left: 33.0, bottom: 33.0, right: 33.0))
    }
}
