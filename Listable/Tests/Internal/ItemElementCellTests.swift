//
//  ItemElementCellTests.swift
//  Listable-Unit-Tests
//
//  Created by Kyle Van Essen on 11/22/19.
//

import XCTest

@testable import Listable


class ItemElementCellTests : XCTestCase
{
    func test_init()
    {
        let cell = ItemElementCell<TestItemElement>(frame: CGRect(origin: .zero, size: CGSize(width: 100.0, height: 100.0)))
        
        XCTAssertEqual(cell.backgroundColor, .clear)
        XCTAssertEqual(cell.layer.masksToBounds, false)
        
        XCTAssertEqual(cell.contentView.backgroundColor, .clear)
        XCTAssertEqual(cell.contentView.layer.masksToBounds, false)
        
        XCTAssertEqual(cell.contentContainer.superview, cell.contentView)
    }
    
    func test_sizeThatFits()
    {
        // The default implementation of size that fits on UIView returns the existing size of the view.
        // Make sure that value is returned from the cell.
        
        let cell1 = ItemElementCell<TestItemElement>(frame: CGRect(origin: .zero, size: CGSize(width: 100.0, height: 100.0)))
        XCTAssertEqual(cell1.sizeThatFits(.zero), CGSize(width: 100.0, height: 100.0))
        
        let cell2 = ItemElementCell<TestItemElement>(frame: CGRect(origin: .zero, size: CGSize(width: 150.0, height: 150.0)))
        XCTAssertEqual(cell2.sizeThatFits(.zero), CGSize(width: 150.0, height: 150.0))
    }
}

fileprivate struct TestItemElement : ItemElement, Equatable
{
    // MARK: ItemElement
    
    var identifier: Identifier<TestItemElement> {
        return .init("Test")
    }
    
    func apply(to views: ItemElementViews<Self>, for reason: ApplyReason, with info: ApplyItemElementInfo) {}

    typealias ContentView = UIView
    
    static func createReusableContentView(frame: CGRect) -> UIView {
        return UIView(frame: frame)
    }
}
