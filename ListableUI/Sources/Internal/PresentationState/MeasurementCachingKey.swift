//
//  MeasurementCachingKey.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 1/23/22.
//

import Foundation


public struct MeasurementContextKey : Hashable
{
    public var constraint : Constraint
    public var layoutDirection : LayoutDirection
    public var sizing : Sizing
    
    public init(
        constraint : Constraint,
        layoutDirection: LayoutDirection,
        sizing: Sizing
    ) {
        self.constraint = constraint
        self.layoutDirection = layoutDirection
        self.sizing = sizing
    }
    
    public struct Constraint : Hashable {
        
        public var width : CGFloat
        public var height : CGFloat
        
        public init(width: CGFloat, height: CGFloat) {
            self.width = width
            self.height = height
        }
        
        public init(_ size : CGSize) {
            self.width = size.width
            self.height = size.height
        }
        
        public var size : CGSize {
            CGSize(width: width, height: height)
        }
    }
}
