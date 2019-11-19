//
//  Appearance.swift
//  Listable
//
//  Created by Kyle Van Essen on 10/17/19.
//


public struct Appearance : Equatable
{
    public var backgroundColor : UIColor
    
    public var direction : LayoutDirection
    
    public var sizing : ListSizing
    public var layout : ListLayout
    public var underflow : UnderflowBehavior
        
    public init(_ configure : (inout Appearance) -> ())
    {
        self.init()
        
        configure(&self)
    }
    
    public init(
        backgroundColor : UIColor = .white,
        direction : LayoutDirection = .vertical,
        sizing : ListSizing = ListSizing(),
        layout : ListLayout = ListLayout(),
        underflow : UnderflowBehavior = .alwaysBounceVertical(true)
    )
    {
        self.backgroundColor = backgroundColor
        
        self.direction = direction
        
        self.sizing = sizing
        self.layout = layout
        self.underflow = underflow
    }
    
    public mutating func set(with block : (inout Appearance) -> ())
    {
        var edited = self
        block(&edited)
        self = edited
    }
}


public struct ListSizing : Equatable
{
    public var itemHeight : CGFloat
    
    public var sectionHeaderHeight : CGFloat
    public var sectionFooterHeight : CGFloat
    
    public var listHeaderHeight : CGFloat
    public var listFooterHeight : CGFloat
    
    public var itemPositionGroupingHeight : CGFloat
        
    public init(
        itemHeight : CGFloat = 50.0,
        sectionHeaderHeight : CGFloat = 60.0,
        sectionFooterHeight : CGFloat = 40.0,
        listHeaderHeight : CGFloat = 60.0,
        listFooterHeight : CGFloat = 60.0,
        itemPositionGroupingHeight : CGFloat = 0.0
    )
    {
        self.itemHeight = itemHeight
        self.sectionHeaderHeight = sectionHeaderHeight
        self.sectionFooterHeight = sectionFooterHeight
        self.listHeaderHeight = listHeaderHeight
        self.listFooterHeight = listFooterHeight
        self.itemPositionGroupingHeight = itemPositionGroupingHeight
    }
    
    public mutating func set(with block: (inout ListSizing) -> ())
    {
        var edited = self
        block(&edited)
        self = edited
    }
}


public struct ListLayout : Equatable
{
    public var padding : UIEdgeInsets
    public var width : WidthConstraint

    public var interSectionSpacingWithNoFooter : CGFloat
    public var interSectionSpacingWithFooter : CGFloat
    
    public var sectionHeaderBottomSpacing : CGFloat
    public var itemSpacing : CGFloat
    public var itemToSectionFooterSpacing : CGFloat
    
    public var stickySectionHeaders : Bool
    
    public init(
        padding : UIEdgeInsets = .zero,
        width : WidthConstraint = .noConstraint,
        interSectionSpacingWithNoFooter : CGFloat = 0.0,
        interSectionSpacingWithFooter : CGFloat = 0.0,
        sectionHeaderBottomSpacing : CGFloat = 0.0,
        itemSpacing : CGFloat = 0.0,
        itemToSectionFooterSpacing : CGFloat = 0.0,
        stickySectionHeaders : Bool = false
    )
    {
        self.padding = padding
        self.width = width
        
        self.interSectionSpacingWithNoFooter = interSectionSpacingWithNoFooter
        self.interSectionSpacingWithFooter = interSectionSpacingWithFooter
        
        self.sectionHeaderBottomSpacing = sectionHeaderBottomSpacing
        self.itemSpacing = itemSpacing
        self.itemToSectionFooterSpacing = itemToSectionFooterSpacing
        
        self.stickySectionHeaders = stickySectionHeaders
    }

    public mutating func set(with block : (inout ListLayout) -> ())
    {
        var edited = self
        block(&edited)
        self = edited
    }
    
    internal static func width(
        with width : CGFloat,
        padding : HorizontalPadding,
        constraint : WidthConstraint
    ) -> CGFloat
    {
        let paddedWidth = width - padding.left - padding.right
        
        return constraint.clamp(paddedWidth)
    }
}


public enum UnderflowBehavior : Equatable
{
    case alwaysBounceVertical(Bool)
    case pinTo(PinAlignment)
    
    public enum PinAlignment : Equatable
    {
        case top
        case center
        case bottom
    }
}

