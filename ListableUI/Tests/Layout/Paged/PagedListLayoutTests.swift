//
//  PagedListLayoutTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 6/6/20.
//

import Snapshot
import XCTest

@testable import ListableUI

class PagedListLayoutTests: XCTestCase {
    func test_layout_vertical() {
        let listView = list(for: .vertical)

        let snapshot = Snapshot(for: SizedViewIteration(size: listView.contentSize), input: listView)

        snapshot.test(output: ViewImageSnapshot.self)
        snapshot.test(output: LayoutAttributesSnapshot.self)
    }

    func test_layout_horizontal() {
        let listView = list(for: .horizontal)

        let snapshot = Snapshot(for: SizedViewIteration(size: listView.contentSize), input: listView)

        snapshot.test(output: ViewImageSnapshot.self)
        snapshot.test(output: LayoutAttributesSnapshot.self)
    }

    func list(for direction: LayoutDirection) -> ListView {
        let listView = ListView(frame: CGRect(origin: .zero, size: CGSize(width: 200.0, height: 200.0)))

        listView.configure { list in

            list.layout = .paged {
                $0.direction = direction
                $0.pagingSize = .fixed(50.0)
                $0.itemInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
            }

            list.header = TestingHeaderFooterContent(color: .blue)
            list.footer = TestingHeaderFooterContent(color: .green)

            list += Section("first") { section in

                section.header = TestingHeaderFooterContent(color: .purple)
                section.footer = TestingHeaderFooterContent(color: .red)

                section += TestingItemContent(color: .init(white: 0.0, alpha: 0.3))
                section += TestingItemContent(color: .init(white: 0.0, alpha: 0.4))
                section += TestingItemContent(color: .init(white: 0.0, alpha: 0.5))
            }

            list += Section("second") { section in

                section.header = TestingHeaderFooterContent(color: .purple)
                section.footer = TestingHeaderFooterContent(color: .red)

                section += TestingItemContent(color: .init(white: 0.0, alpha: 0.6))
                section += TestingItemContent(color: .init(white: 0.0, alpha: 0.7))
            }
        }

        return listView
    }
}

class PagedAppearanceTests: XCTestCase {
    func test_init() {
        let appearance = PagedAppearance()

        XCTAssertEqual(appearance.direction, .vertical)
        XCTAssertEqual(appearance.showsScrollIndicators, false)
        XCTAssertEqual(appearance.itemInsets, .zero)
    }
}

class PagedAppearance_PagingSize_Tests: XCTestCase {
    func test_size() {
        let size = CGSize(width: 30.0, height: 50.0)

        XCTAssertEqual(PagedAppearance.PagingSize.view.size(for: size, direction: .vertical), CGSize(width: 30.0, height: 50.0))
        XCTAssertEqual(PagedAppearance.PagingSize.view.size(for: size, direction: .horizontal), CGSize(width: 30.0, height: 50.0))

        XCTAssertEqual(PagedAppearance.PagingSize.fixed(100).size(for: size, direction: .vertical), CGSize(width: 30.0, height: 100.0))
        XCTAssertEqual(PagedAppearance.PagingSize.fixed(100).size(for: size, direction: .horizontal), CGSize(width: 100.0, height: 50.0))
    }
}

private struct TestingHeaderFooterContent: HeaderFooterContent {
    var color: UIColor

    func apply(
        to views: HeaderFooterContentViews<TestingHeaderFooterContent>,
        for _: ApplyReason,
        with _: ApplyHeaderFooterContentInfo
    ) {
        views.content.backgroundColor = color
    }

    func isEquivalent(to _: TestingHeaderFooterContent) -> Bool {
        false
    }

    typealias ContentView = UIView

    static func createReusableContentView(frame: CGRect) -> UIView {
        UIView(frame: frame)
    }
}

private struct TestingItemContent: ItemContent {
    var color: UIColor

    var identifierValue: String {
        ""
    }

    func apply(to views: ItemContentViews<Self>, for _: ApplyReason, with _: ApplyItemContentInfo) {
        views.content.backgroundColor = color
    }

    func isEquivalent(to _: TestingItemContent) -> Bool {
        false
    }

    typealias ContentView = UIView

    static func createReusableContentView(frame: CGRect) -> UIView {
        UIView(frame: frame)
    }
}
