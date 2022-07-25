//
//  ContentFiltersTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 8/21/20.
//

@testable import ListableUI
import XCTest

class ContentFiltersTests: XCTestCase {
    func test_contains() {
        let sections = [
            Section(
                "",
                header: HeaderFooter(TestHeaderFooter()),
                footer: HeaderFooter(TestHeaderFooter()),
                items: [
                    Item(TestItem()),
                    Item(TestItem()),
                    Item(TestItem()),
                ]
            ),
        ]

        let empty = Content()

        let noHeader = Content(
            header: nil,
            footer: HeaderFooter(TestHeaderFooter()),
            overscrollFooter: HeaderFooter(TestHeaderFooter()),
            sections: sections
        )

        let noFooter = Content(
            header: HeaderFooter(TestHeaderFooter()),
            footer: nil,
            overscrollFooter: HeaderFooter(TestHeaderFooter()),
            sections: sections
        )

        let noOverscroll = Content(
            header: HeaderFooter(TestHeaderFooter()),
            footer: HeaderFooter(TestHeaderFooter()),
            overscrollFooter: nil,
            sections: sections
        )

        let noSections = Content(
            header: HeaderFooter(TestHeaderFooter()),
            footer: HeaderFooter(TestHeaderFooter()),
            overscrollFooter: HeaderFooter(TestHeaderFooter()),
            sections: []
        )

        let populated = Content(
            header: HeaderFooter(TestHeaderFooter()),
            footer: HeaderFooter(TestHeaderFooter()),
            overscrollFooter: HeaderFooter(TestHeaderFooter()),
            sections: sections
        )

        testcase("list header") {
            XCTAssertEqual(empty.contains(any: [.listHeader]), false)
            XCTAssertEqual(noHeader.contains(any: [.listHeader]), false)
            XCTAssertEqual(noFooter.contains(any: [.listHeader]), true)
            XCTAssertEqual(noOverscroll.contains(any: [.listHeader]), true)
            XCTAssertEqual(noSections.contains(any: [.listHeader]), true)
            XCTAssertEqual(populated.contains(any: [.listHeader]), true)
        }

        testcase("list footer") {
            XCTAssertEqual(empty.contains(any: [.listFooter]), false)
            XCTAssertEqual(noHeader.contains(any: [.listFooter]), true)
            XCTAssertEqual(noFooter.contains(any: [.listFooter]), false)
            XCTAssertEqual(noOverscroll.contains(any: [.listFooter]), true)
            XCTAssertEqual(noSections.contains(any: [.listFooter]), true)
            XCTAssertEqual(populated.contains(any: [.listFooter]), true)
        }

        testcase("overscroll footer") {
            XCTAssertEqual(empty.contains(any: [.overscrollFooter]), false)
            XCTAssertEqual(noHeader.contains(any: [.overscrollFooter]), true)
            XCTAssertEqual(noFooter.contains(any: [.overscrollFooter]), true)
            XCTAssertEqual(noOverscroll.contains(any: [.overscrollFooter]), false)
            XCTAssertEqual(noSections.contains(any: [.overscrollFooter]), true)
            XCTAssertEqual(populated.contains(any: [.overscrollFooter]), true)
        }

        testcase("section only fields") {
            XCTAssertEqual(empty.contains(any: [.items]), false)
            XCTAssertEqual(noHeader.contains(any: [.items]), true)
            XCTAssertEqual(noFooter.contains(any: [.items]), true)
            XCTAssertEqual(noOverscroll.contains(any: [.items]), true)
            XCTAssertEqual(noSections.contains(any: [.items]), false)
            XCTAssertEqual(populated.contains(any: [.items]), true)
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
    var identifierValue: String {
        ""
    }

    typealias ContentView = UIView

    static func createReusableContentView(frame: CGRect) -> UIView {
        UIView(frame: frame)
    }

    func apply(to _: ItemContentViews<TestItem>, for _: ApplyReason, with _: ApplyItemContentInfo) {}
}
