//
//  XCTestCase.swift
//  ListableUITesting
//
//  Created by Kyle Van Essen on 12/30/21.
//

import XCTest


extension XCTestCase
{
    public func testcase(_ name : String = "", _ block : () -> ())
    {
        block()
    }
    
    public func assertThrowsError(test : () throws -> (), verify : (Error) -> ())
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
    
    public func waitFor(timeout : TimeInterval = 10.0, predicate : () -> Bool)
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
    
    public func waitFor(timeout : TimeInterval = 10.0, block : (() -> ()) -> ())
    {
        var isDone : Bool = false
        
        self.waitFor(timeout: timeout, predicate: {
            block({ isDone = true })
            return isDone
        })
    }
    
    public func waitFor(duration : TimeInterval)
    {
        let end = Date(timeIntervalSinceNow: abs(duration))
        
        self.waitFor(predicate: {
            Date() >= end
        })
    }
    
    public func waitForOneRunloop()
    {
        let runloop = RunLoop.main
        runloop.run(mode: .default, before: Date(timeIntervalSinceNow: 0.001))
    }
    
    public func determineAverage(for seconds : TimeInterval, using block : () -> ()) {
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
        test: (ViewController) throws -> Void
    ) rethrows {
        
        guard let rootVC = UIApplication.shared.delegate?.window??.rootViewController else {
            XCTFail("Cannot present a view controller in a test host that does not have a root window.")
            return
        }
        
        rootVC.addChild(viewController)
        viewController.didMove(toParent: rootVC)
        
        viewController.view.frame = rootVC.view.bounds
        viewController.view.layoutIfNeeded()
        
        rootVC.beginAppearanceTransition(true, animated: false)
        rootVC.view.addSubview(viewController.view)
        rootVC.endAppearanceTransition()
        
        defer {
            viewController.beginAppearanceTransition(false, animated: false)
            viewController.view.removeFromSuperview()
            viewController.endAppearanceTransition()
            
            viewController.willMove(toParent: nil)
            viewController.removeFromParent()
        }
        
        try autoreleasepool {
            try test(viewController)
        }
    }
    
    /// Verifies that the provided value from `create` gets deallocated after the work done in the `configure`
    /// block. This can be used to ensure that you are not accidentally creating retain cycles in
    /// your types which lead to memory leaks.
    ///
    /// Each closure is passed an `inout [AnyObject]`, to which you can add additional
    /// objects you'd like to track to ensure they are deallocated.
    public func verifyNoRetainCycles<Type: AnyObject>(
        for create: (inout [AnyObject]) -> Type,
        setup: (Type, inout [AnyObject]) -> Void
    ) {
        var boxes = [WeakBox]()
        
        autoreleasepool {
            var toTrack: [AnyObject]? = [AnyObject]()
            
            var root: Type? = create(&toTrack!)
            setup(root!, &toTrack!)
            
            boxes += toTrack!.map(WeakBox.init)
            
            root = nil
            toTrack = nil
        }
        
        waitFor {
            boxes.contains { $0.value != nil } == false
        }
    }
    
    private struct WeakBox {
        weak var value: AnyObject?
        
        init(_ value: AnyObject) {
            self.value = value
        }
    }
}


extension UIView {
    public var recursiveDescription : String {
        self.value(forKey: "recursiveDescription") as! String
    }
}
