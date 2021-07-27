//
//  MosaicListLayoutTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Gabriel Hernandez Ontiveros on 2021-07-27.
//

import XCTest
import Snapshot

@testable import ListableUI


class MosaicAppearanceTests : XCTestCase
{
    func test_init()
    {
        let appearance = MosaicAppearance()
        
        XCTAssertEqual(appearance.layout, MosaicAppearance.Layout())
    }
}

class MosaicAppearance_LayoutTests : XCTestCase
{
    func test_init()
    {
        let layout = MosaicAppearance.Layout()

        XCTAssertEqual(layout.padding, .zero)
        XCTAssertEqual(layout.itemSpacing, .zero)
        XCTAssertEqual(layout.columns, 1)
        XCTAssertEqual(layout.rows, .infinite)

    }
    
    func test_width()
    {
        self.testcase("No width constraint") {
            XCTAssertEqual(110.0, TableAppearance.Layout.width(with: 200.0, padding: HorizontalPadding(left: 50.0, right: 40.0), constraint: .noConstraint))
        }
        
        self.testcase("Has width constraint") {
            XCTAssertEqual(100.0, TableAppearance.Layout.width(with: 200.0, padding: HorizontalPadding(left: 50.0, right: 40.0), constraint: .fixed(100.0)))
            XCTAssertEqual(110.0, TableAppearance.Layout.width(with: 200.0, padding: HorizontalPadding(left: 50.0, right: 40.0), constraint: .atMost(200.0)))
        }
    }
}

class MosaicListLayoutTests : XCTestCase
{
    func test_layout_infiniteScoll()
    {
        let listView = self.list(columns: 2, rows: .infinite)

        let snapshot = Snapshot(for: SizedViewIteration(size: listView.contentSize), input: listView)

        snapshot.test(output: ViewImageSnapshot.self)
        snapshot.test(output: LayoutAttributesSnapshot.self)
    }
    
    func test_layout_rows()
    {
        let listView = self.list(columns: 2, rows: .rows(2))

        let snapshot = Snapshot(for: SizedViewIteration(size: listView.contentSize), input: listView)

        snapshot.test(output: ViewImageSnapshot.self)
        snapshot.test(output: LayoutAttributesSnapshot.self)
    }
    
    func list(columns: Int, rows: MosaicAppearance.Layout.Rows) -> ListView
    {
        let listView = ListView(frame: CGRect(origin: .zero, size: CGSize(width: 200.0, height: 200.0)))
        
        listView.configure { list in

            list.layout = .mosaic {
                $0.layout = .init(
                    padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10),
                    itemSpacing: 10,
                    columns: columns,
                    rows: rows
                )
            }
            
            list += Section("mosaic") { section in
                section += Item(TestingItemContent(color: .init(white: 0.0, alpha: 0.1))) {
                    $0.layouts.mosaic = MosaicAppearance.ItemLayout(
                        origin: .init(x: 0, y: 0), size: .single
                    )
                }
                section += Item(TestingItemContent(color: .init(white: 0.0, alpha: 0.2))) {
                    $0.layouts.mosaic = MosaicAppearance.ItemLayout(
                        origin: .init(x: 1, y: 0), size: .tall
                    )
                }
                
                section += Item(TestingItemContent(color: .init(white: 0.0, alpha: 0.3))) {
                    $0.layouts.mosaic = MosaicAppearance.ItemLayout(
                        origin: .init(x: 0, y: 1), size: .single
                    )
                }
                
                section += Item(TestingItemContent(color: .init(white: 0.0, alpha: 0.4))) {
                    $0.layouts.mosaic = MosaicAppearance.ItemLayout(
                        origin: .init(x: 0, y: 2), size: .wide
                    )
                }
            }
        }
        
        listView.collectionView.layoutIfNeeded()
        
        return listView
    }
}

fileprivate struct TestingItemContent : ItemContent {
    
    var color : UIColor
    
    var identifierValue: String {
        ""
    }
    
    func apply(to views: ItemContentViews<Self>, for reason: ApplyReason, with info: ApplyItemContentInfo)
    {
        views.content.backgroundColor = self.color
    }
    
    func isEquivalent(to other: TestingItemContent) -> Bool {
        false
    }
    
    typealias ContentView = UIView
    
    static func createReusableContentView(frame: CGRect) -> UIView {
        UIView(frame: frame)
    }
}
