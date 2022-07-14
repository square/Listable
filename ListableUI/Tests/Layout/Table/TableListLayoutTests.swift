//
//  TableListLayoutTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 5/8/20.
//

import XCTest
import Snapshot

@testable import ListableUI


class TableAppearanceTests : XCTestCase
{
    func test_init()
    {
        let appearance = TableAppearance()
        
        XCTAssertEqual(appearance.layout, TableAppearance.Layout())
    }
}


class TableAppearance_LayoutTests : XCTestCase
{
    func test_init()
    {
        let layout = TableAppearance.Layout()
        
        XCTAssertEqual(layout.interSectionSpacingWithNoFooter, 0.0)
        XCTAssertEqual(layout.interSectionSpacingWithFooter, 0.0)
        XCTAssertEqual(layout.sectionHeaderBottomSpacing, 0.0)
        XCTAssertEqual(layout.itemSpacing, 0.0)
        XCTAssertEqual(layout.itemToSectionFooterSpacing, 0.0)
    }
    
    func test_width()
    {
        self.testcase("No width constraint") {
            XCTAssertEqual(110.0, TableAppearance.Layout.width(with: 200.0, padding: HorizontalPadding(leading: 50.0, trailing: 40.0), constraint: .noConstraint))
        }
        
        self.testcase("Has width constraint") {
            XCTAssertEqual(100.0, TableAppearance.Layout.width(with: 200.0, padding: HorizontalPadding(leading: 50.0, trailing: 40.0), constraint: .fixed(100.0)))
            XCTAssertEqual(110.0, TableAppearance.Layout.width(with: 200.0, padding: HorizontalPadding(leading: 50.0, trailing: 40.0), constraint: .atMost(200.0)))
        }
    }
}


class TableListLayoutTests : XCTestCase
{
    func test_naturalWidth_vertical() {
        let list = self.listProperties(direction: .vertical, includeHeader: true, stickyListHeader: false)
        
        let size = ListView.contentSize(in: CGSize(width: 400, height: 400), for: list, safeAreaInsets: .zero)
        
        XCTAssertEqual(size.naturalWidth, 130.0)
    }
    
    func test_naturalWidth_horizontal() {
        let list = self.listProperties(direction: .horizontal, includeHeader: true, stickyListHeader: false)
        
        let size = ListView.contentSize(in: CGSize(width: 400, height: 400), for: list, safeAreaInsets: .zero)
        
        XCTAssertEqual(size.naturalWidth, 110.0)
    }
    
    func test_layout_vertical_includingHeader()
    {
        let listView = self.list(direction: .vertical, includeHeader: true)
        
        let snapshot = Snapshot(for: SizedViewIteration(size: listView.contentSize), input: listView)
        
        snapshot.test(output: ViewImageSnapshot.self)
        snapshot.test(output: LayoutAttributesSnapshot.self)
    }

    func test_layout_vertical_stickyHeader()
    {
        let listView = self.list(direction: .vertical, includeHeader: true, stickyListHeader: true)
        listView.collectionView.setContentOffset(.init(x: 0, y: 100), animated: false)

        let snapshot = Snapshot(for: SizedViewIteration(size: listView.frame.size), input: listView)

        snapshot.test(output: ViewImageSnapshot.self)
        snapshot.test(output: LayoutAttributesSnapshot.self)
    }

    func test_layout_vertical_excludingHeader()
    {
        let listView = self.list(direction: .vertical, includeHeader: false)

        let snapshot = Snapshot(for: SizedViewIteration(size: listView.contentSize), input: listView)

        snapshot.test(output: ViewImageSnapshot.self)
        snapshot.test(output: LayoutAttributesSnapshot.self)
    }
    
    func test_layout_horizontal_includingHeader()
    {
        let listView = self.list(direction: .horizontal, includeHeader: true)
        
        let snapshot = Snapshot(for: SizedViewIteration(size: listView.contentSize), input: listView)
        
        snapshot.test(output: ViewImageSnapshot.self)
        snapshot.test(output: LayoutAttributesSnapshot.self)
    }

    func test_layout_horizontal_excludingHeader()
    {
        let listView = self.list(direction: .horizontal, includeHeader: false)

        let snapshot = Snapshot(for: SizedViewIteration(size: listView.contentSize), input: listView)

        snapshot.test(output: ViewImageSnapshot.self)
        snapshot.test(output: LayoutAttributesSnapshot.self)
    }

    func test_layout_horizontal_stickyHeader()
    {
        let listView = self.list(direction: .horizontal, includeHeader: true, stickyListHeader: true)
        listView.collectionView.setContentOffset(.init(x: 100, y: 0), animated: false)

        let snapshot = Snapshot(for: SizedViewIteration(size: listView.frame.size), input: listView)

        snapshot.test(output: ViewImageSnapshot.self)
        snapshot.test(output: LayoutAttributesSnapshot.self)
    }

    
    func list(direction: LayoutDirection, includeHeader: Bool, stickyListHeader: Bool = false) -> ListView
    {
        /// 200x200 so the layout will support both horizontal and vertical layouts.
        let listView = ListView(frame: CGRect(origin: .zero, size: CGSize(width: 200.0, height: 200.0)))
        
        listView.configure(
            with: self.listProperties(direction: direction, includeHeader: includeHeader, stickyListHeader: stickyListHeader)
        )
        
        listView.collectionView.layoutIfNeeded()
        
        return listView
    }
    
