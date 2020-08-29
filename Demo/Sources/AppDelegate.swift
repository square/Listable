//
//  AppDelegate.swift
//  Checkout
//
//  Created by Kyle Van Essen on 6/14/19.
//  Copyright © 2019 Kyle Van Essen. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        let navController = UINavigationController(rootViewController: RootViewController())
        
        if #available(iOS 11.0, *) {
            navController.navigationBar.prefersLargeTitles = true
        }
        
        window.rootViewController = navController
        
        self.window = window
        
        window.makeKeyAndVisible()
        
        return true
    }
}

