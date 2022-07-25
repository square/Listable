//
//  RetailGridListLayoutTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Gabriel Hernandez Ontiveros on 2021-07-27.
//

import Snapshot
import XCTest

@testable import ListableUI

class RetailGridAppearanceTests: XCTestCase {
    func test_init() {
        let appearance = RetailGridAppearance()

        XCTAssertEqual(appearance.layout, RetailGridAppearance.Layout())
    }
}

class RetailGridAppearance_LayoutTests: XCTestCase {
    func test_init() {
        let layout = RetailGridAppearance.Layout()

        XCTAssertEqual(layout.padding, .zero)
        XCTAssertEqual(layout.itemSpacing, .zero)
        XCTAssertEqual(layout.columns, 1)
        XCTAssertEqual(layout.rows, .infinite(tileAspectRatio: 1))
    }
}

class RetailGridListLayoutTests: XCTestCase {
    func test_layout_infiniteScoll() {
        let listView = list(columns: 2, rows: .infinite(tileAspectRatio: 1))

        let snapshot = Snapshot(for: SizedViewIteration(size: listView.contentSize), input: listView)

        snapshot.test(output: ViewImageSnapshot.self)
        snapshot.test(output: LayoutAttributesSnapshot.self)
    }

    func test_layout_rows() {
        let listView = list(columns: 2, rows: .rows(2))

        let snapshot = Snapshot(for: SizedViewIteration(size: listView.contentSize), input: listView)

        snapshot.test(output: ViewImageSnapshot.self)
        snapshot.test(output: LayoutAttributesSnapshot.self)
    }

    func list(columns: Int, rows: RetailGridAppearance.Layout.Rows) -> ListView {
        let listView = ListView(frame: CGRect(origin: .zero, size: CGSize(width: 200.0, height: 200.0)))

        listView.configure { list in

            list.layout = .retailGrid {
                $0.layout = .init(
                    padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10),
                    itemSpacing: 10,
                    columns: columns,
                    rows: rows
                )
            }

            list += Section("RetailGrid") { section in
                section += Item(TestingItemContent(color: .init(white: 0.0, alpha: 0.1))) {
                    $0.layouts.retailGrid = RetailGridAppearance.ItemLayout(
                        origin: .init(x: 0, y: 0), size: .single
                    )
                }
                section += Item(TestingItemContent(color: .init(white: 0.0, alpha: 0.2))) {
                    $0.layouts.retailGrid = RetailGridAppearance.ItemLayout(
                        origin: .init(x: 1, y: 0), size: .tall
                    )
                }

                section += Item(TestingItemContent(color: .init(white: 0.0, alpha: 0.3))) {
                    $0.layouts.retailGrid = RetailGridAppearance.ItemLayout(
                        origin: .init(x: 0, y: 1), size: .single
                    )
                }

                section += Item(TestingItemContent(color: .init(white: 0.0, alpha: 0.4))) {
                    $0.layouts.retailGrid = RetailGridAppearance.ItemLayout(
                        origin: .init(x: 0, y: 2), size: .wide
                    )
                }
            }
        }

        listView.collectionView.layoutIfNeeded()

        return listView
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
