//
//  ListContentLayoutAttributes.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 6/9/21.
//


///
/// A struct-based version of many of the properties available on `UICollectionViewLayoutAttributes`,
/// allowing configuration of properties for custom layouts, appearance animations, etc.
///
public struct ListContentLayoutAttributes
{
    //
    // MARK: Sizing & Position
    //
    
    /// The size of the represented item when it is laid out.
    /// Setting this property changes the value of the ``frame`` property.
    public var size: CGSize
    
    /// The center of the item when it is laid out, in the coordinate space of the outer list.
    /// Setting this property changes the value of the ``frame`` property.
    public var center: CGPoint
    
    /// The frame of the item when it is laid out, in the coordinate space of the outer list.
    /// Setting this property changes the value of the ``size`` and ``center`` properties.
    public var frame: CGRect {
        get {
            CGRect(
                x: self.center.x - (self.size.width / 2.0),
                y: self.center.y - (self.size.height / 2.0),
                width: self.size.width,
                height: self.size.height
            )
        }
        
        set {
            self.center = CGPoint(
                x: newValue.origin.x + (newValue.width / 2.0),
                y: newValue.origin.y + (newValue.height / 2.0)
            )
            
            self.size = newValue.size
        }
    }
    
    //
    // MARK: Transforms & Layout
    //
    
    public var transform: CGAffineTransform
    public var transform3D: CATransform3D

    public var alpha: CGFloat

    public var zIndex: Int
    
    //
    // MARK: Initialization
    //
    
    public init(_ attributes : UICollectionViewLayoutAttributes)
    {
        self.size = attributes.bounds.size
        self.center = attributes.center
        
        self.transform = attributes.transform
        self.transform3D = attributes.transform3D
        
        self.alpha = attributes.alpha
        
        self.zIndex = attributes.zIndex
    }
    
    //
    // MARK: Writing Values
    //
    
    public func apply(to attributes : UICollectionViewLayoutAttributes)
    {
        attributes.bounds = CGRect(origin: .zero, size: self.size)
        attributes.center = self.center
        
        attributes.transform3D = self.transform3D
        attributes.transform = self.transform
        
        attributes.alpha = self.alpha
        
        attributes.zIndex = self.zIndex
    }
}
