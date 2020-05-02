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
        
        XCTAssertEqual(appearance.sizing, Appearance.Sizing())
        XCTAssertEqual(appearance.layout, Appearance.Layout())
        XCTAssertEqual(appearance.underflow, Appearance.UnderflowBehavior())
    }
}


class ListSizingTests : XCTestCase
{
    func test_init()
    {
        let sizing = Appearance.Sizing()
        
        XCTAssertEqual(sizing.itemHeight, 50.0)
        XCTAssertEqual(sizing.sectionHeaderHeight, 60.0)
        XCTAssertEqual(sizing.sectionFooterHeight, 40.0)
        XCTAssertEqual(sizing.listHeaderHeight, 60.0)
        XCTAssertEqual(sizing.listFooterHeight, 60.0)
        XCTAssertEqual(sizing.overscrollFooterHeight, 60.0)
        XCTAssertEqual(sizing.itemPositionGroupingHeight, 0.0)
    }
}


class ListLayoutTests : XCTestCase
{
    func test_init()
    {
        let layout = Appearance.Layout()
        
        XCTAssertEqual(layout.padding, UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0))
        XCTAssertEqual(layout.width, .noConstraint)
        XCTAssertEqual(layout.interSectionSpacingWithNoFooter, 0.0)
        XCTAssertEqual(layout.interSectionSpacingWithFooter, 0.0)
        XCTAssertEqual(layout.sectionHeaderBottomSpacing, 0.0)
        XCTAssertEqual(layout.itemSpacing, 0.0)
        XCTAssertEqual(layout.itemToSectionFooterSpacing, 0.0)
        XCTAssertEqual(layout.stickySectionHeaders, true)
    }
    
    func test_width()
    {
        self.testcase("No width constraint") {
            XCTAssertEqual(110.0, Appearance.Layout.width(with: 200.0, padding: HorizontalPadding(left: 50.0, right: 40.0), constraint: .noConstraint))
        }
        
        self.testcase("Has width constraint") {
            XCTAssertEqual(100.0, Appearance.Layout.width(with: 200.0, padding: HorizontalPadding(left: 50.0, right: 40.0), constraint: .fixed(100.0)))
            XCTAssertEqual(110.0, Appearance.Layout.width(with: 200.0, padding: HorizontalPadding(left: 50.0, right: 40.0), constraint: .atMost(200.0)))
        }
    }
}


class UnderflowBehaviorTests : XCTestCase
{
    func test_init()
    {
        let underflow = Appearance.UnderflowBehavior()
        
        XCTAssertEqual(underflow.alwaysBounce, true)
        XCTAssertEqual(underflow.alignment, .top)
    }
}

class UnderflowBehavior_Alignment_Tests : XCTestCase
{
    func test_offsetFor()
    {
        self.testcase("Larger than content") {
            XCTAssertEqual(Appearance.UnderflowBehavior.Alignment.top.offsetFor(contentHeight: 200.0, viewHeight: 100.0), 0.0)
            XCTAssertEqual(Appearance.UnderflowBehavior.Alignment.center.offsetFor(contentHeight: 200.0, viewHeight: 100.0), 0.0)
            XCTAssertEqual(Appearance.UnderflowBehavior.Alignment.bottom.offsetFor(contentHeight: 200.0, viewHeight: 100.0), 0.0)
        }
        
        self.testcase("Smaller than content") {
            XCTAssertEqual(Appearance.UnderflowBehavior.Alignment.top.offsetFor(contentHeight: 50.0, viewHeight: 100.0), 0.0)
            XCTAssertEqual(Appearance.UnderflowBehavior.Alignment.center.offsetFor(contentHeight: 50.0, viewHeight: 100.0), 25.0)
            XCTAssertEqual(Appearance.UnderflowBehavior.Alignment.bottom.offsetFor(contentHeight: 50.0, viewHeight: 100.0), 50.0)
        }
    }
}
