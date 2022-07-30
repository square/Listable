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
        
        // Check String behavior.
        
        XCTAssertEqual(
            .equal,
            areEquatablePropertiesEqual(
                "A String",
                "A String"
            )
        )
        
        XCTAssertEqual(
            .notEqual,
            areEquatablePropertiesEqual(
                "A String",
                "A String!"
            )
        )
        
        XCTAssertEqual(
            .equal,
            areEquatablePropertiesEqual(
                "A String" as Any,
                "A String" as Any
            )
        )
        
        XCTAssertEqual(
            .notEqual,
            areEquatablePropertiesEqual(
                "A String" as Any,
                "A String!" as Any
            )
        )
        
        // Check Int behavior.
        
        XCTAssertTrue(_isPOD(Int.self))
        
        XCTAssertEqual(
            .equal,
            areEquatablePropertiesEqual(
                10,
                10
            )
        )
        
        XCTAssertEqual(
            .notEqual,
            areEquatablePropertiesEqual(
                10,
                11
            )
        )
        
        XCTAssertEqual(
            .equal,
            areEquatablePropertiesEqual(
                10 as Any,
                10 as Any
            )
        )
        
        XCTAssertEqual(
            .notEqual,
            areEquatablePropertiesEqual(
                10 as Any,
                11 as Any
            )
        )
        
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
        
        // Check what happens with a non-Equatable enum, but it has associated types which may be Equatable.
        
        XCTAssertEqual(
            .error(.noEquatableProperties),
            areEquatablePropertiesEqual(
                NonEquatableEnumOnlyValue(enumValue: .one),
                NonEquatableEnumOnlyValue(enumValue: .one)
            )
        )
        
        XCTAssertEqual(
            .error(.noEquatableProperties),
            areEquatablePropertiesEqual(
                NonEquatableEnumOnlyValue(enumValue: .one),
                NonEquatableEnumOnlyValue(enumValue: .two)
            )
        )
        
        XCTAssertEqual(
            .equal,
            areEquatablePropertiesEqual(
                NonEquatableEnumOnlyValue(enumValue: .three("Hello")),
                NonEquatableEnumOnlyValue(enumValue: .three("Hello"))
            )
        )
        
        XCTAssertEqual(
            .notEqual,
            areEquatablePropertiesEqual(
                NonEquatableEnumOnlyValue(enumValue: .three("Hello")),
                NonEquatableEnumOnlyValue(enumValue: .three("Hello!!"))
            )
        )
        
        // !! Swift (?) bug: Swift cannot resolve these two strings as the same type.
        // Seems to be a bug in the `Mirror` type passthrough for enums with associated values, or something.
        // For now, it'll fail open; eg not finding any Equatable values, but that is wrong.
        
        XCTAssertEqual(
            .error(.noEquatableProperties),
            areEquatablePropertiesEqual(
                NonEquatableEnumOnlyValue(enumValue: .four(.init(value: "Some Value"))),
                NonEquatableEnumOnlyValue(enumValue: .four(.init(value: "Some Value")))
            )
        )
        
        XCTAssertEqual(
            .error(.noEquatableProperties), // Should be `.equal`.
            areEquatablePropertiesEqual(
                NonEquatableEnumOnlyValue(enumValue: .five("Some String")),
                NonEquatableEnumOnlyValue(enumValue: .five("Some String"))
            )
        )
        
        // END: Swift Bug
        
        XCTAssertEqual(
            .error(.noEquatableProperties), // Should be `.equal`.
            areEquatablePropertiesEqual(
                NonEquatableEnumOnlyValue(enumValue: .five(1)),
                NonEquatableEnumOnlyValue(enumValue: .five(1))
            )
        )
        
        XCTAssertEqual(
            .notEqual,
            areEquatablePropertiesEqual(
                NonEquatableEnumOnlyValue(enumValue: .five("Some String")),
                NonEquatableEnumOnlyValue(enumValue: .five(1))
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


fileprivate struct NonEquatableEnumOnlyValue {
    
    var enumValue : AnEnum
    
    enum AnEnum {
        case one
        case two
        case three(String)
        case four(NonEquatableValue)
        case five(Any)
    }
}
