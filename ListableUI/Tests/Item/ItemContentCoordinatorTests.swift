//
//  ItemContentCoordinatorTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 5/22/20.
//

import XCTest

@testable import ListableUI

class ItemContentCoordinatorActionsTests: XCTestCase {
    func test_update() {
        var item = Item(TestContent(value: "first"))

        var callbackCount = 0

        let actions = ItemContentCoordinatorActions(current: { item }, update: { new, _ in
            item = new
            callbackCount += 1
        })

        testcase("Closure based update") {
            actions.update {
                $0.content.value = "update2"
            }

            actions.update {
                $0.content.value = "update3"
            }

            XCTAssertEqual(item.content.value, "update3")
            XCTAssertEqual(callbackCount, 2)
        }
    }
}

class ItemContentCoordinatorInfoTests: XCTestCase {
    func test() {
        let original = Item(TestContent(value: "original"))
        var current = original

        let info = ItemContentCoordinatorInfo(original: original, current: { current })

        current.content.value = "current"

        XCTAssertEqual(info.original.content.value, "original")
        XCTAssertEqual(info.current.content.value, "current")
    }
}

private struct TestContent: ItemContent, Equatable {
    var value: String

    typealias ContentView = UIView

    var identifierValue: String {
        value
    }

    func apply(to _: ItemContentViews<TestContent>, for _: ApplyReason, with _: ApplyItemContentInfo) {}

    static func createReusableContentView(frame: CGRect) -> UIView {
        UIView(frame: frame)
    }
}
