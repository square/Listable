//
//  AppDelegate.swift
//  Checkout
//
//  Created by Kyle Van Essen on 6/14/19.
//  Copyright © 2019 Kyle Van Essen. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = DemoNavigationController()

        self.window = window

        window.makeKeyAndVisible()

        return true
    }
}

final class DemoNavigationController: UINavigationController, UINavigationControllerDelegate {
    init() {
        super.init(rootViewController: DemosRootViewController())

        if let demoClass = Self.demoClass {
            pushViewController(demoClass.init(), animated: false)
        }

        delegate = self
    }

    private static let userDefaultsKey = "ListableDemo.PushedDemoClassName"

    static func setPushedDemo(_ demo: UIViewController) {
        UserDefaults.standard.set(NSStringFromClass(type(of: demo)), forKey: userDefaultsKey)
        UserDefaults.standard.synchronize()
    }

    static var demoClass: UIViewController.Type? {
        if let demoClassName = UserDefaults.standard.string(forKey: userDefaultsKey) {
            return NSClassFromString(demoClassName) as? UIViewController.Type
        } else {
            return nil
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError() }

    func navigationController(
        _: UINavigationController,
        didShow _: UIViewController,
        animated _: Bool
    ) {
        if topViewController is DemosRootViewController {
            UserDefaults.standard.removeObject(forKey: Self.userDefaultsKey)
            UserDefaults.standard.synchronize()
        }
    }
}
