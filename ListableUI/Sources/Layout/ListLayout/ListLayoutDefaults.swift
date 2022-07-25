//
//  ListLayoutDefaults.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 6/22/20.
//

import Foundation

public struct ListLayoutDefaults {
    public var itemInsertAndRemoveAnimations: ItemInsertAndRemoveAnimations

    public init(itemInsertAndRemoveAnimations: ItemInsertAndRemoveAnimations) {
        self.itemInsertAndRemoveAnimations = itemInsertAndRemoveAnimations
    }
}
