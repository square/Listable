//
//  ItemElementCoordinatorTests.swift
//  Listable-Unit-Tests
//
//  Created by Kyle Van Essen on 5/22/20.
//

import XCTest

@testable import Listable


class ItemElementCoordinatorActionsTests : XCTestCase
{
    func test_update()
    {
        var item = Item(TestElement(value: "first"))
        
        var callbackCount = 0

        let actions = ItemElementCoordinatorActions(current: { item }, update: { new in
            item = new
            callbackCount += 1
        })
        
        self.testcase("Setter based update") {
        
            var updated = item
            updated.element.value = "update1"
            actions.update(updated)
            
            XCTAssertEqual(item.element.value, "update1")
            XCTAssertEqual(callbackCount, 1)
        }
        
        self.testcase("Closure based update") {
                        
            actions.update {
                $0.element.value = "update2"
            }
            
            XCTAssertEqual(item.element.value, "update2")
            XCTAssertEqual(callbackCount, 2)
        }
    }
}


class ItemElementCoordinatorInfoTests : XCTestCase
{
    func test()
    {
        let original = Item(TestElement(value: "original"))
        var current = original
        
        let info = ItemElementCoordinatorInfo(original: original, current: { current })
        
        current.element.value = "current"
        
        XCTAssertEqual(info.original.element.value, "original")
        XCTAssertEqual(info.current.element.value, "current")
    }
}


fileprivate struct TestElement : ItemElement, Equatable
{
    var value : String
    
    typealias ContentView = UIView
    
    var identifier: Identifier<TestElement> {
        .init(self.value)
    }
    
    func apply(to views: ItemElementViews<TestElement>, for reason: ApplyReason, with info: ApplyItemElementInfo) {}
    
    static func createReusableContentView(frame: CGRect) -> UIView {
        UIView(frame: frame)
    }
}
