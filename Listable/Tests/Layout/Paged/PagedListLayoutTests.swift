//
//  PagedListLayoutTests.swift
//  Listable-Unit-Tests
//
//  Created by Kyle Van Essen on 6/6/20.
//

import XCTest
@testable import Listable


class PagedListLayoutTests : XCTestCase
{
    func test_layout_vertical()
    {
        let listView = ListView(frame: CGRect(origin: .zero, size: CGSize(width: 200.0, height: 500.0)))
        
        listView.setContent { list in
            
            list.layout = .paged()
                        
            list += Section(identifier: "first") { section in
                section += Item(TestingItemContent(color: .init(white: 0.0, alpha: 0.1)))
                section += Item(TestingItemContent(color: .init(white: 0.0, alpha: 0.1)))
            }
            
            list += Section(identifier: "second") { section in
                section += Item(TestingItemContent(color: .init(white: 0.0, alpha: 0.1)))
                section += Item(TestingItemContent(color: .init(white: 0.0, alpha: 0.2)))
            }
        }
        
        let attributes = listView.collectionViewLayout.layout.content.layoutAttributes
        
        let expectedAttributes = ListLayoutAttributes(
            contentSize: CGSize(width: 800, height: 500.0),
            header: nil,
            footer: nil,
            overscrollFooter: nil,
            sections: [
                .init(
                    frame: CGRect(x: 0.0, y: 0.0, width: 400.0, height: 500.0),
                    header: nil,
                    footer: nil,
                    items: [
                        .init(frame: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 500.0)),
                        .init(frame: CGRect(x: 200.0, y: 0.0, width: 200.0, height: 500.0)),
                    ]
                ),

                .init(
                    frame: CGRect(x: 400.0, y: 0.0, width: 400.0, height: 500.0),
                    header: nil,
                    footer: nil,
                    items: [
                        .init(frame: CGRect(x: 400.0, y: 0.0, width: 200.0, height: 500.0)),
                        .init(frame: CGRect(x: 600.0, y: 0.0, width: 200.0, height: 500.0)),
                    ]
                )
            ]
        )
                
        XCTAssertEqual(attributes, expectedAttributes)
    }
    
    func disabled_test_layout_horizontal()
    {
        // TODO
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
