//
//  AppDelegate.swift
//  Checkout
//
//  Created by Kyle Van Essen on 6/14/19.
//  Copyright © 2019 Kyle Van Essen. All rights reserved.
//

import UIKit

import Listable
import Dispatch


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UINavigationController(rootViewController: DemosRootViewController())
        
        self.window = window
        
        window.makeKeyAndVisible()
        
        return true
    }
}

