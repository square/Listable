//
//  ColorTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 1/6/21.
//

import XCTest
import UIKit
import ListableUI


class ColorTests : XCTestCase {
    
    func test_equatable() {
        
        self.testcase("Regular colors") {
            
            XCTAssertEqual(Color(.black), Color(.black))
            XCTAssertNotEqual(Color(.black), Color(.blue))
        }
        
        self.testcase("Dynamic colors") {
            
            XCTAssertEqual(
                Color(.init(dynamicProvider: { _ in .black })),
                Color(.init(dynamicProvider: { _ in .black }))
            )
            
            XCTAssertNotEqual(
                Color(.init(dynamicProvider: { _ in .black })),
                Color(.init(dynamicProvider: { _ in .blue }))
            )
        }
    }
}
