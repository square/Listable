//
//  ListableBuilderAndSectionOverloadTests.swift
//  BlueprintUILists
//
//  Created by Kyle Van Essen on 7/24/22.
//

import BlueprintUILists
import XCTest


class ListableBuilderAndSectionOverloadTests : XCTestCase {
    
    func test_build() {
        
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
