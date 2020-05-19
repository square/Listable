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


public struct Item<Element:ItemElement> : AnyItem
{
    public var identifier : AnyIdentifier
    
    public var element : Element
    
    public var sizing : Sizing
    public var layout : ItemLayout
    
    public var selectionStyle : ItemSelectionStyle
    
    public var swipeActions : SwipeActionsConfiguration?

    public var reordering : Reordering?
        
    public typealias OnSelect = (Element) -> ()
    public var onSelect : OnSelect?
    
    public typealias OnDeselect = (Element) -> ()
    public var onDeselect : OnDeselect?
    
    public typealias OnDisplay = (Element) -> ()
    public var onDisplay : OnDisplay?
    
    public typealias OnEndDisplay = (Element) -> ()
    public var onEndDisplay : OnEndDisplay?
    
    internal let reuseIdentifier : ReuseIdentifier<Element>
    
    public var debuggingIdentifier : String? = nil
    
    //
    // MARK: Initialization
    //
    
    public typealias Build = (inout Item) -> ()
    
    public init(
        _ element : Element,
        build : Build
        )
    {
        self.init(element)
        
        build(&self)
    }
    
    public init(
        _ element : Element,
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
        self.element = element
                
        if let sizing = sizing {
            self.sizing = sizing
        } else if let sizing = element.defaultItemProperties.sizing {
            self.sizing = sizing
        } else {
            self.sizing = .thatFitsWith(.init(.atLeast(.default)))
        }
        
        if let layout = layout {
            self.layout = layout
        } else if let layout = element.defaultItemProperties.layout {
            self.layout = layout
        } else {
            self.layout = ItemLayout()
        }
        
        if let selectionStyle = selectionStyle {
            self.selectionStyle = selectionStyle
        } else if let selectionStyle = element.defaultItemProperties.selectionStyle {
            self.selectionStyle = selectionStyle
        } else {
            self.selectionStyle = .none
        }
        
        if let swipeActions = swipeActions {
            self.swipeActions = swipeActions
        } else if let swipeActions = element.defaultItemProperties.swipeActions {
            self.swipeActions = swipeActions
        } else {
            self.swipeActions = nil
        }
                
        self.reordering = reordering
                
        self.onDisplay = onDisplay
        self.onEndDisplay = onEndDisplay
        
        self.onSelect = onSelect
        self.onDeselect = onDeselect
        
        self.reuseIdentifier = ReuseIdentifier.identifier(for: Element.self)
        
        self.identifier = AnyIdentifier(self.element.identifier)
    }
    
    // MARK: AnyItem_Internal
    
    public func anyIsEquivalent(to other : AnyItem) -> Bool
    {
        guard let other = other as? Item<Element> else {
            return false
        }
        
        return self.element.isEquivalent(to: other.element)
    }
    
    public func anyWasMoved(comparedTo other : AnyItem) -> Bool
    {
        guard let other = other as? Item<Element> else {
            return true
        }
        
        return self.element.wasMoved(comparedTo: other.element)
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
/// 2) The value from `ItemProperties` on the contained `ItemElement`, if non-nil.
/// 3) A standard, default value.
///
public struct DefaultItemProperties<Element:ItemElement>
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
