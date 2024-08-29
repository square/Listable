//
//  AppDelegate.swift
//  Checkout
//
//  Created by Kyle Van Essen on 6/14/19.
//  Copyright © 2019 Kyle Van Essen. All rights reserved.
//

import UIKit
import ListableUI


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        ListView.configure(with: application)
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = DemoNavigationController()
        
        self.window = window
        
        UserDefaults.standard.set(true, forKey: "Listable.EnableIOS164FirstResponderWorkaround")
        
        window.makeKeyAndVisible()
        
        return true
    }
}


final class DemoNavigationController : UINavigationController, UINavigationControllerDelegate {
        
    init() {
        super.init(rootViewController: DemosRootViewController())
        
        if let demoClass = Self.demoClass {
            self.pushViewController(demoClass.init(), animated: false)
        }
        
        self.delegate = self
    }
    
    private static let userDefaultsKey = "ListableDemo.PushedDemoClassName"
    
    static func setPushedDemo(_ demo : UIViewController) {
        UserDefaults.standard.set(NSStringFromClass(type(of: demo)), forKey: userDefaultsKey)
        UserDefaults.standard.synchronize()
    }
    
    static var demoClass : UIViewController.Type? {
        if let demoClassName = UserDefaults.standard.string(forKey: userDefaultsKey) {
            return NSClassFromString(demoClassName) as? UIViewController.Type
        } else {
            return nil
        }
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        if self.topViewController is DemosRootViewController {
            UserDefaults.standard.removeObject(forKey: Self.userDefaultsKey)
            UserDefaults.standard.synchronize()
        }
    }
}
