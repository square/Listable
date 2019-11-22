//
//  PerformanceCurveTest.swift
//  Listable-Unit-Tests
//
//  Created by Kyle Van Essen on 11/24/19.
//

import XCTest
import Foundation

@testable import Listable


final class PerformanceCurveTest<Data>
{
    private(set) var state : State
    
    let cases : [TestCase]
    
    typealias ExpectedCurve = (Int) -> TimeInterval
    let expectedCurve : ExpectedCurve
    
    let caseRunCount : Int
    
    typealias Test = (Data) -> ()
    let test : Test
        
    init(cases : [TestCase], expectedCurve : @escaping ExpectedCurve, caseRunCount : Int = 5, test : @escaping Test)
    {
        precondition(PerformanceCurveTest.validateCaseOrdering(with: cases), "Cases must be in ascending order.")
        precondition(cases.count >= 3, "To test performance, must need at least three cases to compare (one base, 2 additional).")
        precondition(caseRunCount >= 3, "Must run each case at least 3 times.")
        
        self.state = .new
        
        self.cases = cases
        
        self.expectedCurve = expectedCurve
        self.caseRunCount = caseRunCount
        self.test = test
    }
    
    private static func validateCaseOrdering(with cases : [TestCase]) -> Bool
    {
        let counts : [Int] = cases.map { $0.count }
        let sorted = counts.sorted { $0 < $1 }
        
        return counts == sorted
    }
        
    func run()
    {
        guard self.state == .new else {
            fatalError("Cannot re-run a performance test. Please allocate a new test instead.")
        }
        
        self.state = .running
        
        let results : [TestCase.Executed] = self.cases.mapWithIndex { index, _, testCase in
            
            print("Starting Test Case #\(index). Count: \(testCase.count)...")
            
            let durations : [TimeInterval] = self.caseRunCount.mapEach { index in
                
                print("   > Starting Iteration #\(index + 1)...")
                
                let start = Date()
                
                autoreleasepool {
                    self.test(testCase.data)
                }
                
                let end = Date()
                let duration = end.timeIntervalSinceReferenceDate - start.timeIntervalSinceReferenceDate
                
                print("   > Finished Iteration #\(index + 1) in \(duration).")
                
                return duration
            }
            
            print("Finished Test Case #\(index).")
            
            return TestCase.Executed(
                testCase: testCase,
                duration: durations.averageTimeDiscardingOutliers()
            )
        }
        
        let first = results[0]
        let scaling = 1.0 / first.duration
        
        let scaled : [TestCase.Scaled] = results.map {
            let scaled = $0.duration * scaling
            
            return TestCase.Scaled(
                testCase: $0.testCase,
                originalDuration: $0.duration,
                scaledDuration: scaled,
                durationPerCount: scaled / TimeInterval($0.testCase.count),
                countMultiplier: Double($0.testCase.count) / Double(first.testCase.count)
            )
        }
        
        self.state = .done
    }
    
    func printResults(with results : [TestCase.Scaled])
    {
        
    }
    
    enum State
    {
        case new
        case running
        case done
    }
    
    struct TestCase
    {
        var count : Int
        var data : Data
        
        struct Executed
        {
            let testCase : TestCase
            let duration : TimeInterval
        }
        
        struct Scaled
        {
            let testCase : TestCase
            
            let originalDuration : TimeInterval
            let scaledDuration : TimeInterval
            let durationPerCount : TimeInterval
            let countMultiplier : Double
        }
    }
}

fileprivate extension Array where Element == TimeInterval
{
    func averageTimeDiscardingOutliers() -> TimeInterval
    {
        precondition(self.count > 2, "Must have at least 3 values.")
        
        let sorted = self.sorted { $1 > $0 }
        
        let trimmed = Array(sorted[1...(sorted.count - 2)])
        
        let sum : TimeInterval = trimmed.reduce(0.0, { $0 + $1 })
        return sum / TimeInterval(trimmed.count)
    }
}

fileprivate extension Int
{
    func mapEach<Mapped>(_ block : (Int) -> Mapped) -> [Mapped]
    {
        var mapped = [Mapped]()
        
        for index in 0..<self {
            mapped.append(block(index))
        }
        
        return mapped
    }
}
