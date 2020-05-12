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
    
    var layout : ItemLayout { get set }
    var selectionStyle : ItemSelectionStyle { get set }
    
    var reordering : Reordering? { get set }
    
    func elementEqual(to other : AnyItem) -> Bool
}


public protocol AnyItem_Internal
{
    func anyWasMoved(comparedTo other : AnyItem) -> Bool
    func anyIsEquivalent(to other : AnyItem) -> Bool
    
    func newPresentationItemState(in listView : ListView) -> Any
}


public struct Item<Element:ItemElement> : AnyItem
{
    public var identifier : AnyIdentifier
    
    public var element : Element
    
    public var sizing : Sizing
    public var layout : ItemLayout
    
    public var selectionStyle : ItemSelectionStyle
    
    public var swipeActions : SwipeActions?
    public var swipeActionsAppearance : Element.SwipeActionsAppearance?
    
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
    
    public typealias CreateBinding = (Element) -> Binding<Element>
    internal let bind : CreateBinding?
    
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
        sizing : Sizing = .thatFitsWith(.init(.atLeast(.default))),
        layout : ItemLayout = ItemLayout(),
        selectionStyle : ItemSelectionStyle = .none,
        swipeActions : SwipeActions? = nil,
        swipeActionsAppearance : Element.SwipeActionsAppearance? = nil,
        reordering : Reordering? = nil,
        bind : CreateBinding? = nil,
        onDisplay : OnDisplay? = nil,
        onEndDisplay : OnEndDisplay? = nil,
        onSelect : OnSelect? = nil,
        onDeselect : OnDeselect? = nil
        )
    {
        assert((swipeActions != nil) == (swipeActionsAppearance != nil),
               "A swipeActionsAppearance must be provided if swipeActions is provided")

        self.element = element
        
        self.sizing = sizing
        self.layout = layout
        
        self.selectionStyle = selectionStyle
        
        self.swipeActions = swipeActions
        self.swipeActionsAppearance = swipeActionsAppearance
        
        self.reordering = reordering
        
        self.bind = bind
        
        self.onDisplay = onDisplay
        self.onEndDisplay = onEndDisplay
        
        self.onSelect = onSelect
        self.onDeselect = onDeselect
        
        self.reuseIdentifier = ReuseIdentifier.identifier(for: Element.self)
        
        self.identifier = AnyIdentifier(self.element.identifier)
    }
    
    // MARK: AnyItem
    
    public func elementEqual(to other : AnyItem) -> Bool
    {
        guard let other = other as? Item<Element> else {
            return false
        }
        
        return self.elementEqual(to: other)
    }
    
    internal func elementEqual(to other : Item<Element>) -> Bool
    {
        return false
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
    
    public func newPresentationItemState(in listView : ListView) -> Any
    {
        return PresentationState.ItemState(with: self, listView: listView)
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


public extension Item where Element:Equatable
{
    func elementEqual(to other : Item<Element>) -> Bool
    {
        return self.element == other.element
    }
}


public extension Array where Element == AnyItem
{
    func elementsEqual(to other : [AnyItem]) -> Bool
    {
        if self.count != other.count {
            return false
        }
        
        let items = zip(self, other)
        
        return items.allSatisfy { both in
            both.0.elementEqual(to: both.1)
        }
    }
}
