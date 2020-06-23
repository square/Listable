//
//  PagedListLayoutTests.swift
//  Listable-Unit-Tests
//
//  Created by Kyle Van Essen on 6/6/20.
//

import XCTest
import Snapshot

@testable import Listable


class PagedListLayoutTests : XCTestCase
{
    func test_layout_vertical()
    {
        let listView = self.list(for: .vertical)
        
        let snapshot = Snapshot(for: SizedViewIteration(size: listView.contentSize), input: listView)
        
        snapshot.test(output: ViewImageSnapshot.self)
        snapshot.test(output: LayoutAttributesSnapshot.self)
    }
    
    func test_layout_horizontal()
    {
        let listView = self.list(for: .horizontal)
        
        let snapshot = Snapshot(for: SizedViewIteration(size: listView.contentSize), input: listView)
        
        snapshot.test(output: ViewImageSnapshot.self)
        snapshot.test(output: LayoutAttributesSnapshot.self)
    }
    
    func list(for direction : LayoutDirection) -> ListView
    {
        let listView = ListView(frame: CGRect(origin: .zero, size: CGSize(width: 200.0, height: 200.0)))

        listView.setProperties { list in
            
            list.layout = .paged {
                $0.direction = direction
                $0.pagingSize = .fixed(50.0)
                $0.itemInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
            }
            
            list.content.header = HeaderFooter(TestingHeaderFooterContent(color: .blue))
            list.content.footer = HeaderFooter(TestingHeaderFooterContent(color: .green))
            
            list += Section(identifier: "first") { section in
                
                section.header = HeaderFooter(TestingHeaderFooterContent(color: .purple))
                section.footer = HeaderFooter(TestingHeaderFooterContent(color: .red))
                
                section += TestingItemContent(color: .init(white: 0.0, alpha: 0.3))
                section += TestingItemContent(color: .init(white: 0.0, alpha: 0.4))
                section += TestingItemContent(color: .init(white: 0.0, alpha: 0.5))
            }
            
            list += Section(identifier: "second") { section in
                
                section.header = HeaderFooter(TestingHeaderFooterContent(color: .purple))
                section.footer = HeaderFooter(TestingHeaderFooterContent(color: .red))
                
                section += TestingItemContent(color: .init(white: 0.0, alpha: 0.6))
                section += TestingItemContent(color: .init(white: 0.0, alpha: 0.7))
            }
        }
        
        return listView
    }
}


fileprivate struct TestingHeaderFooterContent : HeaderFooterContent {
    
    var color : UIColor
    
    func apply(to view: UIView, reason: ApplyReason) {
        view.backgroundColor = self.color
    }
    
    func isEquivalent(to other: TestingHeaderFooterContent) -> Bool {
        false
    }
    
    typealias ContentView = UIView
    
    static func createReusableHeaderFooterView(frame: CGRect) -> UIView {
        UIView(frame: frame)
    }
}


fileprivate struct TestingItemContent : ItemContent {
    
    var color : UIColor
    
    var identifier: Identifier<TestingItemContent> {
        .init("testing")
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
