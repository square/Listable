//
//  ComparePropertiesTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 7/28/22.
//

@_spi(ListableInternal) import ListableUI
import XCTest


class ComparePropertiesTests : XCTestCase {
    
    func test_compare_string() {
        
        XCTAssertEqual(
            .equal,
            compareEquatableProperties(
                "A String",
                "A String"
            )
        )
        
        XCTAssertEqual(
            .notEqual,
            compareEquatableProperties(
                "A String",
                "A String!"
            )
        )
        
        XCTAssertEqual(
            .equal,
            compareEquatableProperties(
                "A String" as Any,
                "A String" as Any
            )
        )
        
        XCTAssertEqual(
            .notEqual,
            compareEquatableProperties(
                "A String" as Any,
                "A String!" as Any
            )
        )
    }
        
    func test_compare_int() {
        
        XCTAssertTrue(_isPOD(Int.self))
        
        XCTAssertEqual(
            .equal,
            compareEquatableProperties(
                10,
                10
            )
        )
        
        XCTAssertEqual(
            .notEqual,
            compareEquatableProperties(
                10,
                11
            )
        )
        
        XCTAssertEqual(
            .equal,
            compareEquatableProperties(
                10 as Any,
                10 as Any
            )
        )
        
        XCTAssertEqual(
            .notEqual,
            compareEquatableProperties(
                10 as Any,
                11 as Any
            )
        )
        
    }
    
    func test_empty() {
        
        XCTAssertEqual(
            .hasNoFields,
            compareEquatableProperties(
                EmptyValue(),
                EmptyValue()
            )
        )
        
    }
    
