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
