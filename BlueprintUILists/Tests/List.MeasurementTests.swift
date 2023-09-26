//
//  List.MeasurementTests.swift
//  BlueprintUILists-Unit-Tests
//
//  Created by Kyle Van Essen on 11/29/21.
//

@testable import BlueprintUILists
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
    
    func test_vertical_measurement() {
    
    }
}
