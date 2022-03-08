//
//  Bundle+ListableUI.swift
//  ListableUI
//
//  Created by Alex Odawa on 01/03/2022.
//

import Foundation

private final class MarkerClass {}

extension Bundle {
    /// The resource bundle
    static let listableUIResources: Bundle = {
        #if SWIFT_PACKAGE
            return .module
        #else
            let listableUIResources: Bundle = Bundle(for: MarkerClass.self)

            guard let resourcePath = listableUIResources.path(forResource: "ListableUIResources", ofType: "bundle"),
                  let bundle = Bundle(path: resourcePath)
            else {
                fatalError("Could not load bundle ListableUIResources")
            }
            return bundle
        #endif
    }()
}
