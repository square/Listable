//
//  ItemInsertAndRemoveAnimations.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 6/18/20.
//

import UIKit


public struct ItemInsertAndRemoveAnimations
{
    public typealias Prepare = (inout Attributes) -> ()
    
    public var onInsert : Prepare
    public var onRemoval : Prepare
    
    public init(
        onInsert : @escaping Prepare,
        onRemoval : @escaping Prepare
    ) {
        self.onInsert = onInsert
        self.onRemoval = onRemoval
    }
    
    public init(attributes : @escaping Prepare)
    {
        self.onInsert = attributes
        self.onRemoval = attributes
    }
    
    public struct Attributes
    {
        public var bounds: CGRect
        public var center: CGPoint
        
        public var transform: CGAffineTransform
        public var transform3D: CATransform3D

        public var alpha: CGFloat

        public var zIndex: Int
        
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
        
        init(_ attributes : UICollectionViewLayoutAttributes)
        {
            self.bounds = attributes.bounds
            self.center = attributes.center
            
            self.transform = attributes.transform
            self.transform3D = attributes.transform3D
            
            self.alpha = attributes.alpha
            
            self.zIndex = attributes.zIndex
        }
        
        func apply(to attributes : UICollectionViewLayoutAttributes)
        {
            attributes.bounds = self.bounds
            attributes.center = self.center
            
            attributes.transform3D = self.transform3D
            attributes.transform = self.transform
            
            attributes.alpha = self.alpha
            
            attributes.zIndex = self.zIndex
        }
    }
}


public extension ItemInsertAndRemoveAnimations
{
    static var fade : Self {
                Self(
            onInsert: {
                $0.alpha = 0.0
            },
            onRemoval: {
                $0.alpha = 0.0
            }
        )
    }
    
    static var right : Self {
        Self(
            onInsert: {
                $0.frame.origin.x += $0.frame.width
                $0.alpha = 0.0
            },
            onRemoval: {
                $0.frame.origin.x += $0.frame.width
                $0.alpha = 0.0
            }
        )
    }
    
    static var left : Self {
        Self(
            onInsert: {
                $0.frame.origin.x -= $0.frame.width
                $0.alpha = 0.0
            },
            onRemoval: {
                $0.frame.origin.x -= $0.frame.width
                $0.alpha = 0.0
            }
        )
    }
    
    static var top : Self {
        Self(
            onInsert: {
                $0.frame.origin.y -= $0.frame.height
                $0.alpha = 0.0
            },
            onRemoval: {
                $0.frame.origin.y -= $0.frame.height
                $0.alpha = 0.0
            }
        )
    }
    
    static var bottom : Self {
        Self(
            onInsert: {
                $0.frame.origin.y += $0.frame.height
                $0.alpha = 0.0
            },
            onRemoval: {
                $0.frame.origin.y += $0.frame.height
                $0.alpha = 0.0
            }
        )
    }
    
    static var scaleDown : Self {
        Self(
            onInsert: {
                $0.transform = CGAffineTransform.identity.scaledBy(x: 0.5, y: 0.5)
                $0.alpha = 0.0
            },
            onRemoval: {
                $0.transform = CGAffineTransform.identity.scaledBy(x: 0.5, y: 0.5)
                $0.alpha = 0.0
            }
        )
    }
    
    static var scaleUp : Self {
        Self(
            onInsert: {
                $0.transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5)
                $0.alpha = 0.0
            },
            onRemoval: {
                $0.transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5)
                $0.alpha = 0.0
            }
        )
    }
}
