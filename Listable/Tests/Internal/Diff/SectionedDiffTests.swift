//
//  SectionedDiffTests.swift
//  Listable-Unit-Tests
//
//  Created by Kyle Van Essen on 11/22/19.
//

import XCTest

@testable import Listable

class SectionedDiffTests: XCTestCase {

  func test_section_changes() {

    struct Section {
      let identifier: Int
      let items: [Int]
    }

    self.testcase("test_added_items_in_added_section") {

      let old = [
        Section(identifier: 0, items: [0, 1]),
      ]

      let new = [
        Section(identifier: 0, items: [0, 1]),
        Section(identifier: 1, items: [2]),
      ]

      let diff = makeDiff(old: old, new: new)

      let addedIndentifier = Identifier<Int>(2)
      let addedAnyIdentifier = AnyIdentifier(addedIndentifier)

      XCTAssert(diff.changes.addedItemIdentifiers.contains(addedAnyIdentifier))
      XCTAssertEqual(diff.changes.addedItemIdentifiers.count, 1)
    }

    self.testcase("test_added_items_in_no_change_section") {

      let old = [
        Section(identifier: 0, items: [0, 1]),
      ]

      let new = [
        Section(identifier: 0, items: [0, 1, 2, 3]),
      ]

      let diff = makeDiff(old: old, new: new)

      let firstAddedIndentifier = Identifier<Int>(2)
      let firstAddedAnyIdentifier = AnyIdentifier(firstAddedIndentifier)

      let secondAddedIndentifier = Identifier<Int>(3)
      let secondAddedAnyIdentifier = AnyIdentifier(secondAddedIndentifier)

      XCTAssert(diff.changes.addedItemIdentifiers.contains(firstAddedAnyIdentifier))
      XCTAssert(diff.changes.addedItemIdentifiers.contains(secondAddedAnyIdentifier))

      XCTAssertEqual(diff.changes.addedItemIdentifiers.count, 2)
    }

    self.testcase("test_added_items_in_moved_section") {

      let old = [
        Section(identifier: 0, items: [0, 1]),
        Section(identifier: 1, items: [2, 3]),
      ]

      let new = [
        Section(identifier: 1, items: [2, 3]),
        Section(identifier: 0, items: [0, 1, 4]),
      ]
      let diff = makeDiff(old: old, new: new)

      let addedIndentifier = Identifier<Int>(4)
      let addedAnyIdentifier = AnyIdentifier(addedIndentifier)

      XCTAssert(diff.changes.addedItemIdentifiers.contains(addedAnyIdentifier))
      XCTAssertEqual(diff.changes.addedItemIdentifiers.count, 1)
    }

    self.testcase("test_moving_item_is_not_added") {

      let old = [
        Section(identifier: 0, items: [0, 1, 2]),
      ]

      let new = [
        Section(identifier: 0, items: [2, 0, 1]),
      ]

      let diff = makeDiff(old: old, new: new)

      XCTAssert(diff.changes.addedItemIdentifiers.isEmpty)
    }

    func makeDiff(old: [Section], new: [Section]) -> SectionedDiff<Section, Int> {
      return SectionedDiff<Section, Int>.init(
        old: old,
        new: new,
        configuration: .init(
          section: .init(
            identifier: {
              let identifier = Identifier<Int>($0.identifier)
              return AnyIdentifier(identifier)
            },
            items: { $0.items },
            movedHint: { _, _ in false }
          ),
          item: .init(
            identifier: {
              let identifier = Identifier<Int>($0)
              return AnyIdentifier(identifier)
            },
            updated: { _, _ in false },
            movedHint: { $0 == $1 }
          )
        )
      )
    }
  }
}
