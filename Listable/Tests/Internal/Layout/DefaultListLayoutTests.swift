//
//  DefaultListLayoutTests.swift
//  Listable-Unit-Tests
//
//  Created by Kyle Van Essen on 5/8/20.
//

import XCTest

@testable import Listable


class ListAppearanceTests : XCTestCase
{
    func test_init()
    {
        let appearance = ListAppearance()
        
        XCTAssertEqual(appearance.sizing, ListAppearance.Sizing())
        XCTAssertEqual(appearance.layout, ListAppearance.Layout())
    }
}


class ListAppearance_SizingTests : XCTestCase
{
    func test_init()
    {
        let sizing = ListAppearance.Sizing()
        
        XCTAssertEqual(sizing.itemHeight, 50.0)
        XCTAssertEqual(sizing.sectionHeaderHeight, 60.0)
        XCTAssertEqual(sizing.sectionFooterHeight, 40.0)
        XCTAssertEqual(sizing.listHeaderHeight, 60.0)
        XCTAssertEqual(sizing.listFooterHeight, 60.0)
        XCTAssertEqual(sizing.overscrollFooterHeight, 60.0)
        XCTAssertEqual(sizing.itemPositionGroupingHeight, 0.0)
    }
}


class ListAppearance_LayoutTests : XCTestCase
{
    func test_init()
    {
        let layout = ListAppearance.Layout()
        
        XCTAssertEqual(layout.padding, UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0))
        XCTAssertEqual(layout.width, .noConstraint)
        XCTAssertEqual(layout.interSectionSpacingWithNoFooter, 0.0)
        XCTAssertEqual(layout.interSectionSpacingWithFooter, 0.0)
        XCTAssertEqual(layout.sectionHeaderBottomSpacing, 0.0)
        XCTAssertEqual(layout.itemSpacing, 0.0)
        XCTAssertEqual(layout.itemToSectionFooterSpacing, 0.0)
    }
    
    func test_width()
    {
        self.testcase("No width constraint") {
            XCTAssertEqual(110.0, ListAppearance.Layout.width(with: 200.0, padding: HorizontalPadding(left: 50.0, right: 40.0), constraint: .noConstraint))
        }
        
        self.testcase("Has width constraint") {
            XCTAssertEqual(100.0, ListAppearance.Layout.width(with: 200.0, padding: HorizontalPadding(left: 50.0, right: 40.0), constraint: .fixed(100.0)))
            XCTAssertEqual(110.0, ListAppearance.Layout.width(with: 200.0, padding: HorizontalPadding(left: 50.0, right: 40.0), constraint: .atMost(200.0)))
        }
    }
}
