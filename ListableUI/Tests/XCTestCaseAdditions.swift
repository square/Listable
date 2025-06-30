//
//  XCTestCaseAdditions.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 11/22/19.
//

import XCTest


extension XCTestCase
{
    ///
    /// Call this method to show a view controller in the test host application
    /// during a unit test. The view controller will be the size of host application's device.
    ///
    /// After the test runs, the view controller will be removed from the view hierarchy.
    ///
    /// A test failure will occur if the host application does not exist, or does not have a root view controller.
    ///
    public func show<ViewController: UIViewController>(
        vc viewController: ViewController,
        loadAndPlaceView: Bool = true,
        test: (ViewController) throws -> Void
    ) rethrows {

        guard let rootVC = UIApplication.shared.delegate?.window??.rootViewController else {
            XCTFail("Cannot present a view controller in a test host that does not have a root window.")
            return
        }

        rootVC.addChild(viewController)
        viewController.didMove(toParent: rootVC)

        if loadAndPlaceView {
            viewController.view.frame = rootVC.view.bounds
            viewController.view.layoutIfNeeded()

            rootVC.beginAppearanceTransition(true, animated: false)
            rootVC.view.addSubview(viewController.view)
            rootVC.endAppearanceTransition()
        }

        defer {
            if loadAndPlaceView {
                viewController.beginAppearanceTransition(false, animated: false)
                viewController.view.removeFromSuperview()
                viewController.endAppearanceTransition()
            }

            viewController.willMove(toParent: nil)
            viewController.removeFromParent()
        }

        try autoreleasepool {
            try test(viewController)
        }
    }
    
    func testcase(_ name : String = "", _ block : () throws -> ()) rethrows
    {
        try block()
    }
    
    func assertThrowsError(test : () throws -> (), verify : (Error) -> ())
    {
        var thrown = false
        
        do {
            try test()
        } catch {
            thrown = true
            verify(error)
        }
        
        XCTAssertTrue(thrown, "Expected an error to be thrown but one was not.")
    }
    
    func waitFor(timeout : TimeInterval = 10.0, predicate : () -> Bool)
    {
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
    
    func waitFor(timeout : TimeInterval = 10.0, block : (() -> ()) -> ())
    {
        var isDone : Bool = false
        
        self.waitFor(timeout: timeout, predicate: {
            block({ isDone = true })
            return isDone
        })
    }
    
    func waitFor(duration : TimeInterval)
    {
        let end = Date(timeIntervalSinceNow: abs(duration))

        self.waitFor(predicate: {
            Date() >= end
        })
    }
    
    func waitForOneRunloop()
    {
        let runloop = RunLoop.main
        runloop.run(mode: .default, before: Date(timeIntervalSinceNow: 0.001))
    }
    
    func determineAverage(for seconds : TimeInterval, using block : () -> ()) {
        let start = Date()

        var iterations : Int = 0
        
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
    var recursiveDescription : String {
        self.value(forKey: "recursiveDescription") as! String
    }
}
