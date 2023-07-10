//
//  ViewProperties.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 2/14/23.
//

import UIKit


/// Describes the properties to apply to a view for an `ItemContent` or `HeaderFooterContent`
public struct ViewProperties {

    /// If the view should clip its contents or not.
    public var clipsToBounds : Bool
    
    /// The corner style to apply, eg rounded, capsule, or normal, square corners.
    public var cornerStyle: CornerStyle

    /// How to style the curves when `cornerStyle` is non-square.
    public var cornerCurve: CornerCurve
    
    /// Creates new view properties.
    public init(
        clipsToBounds: Bool = false,
        cornerStyle: CornerStyle = .square,
        cornerCurve: CornerCurve = .continuous
    ) {
        self.clipsToBounds = clipsToBounds
        
        self.cornerStyle = cornerStyle
        self.cornerCurve = cornerCurve
    }
    
    public func apply(to view : UIView) {
        
        let cornerRadius = cornerStyle.radius(for: view.bounds)
        
        /// We check `cornerRadius`, because clipping is required for corner radii to affect view content.
        let clipsToBounds = clipsToBounds || cornerRadius > 0
        
        if clipsToBounds != view.clipsToBounds {
            view.clipsToBounds = clipsToBounds
        }
        
        if cornerRadius != view.layer.cornerRadius {
            view.layer.cornerRadius = cornerRadius
        }
        
        if cornerStyle.cornerMask != view.layer.maskedCorners {
            view.layer.maskedCorners = self.cornerStyle.cornerMask
        }

        if cornerCurve.toLayerCornerCurve != view.layer.cornerCurve {
            view.layer.cornerCurve = cornerCurve.toLayerCornerCurve
        }
    }
}


extension ViewProperties {
    
    /// The style of corners to draw on the view.
    public enum CornerStyle: Equatable {
        
        /// Regular, non-rounded corners.
         case square
        
        /// Capsule-style corners will be rendered. Eg, the corner radii is the same
        /// as the view height or width, whichever is less.
         case capsule
        
        /// The provided radii is applied to the specified corners.
         case rounded(radius: CGFloat, corners: Corners = .all)

        /// Describes the corners to apply the style to.
         public struct Corners: OptionSet, Equatable {
             public let rawValue: UInt8

             public init(rawValue: UInt8) {
                 self.rawValue = rawValue
             }

             public static let topLeft = Corners(rawValue: 1)
             public static let topRight = Corners(rawValue: 1 << 1)
             public static let bottomLeft = Corners(rawValue: 1 << 2)
             public static let bottomRight = Corners(rawValue: 1 << 3)

             public static let all: Corners = [.topLeft, .topRight, .bottomLeft, .bottomRight]
             public static let top: Corners = [.topRight, .topLeft]
             public static let left: Corners = [.topLeft, .bottomLeft]
             public static let bottom: Corners = [.bottomLeft, .bottomRight]
             public static let right: Corners = [.topRight, .bottomRight]
         }
     }

     /// Specifies the curve style when showing rounded corners on a `Box`.
     public enum CornerCurve: Equatable {

         /// Provides a standard-style corner radius as you would see in design tools like Figma.
         case circular

         /// Provides an iOS icon-style corner radius.
         case continuous

         var toLayerCornerCurve: CALayerCornerCurve {
             switch self {
             case .circular: return .circular
             case .continuous: return .continuous
             }
         }
     }
}


extension ViewProperties.CornerStyle {

    fileprivate func radius(for bounds: CGRect) -> CGFloat {
        switch self {
        case .square:
            return 0
        case .capsule:
            return min(bounds.width, bounds.height) / 2
        case let .rounded(radius: radius, _):
            let maximumRadius = min(bounds.width, bounds.height) / 2
            return min(maximumRadius, radius)
        }
    }

    fileprivate var cornerMask: CACornerMask {
        switch self {
        case .square, .capsule:
            return Corners.all.toCACornerMask
        case let .rounded(_, corners):
            return corners.toCACornerMask
        }
    }

    fileprivate var shadowRoundedCorners: UIRectCorner {
        switch self {
        case .square, .capsule:
            return Corners.all.toUIRectCorner
        case let .rounded(_, corners):
            return corners.toUIRectCorner
        }
    }
}

extension ViewProperties.CornerStyle.Corners {
    
    fileprivate var toCACornerMask: CACornerMask {
        var mask: CACornerMask = []
        if contains(.topLeft) {
            mask.update(with: .layerMinXMinYCorner)
        }

        if contains(.topRight) {
            mask.update(with: .layerMaxXMinYCorner)
        }

        if contains(.bottomLeft) {
            mask.update(with: .layerMinXMaxYCorner)
        }

        if contains(.bottomRight) {
            mask.update(with: .layerMaxXMaxYCorner)
        }
        
        return mask
    }

    fileprivate var toUIRectCorner: UIRectCorner {
        var rectCorner: UIRectCorner = []
        if contains(.topLeft) {
            rectCorner.update(with: .topLeft)
        }

        if contains(.topRight) {
            rectCorner.update(with: .topRight)
        }

        if contains(.bottomLeft) {
            rectCorner.update(with: .bottomLeft)
        }

        if contains(.bottomRight) {
            rectCorner.update(with: .bottomRight)
        }
        
        return rectCorner
    }
}
