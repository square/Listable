//
//  SectionedDiffTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 11/22/19.
//

import XCTest
@testable import ListableUI


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

            let addedIdentifier = 2

            XCTAssert(diff.changes.addedItemIdentifiers.contains(addedIdentifier))
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

            let firstAddedIndentifier = 2
            let secondAddedIndentifier = 3

            XCTAssert(diff.changes.addedItemIdentifiers.contains(firstAddedIndentifier))
            XCTAssert(diff.changes.addedItemIdentifiers.contains(secondAddedIndentifier))

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

            let addedIdentifier = 4

            XCTAssert(diff.changes.addedItemIdentifiers.contains(addedIdentifier))
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

        func makeDiff(old: [Section], new: [Section]) -> SectionedDiff<Section, Int, Int, Int> {
            return SectionedDiff<Section, Int, Int, Int>.init(
                old: old,
                new: new,
                configuration: .init(
                    section: .init(
                        identifier: {
                            $0.identifier
                        },
                        items: { $0.items },
                        movedHint: { _, _ in false }
                    ),
                    item: .init(
                        identifier: { $0 },
                        updated: { _, _ in false },
                        movedHint: { $0 == $1 }
                    )
                )
            )
        }
    }
}
