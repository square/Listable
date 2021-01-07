//
//  ArrayTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 11/22/19.
//

import XCTest

@testable import ListableUI


class ArrayTests: XCTestCase
{
    func test_forEachWithIndex()
    {
        let array = ["first", "second", "third"]
        
        var iterations = [Iteration]()
        
        array.forEachWithIndex { index, isLast, value in
            iterations.append(Iteration(index: index, isLast: isLast, value: value))
        }
        
        XCTAssertEqual(iterations, [
            Iteration(index: 0, isLast: false, value: "first"),
            Iteration(index: 1, isLast: false, value: "second"),
            Iteration(index: 2, isLast: true, value: "third"),
            ])
        
        struct Iteration : Equatable
        {
            var index : Int
            var isLast : Bool
            var value : String
        }
    }
    
    func test_mapWithIndex()
    {
        let array = [1, 2, 3]
        
        var iterations = [Iteration]()
        
        let mapped : [String] = array.mapWithIndex { index, isLast, value in
            iterations.append(Iteration(index: index, isLast: isLast, value: value))
            
            return String(value)
        }
        
        XCTAssertEqual(mapped, [
            "1",
            "2",
            "3"
            ])
        
        XCTAssertEqual(iterations, [
            Iteration(index: 0, isLast: false, value: 1),
            Iteration(index: 1, isLast: false, value: 2),
            Iteration(index: 2, isLast: true, value: 3),
            ])
        
        struct Iteration : Equatable
        {
            var index : Int
            var isLast : Bool
            var value : Int
        }
    }

    func test_compactMapWithIndex()
    {
        let array = [1, nil, 3, 4]
        
        var iterations = [Iteration]()
        
        let mapped : [String] = array.compactMapWithIndex { index, isLast, value in
            iterations.append(Iteration(index: index, isLast: isLast, value: value))
            
            if let value = value {
                return String(value)
            } else {
                return nil
            }
        }
        
        XCTAssertEqual(mapped, [
            "1",
            "3",
            "4"
            ])
        
        XCTAssertEqual(iterations, [
            Iteration(index: 0, isLast: false, value: 1),
            Iteration(index: 1, isLast: false, value: nil),
            Iteration(index: 2, isLast: false, value: 3),
            Iteration(index: 3, isLast: true, value: 4)
            ])
        
        struct Iteration : Equatable
        {
            var index : Int
            var isLast : Bool
            var value : Int?
        }
    }
}
