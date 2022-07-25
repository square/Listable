//
//  CGSize.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 11/12/19.
//

import Foundation
import UIKit

internal extension CGSize {
    var isEmpty: Bool {
        width == 0.0 || height == 0.0
    }
}
