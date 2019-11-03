//
//  Appearance.swift
//  Listable
//
//  Created by Kyle Van Essen on 10/17/19.
//


public struct Appearance : Equatable
{
    public var backgroundColor : UIColor
    
    public var sizing : ListSizing
    public var contentLayout : ListContentLayout
    public var underflow : UnderflowBehavior
    
    public init(_ configure : (inout Appearance) -> ())
    {
        self.init()
        
        configure(&self)
    }
    
    public init(
        backgroundColor : UIColor = .white,
        sizing : ListSizing = ListSizing(),
        contentLayout : ListContentLayout = ListContentLayout(),
        underflow : UnderflowBehavior = .alwaysBounceVertical(true)
    )
    {
        self.backgroundColor = backgroundColor
        self.sizing = sizing
        self.contentLayout = contentLayout
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
    public var rowHeight : CGFloat
    
    public var sectionHeaderHeight : CGFloat
    public var sectionFooterHeight : CGFloat
    
    public var listHeaderHeight : CGFloat
    public var listFooterHeight : CGFloat
        
    public init(
        rowHeight : CGFloat = 50.0,
        sectionHeaderHeight : CGFloat = 60.0,
        sectionFooterHeight : CGFloat = 40.0,
        listHeaderHeight : CGFloat = 60.0,
        listFooterHeight : CGFloat = 60.0
    )
    {
        self.rowHeight = rowHeight
        self.sectionHeaderHeight = sectionHeaderHeight
        self.sectionFooterHeight = sectionFooterHeight
        self.listHeaderHeight = listHeaderHeight
        self.listFooterHeight = listFooterHeight
    }
    
    public mutating func set(with block: (inout ListSizing) -> ())
    {
        var edited = self
        block(&edited)
        self = edited
    }
}


public struct ListContentLayout : Equatable
{
    public var padding : UIEdgeInsets
    public var width : WidthConstraint
    
    public var interSectionSpacingWithNoFooter : CGFloat
    public var interSectionSpacingWithFooter : CGFloat
    
    public var sectionHeaderBottomSpacing : CGFloat
    public var rowSpacing : CGFloat
    public var rowToSectionFooterSpacing : CGFloat
    
    public var sectionHeadersPinToVisibleBounds : Bool
    
    public init(
        padding : UIEdgeInsets = .zero,
        width : WidthConstraint = .noConstraint,
        interSectionSpacingWithNoFooter : CGFloat = 0.0,
        interSectionSpacingWithFooter : CGFloat = 0.0,
        sectionHeaderBottomSpacing : CGFloat = 0.0,
        rowSpacing : CGFloat = 0.0,
        rowToSectionFooterSpacing : CGFloat = 0.0,
        sectionHeadersPinToVisibleBounds : Bool = false
    )
    {
        self.padding = padding
        self.width = width
        
        self.interSectionSpacingWithNoFooter = interSectionSpacingWithNoFooter
        self.interSectionSpacingWithFooter = interSectionSpacingWithFooter
        
        self.sectionHeaderBottomSpacing = sectionHeaderBottomSpacing
        self.rowSpacing = rowSpacing
        self.rowToSectionFooterSpacing = rowToSectionFooterSpacing
        
        self.sectionHeadersPinToVisibleBounds = sectionHeadersPinToVisibleBounds
    }

    public mutating func set(with block : (inout ListContentLayout) -> ())
    {
        var edited = self
        block(&edited)
        self = edited
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
