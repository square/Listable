//
//  Item.swift
//  Listable
//
//  Created by Kyle Van Essen on 8/10/19.
//


public enum ItemPosition
{
    case single
    
    case first
    case middle
    case last
}


public protocol AnyItem : AnyItem_Internal
{
    var identifier : AnyIdentifier { get }
    
    var sizing : Sizing { get set }
    var layout : ItemLayout { get set }
    var selectionStyle : ItemSelectionStyle { get set }
    var swipeActions : SwipeActionsConfiguration? { get set }
    
    var reordering : Reordering? { get set }
}


public protocol AnyItem_Internal
{
    func anyWasMoved(comparedTo other : AnyItem) -> Bool
    func anyIsEquivalent(to other : AnyItem) -> Bool
    
    func newPresentationItemState(with dependencies : ItemStateDependencies) -> Any
}


public struct Item<Content:ItemContent> : AnyItem
{
    public var identifier : AnyIdentifier
    
    public var content : Content
    
    public var sizing : Sizing
    public var layout : ItemLayout
    
    public var selectionStyle : ItemSelectionStyle
    
    public var swipeActions : SwipeActionsConfiguration?

    public var reordering : Reordering?
        
    public typealias OnSelect = (Content) -> ()
    public var onSelect : OnSelect?
    
    public typealias OnDeselect = (Content) -> ()
    public var onDeselect : OnDeselect?
    
    public typealias OnDisplay = (Content) -> ()
    public var onDisplay : OnDisplay?
    
    public typealias OnEndDisplay = (Content) -> ()
    public var onEndDisplay : OnEndDisplay?
    
    internal let reuseIdentifier : ReuseIdentifier<Content>
    
    public var debuggingIdentifier : String? = nil
    
    //
    // MARK: Initialization
    //
    
    public typealias Build = (inout Item) -> ()
    
    public init(
        _ content : Content,
        build : Build
        )
    {
        self.init(content)
        
        build(&self)
    }
    
    public init(
        _ content : Content,
        sizing : Sizing? = nil,
        layout : ItemLayout? = nil,
        selectionStyle : ItemSelectionStyle? = nil,
        swipeActions : SwipeActionsConfiguration? = nil,
        reordering : Reordering? = nil,
        onDisplay : OnDisplay? = nil,
        onEndDisplay : OnEndDisplay? = nil,
        onSelect : OnSelect? = nil,
        onDeselect : OnDeselect? = nil
        )
    {
        self.content = content
                
        if let sizing = sizing {
            self.sizing = sizing
        } else if let sizing = content.defaultItemProperties.sizing {
            self.sizing = sizing
        } else {
            self.sizing = .thatFitsWith(.init(.atLeast(.default)))
        }
        
        if let layout = layout {
            self.layout = layout
        } else if let layout = content.defaultItemProperties.layout {
            self.layout = layout
        } else {
            self.layout = ItemLayout()
        }
        
        if let selectionStyle = selectionStyle {
            self.selectionStyle = selectionStyle
        } else if let selectionStyle = content.defaultItemProperties.selectionStyle {
            self.selectionStyle = selectionStyle
        } else {
            self.selectionStyle = .none
        }
        
        if let swipeActions = swipeActions {
            self.swipeActions = swipeActions
        } else if let swipeActions = content.defaultItemProperties.swipeActions {
            self.swipeActions = swipeActions
        } else {
            self.swipeActions = nil
        }
                
        self.reordering = reordering
                
        self.onDisplay = onDisplay
        self.onEndDisplay = onEndDisplay
        
        self.onSelect = onSelect
        self.onDeselect = onDeselect
        
        self.reuseIdentifier = ReuseIdentifier.identifier(for: Content.self)
        
        self.identifier = self.content.identifier.toAny
    }
    
    // MARK: AnyItem_Internal
    
    public func anyIsEquivalent(to other : AnyItem) -> Bool
    {
        guard let other = other as? Item<Content> else {
            return false
        }
        
        return self.content.isEquivalent(to: other.content)
    }
    