    func test_compare_non_equatable_values() {
        
        XCTAssertEqual(
            .equal,
            compareEquatableProperties(
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
            compareEquatableProperties(
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
            compareEquatableProperties(
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
            compareEquatableProperties(
                TestValueWithNoEquatableProperties(),
                TestValueWithNoEquatableProperties()
            )
        )
        
        // Check what happens with a non-Equatable enum, but it has associated types which may be Equatable.
        
        XCTAssertEqual(
            .error(.noEquatableProperties),
            compareEquatableProperties(
                NonEquatableEnumOnlyValue(enumValue: .one),
                NonEquatableEnumOnlyValue(enumValue: .one)
            )
        )
        
        XCTAssertEqual(
            .error(.noEquatableProperties),
            compareEquatableProperties(
                NonEquatableEnumOnlyValue(enumValue: .one),
                NonEquatableEnumOnlyValue(enumValue: .two)
            )
        )
        
        XCTAssertEqual(
            .equal,
            compareEquatableProperties(
                NonEquatableEnumOnlyValue(enumValue: .three("Hello")),
                NonEquatableEnumOnlyValue(enumValue: .three("Hello"))
            )
        )
        
        XCTAssertEqual(
            .notEqual,
            compareEquatableProperties(
                NonEquatableEnumOnlyValue(enumValue: .three("Hello")),
                NonEquatableEnumOnlyValue(enumValue: .three("Hello!!"))
            )
        )
        
        // ⚠️ Swift 5.6 and earlier bug: Swift cannot resolve these two strings as an `Equatable` type.
        // This seems to be a bug in how `Any` instances can get cast back to a strict type
        // through `_openExistential`. This is resolved in Swift 5.7 / Xcode 14.
        //
        // Once we support Xcode 14 and later only, we can remove the `#else` branches here and in `ComparableProperties.swift`.
        
#if swift(>=5.7)
        XCTAssertEqual(
            .equal,
            compareEquatableProperties(
                NonEquatableEnumOnlyValue(enumValue: .four(.init(value: "Some Value"))),
                NonEquatableEnumOnlyValue(enumValue: .four(.init(value: "Some Value")))
            )
        )
#else
        XCTAssertEqual(
            .error(.noEquatableProperties),
            compareEquatableProperties(
                NonEquatableEnumOnlyValue(enumValue: .four(.init(value: "Some Value"))),
                NonEquatableEnumOnlyValue(enumValue: .four(.init(value: "Some Value")))
            )
        )
#endif
        
#if swift(>=5.7)
        XCTAssertEqual(
            .equal,
            compareEquatableProperties(
                NonEquatableEnumOnlyValue(enumValue: .five("Some String")),
                NonEquatableEnumOnlyValue(enumValue: .five("Some String"))
            )
        )
#else
        XCTAssertEqual(
            .error(.noEquatableProperties),
            compareEquatableProperties(
                NonEquatableEnumOnlyValue(enumValue: .five("Some String")),
                NonEquatableEnumOnlyValue(enumValue: .five("Some String"))
            )
        )
#endif
        
#if swift(>=5.7)
        XCTAssertEqual(
            .equal,
            compareEquatableProperties(
                NonEquatableEnumOnlyValue(enumValue: .five(1)),
                NonEquatableEnumOnlyValue(enumValue: .five(1))
            )
        )
#else
        XCTAssertEqual(
            .error(.noEquatableProperties),
            compareEquatableProperties(
                NonEquatableEnumOnlyValue(enumValue: .five(1)),
                NonEquatableEnumOnlyValue(enumValue: .five(1))
            )
        )
#endif
        
        XCTAssertEqual(
            .notEqual,
            compareEquatableProperties(
                NonEquatableEnumOnlyValue(enumValue: .five("Some String")),
                NonEquatableEnumOnlyValue(enumValue: .five(1))
            )
        )
        
    }
    
    func test_compare_equatable_values() {
        
        XCTAssertEqual(
            .equal,
            compareEquatableProperties(
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
            compareEquatableProperties(
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
    
    func test_array() {
        
        XCTAssertEqual(
            .equal,
            compareEquatableProperties(
                [],
                []
            )
        )
        
        XCTAssertEqual(
            .equal,
            compareEquatableProperties(
                ["A", "B"],
                ["A", "B"]
            )
        )
        
        XCTAssertEqual(
            .equal,
            compareEquatableProperties(
                ["A", "B"],
                ["A", "B"]
            )
        )
        
        XCTAssertEqual(
            .notEqual,
            compareEquatableProperties(
                ["A", "B"],
                ["A", "B", "C"]
            )
        )
        
        XCTAssertEqual(
            .notEqual,
            compareEquatableProperties(
                ["A", "2"],
                ["A", 2]
            )
        )
    }
    
    func test_set() {
        
        XCTAssertEqual(
            .equal,
            compareEquatableProperties(
                Set<AnyHashable>(),
                Set<AnyHashable>()
            )
        )
        
        XCTAssertEqual(
            .equal,
            compareEquatableProperties(
                Set(["A", "B"]),
                Set(["A", "B"])
            )
        )
        
        XCTAssertEqual(
            .equal,
            compareEquatableProperties(
                Set(["A", "B"]),
                Set(["B", "A"])
            )
        )
        
        XCTAssertEqual(
            .notEqual,
            compareEquatableProperties(
                Set(["A", "B"]),
                Set(["A", "B", "C"])
            )
        )
        
        XCTAssertEqual(
            .notEqual,
            compareEquatableProperties(
                Set<AnyHashable>(["A", "2"]),
                Set<AnyHashable>(["A", 2])
            )
        )
    }
    
    func test_dictionary() {
        
        XCTAssertEqual(
            .equal,
            compareEquatableProperties(
                Dictionary<String, Any>(),
                Dictionary<String, Any>()
            )
        )
        
        XCTAssertEqual(
            .equal,
            compareEquatableProperties(
                ["Key1": 1, "Key2" : 2] as Dictionary<String, AnyHashable>,
                ["Key1": 1, "Key2" : 2] as Dictionary<String, AnyHashable>
            )
        )
        
        XCTAssertEqual(
            .notEqual,
            compareEquatableProperties(
                ["Key1": 1, "Key2" : 3] as Dictionary<String, AnyHashable>,
                ["Key1": 1, "Key3" : 2] as Dictionary<String, AnyHashable>
            )
        )
        
        XCTAssertEqual(
            .notEqual,
            compareEquatableProperties(
                ["Key1": 1, "Key2" : 2] as Dictionary<String, AnyHashable>,
                ["Key1": 1, "Key3" : 2] as Dictionary<String, AnyHashable>
            )
        )
        
        // ⚠️ Swift 5.6 and earlier bug: Swift cannot resolve these two strings as an `Equatable` type.
        // This seems to be a bug in how `Any` instances can get cast back to a strict type
        // through `_openExistential`. This is resolved in Swift 5.7 / Xcode 14.
        //
        // Once we support Xcode 14 and later only, we can remove the `#else` branches here and in `ComparableProperties.swift`.
        
#if swift(>=5.7)
        XCTAssertEqual(
            .equal,
            compareEquatableProperties(
                ["Key1": 1, "Key2" : 2] as Dictionary<String, Any>,
                ["Key1": 1, "Key2" : 2] as Dictionary<String, Any>
            )
        )
#else
        XCTAssertEqual(
            .notEqual,
            compareEquatableProperties(
                ["Key1": 1, "Key2" : 2] as Dictionary<String, Any>,
                ["Key1": 1, "Key2" : 2] as Dictionary<String, Any>
            )
        )
#endif
    }
    
    func test_performance() {
        
        print("Compare based on properties...")
        
        determineAverage(for: 0.5) {
            _ = compareEquatableProperties(
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
        
        print("Compare based on synthesized Equatable implementation...")
        
        determineAverage(for: 0.5) {
            _ = compareEquatableProperties(
                TestValue.ButEquatable(
                    title: "A Title",
                    count: 10,
                    enumValue: .foo
                ),
                TestValue.ButEquatable(
                    title: "A Title",
                    count: 10,
                    enumValue: .foo
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
    
    /// Mirrors the structure of the parent type but with a synthesized `Equatable`
    /// implementation to compare performance.
    
    fileprivate struct ButEquatable : Equatable {
        
        var title : String
        var detail : String?
        var count : Int
        
        var enumValue : EnumValue
        
        var nonEquatable: EquatableValue = .init(value: "An inner string")
        
        enum EnumValue : Equatable {
            case foo
            case bar(String)
        }
        
        fileprivate struct EquatableValue : Equatable {
            
            var value : AnyHashable
        }
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


fileprivate struct EmptyValue {}


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
