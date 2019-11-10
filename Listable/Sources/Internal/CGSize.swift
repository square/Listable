//
//  CGSize.swift
//  Listable
//
//  Created by Kyle Van Essen on 11/12/19.
//

import Foundation


internal extension CGSize
{
    var isEmpty : Bool {
        return self.width == 0.0 || self.height == 0.0
    }
}
