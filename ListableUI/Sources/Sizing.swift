//
//  Sizing.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 10/27/19.
//

import Foundation
import UIKit


///
/// Controls how a header, footer, or item in a list view is sized.
///
public enum Sizing : Hashable
{
    /// Fixes the size to the absolute value passed in.
    ///
    /// ### Note
    /// This option takes in both a size and a width. However, for standard list views,
    /// only the height is used. The width is provided for when custom layouts are used,
    /// which may allow sizing for other types of layouts, eg, grids.
    ///
    case fixed(width : CGFloat = 0.0, height : CGFloat = 0.0)
    
    /// Sizes the item by calling `sizeThatFits` on its underlying view type.
    /// The passed in constraint is used to clamp the size to a minimum, maximum, or range.
    /// If you do not specify a constraint, `.noConstraint` is used.
    ///
    /// ### Example
    /// If you would like to use `sizeThatFits` to size an item, but would like to enforce a minimum size,
    /// you would do something similar to the following:
    ///
    /// ```
    /// // Enforces that the size is at least the default size of the list.
    /// .thatFits(.init(.atLeast(.default)))
    ///
    ///  // Enforces that the size is at least 50 points.
    /// .thatFits(.init(.atLeast(.fixed(50))))
    /// ```
    case thatFits(Constraint = .noConstraint)
    
    /// Sizes the item by calling `sizeThatFits` on its underlying view type.
    /// The passed in constraints are used to clamp the size to a minimum, maximum, or range.
    /// If you do not specify a constraint, `.noConstraint` is used.
    ///
    /// See `case thatFits(Constraint = .noConstraint)` for a full discussion.
    static func thatFits(
        width: Constraint.Axis = .noConstraint,
        height: Constraint.Axis = .noConstraint
    ) -> Self
    {
        .thatFits(.init(width: width, height: height))
    }
    
    /// Sizes the item by calling `systemLayoutSizeFitting` on its underlying view type.
    /// The passed in constraint is used to clamp the size to a minimum, maximum, or range.
    /// If you do not specify a constraint, `.noConstraint` is used.
    ///
    /// ### Example
    /// If you would like to use `systemLayoutSizeFitting` to size an item, but would like to enforce a minimum size,
    /// you would do something similar to the following:
    ///
    /// ```
    /// // Enforces that the size is at least the default size of the list.
    /// .autolayout(.init(.atLeast(.default)))
    ///
    ///  // Enforces that the size is at least 50 points.
    /// .autolayout(.init(.atLeast(.fixed(50))))
    /// ```
    case autolayout(Constraint = .noConstraint)
    
    /// Sizes the item by calling `systemLayoutSizeFitting` on its underlying view type.
    /// The passed in constraints are used to clamp the size to a minimum, maximum, or range.
    /// If you do not specify a constraint, `.noConstraint` is used.
    ///
    /// See `case autolayout(Constraint = .noConstraint)` for a full discussion.
    static func autolayout(
        width: Constraint.Axis = .noConstraint,
        height: Constraint.Axis = .noConstraint
    ) -> Self
    {
        .thatFits(.init(width: width, height: height))
    }
    
    /// Measures the given view with the provided options.
    /// The returned value is `ceil()`'d to round up to the next full integer value.
    func measure(with view : UIView, info : MeasureInfo) -> CGSize
    {
        let size : CGSize = {
            switch self {
            case .fixed(let width, let height):
                return CGSize(width: width, height: height)
                
            case .thatFits(let constraint):
                let size = view.sizeThatFits(info.sizeConstraint)
                
                return constraint.clamp(size)
                
            case .autolayout(let constraint):
                
                let size : CGSize = {
                    switch info.direction {
                    case .vertical:
                        return view.systemLayoutSizeFitting(
                            CGSize(width: info.sizeConstraint.width, height:0),
                            withHorizontalFittingPriority: .required,
                            verticalFittingPriority: .fittingSizeLevel
                        )
                    case .horizontal:
                        return view.systemLayoutSizeFitting(
                            CGSize(width: 0, height:info.sizeConstraint.height),
                            withHorizontalFittingPriority: .fittingSizeLevel,
                            verticalFittingPriority: .required
                        )
                    }
                }()

                return constraint.clamp(size)
            }
        }()
        
        self.validateMeasuredSize(size)
        
        return CGSize(
            width: ceil(size.width),
            height: ceil(size.height)
        )
    }
    
    private func validateMeasuredSize(_ size : CGSize) {
        
        // Ensure we have a reasonably valid size for the cell.
        
        let reasonableMaxDimension : CGFloat = 10_000
        
        precondition(
            size.height <= reasonableMaxDimension,
            "The height of the view was outside of reasonable expectations, and this is likely programmer error. Height: \(size.height). Your sizeThatFits or autolayout constraints are likely incorrect."
        )
        
        precondition(
            size.width <= reasonableMaxDimension,
            "The width of the view was outside of reasonable expectations, and this is likely programmer error. Width: \(size.width). Your sizeThatFits or autolayout constraints are likely incorrect."
        )
    }
}


extension Sizing
{
    public struct MeasureInfo
    {
        public var sizeConstraint : CGSize
        public var direction : LayoutDirection
        
        public init(
            sizeConstraint: CGSize,
            direction: LayoutDirection
        ) {
            self.sizeConstraint = sizeConstraint
            self.direction = direction
        }
    }
    
