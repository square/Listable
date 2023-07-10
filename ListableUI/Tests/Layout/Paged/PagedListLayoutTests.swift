//
//  PagedListLayoutTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 6/6/20.
//

import XCTest
import Snapshot

@testable import ListableUI


class PagedListLayoutTests : XCTestCase
{
    private enum TestCase : String {
        case hasBounds
        case fullSize
    }
    
    func test_layout_vertical_full()
    {
        let listView = self.list(for: .vertical, testCase: .fullSize)
        
        let snapshot = Snapshot(for: SizedViewIteration(size: listView.contentSize), input: listView)
        
        snapshot.test(output: ViewImageSnapshot.self)
        snapshot.test(output: LayoutAttributesSnapshot.self)
    }
    
    func test_layout_horizontal_full()
    {
        let listView = self.list(for: .horizontal, testCase: .fullSize)
        
        let snapshot = Snapshot(for: SizedViewIteration(size: listView.contentSize), input: listView)
        
        snapshot.test(output: ViewImageSnapshot.self)
        snapshot.test(output: LayoutAttributesSnapshot.self)
    }
    
    func test_layout_vertical_bounds()
    {
        let listView = self.list(for: .vertical, testCase: .hasBounds)
        
        let snapshot = Snapshot(for: SizedViewIteration(size: listView.contentSize), input: listView)
        
        snapshot.test(output: ViewImageSnapshot.self)
        snapshot.test(output: LayoutAttributesSnapshot.self)
    }
    
    func test_layout_horizontal_bounds()
    {
        let listView = self.list(for: .horizontal, testCase: .hasBounds)
        
        let snapshot = Snapshot(for: SizedViewIteration(size: listView.contentSize), input: listView)
        
        snapshot.test(output: ViewImageSnapshot.self)
        snapshot.test(output: LayoutAttributesSnapshot.self)
    }
    
    private func list(for direction : LayoutDirection, testCase: TestCase) -> ListView
    {
        let listView = ListView(frame: CGRect(origin: .zero, size: CGSize(width: 100.0, height: 100.0)))

        listView.configure { list in
            
            list.layout = .paged {
                $0.direction = direction
                $0.pagingSize = .fixed(100.0)
                
                switch testCase {
                case .fullSize:
                    $0.bounds = nil
                case .hasBounds:
                    $0.bounds = .init(
                        padding: UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0),
                        width: .atMost(40)
                    )
                }
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


class PagedAppearanceTests : XCTestCase
{
    func test_init()
    {
        let appearance = PagedAppearance()
        
        XCTAssertEqual(appearance.direction, .vertical)
        XCTAssertEqual(appearance.showsScrollIndicators, false)
        XCTAssertEqual(appearance.bounds, nil)
    }
}


class PagedAppearance_PagingSize_Tests : XCTestCase
{
    func test_size()
    {
        let size = CGSize(width: 30.0, height: 50.0)
        
        XCTAssertEqual(PagedAppearance.PagingSize.view.size(for: size, direction: .vertical), CGSize(width: 30.0, height: 50.0))
        XCTAssertEqual(PagedAppearance.PagingSize.view.size(for: size, direction: .horizontal), CGSize(width: 30.0, height: 50.0))
        
        XCTAssertEqual(PagedAppearance.PagingSize.fixed(100).size(for: size, direction: .vertical), CGSize(width: 30.0, height: 100.0))
        XCTAssertEqual(PagedAppearance.PagingSize.fixed(100).size(for: size, direction: .horizontal), CGSize(width: 100.0, height: 50.0))
    }
}


fileprivate struct TestingHeaderFooterContent : HeaderFooterContent {
    
    var color : UIColor
    
    func apply(
        to views: HeaderFooterContentViews<TestingHeaderFooterContent>,
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
