//
//  Sizing.swift
//  Listable
//
//  Created by Kyle Van Essen on 10/27/19.
//

import Foundation


public enum Sizing : Equatable
{
    case `default`
    case fixed(CGFloat)
    case thatFits(Constraint)
    case autolayout(Constraint)
    
    public func measure(with view : UIView, width : CGFloat, layoutDirection : LayoutDirection, defaultHeight : CGFloat) -> CGFloat
    {
        let value : CGFloat = {
            switch self {
            case .default:
                return defaultHeight
                
            case .fixed(let fixedHeight):
                return fixedHeight
                
            case .thatFits(let constraints):
                let fittingSize = layoutDirection.fittingSize(with: width)
                let size = view.sizeThatFits(fittingSize)
                
                return constraints.clamp(layoutDirection.height(for: size), with: defaultHeight)
                
            case .autolayout(let constraints):
                let fittingSize = layoutDirection.fittingSize(with: width)
                
                let size : CGSize
                
                switch layoutDirection {
                case .vertical:
                    size = view.systemLayoutSizeFitting(fittingSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)
                case .horizontal:
                    size = view.systemLayoutSizeFitting(fittingSize, withHorizontalFittingPriority: .defaultLow, verticalFittingPriority: .required)
                }
                
                return constraints.clamp(layoutDirection.height(for: size), with: defaultHeight)
            }
        }()
        
        return value.rounded()
    }
    
    public enum ConstraintValue : Equatable
    {
        case `default`
        case fixed(CGFloat)
        
        public func value(with defaultHeight : CGFloat) -> CGFloat
        {
            switch self {
            case .`default`: return defaultHeight
            case .fixed(let fixed): return fixed
            }
        }
    }
    
    public enum Constraint : Equatable
    {
        case noConstraint
        
        case atLeast(ConstraintValue)
        case atMost(CGFloat)
        
        case within(ConstraintValue, CGFloat)
        
        public enum Limit
        {
            case fixed(CGFloat)
            case listHeight
        }
        
        public func clamp(_ value : CGFloat, with defaultHeight : CGFloat) -> CGFloat
        {
            switch self {
            case .noConstraint: return value
            case .atLeast(let minimum): return max(minimum.value(with: defaultHeight), value)
            case .atMost(let maximum): return min(maximum, value)
            case .within(let minimum, let maximum): return max(minimum.value(with: defaultHeight), min(maximum, value))
            }
        }
    }
}


public enum WidthConstraint : Equatable
{
    case noConstraint
    case fixed(CGFloat)
    case atMost(CGFloat)
    
    public func clamp(_ value : CGFloat) -> CGFloat
    {
        switch self {
        case .noConstraint: return value
        case .fixed(let fixed): return fixed
        case .atMost(let maximum): return min(maximum, value)
        }
    }
}


public enum CustomWidth : Equatable
{
    case `default`
    case fill
    case custom(Custom)
    
    public func merge(with parent : CustomWidth) -> CustomWidth
    {
        switch self {
        case .default: return parent
        case .fill: return self
        case .custom(_): return self
        }
    }
    
    public func position(with viewSize : CGSize, defaultWidth : CGFloat, layoutDirection : LayoutDirection) -> Position
    {
        switch self {
        case .default: return Position(origin: round((layoutDirection.width(for: viewSize) - defaultWidth) / 2.0), width: defaultWidth)
        case .fill: return Position(origin: 0.0, width: layoutDirection.width(for: viewSize))
        case .custom(let custom): return custom.position(with: viewSize, layoutDirection: layoutDirection)
        }
    }
    
    public struct Custom : Equatable
    {
        public var padding : UIEdgeInsets
        public var width : WidthConstraint
        public var alignment : Alignment
        
        public init(
            padding : UIEdgeInsets = .zero,
            width : WidthConstraint = .noConstraint,
            alignment : Alignment = .center
        )
        {
            self.padding = padding
            self.width = width
            self.alignment = alignment
        }
        
        public func position(with viewSize : CGSize, layoutDirection : LayoutDirection) -> Position
        {
            let width = ListLayout.width(with: viewSize, padding: self.padding, constraint: self.width, layoutDirection: layoutDirection)
            
            return Position(
                origin: self.alignment.originWith(
                    parentWidth: layoutDirection.width(for: viewSize),
                    width: width,
                    padding: self.padding,
                    layoutDirection: layoutDirection
                ),
                width: width
            )
        }
    }
    
    public enum Alignment : Equatable
    {
        case left
        case center
        case right
        
        public func originWith(parentWidth : CGFloat, width : CGFloat, padding : UIEdgeInsets, layoutDirection : LayoutDirection) -> CGFloat
        {
            switch self {
            case .left:
                switch layoutDirection {
                case .vertical: return padding.left
                case .horizontal: return padding.bottom
                }
            case .center:
                return round((parentWidth - width) / 2.0)
            case .right:
                switch layoutDirection {
                case .vertical: return parentWidth - width - padding.right
                case .horizontal: return parentWidth - width - padding.top
                }
            }
        }
    }
    
    public struct Position : Equatable
    {
        var origin : CGFloat
        var width : CGFloat
    }
}
