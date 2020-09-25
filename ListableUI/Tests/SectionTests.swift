//
//  SectionTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 11/27/19.
//

import XCTest
@testable import ListableUI


class SectionTests: XCTestCase
{
    func test_contains()
    {
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
        
        self.testcase("empty") {
            XCTAssertEqual(empty.contains(any: []), false)
            XCTAssertEqual(noHeader.contains(any: []), false)
            XCTAssertEqual(noFooter.contains(any: []), false)
            XCTAssertEqual(populated.contains(any: []), false)
        }
        
        self.testcase("header") {
            XCTAssertEqual(empty.contains(any: [.sectionHeaders]), false)
            XCTAssertEqual(noHeader.contains(any: [.sectionHeaders]), false)
            XCTAssertEqual(noFooter.contains(any: [.sectionHeaders]), true)
            XCTAssertEqual(populated.contains(any: [.sectionHeaders]), true)
        }
        
        self.testcase("footer") {
            XCTAssertEqual(empty.contains(any: [.sectionFooters]), false)
            XCTAssertEqual(noHeader.contains(any: [.sectionFooters]), true)
            XCTAssertEqual(noFooter.contains(any: [.sectionFooters]), false)
            XCTAssertEqual(populated.contains(any: [.sectionFooters]), true)
        }
        
        self.testcase("items") {
            XCTAssertEqual(empty.contains(any: [.items]), false)
            XCTAssertEqual(noHeader.contains(any: [.items]), true)
            XCTAssertEqual(noFooter.contains(any: [.items]), true)
            XCTAssertEqual(populated.contains(any: [.items]), true)
        }
        
        self.testcase("all ") {
            XCTAssertEqual(empty.contains(any: [.items, .sectionHeaders, .sectionFooters]), false)
            XCTAssertEqual(noHeader.contains(any: [.items, .sectionHeaders, .sectionFooters]), true)
            XCTAssertEqual(noFooter.contains(any: [.items, .sectionHeaders, .sectionFooters]), true)
            XCTAssertEqual(populated.contains(any: [.items, .sectionHeaders, .sectionFooters]), true)
        }
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
    
    var identifier: Identifier<TestItem> {
        .init()
    }
    
    typealias ContentView = UIView
    
    static func createReusableContentView(frame: CGRect) -> UIView {
        UIView(frame: frame)
    }
    
    func apply(to views: ItemContentViews<TestItem>, for reason: ApplyReason, with info: ApplyItemContentInfo) {}
}
