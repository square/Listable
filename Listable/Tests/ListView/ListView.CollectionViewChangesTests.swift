//
//  ListView.CollectionViewChangesTests.swift
//  Listable-Unit-Tests
//
//  Created by Kyle Van Essen on 8/24/20.
//

import XCTest
@testable import Listable


class ListView_CollectionViewChangesTests : XCTestCase
{
    func test_init()
    {
        self.testcase("regular") {
            
        }
        
        self.testcase("move workaround enabled") {
            
        }
    }
    
    func test_if_converting_section_moves_requires_removing_overlapping_item_inserts()
    {
        /// When we convert section moves into deletes + inserts, we technically do not
        /// need to tell the collection view about any item-level changes in those deleted
        /// or inserted sections:
        /// - Deleted sections implicitly remove all items:
        /// - Inserted sections query the data source for their row counts.
        ///
        /// This test checks if we need to filter row-level deletions and insertions from these
        /// sections, or if the collection view just ignores them.
        
        let one = Content { content in
            content("a") { section in
                section += TestItem(content: "a")
                section += TestItem(content: "b")
                section += TestItem(content: "c")
            }
            
            content("b") { section in
                section += TestItem(content: "d")
                section += TestItem(content: "e")
            }
        }
        
        let two = Content { content in
            content("b") { section in
                section += TestItem(content: "d")
                section += TestItem(content: "e")
                section += TestItem(content: "f")
            }
            
            content("a") { section in
                section += TestItem(content: "a")
                section += TestItem(content: "b")
            }
        }
        
        let three = Content { content in
            content("a") { section in
                section += TestItem(content: "a")
            }
            
            content("b") { section in
                section += TestItem(content: "d")
                section += TestItem(content: "e")
                section += TestItem(content: "f")
                section += TestItem(content: "g")
            }
        }
        
        let list = ListView(frame: CGRect(origin: .zero, size: CGSize(width: 300.0, height: 500.0)))
        list.content = one
        
        // If we had to filter row level changes, these would crash. If not, the update will work as expected.
        
        XCTAssertNoThrow(list.content = two)
        XCTAssertNoThrow(list.content = three)
    }
}


fileprivate struct TestHeaderFooter : HeaderFooterContent, Equatable {

    typealias ContentView = UIView

    static func createReusableContentView(frame: CGRect) -> UIView {
        UIView(frame: frame)
    }

    func apply(to views: HeaderFooterContentViews<TestHeaderFooter>, reason: ApplyReason) {}
}


fileprivate struct TestItem : ItemContent, Equatable {

    var content : String
    
    var identifier: Identifier<TestItem> {
        .init(content)
    }

    typealias ContentView = UIView

    static func createReusableContentView(frame: CGRect) -> UIView {
        UIView(frame: frame)
    }

    func apply(to views: ItemContentViews<TestItem>, for reason: ApplyReason, with info: ApplyItemContentInfo) {}
}
