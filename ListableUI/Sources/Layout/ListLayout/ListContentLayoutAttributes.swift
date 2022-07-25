//
//  ListContentLayoutAttributes.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 6/9/21.
//

import UIKit

///
/// A struct-based version of many of the properties available on `UICollectionViewLayoutAttributes`,
/// allowing configuration of properties for custom layouts, appearance animations, etc.
///
public struct ListContentLayoutAttributes {
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
                x: center.x - (size.width / 2.0),
                y: center.y - (size.height / 2.0),
                width: size.width,
                height: size.height
            )
        }

        set {
            center = CGPoint(
                x: newValue.origin.x + (newValue.width / 2.0),
                y: newValue.origin.y + (newValue.height / 2.0)
            )

            size = newValue.size
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

    public init(_ attributes: UICollectionViewLayoutAttributes) {
        size = attributes.bounds.size
        center = attributes.center

        transform = attributes.transform
        transform3D = attributes.transform3D

        alpha = attributes.alpha

        zIndex = attributes.zIndex
    }

    //

    // MARK: Writing Values

    //

    public func apply(to attributes: UICollectionViewLayoutAttributes) {
        attributes.bounds = CGRect(origin: .zero, size: size)
        attributes.center = center

        attributes.transform3D = transform3D
        attributes.transform = transform

        attributes.alpha = alpha

        attributes.zIndex = zIndex
    }
}
