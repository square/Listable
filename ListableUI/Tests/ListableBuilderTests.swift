//
//  ListableBuilderTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 10/31/21.
//

import ListableUI
import XCTest


class ListableBuilderTests : XCTestCase {
    
    func test_empty() {
        let content : [String] = build {}
        
        XCTAssertEqual(content, [])
    }
    
    func test_single() {
        let content : [String] = build {
            "1"
        }
        
        XCTAssertEqual(
            content, ["1"]
        )
    }
    
    func test_multiple() {
        let content : [String] = build {
            "1"
            "2"
        }
        
        XCTAssertEqual(
            content, ["1", "2"]
        )
    }
    
    func test_array() {
        
        let content : [String] = build {
            ["1", "2"]
        }
        
        XCTAssertEqual(
            content, ["1", "2"]
        )
    }
    
    func test_if_else() {
        
        /// If we use just `true` or `false`, the compiler (rightly) complains about unreachable code.
        let trueValue = "true" == "true"
        let falseValue = "true" == "false"
        
        let content : [String] = build {
            "1"
            
            if trueValue {
                "2"
            } else {
                "3"
            }
            
            if falseValue {
                "4"
            } else {
                "5"
            }
            
            if falseValue {
                "6"
            } else if falseValue {
                "7"
            }
        }
        
        XCTAssertEqual(
            content, ["1", "2", "5"]
        )
    }
    
    func test_for_in() {
        
        let content : [String] = build {
            for item in 1...6 {
                if item % 2 == 0 {
                    "\(item)"
                }
            }
        }
        
        XCTAssertEqual(
            content, ["2", "4", "6"]
        )
    }
    
    func test_map() {
        
        let numbers : [Int] = [1, 2, 3]
        
        let content : [String] = build {
            numbers.map(String.init)
        }
        
        XCTAssertEqual(
            content, ["1", "2", "3"]
        )
    }
    
    func test_switch() {
        
        enum TestEnum : CaseIterable {
            case first
            case second
            case third
        }
        
        let content : [String] = build {
            for item in TestEnum.allCases {
                switch item {
                case .first:
                    "1"
                case .second:
                    "2"
                case .third:
                    "3"
                }
            }
        }
        
        XCTAssertEqual(
            content, ["1", "2", "3"]
        )
    }
    
    func test_available() {
                
        let content : [String] = build {
            
            if #available(iOS 20, *) {
                "1"
            } else {
                "2"
            }
            
            if #available(iOS 11, *) {
                "3"
            } else {
                "4"
            }
        }
        
        XCTAssertEqual(
            content, ["2", "3"]
        )
    }
    
    func test_item_default_implementation_resolution() {
        
        var callCount : Int = 0
        
        let sections : [Section] = [
            Section("1") {
                EquatableContent { callCount += 1 }
                Item(EquatableContent { callCount += 1 })
                EquivalentContent { callCount += 1 }
                Item(EquivalentContent { callCount += 1 })
            },
            
            Section("1") { section in
                section += EquatableContent { callCount += 1 }
                section.add(Item(EquatableContent { callCount += 1 }))
                section += EquivalentContent { callCount += 1 }
                section.add(Item(EquivalentContent { callCount += 1 }))
            },
            
            Section("1") { section in
                section.add {
                    EquatableContent { callCount += 1 }
                    Item(EquatableContent { callCount += 1 })
                    EquivalentContent { callCount += 1 }
                    Item(EquivalentContent { callCount += 1 })
                }
            }
        ]
        
        for section in sections {
            
            callCount = 0
            
            let equatableItem1 = section.items[0]
            let equatableItem2 = section.items[1]
            let equivalentItem1 = section.items[2]
            let equivalentItem2 = section.items[3]
            
            XCTAssertTrue(equatableItem1.anyIsEquivalent(to: equatableItem1))
            XCTAssertEqual(callCount, 1)
            
            XCTAssertTrue(equatableItem2.anyIsEquivalent(to: equatableItem2))
            XCTAssertEqual(callCount, 2)
            
            XCTAssertTrue(equivalentItem1.anyIsEquivalent(to: equivalentItem1))
            XCTAssertEqual(callCount, 3)
            
            XCTAssertTrue(equivalentItem2.anyIsEquivalent(to: equivalentItem2))
            XCTAssertEqual(callCount, 4)
        }
    }
    
    func test_headerfooter_default_implementation_resolution() {
        
        var callCount : Int = 0
        
        let equatableSection = Section("1") {
            TestContent()
        } header: {
            EquatableHeaderFooter { callCount += 1 }
        } footer: {
            HeaderFooter(EquatableHeaderFooter { callCount += 1 })
        }
        
        let equivalentSection = Section("1") {
            TestContent()
        } header: {
            EquivalentHeaderFooter { callCount += 1 }
        } footer: {
            HeaderFooter(EquivalentHeaderFooter { callCount += 1 })
        }
        
        let equatableItem1 = equatableSection.header!.asAnyHeaderFooter()
        let equatableItem2 = equatableSection.footer!.asAnyHeaderFooter()
        let equivalentItem1 = equivalentSection.header!.asAnyHeaderFooter()
        let equivalentItem2 = equivalentSection.footer!.asAnyHeaderFooter()
        
        XCTAssertTrue(equatableItem1.anyIsEquivalent(to: equatableItem1))
        XCTAssertEqual(callCount, 1)
        
        XCTAssertTrue(equatableItem2.anyIsEquivalent(to: equatableItem2))
        XCTAssertEqual(callCount, 2)
        
        XCTAssertTrue(equivalentItem1.anyIsEquivalent(to: equivalentItem1))
        XCTAssertEqual(callCount, 3)
        
        XCTAssertTrue(equivalentItem2.anyIsEquivalent(to: equivalentItem2))
        XCTAssertEqual(callCount, 4)
    }
    
    fileprivate func build<Content>(
        @ListableArrayBuilder<Content> using builder : () -> [Content]
    ) -> [Content]
    {
        builder()
    }
}


