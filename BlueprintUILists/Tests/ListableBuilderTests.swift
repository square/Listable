//
//  ListableBuilderTests.swift
//  BlueprintUILists
//
//  Created by Kyle Van Essen on 7/24/22.
//

import BlueprintUILists
import XCTest


class ListableBuilderTests : XCTestCase {
    
    func test_builders() {
        
        // Make sure the various result builder methods
        // are present such that various control flow statements still compile.
        
        let aBool = Bool("true")!
        
        _ = Section("1") {
            
            if aBool {
                TestContent1()
            } else {
                Element1()
            }
            
            if aBool {
                Element1()
            } else {
                Element2()
            }
            
            if #available(iOS 11.0, *) {
                Element1()
            } else {
                Element2()
            }
        }
        
        // Make sure building happens how we would expect.
        
        let list = List {
            Section("1") {
                TestContent1()
                TestContent1()
                TestContent2()
                
                Element1()
                Element2()
            } header: {
                Element1()
            } footer: {
                Element2().headerFooter()
            }
            
            Section("2") { section in
                section += TestContent1()
                section += TestContent2()
                
                section += Element1()
                section += Element2()
            }
            
            Section("3") { section in
                section.add {
                    TestContent1()

                    Element1()
                    Element2()
                }
            }
        }
        
        XCTAssertEqual(list.properties.content.sections.count, 3)
        
        XCTAssertEqual(list.properties.content.sections[0].count, 5)
        XCTAssertEqual(list.properties.content.sections[1].count, 4)
        XCTAssertEqual(list.properties.content.sections[2].count, 3)
    }
    
    // TODO: Test header/footers too
    
    func test_default_implementation_resolution() {
        
        var callCount : Int = 0
        
        let section = Section("1") {
            EquatableElement { callCount += 1 }
            EquatableElement { callCount += 1 }.item()
            EquivalentElement { callCount += 1 }
            EquivalentElement { callCount += 1 }.item()
        }
        
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


fileprivate struct Element1 : ProxyElement {
    
    var elementRepresentation: Element {
        Empty()
    }
}


fileprivate struct Element2 : ProxyElement {
    
    var elementRepresentation: Element {
        Empty()
    }
}


fileprivate struct EquatableElement : ProxyElement, Equatable {
    
    var calledEqual : () -> ()
    
    var elementRepresentation: Element {
        Empty()
    }
    
    static func == (lhs : Self, rhs : Self) -> Bool {
        lhs.calledEqual()
        return true
    }
}


fileprivate struct EquivalentElement : ProxyElement, IsEquivalentContent {
    
    var calledIsEquivalent : () -> ()
    
    var elementRepresentation: Element {
        Empty()
    }
    
    func isEquivalent(to other: EquivalentElement) -> Bool {
        calledIsEquivalent()
        return true
    }
}


fileprivate struct TestContent1 : BlueprintItemContent, Equatable {
    
    var identifierValue: String {
        "1"
    }
    
    func element(with info: ApplyItemContentInfo) -> Element {
        Empty()
    }
}


fileprivate struct TestContent2 : BlueprintItemContent, Equatable {
    
    var identifierValue: String {
        "1"
    }
    
    func element(with info: ApplyItemContentInfo) -> Element {
        Empty()
    }
}
