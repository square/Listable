//
//  ListLayoutAppearance.swift
//  ListableUI
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


/// Represents the properties from a `ListLayoutAppearance`, which
/// are applicable to any kind of layout.
public struct ListLayoutAppearanceProperties : Equatable {
        
    public let direction : LayoutDirection
    public let stickySectionHeaders : Bool
    
    public init(
        direction: LayoutDirection,
        stickySectionHeaders: Bool
    ) {
        self.direction = direction
        self.stickySectionHeaders = stickySectionHeaders
    }
    
    public init<Appearance:ListLayoutAppearance>(_ appearance : Appearance) {
        self.direction = appearance.direction
        self.stickySectionHeaders = appearance.stickySectionHeaders
    }
}
