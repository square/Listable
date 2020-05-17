//
//  PositioningTransformationTests.swift
//  Listable-Unit-Tests
//
//  Created by Kyle Van Essen on 5/17/20.
//

import XCTest
@testable import Listable

class PositioningTransformation_ClosedRange_Tests : XCTestCase
{
    func test_containedValue()
    {
        let valueProvider : (CGFloat) -> CGFloat = { distance in
            (0.5...1.0).containedValue(for: distance, in: 0...100)
        }
        
        XCTAssertEqual(0.5, valueProvider(-10.0))
        XCTAssertEqual(0.5, valueProvider(0.0))
        
        XCTAssertEqual(0.625, valueProvider(25.0))
        XCTAssertEqual(0.75, valueProvider(50.0))
        XCTAssertEqual(0.875, valueProvider(75.0))
        
        XCTAssertEqual(1.0, valueProvider(100.0))
        XCTAssertEqual(1.0, valueProvider(100.0))
    }
}
