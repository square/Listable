//
//  AxisConstraint.swift
//  Listable
//
//  Created by Kyle Van Essen on 7/2/19.
//

import Foundation


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
