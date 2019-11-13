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
    private static let minHeightValue : CGFloat = 1.0
    
    public var itemHeight : CGFloat {
        willSet {
            precondition(newValue >= ListSizing.minHeightValue)
        }
    }
    
    public var sectionHeaderHeight : CGFloat {
        willSet {
            precondition(newValue >= ListSizing.minHeightValue)
        }
    }
    
    public var sectionFooterHeight : CGFloat {
        willSet {
            precondition(newValue >= ListSizing.minHeightValue)
        }
    }
    
    public var listHeaderHeight : CGFloat {
        willSet {
            precondition(newValue >= ListSizing.minHeightValue)
        }
    }
    
    public var listFooterHeight : CGFloat {
        willSet {
            precondition(newValue >= ListSizing.minHeightValue)
        }
    }
        
    public init(
        itemHeight : CGFloat = 50.0,
        sectionHeaderHeight : CGFloat = 60.0,
        sectionFooterHeight : CGFloat = 40.0,
        listHeaderHeight : CGFloat = 60.0,
        listFooterHeight : CGFloat = 60.0
    )
    {
        precondition(itemHeight >= ListSizing.minHeightValue)
        precondition(sectionHeaderHeight >= ListSizing.minHeightValue)
        precondition(sectionFooterHeight >= ListSizing.minHeightValue)
        precondition(listHeaderHeight >= ListSizing.minHeightValue)
        precondition(listFooterHeight >= ListSizing.minHeightValue)
        
        self.itemHeight = itemHeight
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
        with viewSize : CGSize,
        padding : UIEdgeInsets,
        constraint : WidthConstraint,
        layoutDirection : LayoutDirection
    ) -> CGFloat
    {
        let paddedWidth : CGFloat = {
            let viewWidth = layoutDirection.width(for: viewSize)
            
            switch layoutDirection {
            case .vertical: return viewWidth - padding.left - padding.right
            case .horizontal: return viewWidth - padding.top - padding.bottom
            }
        }()
        
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

