//
//  LayoutDirection.swift
//  Listable
//
//  Created by Kyle Van Essen on 11/10/19.
//


public enum LayoutDirection : Hashable
{
    case vertical
    case horizontal
    
    public func `switch`<Value>(vertical : () -> Value, horizontal : () -> Value) -> Value {
        switch self {
        case .vertical: return vertical()
        case .horizontal: return horizontal()
        }
    }
    
    public func `switch`<Value>(vertical : @autoclosure () -> Value, horizontal : @autoclosure () -> Value) -> Value {
        switch self {
        case .vertical: return vertical()
        case .horizontal: return horizontal()
        }
    }
    
    //
    // MARK: Creating & Reading Values
    //
    
    public func height_new(for size : CGSize) -> CGFloat
    {
        switch self {
        case .vertical: return size.height
        case .horizontal: return size.width
        }
    }
    
    public func width_new(for size : CGSize) -> CGFloat
    {
        switch self {
        case .vertical: return size.width
        case .horizontal: return size.height
        }
    }
    
    public func point_new(x : CGFloat, y : CGFloat) -> CGPoint
    {
        switch self {
        case .vertical: return CGPoint(x: x, y: y)
        case .horizontal: return CGPoint(x: y, y: x)
        }
    }
    
    public func size_new(for size : CGSize) -> CGSize
    {
        switch self {
        case .vertical: return CGSize(width: size.width, height: size.height)
        case .horizontal: return CGSize(width: size.height, height: size.width)
        }
    }
    
    public func size_new(width : CGFloat, height : CGFloat) -> CGSize
    {
        switch self {
        case .vertical: return CGSize(width: width, height: height)
        case .horizontal: return CGSize(width: height, height: width)
        }
    }
    
    public func maxY_new(for frame : CGRect) -> CGFloat
    {
        switch self {
        case .vertical: return frame.maxY
        case .horizontal: return frame.maxX
        }
    }
    
    public func maxX_new(for frame : CGRect) -> CGFloat
    {
        switch self {
        case .vertical: return frame.maxX
        case .horizontal: return frame.maxY
        }
    }
    
    public func x_new(for point : CGPoint) -> CGFloat
    {
        switch self {
        case .vertical: return point.x
        case .horizontal: return point.y
        }
    }
    
    public func y_new(for point : CGPoint) -> CGFloat
    {
        switch self {
        case .vertical: return point.y
        case .horizontal: return point.x
        }
    }
    
    public func horizontalPadding_new(with insets : UIEdgeInsets) -> HorizontalPadding
    {
        switch self {
        case .vertical: return HorizontalPadding(left: insets.left, right: insets.right)
        case .horizontal: return HorizontalPadding(left: insets.bottom, right: insets.top)
        }
    }
    
    public func top_new(with insets : UIEdgeInsets) -> CGFloat
    {
        switch self {
        case .vertical: return insets.top
        case .horizontal: return insets.left
        }
    }
    
    public func bottom_new(with insets : UIEdgeInsets) -> CGFloat
    {
        switch self {
        case .vertical: return insets.bottom
        case .horizontal: return insets.right
        }
    }
}
