//
//  ItemCellTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 11/22/19.
//

import XCTest

@testable import ListableUI


class ItemElementCellTests : XCTestCase
{
    func test_init()
    {
        let cell = ItemCell<TestItemContent>(frame: CGRect(origin: .zero, size: CGSize(width: 100.0, height: 100.0)))
        
        XCTAssertEqual(cell.backgroundColor, .clear)
        XCTAssertEqual(cell.layer.masksToBounds, false)
        
        XCTAssertEqual(cell.contentView.backgroundColor, .clear)
        XCTAssertEqual(cell.contentView.layer.masksToBounds, false)
        
        XCTAssertEqual(cell.contentContainer.superview, cell.contentView)

        // Ensure the content subviews can specify accessibility element params.
        XCTAssertFalse(cell.contentContainer.isAccessibilityElement)
    }
    
    func test_sizeThatFits()
    {
        let cell = ItemCell<TestItemContent>(frame: CGRect(origin: .zero, size: CGSize(width: 100.0, height: 100.0)))
        XCTAssertEqual(cell.sizeThatFits(.zero), CGSize(width: 40.0, height: 50.0))
    }
    
    func test_systemLayoutSizeFitting()
    {
        let cell = ItemCell<TestItemContent>(frame: CGRect(origin: .zero, size: CGSize(width: 100.0, height: 100.0)))
        XCTAssertEqual(cell.systemLayoutSizeFitting(.zero), CGSize(width: 41.0, height: 51.0))
    }
    
    func test_systemLayoutSizeFitting_withHorizontalFittingPriority_verticalFittingPriority()
    {
        let cell = ItemCell<TestItemContent>(frame: CGRect(origin: .zero, size: CGSize(width: 100.0, height: 100.0)))
        
        XCTAssertEqual(
            cell.systemLayoutSizeFitting(
                .zero,
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            ),
            
            CGSize(width: 42.0, height: 52.0)
        )
    }
}

fileprivate struct TestItemContent : ItemContent, Equatable
{
    // MARK: ItemElement
    
    var identifierValue: String {
        ""
    }
    
    func apply(to views: ItemContentViews<Self>, for reason: ApplyReason, with info: ApplyItemContentInfo) {}

    typealias ContentView = UIView
    
    static func createReusableContentView(frame: CGRect) -> UIView {
        return View(frame: frame)
    }
    
    private final class View : UIView {
        override func sizeThatFits(_ size: CGSize) -> CGSize {
            CGSize(width: 40, height: 50)
        }
        
        override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
            CGSize(width: 41, height: 51)
        }
        
        override func systemLayoutSizeFitting(
            _ targetSize: CGSize,
            withHorizontalFittingPriority horizontalFittingPriority:
                UILayoutPriority, verticalFittingPriority: UILayoutPriority
        ) -> CGSize {
            CGSize(width: 42, height: 52)
        }
    }
}


class ItemElementCell_LiveCells_Tests : XCTestCase
{
    func test_add() {
        let liveCells = LiveCells()
        
        var cell1 : AnyItemCell? = ItemCell<TestContent>(frame: .zero)
        
        liveCells.add(cell1!)
        
        // Should only add the cell once.
        
        XCTAssertEqual(liveCells.cells.count, 1)
        
        // Nil out the first cell
        
        weak var weakCell1 = cell1
        
        cell1 = nil
        
        self.waitFor {
            weakCell1 == nil
        }
        
        // Register a second cell, should remove the first
        
        let cell2 = ItemCell<TestContent>(frame: .zero)
        
        liveCells.add(cell2)
        
        XCTAssertEqual(liveCells.cells.count, 1)
        XCTAssertTrue(liveCells.cells.first?.cell === cell2)
    }

    private struct TestContent : ItemContent, Equatable {
        
        var identifierValue: String {
            ""
        }
        
        static func createReusableContentView(frame: CGRect) -> UIView {
            UIView(frame: frame)
        }
        
        func apply(to views: ItemContentViews<TestContent>, for reason: ApplyReason, with info: ApplyItemContentInfo) {
            // Nothing needed
        }
    }
}
