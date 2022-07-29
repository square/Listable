//
//  ComparePropertiesTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 7/28/22.
//

@_spi(ListableInternal) import ListableUI
import XCTest


class ComparePropertiesTests : XCTestCase {
    
    func test_compare() {
        
        // Check values which aren't Equatable but have Equatable properties.
        
        XCTAssertEqual(
            .equal,
            areEquatablePropertiesEqual(
                TestValue(
                    title: "A Title",
                    detail: "Some Detail",
                    count: 10,
                    enumValue: .foo,
                    closure: {}
                ),
                TestValue(
                    title: "A Title",
                    detail: "Some Detail",
                    count: 10,
                    enumValue: .foo,
                    closure: {}
                )
            )
        )
        
        XCTAssertEqual(
            .notEqual,
            areEquatablePropertiesEqual(
                TestValue(
                    title: "A Different Title",
                    detail: "Some Detail",
                    count: 10,
                    enumValue: .foo,
                    closure: {}
                ),
                TestValue(
                    title: "A Title",
                    detail: "Some Detail",
                    count: 10,
                    enumValue: .foo,
                    closure: {}
                )
            )
        )
        
        XCTAssertEqual(
            .notEqual,
            areEquatablePropertiesEqual(
                TestValue(
                    title: "A Title",
                    detail: "Some Detail",
                    count: 10,
                    enumValue: .foo,
                    closure: {}
                ),
                TestValue(
                    title: "A Title",
                    detail: "Some Detail",
                    count: 10,
                    enumValue: .bar("A String"),
                    closure: {}
                )
            )
        )
        
        // Ensure we message that there were no Equatable properties to compare.
        
        XCTAssertEqual(
            .error(.noEquatableProperties),
            areEquatablePropertiesEqual(
                TestValueWithNoEquatableProperties(),
                TestValueWithNoEquatableProperties()
            )
        )
        
        // Check that we properly handle values which themselves are Equatable.
        
        XCTAssertEqual(
            .equal,
            areEquatablePropertiesEqual(
                EquatableValue(
                    title: "A Title",
                    detail: "Some Detail",
                    count: 10
                ),
                EquatableValue(
                    title: "A Title",
                    detail: "Some Detail",
                    count: 10
                )
            )
        )
        
        XCTAssertEqual(
            .notEqual,
            areEquatablePropertiesEqual(
                EquatableValue(
                    title: "A Title",
                    detail: "Some Detail",
                    count: 10
                ),
                EquatableValue(
                    title: "Another Title",
                    detail: "Some Detail",
                    count: 10
                )
            )
        )
    }
    
    func test_performance() {
        determineAverage(for: 1.0) {
            _ = areEquatablePropertiesEqual(
                TestValue(
                    title: "A Title",
                    count: 10,
                    enumValue: .foo,
                    closure: {}
                ),
                TestValue(
                    title: "A Title",
                    count: 10,
                    enumValue: .foo,
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
    
    var enumValue : EnumValue
    
    var nonEquatable: NonEquatableValue = .init(value: "An inner string")
    
    var closure : () -> ()
    
    enum EnumValue : Equatable {
        case foo
        case bar(String)
    }
}


fileprivate struct EquatableValue : Equatable {
    
    var title : String
    var detail : String?
    var count : Int
}


fileprivate struct NonEquatableValue {
    
    var value : Any
}


fileprivate struct TestValueWithNoEquatableProperties {
    
    var closure1 : () -> () = {}
    var closure2 : () -> () = {}
    
}