    public func anyWasMoved(comparedTo other : AnyItem) -> Bool
    {
        guard let other = other as? Item<Content> else {
            return true
        }
        
        return self.content.wasMoved(comparedTo: other.content)
    }
    
    public func newPresentationItemState(with dependencies : ItemStateDependencies) -> Any
    {
        PresentationState.ItemState(with: self, dependencies: dependencies)
    }
}


/// Allows specifying default properties to apply to an item when it is initialized,
/// if those values are not provided to the initializer.
/// Only non-nil values are used – if you do not want to provide a default value,
/// simply leave the property nil.
///
/// The order of precedence used when assigning values is:
/// 1) The value passed to the initializer.
/// 2) The value from `defaultItemProperties` on the contained `ItemContent`, if non-nil.
/// 3) A standard, default value.
///
public struct DefaultItemProperties<Content:ItemContent>
{
    public var sizing : Sizing?
    public var layout : ItemLayout?
    
    public var selectionStyle : ItemSelectionStyle?
    
    public var swipeActions : SwipeActionsConfiguration?
    
    public init(
        sizing : Sizing? = nil,
        layout : ItemLayout? = nil,
        selectionStyle : ItemSelectionStyle? = nil,
        swipeActions : SwipeActionsConfiguration? = nil
    ) {
        self.sizing = sizing
        self.layout = layout
        self.selectionStyle = selectionStyle
        self.swipeActions = swipeActions
    }
}


extension Item : SignpostLoggable
{
    var signpostInfo : SignpostLoggingInfo {
        SignpostLoggingInfo(
            identifier: self.debuggingIdentifier,
            instanceIdentifier: nil
        )
    }
}


public struct Reordering
{
    public var sections : Sections
    
    public typealias CanReorder = (Result) -> Bool
    public var canReorder : CanReorder?
    
    public typealias DidReorder = (Result) -> ()
    public var didReorder : DidReorder
    
    public init(
        sections : Sections = .same,
        canReorder : CanReorder? = nil,
        didReorder : @escaping DidReorder
    )
    {
        self.sections = sections
        self.canReorder = canReorder
        self.didReorder = didReorder
    }
    
    public enum Sections : Equatable
    {
        case same
    }
    
    public struct Result
    {
        public var fromSection : Section
        public var fromIndexPath : IndexPath
        
        public var toSection : Section
        public var toIndexPath : IndexPath
    }
}


public struct ItemLayout : Equatable
{
    public var itemSpacing : CGFloat?
    public var itemToSectionFooterSpacing : CGFloat?
    
    public var width : CustomWidth
    
    public init(
        itemSpacing : CGFloat? = nil,
        itemToSectionFooterSpacing : CGFloat? = nil,
        width : CustomWidth = .default
    )
    {
        self.itemSpacing = itemSpacing
        self.itemSpacing = itemSpacing
        self.width = width
    }
}


public struct ItemState : Equatable
{
    public init(isSelected : Bool, isHighlighted : Bool)
    {
        self.isSelected = isSelected
        self.isHighlighted = isHighlighted
    }
    
    public init(cell : UICollectionViewCell)
    {
        self.isSelected = cell.isSelected
        self.isHighlighted = cell.isHighlighted
    }
    
    public var isSelected : Bool
    public var isHighlighted : Bool
}


/// Controls the selection style and behavior of an item in a list.
public enum ItemSelectionStyle : Equatable
{
    /// The item is not selectable at all.
    case none
    
    /// The item is temporarily selectable. Once the user lifts their finger, the item is deselected.
    case tappable
    
    /// The item is persistently selectable. Once the user lifts their finger, the item is maintained.
    case selectable(isSelected : Bool)
    
    var isSelected : Bool {
        switch self {
        case .none: return false
        case .tappable: return false
        case .selectable(let selected): return selected
        }
    }
    
    var isSelectable : Bool {
        switch self {
        case .none: return false
        case .tappable: return true
        case .selectable(_): return true
        }
    }
}
