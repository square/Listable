//
//  ListLayoutAppearance.swift
//  Listable
//
//  Created by Kyle Van Essen on 6/15/20.
//

import Foundation


public protocol ListLayoutAppearance : Equatable
{
    static var `default` : Self { get }
    
    var direction : LayoutDirection { get }
    
    var stickySectionHeaders : Bool { get }
}
