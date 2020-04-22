//
//  ItemElementCellTests.swift
//  Listable-Unit-Tests
//
//  Created by Kyle Van Essen on 11/22/19.
//

import XCTest

@testable import Listable

class ItemElementCellTests: XCTestCase {
  func test_init() {
    let cell = ItemElementCell<TestItemElement>(
      frame: CGRect(origin: .zero, size: CGSize(width: 100.0, height: 100.0)))

    XCTAssertEqual(cell.backgroundColor, .clear)
    XCTAssertEqual(cell.layer.masksToBounds, false)

    XCTAssertEqual(cell.contentView.backgroundColor, .clear)
    XCTAssertEqual(cell.contentView.layer.masksToBounds, false)

    XCTAssertEqual(cell.content.superview, cell.contentView)
  }

  func test_sizeThatFits() {
    // The default implementation of size that fits on UIView returns the existing size of the view.
    // Make sure that value is returned from the cell.

    let cell1 = ItemElementCell<TestItemElement>(
      frame: CGRect(origin: .zero, size: CGSize(width: 100.0, height: 100.0)))
    XCTAssertEqual(cell1.sizeThatFits(.zero), CGSize(width: 100.0, height: 100.0))

    let cell2 = ItemElementCell<TestItemElement>(
      frame: CGRect(origin: .zero, size: CGSize(width: 150.0, height: 150.0)))
    XCTAssertEqual(cell2.sizeThatFits(.zero), CGSize(width: 150.0, height: 150.0))
  }
}

fileprivate struct TestItemElement: ItemElement, Equatable {
  // MARK: ItemElement

  var identifier: Identifier<TestItemElement> {
    return .init("Test")
  }

  func apply(
    to view: Appearance.ContentView, for reason: ApplyReason, with info: ApplyItemElementInfo
  ) {}

  struct Appearance: ItemElementAppearance, Equatable {
    typealias ContentView = UIView

    static func createReusableItemView(frame: CGRect) -> UIView {
      return UIView(frame: frame)
    }

    func apply(to view: UIView, with info: ApplyItemElementInfo) {}
  }
}
