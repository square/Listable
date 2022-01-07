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
    
    var bounds : ListContentBounds? { get }
    
    var stickySectionHeaders : Bool { get }
    
    var pagingBehavior : ListPagingBehavior { get }
    
    var scrollViewProperties : ListLayoutScrollViewProperties { get }
    
    func toLayoutDescription() -> LayoutDescription
}


/// Represents the properties from a `ListLayoutAppearance`, which
/// are applicable to any kind of layout.
public struct ListLayoutAppearanceProperties : Equatable {
        
    public let direction : LayoutDirection
    public let bounds : ListContentBounds?
    public let stickySectionHeaders : Bool
    public let pagingBehavior : ListPagingBehavior
    public let scrollViewProperties : ListLayoutScrollViewProperties
    
    public init(
        direction: LayoutDirection,
        bounds : ListContentBounds?,
        stickySectionHeaders: Bool,
        pagingBehavior : ListPagingBehavior,
        scrollViewProperties : ListLayoutScrollViewProperties
    ) {
        self.direction = direction
        self.bounds = bounds
        self.stickySectionHeaders = stickySectionHeaders
        self.pagingBehavior = pagingBehavior
        self.scrollViewProperties = scrollViewProperties
    }
    
    public init<Appearance:ListLayoutAppearance>(_ appearance : Appearance) {
        self.direction = appearance.direction
        self.bounds = appearance.bounds
        self.stickySectionHeaders = appearance.stickySectionHeaders
        self.pagingBehavior = appearance.pagingBehavior
        self.scrollViewProperties = appearance.scrollViewProperties
    }
}