    func listProperties(direction : LayoutDirection, includeHeader : Bool, stickyListHeader: Bool) -> ListProperties {
        ListProperties.default { list in
            list.layout = .table {
                $0.stickyListHeader = stickyListHeader

                $0.direction = direction
                
                $0.bounds = .init(
                    padding: UIEdgeInsets(top: 10.0, left: 20.0, bottom: 30.0, right: 40.0),
                    width: .noConstraint
                )
                
                $0.layout = .init(
                    headerToFirstSectionSpacing: 10.0,
                    interSectionSpacingWithNoFooter: 15.0,
                    interSectionSpacingWithFooter: 20.0,
                    sectionHeaderBottomSpacing: 10.0,
                    itemSpacing: 5.0,
                    itemToSectionFooterSpacing: 10.0,
                    lastSectionToFooterSpacing: 20.0
                )
            }
            
            list.content.containerHeader = HeaderFooter(TestingHeaderFooterContent(color: .red), sizing: .fixed(width: 50.0, height: 50.0))
            
            if includeHeader {
                list.header = HeaderFooter(TestingHeaderFooterContent(color: .blue), sizing: .fixed(width: 50.0, height: 50.0))
            }
            
            list.footer = HeaderFooter(TestingHeaderFooterContent(color: .cyan), sizing: .fixed(width: 70.0, height: 70.0))
            
            list += Section("first") { section in
                section.layouts.table.customInterSectionSpacing = 30
                
                section.layouts.table.width = .fill
                
                section.header = HeaderFooter(TestingHeaderFooterContent(color: .green), sizing: .fixed(width: 30.0, height: 30.0))
                section.footer = HeaderFooter(TestingHeaderFooterContent(color: .magenta), sizing: .fixed(width: 40.0, height: 40.0))
                
                section += Item(TestingItemContent(color: .init(white: 0.0, alpha: 0.1)), sizing: .fixed(width: 20.0, height: 20.0))
                section += Item(TestingItemContent(color: .init(white: 0.0, alpha: 0.2)), sizing: .fixed(width: 20.0, height: 20.0))
                section += Item(TestingItemContent(color: .init(white: 0.0, alpha: 0.3)), sizing: .fixed(width: 20.0, height: 20.0))
            }
            
            list += Section("second") { section in
                
                section.layouts.table.width = .custom(
                    .init(
                        padding: .init(leading: 10, trailing: 50),
                        width: .fixed(100),
                        alignment: .leading
                    )
                )
                
                section.header = HeaderFooter(TestingHeaderFooterContent(color: .green), sizing: .fixed(width: 30.0, height: 30.0))
                section.footer = HeaderFooter(TestingHeaderFooterContent(color: .magenta), sizing: .fixed(width: 40.0, height: 40.0))

                section += Item(TestingItemContent(color: .init(white: 0.0, alpha: 0.1)), sizing: .fixed(width: 30.0, height: 30.0))
                section += Item(TestingItemContent(color: .init(white: 0.0, alpha: 0.2)), sizing: .fixed(width: 40.0, height: 40.0))
            }
            
            list += Section("third") { section in
                section.header = HeaderFooter(TestingHeaderFooterContent(color: .green), sizing: .fixed(width: 30.0, height: 30.0))
                
                section += Item(TestingItemContent(color: .init(white: 0.0, alpha: 0.1)), sizing: .fixed(width: 10.0, height: 10.0))
                section += Item(TestingItemContent(color: .init(white: 0.0, alpha: 0.2)), sizing: .fixed(width: 20.0, height: 20.0))
            }
            
            list += Section("fourth") { section in
                section.header = HeaderFooter(TestingHeaderFooterContent(color: .green), sizing: .fixed(width: 30.0, height: 30.0))
                section.footer = HeaderFooter(TestingHeaderFooterContent(color: .magenta), sizing: .fixed(width: 40.0, height: 40.0))

                section.layouts.table.columns = .init(count: 2, spacing: 10.0)
                
                section += Item(TestingItemContent(color: .init(white: 0.0, alpha: 0.1)), sizing: .fixed(width: 50.0, height: 50.0))
                section += Item(TestingItemContent(color: .init(white: 0.0, alpha: 0.2)), sizing: .fixed(width: 70.0, height: 70.0))
                
                section += Item(TestingItemContent(color: .init(white: 0.0, alpha: 0.1)), sizing: .fixed(width: 70.0, height: 70.0))
                section += Item(TestingItemContent(color: .init(white: 0.0, alpha: 0.2)), sizing: .fixed(width: 50.0, height: 50.0))
            }
            
            list += Section("fifth") { section in
                section += Item(TestingItemContent(color: .init(white: 0.0, alpha: 0.1)), sizing: .fixed(width: 10.0, height: 10.0))
                section += Item(TestingItemContent(color: .init(white: 0.0, alpha: 0.2)), sizing: .fixed(width: 20.0, height: 20.0))
            }
        }
    }
    
}


fileprivate struct TestingHeaderFooterContent : HeaderFooterContent {
    
    var color : UIColor
    
    func apply(
        to views: HeaderFooterContentViews<Self>,
        for reason: ApplyReason,
        with info: ApplyHeaderFooterContentInfo
    ) {
        views.content.backgroundColor = self.color
    }
    
    func isEquivalent(to other: TestingHeaderFooterContent) -> Bool {
        false
    }
    
    typealias ContentView = UIView
    
    static func createReusableContentView(frame: CGRect) -> UIView {
        UIView(frame: frame)
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
