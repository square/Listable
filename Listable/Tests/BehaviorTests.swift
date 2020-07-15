//
//  BehaviorTests.swift
//  Listable-Unit-Tests
//
//  Created by Kyle Van Essen on 11/27/19.
//

import XCTest

@testable import Listable


class BehaviorTests: XCTestCase
{
    func test_init()
    {
        let behavior = Behavior()
        
        XCTAssertEqual(behavior.keyboardDismissMode, .interactive)
        XCTAssertEqual(behavior.keyboardAdjustmentMode, .adjustsWhenVisible)
        
        XCTAssertEqual(behavior.selectionMode, .single)
        
        XCTAssertEqual(behavior.underflow, Behavior.Underflow())
        
        let listView = ListView()
        
        // These values should match the default values from the collection view.
        XCTAssertEqual(behavior.canCancelContentTouches, listView.collectionView.canCancelContentTouches)
        XCTAssertEqual(behavior.delaysContentTouches, listView.collectionView.delaysContentTouches)
    }
}


class Behavior_Underflow_Tests : XCTestCase
{
    func test_init()
    {
        let underflow = Behavior.Underflow()
        
        XCTAssertEqual(underflow.alwaysBounce, true)
        XCTAssertEqual(underflow.alignment, .top)
    }
}


class Behavior_Underflow_Alignment_Tests : XCTestCase
{
    func test_offsetFor()
    {
        self.testcase("Larger than content") {
            XCTAssertEqual(Behavior.Underflow.Alignment.top.offsetFor(contentHeight: 200.0, viewHeight: 100.0), 0.0)
            XCTAssertEqual(Behavior.Underflow.Alignment.center.offsetFor(contentHeight: 200.0, viewHeight: 100.0), 0.0)
            XCTAssertEqual(Behavior.Underflow.Alignment.bottom.offsetFor(contentHeight: 200.0, viewHeight: 100.0), 0.0)
        }
        
        self.testcase("Smaller than content") {
            XCTAssertEqual(Behavior.Underflow.Alignment.top.offsetFor(contentHeight: 50.0, viewHeight: 100.0), 0.0)
            XCTAssertEqual(Behavior.Underflow.Alignment.center.offsetFor(contentHeight: 50.0, viewHeight: 100.0), 25.0)
            XCTAssertEqual(Behavior.Underflow.Alignment.bottom.offsetFor(contentHeight: 50.0, viewHeight: 100.0), 50.0)
        }
    }
}
