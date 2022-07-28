//
//  CompareEquatablePropertiesTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 7/28/22.
//

@_spi(ListableInternal) import ListableUI
import XCTest


class CompareEquatablePropertiesTests : XCTestCase {
    
    func test_compare() {
        
        XCTAssertTrue(
            isEqualComparingEquatableProperties(
                TestValue(
                    title: "A Title",
                    detail: "Some Detail",
                    count: 10,
                    closure: {}
                ),
                TestValue(
                    title: "A Title",
                    detail: "Some Detail",
                    count: 10,
                    closure: {}
                )
            )
        )
        
        XCTAssertFalse(
            isEqualComparingEquatableProperties(
                TestValue(
                    title: "A Different Title",
                    detail: "Some Detail",
                    count: 10,
                    closure: {}
                ),
                TestValue(
                    title: "A Title",
                    detail: "Some Detail",
                    count: 10,
                    closure: {}
                )
            )
        )
        
        XCTAssertTrue(
            isEqualComparingEquatableProperties(
                TestValueWithNoEquatableProperties(),
                TestValueWithNoEquatableProperties()
            )
        )
    }
    
    func test_performance() {
        determineAverage(for: 1.0) {
            _ = isEqualComparingEquatableProperties(
                TestValue(
                    title: "A Title",
                    count: 10,
                    closure: {}
                ),
                TestValue(
                    title: "A Title",
                    count: 10,
                    closure: {}
                )
            )
        }
    }
}


fileprivate struct TestValue {
    
    var title : String
    var detail : String?
    var count : Int
    
    var nonEquatable: NonEquatableValue = .init(value: "An inner string")
    
    var closure : () -> ()
}


fileprivate struct NonEquatableValue {
    
    var value : Any
}


fileprivate struct TestValueWithNoEquatableProperties {
    
    var closure1 : () -> () = {}
    var closure2 : () -> () = {}
    
}
