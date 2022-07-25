//
//  XCTestCaseAdditions.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 11/22/19.
//

import XCTest

extension XCTestCase {
    func testcase(_: String = "", _ block: () -> Void) {
        block()
    }

    func assertThrowsError(test: () throws -> Void, verify: (Error) -> Void) {
        var thrown = false

        do {
            try test()
        } catch {
            thrown = true
            verify(error)
        }

        XCTAssertTrue(thrown, "Expected an error to be thrown but one was not.")
    }

    func waitFor(timeout: TimeInterval = 10.0, predicate: () -> Bool) {
        let runloop = RunLoop.main
        let timeout = Date(timeIntervalSinceNow: timeout)

        while Date() < timeout {
            if predicate() {
                return
            }

            runloop.run(mode: .default, before: Date(timeIntervalSinceNow: 0.001))
        }

        XCTFail("waitUntil timed out waiting for a check to pass.")
    }

    func waitFor(timeout: TimeInterval = 10.0, block: (() -> Void) -> Void) {
        var isDone = false

        waitFor(timeout: timeout, predicate: {
            block { isDone = true }
            return isDone
        })
    }

    func waitFor(duration: TimeInterval) {
        let end = Date(timeIntervalSinceNow: abs(duration))

        waitFor(predicate: {
            Date() >= end
        })
    }

    func waitForOneRunloop() {
        let runloop = RunLoop.main
        runloop.run(mode: .default, before: Date(timeIntervalSinceNow: 0.001))
    }

    func determineAverage(for seconds: TimeInterval, using block: () -> Void) {
        let start = Date()

        var iterations = 0

        var lastUpdateDate = Date()

        repeat {
            block()

            iterations += 1

            if Date().timeIntervalSince(lastUpdateDate) >= 1 {
                lastUpdateDate = Date()
                print("Continuing Test: \(iterations) Iterations...")
            }

        } while Date() < start + seconds

        let end = Date()

        let duration = end.timeIntervalSince(start)
        let average = duration / TimeInterval(iterations)

        print("Iterations: \(iterations), Average Time: \(average)")
    }
}

extension UIView {
    var recursiveDescription: String {
        value(forKey: "recursiveDescription") as! String
    }
}
