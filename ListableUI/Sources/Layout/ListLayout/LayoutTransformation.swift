//
//  LayoutTransformation.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 6/14/21.
//

import Foundation


public struct LayoutTransformation {
    
    public var externality : Externality
    public var behavior : Behavior
    
    public var calculate : (Context, inout Attributes) -> ()
    
    public init(
        externality : Externality,
        behavior : Behavior,
        calculate : @escaping (Context, inout Attributes) -> ()
    ) {
        self.externality = externality
        self.behavior = behavior
        self.calculate = calculate
    }
}


extension LayoutTransformation {
    
    public struct Attributes
    {
        public var bounds: CGRect
        public var center: CGPoint
        
        public var transform : Transform

        public var alpha: CGFloat
        
        public var frame: CGRect {
            get {
                CGRect(
                    x: self.center.x - (self.bounds.width / 2.0),
                    y: self.center.y - (self.bounds.height / 2.0),
                    width: self.bounds.width,
                    height: self.bounds.height
                )
            }
            
            set {
                self.center = CGPoint(
                    x: newValue.origin.x + (newValue.width / 2.0),
                    y: newValue.origin.y + (newValue.height / 2.0)
                )
                
                self.bounds = CGRect(
                    origin: .zero,
                    size: newValue.size
                )
            }
        }
    }
    
    public enum Externality : Equatable {
        case affectsSelf
        case affectsLayout
    }
    
    public enum Behavior : Equatable {
        case contentOnly
        case contentAndBackground
    }
    
    public struct Context : Equatable {
        
        public var layoutContext : ListLayoutLayoutContext
    }
}


extension LayoutTransformation.Attributes {
    
    public enum Transform {
        case affine(CGAffineTransform)
        case transform3d(CATransform3D)
    }
}