    /// Describes the range of values that are acceptable for both
    /// the width and the height of content within a list.
    ///
    /// Usually, for layouts like a table, only the axis that matches the current
    /// `LayoutDirection` will be used. Eg, if your table layout is laying out
    /// vertically, only the `height` axis will be used.
    public struct Constraint : Hashable
    {
        /// Describes the range of acceptable width values.
        public var width : Axis
        
        /// Describes the range of acceptable height values.
        public var height : Axis
        
        /// Applies no constraints to the measurement in either axis.
        public static var noConstraint : Constraint {
            Constraint(
                width: .noConstraint,
                height: .noConstraint
            )
        }
        
        /// Creates a new constraint with the provided value for both axes.
        public init(_ value : Axis)
        {
            self.width = value
            self.height = value
        }
        
        /// Creates a new constraint with the provided width and height axes.
        public init(
            width : Axis,
            height : Axis
        ) {
            self.width = width
            self.height = height
        }
        
        /// Clamps the provided size, falling back to the provided default if the measurement calls for a default value.
        public func clamp(_ value : CGSize) -> CGSize
        {
            return CGSize(
                width: self.width.clamp(value.width),
                height: self.height.clamp(value.height)
            )
        }
        
        /// Describes the range of values that are acceptable for one dimension
        /// in a `Constraint`, eg width or height.
        public enum Axis : Hashable
        {
            /// No constraint is applied to any measurement.
            case noConstraint
            
            /// Any returned measurement must be at least this value. If it is smaller than
            /// this value, then this value will be returned instead.
            case atLeast(CGFloat)
            
            /// Any returned measurement can be at least this large. If it is larger than
            /// this value, then this value is returned instead.
            case atMost(CGFloat)
            
            /// Any returned measurement must be within the provided range. If it is smaller
            /// or larger than the provided range, the range is used to clamp the value.
            case within(CGFloat, CGFloat)
            
            /// Clamps the provided value by the `Axis'` underlying value.
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
    }
}


/// Describes the range of acceptable values for a width.
public enum WidthConstraint : Equatable
{
    /// There is no limit to a width, it can be as wide as possible.
    case noConstraint
    
    /// The width must be exactly this value.
    case fixed(CGFloat)
    
    /// The width can be at most, this value. Any value larger will be clamped.
    case atMost(CGFloat)
    
    /// Clamps the provided value based on our underlying value.
    public func clamp(_ value : CGFloat) -> CGFloat
    {
        switch self {
        case .noConstraint: return value
        case .fixed(let fixed): return fixed
        case .atMost(let maximum): return min(maximum, value)
        }
    }
}


/// Specifies a custom width for an item or header in a list.
public enum CustomWidth : Equatable
{
    /// The default width from the layout is used.
    case `default`
    
    /// The width will fill all available space.
    case fill
    
    /// A custom width and/or alignment.
    case custom(Custom)
    
    public func merge(with parent : CustomWidth) -> CustomWidth
    {
        switch self {
        case .default: return parent
        case .fill: return self
        case .custom(_): return self
        }
    }
    
    public func position(with viewWidth : CGFloat, defaultWidth : CGFloat) -> Position
    {
        switch self {
        case .default:
            return Position(
                origin: round((viewWidth - defaultWidth) / 2.0),
                width: defaultWidth
            )
            
        case .fill:
            return Position(
                origin: 0.0,
                width: viewWidth
            )
            
        case .custom(let custom):
            return custom.position(
                with: viewWidth
            )
        }
    }
    
    public struct Custom : Equatable
    {
        public var padding : HorizontalPadding
        public var width : WidthConstraint
        public var alignment : Alignment
        
        public init(
            padding : HorizontalPadding = .zero,
            width : WidthConstraint = .noConstraint,
            alignment : Alignment = .center
        )
        {
            self.padding = padding
            self.width = width
            self.alignment = alignment
        }
        
        public func position(with viewWidth : CGFloat) -> Position
        {
            let width = TableAppearance.Layout.width(
                with: viewWidth,
                padding: self.padding,
                constraint: self.width
            )
            
            return Position(
                origin: self.alignment.originWith(
                    parentWidth: viewWidth,
                    width: width,
                    padding: self.padding
                ),
                width: width
            )
        }
    }
    
    public enum Alignment : Equatable
    {
        case leading
        case center
        case trailing
        
        public func originWith(parentWidth : CGFloat, width : CGFloat, padding : HorizontalPadding) -> CGFloat
        {
            switch self {
            case .leading:
                return padding.leading
            case .center:
                let availableWidth = parentWidth - (padding.leading + padding.trailing)
                return round((availableWidth - width) / 2.0) + padding.leading
            case .trailing:
                return parentWidth - width - padding.trailing
            }
        }
    }
    
    public struct Position : Equatable
    {
        public var origin : CGFloat
        public var width : CGFloat
        
        public init(origin: CGFloat, width: CGFloat) {
            self.origin = origin
            self.width = width
        }
    }
}


public struct HorizontalPadding : Equatable
{
    public var leading : CGFloat
    public var trailing : CGFloat
    
    public static var zero : HorizontalPadding {
        return HorizontalPadding(uniform: 0.0)
    }
    
    public init(leading : CGFloat = 0.0, trailing : CGFloat = 0.0)
    {
        self.leading = leading
        self.trailing = trailing
    }
    
    public init(uniform : CGFloat = 0.0)
    {
        self.leading = uniform
        self.trailing = uniform
    }
}
