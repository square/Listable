//
//  SectionTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 11/27/19.
//

@testable import ListableUI
import XCTest

class SectionTests: XCTestCase {
    func test_contains() {
        let items = [
            Item(TestItem()),
            Item(TestItem()),
            Item(TestItem()),
        ]

        let empty = Section(
            "",
            header: nil,
            footer: nil,
            items: []
        )

        let noHeader = Section(
            "",
            header: nil,
            footer: HeaderFooter(TestHeaderFooter()),
            items: items
        )

        let noFooter = Section(
            "",
            header: HeaderFooter(TestHeaderFooter()),
            footer: nil,
            items: items
        )

        let populated = Section(
            "",
            header: HeaderFooter(TestHeaderFooter()),
            footer: HeaderFooter(TestHeaderFooter()),
            items: items
        )

        testcase("empty") {
            XCTAssertEqual(empty.contains(any: []), false)
            XCTAssertEqual(noHeader.contains(any: []), false)
            XCTAssertEqual(noFooter.contains(any: []), false)
            XCTAssertEqual(populated.contains(any: []), false)
        }

        testcase("header") {
            XCTAssertEqual(empty.contains(any: [.sectionHeaders]), false)
            XCTAssertEqual(noHeader.contains(any: [.sectionHeaders]), false)
            XCTAssertEqual(noFooter.contains(any: [.sectionHeaders]), true)
            XCTAssertEqual(populated.contains(any: [.sectionHeaders]), true)
        }

        testcase("footer") {
            XCTAssertEqual(empty.contains(any: [.sectionFooters]), false)
            XCTAssertEqual(noHeader.contains(any: [.sectionFooters]), true)
            XCTAssertEqual(noFooter.contains(any: [.sectionFooters]), false)
            XCTAssertEqual(populated.contains(any: [.sectionFooters]), true)
        }

        testcase("items") {
            XCTAssertEqual(empty.contains(any: [.items]), false)
            XCTAssertEqual(noHeader.contains(any: [.items]), true)
            XCTAssertEqual(noFooter.contains(any: [.items]), true)
            XCTAssertEqual(populated.contains(any: [.items]), true)
        }

        testcase("all ") {
            XCTAssertEqual(empty.contains(any: [.items, .sectionHeaders, .sectionFooters]), false)
            XCTAssertEqual(noHeader.contains(any: [.items, .sectionHeaders, .sectionFooters]), true)
            XCTAssertEqual(noFooter.contains(any: [.items, .sectionHeaders, .sectionFooters]), true)
            XCTAssertEqual(populated.contains(any: [.items, .sectionHeaders, .sectionFooters]), true)
        }
    }
}

private struct TestHeaderFooter: HeaderFooterContent, Equatable {
    typealias ContentView = UIView

    static func createReusableContentView(frame: CGRect) -> UIView {
        UIView(frame: frame)
    }

    func apply(
        to _: HeaderFooterContentViews<Self>,
        for _: ApplyReason,
        with _: ApplyHeaderFooterContentInfo
    ) {
        // Nothing.
    }
}

private struct TestItem: ItemContent, Equatable {
    var identifier: String {
        ""
    }

    typealias ContentView = UIView

    static func createReusableContentView(frame: CGRect) -> UIView {
        UIView(frame: frame)
    }

    func apply(to _: ItemContentViews<TestItem>, for _: ApplyReason, with _: ApplyItemContentInfo) {}
}
