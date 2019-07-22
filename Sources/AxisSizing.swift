//
//  AxisSizing.swift
//  Listable
//
//  Created by Kyle Van Essen on 7/6/19.
//

import Foundation


public enum AxisSizing
{
    case `default`
    case fixed(CGFloat)
    case thatFits(AxisConstraint)
    case autolayout(AxisConstraint)
    
    public func height(with view : UIView, fittingWidth : CGFloat, default defaultHeight : CGFloat) -> CGFloat
    {
        // TODO Why is this here??
        view.frame.size.width = fittingWidth
        
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
