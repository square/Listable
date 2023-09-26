//
//  XCTestCaseAdditions.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 11/22/19.
//

import XCTest


extension XCTestCase
{
    func determineAverage(for seconds : TimeInterval, using block : () -> ()) {
        let start = Date()
        
        var iterations : Int = 0
        
        repeat {
            let iterationStart = Date()
            block()
            let iterationEnd = Date()
            let duration = iterationEnd.timeIntervalSince(iterationStart)
            
            iterations += 1

            print("Iteration: \(iterations), Duration : \(duration)")
            
        } while Date() < start + seconds
        
        let end = Date()
        
        let duration = end.timeIntervalSince(start)
        let average = duration / TimeInterval(iterations)
        
        print("Iterations: \(iterations), Average Time: \(average)")
    }
    
    func testcase(_ name : String = "", _ block : () -> ())
    {
        block()
    }
}
