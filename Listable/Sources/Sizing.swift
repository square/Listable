//
//  Sizing.swift
//  Listable
//
//  Created by Kyle Van Essen on 10/27/19.
//

import Foundation


public enum Height : Equatable
{
    case `default`
    case fixed(CGFloat)
    case thatFits(Constraint)
    case autolayout(Constraint)
    
    public func measure(with view : UIView, fittingWidth : CGFloat, default defaultHeight : CGFloat) -> CGFloat
    {
        switch self {
        case .default:
            return defaultHeight
            
        case .fixed(let fixedHeight):
            return fixedHeight
            
        case .thatFits(let constraints):
            let fittingSize = CGSize(width: fittingWidth, height: constraints.fittingHeight(with: defaultHeight))
            let size = view.sizeThatFits(fittingSize)
            
            return constraints.clamp(size.height, with: defaultHeight)
            
        case .autolayout(let constraints):
            let fittingSize = CGSize(width: fittingWidth, height: constraints.fittingHeight(with: defaultHeight))
            let size = view.systemLayoutSizeFitting(fittingSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)
            
            return constraints.clamp(size.height, with: defaultHeight)
        }
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
        
        public func fittingHeight(with defaultHeight : CGFloat) -> CGFloat
        {
            switch self {
            case .noConstraint: return .greatestFiniteMagnitude
            case .atLeast(_): return .greatestFiniteMagnitude
            case .atMost(let maximum): return maximum
            case .within(_, let maximum): return maximum
            }
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
