//
//  ListView+FeatureFlag.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 11/29/23.
//

import Foundation


extension ListView {
    
    public static let isNewBackingViewEnabled : Bool = {
        UserDefaults.standard.bool(forKey: "Listable.isNewBackingViewEnabled")
    }()
}
