//
//  Bundle.swift
//  Listable-DemoApp
//
//  Created by Kyle Van Essen on 6/26/19.
//

import Foundation

private class ListableDemoResourcesBundleFinderClass: NSObject {}

extension Bundle {
    static var ListableDemoResourcesBundle: Bundle {
        let mainBundle = Bundle(for: ListableDemoResourcesBundleFinderClass.self)
        
        guard let bundleURL = mainBundle.url(forResource: "ListableDemoResources", withExtension: "bundle"),
            let bundle = Bundle(url: bundleURL) else {
                fatalError("Could not find resource bundle for ListableDemo within main application bundle.")
        }
        
        return bundle
    }
}
