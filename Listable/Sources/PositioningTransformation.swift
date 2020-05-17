//
//  PositioningTransformation.swift
//  Listable
//
//  Created by Kyle Van Essen on 5/17/20.
//

import UIKit




public struct PositioningTransformation {
    
    public typealias Provider = (Input) -> Self
    
    public static var none : Self {
        Self(
            alpha: nil,
            transform: nil
        )
    }
    
    public init(
        alpha : CGFloat? = nil,
        transform : Transform? = nil
    ) {
        self.alpha = alpha
        self.transform = transform
    }
    
    public var alpha : CGFloat?
    public var transform : Transform?
    
    func setAttributes(on attributes : UICollectionViewLayoutAttributes)
    {
        if let transform = self.transform {
            switch transform {
            case .affine(let affine): attributes.transform = affine
            case .transform3D(let transform3d): attributes.transform3D = transform3d
            }
        }
        
        if let alpha = self.alpha {
            attributes.alpha = alpha
        }
    }
 
    public enum Transform {
        case affine(CGAffineTransform)
        case transform3D(CATransform3D)
    }
    
    public struct Input : Equatable {
        public var listSize : CGSize
        public var listBounds : CGRect
        public var listSafeAreaInsets : UIEdgeInsets
        
        public var itemFrame : CGRect
    }
}


public extension ClosedRange where Bound : BinaryFloatingPoint
{
    func containedValue(for value : Bound, in bounds : ClosedRange<Bound>) -> Bound
    {
        if value <= bounds.lowerBound {
            return self.lowerBound
        } else if value >= bounds.upperBound {
            return self.upperBound
        } else {
            let boundsLength = bounds.upperBound - bounds.lowerBound
            let distanceIntoBoundsRange = boundsLength - (value - bounds.lowerBound)
            
            let scale = 1.0 - (distanceIntoBoundsRange / boundsLength)
            
            let length = self.upperBound - self.lowerBound
            
            return self.lowerBound + (length * scale)
        }
    }
}