fileprivate struct TestContent : ItemContent, Equatable {
    
    var identifierValue: String {
        ""
    }
    
    static func createReusableContentView(frame: CGRect) -> UIView {
        UIView()
    }
    
    func apply(to views: ItemContentViews<Self>, for reason: ApplyReason, with info: ApplyItemContentInfo) {}
}


fileprivate struct EquatableContent : ItemContent, Equatable {

    var identifierValue: String {
        ""
    }
    
    var calledEqual : () -> ()
    
    static func == (lhs : Self, rhs : Self) -> Bool {
        lhs.calledEqual()
        return true
    }
    
    static func createReusableContentView(frame: CGRect) -> UIView {
        UIView()
    }
    
    func apply(to views: ItemContentViews<Self>, for reason: ApplyReason, with info: ApplyItemContentInfo) {}
}


fileprivate struct EquivalentContent : ItemContent, LayoutEquivalent {
    
    var identifierValue: String {
        ""
    }
    
    var calledIsEquivalent : () -> ()
    
    func isEquivalent(to other: EquivalentContent) -> Bool {
        calledIsEquivalent()
        return true
    }
    
    static func createReusableContentView(frame: CGRect) -> UIView {
        UIView()
    }
    
    func apply(to views: ItemContentViews<Self>, for reason: ApplyReason, with info: ApplyItemContentInfo) {}
}


fileprivate struct EquatableHeaderFooter : HeaderFooterContent, Equatable {
    
    var calledEqual : () -> ()
    
    static func == (lhs : Self, rhs : Self) -> Bool {
        lhs.calledEqual()
        return true
    }
    
    static func createReusableContentView(frame: CGRect) -> UIView {
        UIView()
    }
    
    func apply(to views: HeaderFooterContentViews<Self>, for reason: ApplyReason, with info: ApplyHeaderFooterContentInfo) {}
}


fileprivate struct EquivalentHeaderFooter : HeaderFooterContent, LayoutEquivalent {
    
    var calledIsEquivalent : () -> ()
    
    func isEquivalent(to other: EquivalentHeaderFooter) -> Bool {
        calledIsEquivalent()
        return true
    }
    
    static func createReusableContentView(frame: CGRect) -> UIView {
        UIView()
    }
    
    func apply(to views: HeaderFooterContentViews<Self>, for reason: ApplyReason, with info: ApplyHeaderFooterContentInfo) {}
}

