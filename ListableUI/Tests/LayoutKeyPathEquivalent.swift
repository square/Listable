//
//  LayoutKeyPathEquivalentTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 5/24/23.
//

import ListableUI
import XCTest

class LayoutKeyPathEquivalentTests : XCTestCase {
    
    func test_isEquivalent() {
        
        struct TestingThing : LayoutKeyPathEquivalent {
            
            var name : String
            var age : Int
            var birthdate : Date
            var nonCompared : Bool
            
            static var isEquivalentKeyPaths: KeyPaths {
                \.name
                \.age
                \.birthdate
            }
        }
        
        let value1 = TestingThing(
            name: "1",
            age: 0,
            birthdate: Date(),
            nonCompared: false
        )
        
        let equivalentToValue1 = TestingThing(
            name: "1",
            age: 0,
            birthdate: Date(),
            nonCompared: true
        )
        
        let notEquivalentToValue1 = TestingThing(
            name: "2",
            age: 0,
            birthdate: Date(),
            nonCompared: false
        )
        
        XCTAssertTrue(value1.isEquivalent(to: equivalentToValue1))
        XCTAssertFalse(value1.isEquivalent(to: notEquivalentToValue1))
    }
}
