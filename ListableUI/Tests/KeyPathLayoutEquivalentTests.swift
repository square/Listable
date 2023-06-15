//
//  KeyPathLayoutEquivalentTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 5/24/23.
//

import ListableUI
import XCTest

class KeyPathLayoutEquivalentTests : XCTestCase {
    
    func test_isEquivalent() {
        
struct TestingThing : KeyPathLayoutEquivalent {
    
    var name : String
    var age : Int
    var birthdate : Date
    var nonCompared : Bool
    
    static var isEquivalent: KeyPaths {
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
        
        /// Our implementation caches the result of `isEquivalent`,
        /// ensure calling the above again does not crash when retrieving values from the cache.
        
        XCTAssertTrue(value1.isEquivalent(to: equivalentToValue1))
        XCTAssertFalse(value1.isEquivalent(to: notEquivalentToValue1))
    }
}
