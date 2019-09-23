//
//  Sizing.swift
//  Listable
//
//  Created by Kyle Van Essen on 7/6/19.
//

import Foundation


public enum AxisSizing : Equatable
{
    case `default`
    case fixed(CGFloat)
    case thatFits(AxisConstraint)
    case autolayout(AxisConstraint)
    
    public func height(with view : UIView, fittingWidth : CGFloat, default defaultHeight : CGFloat) -> CGFloat
    {        
        switch self {
        case .default:
            return defaultHeight
            
        case .fixed(let fixedHeight):
            return fixedHeight
            
        case .thatFits(let constraints):
            let fittingSize = CGSize(width: fittingWidth, height: constraints.fittingHeight)
            let size = view.sizeThatFits(fittingSize)
            
            return constraints.clamp(size.height)
            
        case .autolayout(let constraints):
            let fittingSize = CGSize(width: fittingWidth, height: constraints.fittingHeight)
            let size = view.systemLayoutSizeFitting(fittingSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)
            
            return constraints.clamp(size.height)
        }
    }
}

public enum AxisConstraint : Equatable
{
    case noConstraint
    case atLeast(CGFloat)
    case atMost(CGFloat)
    case within(CGFloat, CGFloat)
    
    public var fittingHeight : CGFloat {
        switch self {
        case .noConstraint: return .greatestFiniteMagnitude
        case .atLeast(_): return .greatestFiniteMagnitude
        case .atMost(let maximum): return maximum
        case .within(_, let maximum): return maximum
        }
    }
    
    public func clamp(_ value : CGFloat) -> CGFloat
    {
        switch self {
        case .noConstraint: return value
        case .atLeast(let minimum): return max(minimum, value)
        case .atMost(let maximum): return min(maximum, value)
        case .within(let minimum, let maximum): return max(minimum, min(maximum, value))
        }
    }
}

