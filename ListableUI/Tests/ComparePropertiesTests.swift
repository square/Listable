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
        
        XCTAssertEqual(
            .error(.noEquatableProperties),
            areEquatablePropertiesEqual(
                TestValueWithNoEquatableProperties(),
                TestValueWithNoEquatableProperties()
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


fileprivate struct NonEquatableValue {
    
    var value : Any
}


fileprivate struct TestValueWithNoEquatableProperties {
    
    var closure1 : () -> () = {}
    var closure2 : () -> () = {}
    
}
