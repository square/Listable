//
//  List.MeasurementTests.swift
//  BlueprintUILists-Unit-Tests
//
//  Created by Kyle Van Essen on 11/29/21.
//

@testable import BlueprintUILists
import BlueprintUI
import XCTest

class List_MeasurementTests : XCTestCase {
    
    func test_measureContent_defaults() {
        
        let defaults = List.Measurement.measureContent()
        
        if case let .measureContent(horizontal, vertical, safeArea, itemLimit) = defaults {
            XCTAssertEqual(horizontal, .fillParent)
            XCTAssertEqual(vertical, .natural)
            XCTAssertEqual(safeArea, .none)
            XCTAssertEqual(itemLimit, 50)
        } else {
            XCTFail()
        }
    }
    
    func test_natural() {
    
        func testList(
            with measurement: List.Measurement,
            direction: LayoutDirection
        ) -> some Element {
            List(
                measurement: measurement,
                configure: {
                    $0.layout = .table {
                        $0.direction = direction
                    }
                },
                sections: {
                    Section("1") {
                        TestingItem(identifierValue: "1")
                        TestingItem(identifierValue: "2")
                        TestingItem(identifierValue: "3")
                        TestingItem(identifierValue: "4")
                        TestingItem(identifierValue: "5")
                    }
                }
            )
        }
        
        testcase("Horizontal Layouts") {
            
            let constraint = SizeConstraint(.init(width: 200, height: 200))
            
            XCTAssertEqual(
                CGSize(width: 0, height: 0),
                testList(
                    with: .measureContent(horizontalFill: .natural, verticalFill: .natural),
                    direction: .vertical
                )
                .measure(in: constraint)
            )
            
        }
        
        testcase("Vertical Layouts") {
            
        }

    }
    
    private struct TestingItem : BlueprintItemContent, Equatable {
        
        var identifierValue: AnyHashable
        
        func element(with info: ApplyItemContentInfo) -> Element {
            Empty()
                .constrainedTo(size: .init(width: 100, height: 50))
        }
    }
}


fileprivate extension Element {
    func measure(in constraint : SizeConstraint, environment : Environment = .empty) -> CGSize {
        self
            .content
            .measure(in: constraint, environment: environment)
    }
}
