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
    
    var selection : ItemSelection { get }
    
    func elementEqual(to other : AnyItem) -> Bool
}

public protocol AnyItem_Internal
{
    var layout : ItemLayout { get }
    
    func anyWasMoved(comparedTo other : AnyItem) -> Bool
    func anyWasUpdated(comparedTo other : AnyItem) -> Bool
    
    func newPresentationItemState() -> Any
}


public struct Item<Element:ItemElement> : AnyItem
{
    public var identifier : AnyIdentifier
    
    public var element : Element
    public var appearance : Element.Appearance
    
    public var sizing : Sizing
    public var layout : ItemLayout
    
    public var selection : ItemSelection
    
    public var swipeActions : SwipeActions?
        
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
    
    //
    // MARK: Initialization
    //
    
    public typealias Build = (inout Item) -> ()
    
    public init(
        with element : Element,
        appearance : Element.Appearance,
        build : Build
        )
    {
        self.init(with: element, appearance: appearance)
        
        build(&self)
    }
    
    public init(
        with element : Element,
        appearance : Element.Appearance,
        sizing : Sizing = .default,
        layout : ItemLayout = ItemLayout(),
        selection : ItemSelection = .notSelectable,
        swipeActions : SwipeActions? = nil,
        bind : CreateBinding? = nil,
        onDisplay : OnDisplay? = nil,
        onEndDisplay : OnEndDisplay? = nil,
        onSelect : OnSelect? = nil,
        onDeselect : OnDeselect? = nil
        )
    {
        self.element = element
        self.appearance = appearance
        
        self.sizing = sizing
        self.layout = layout
        
        self.selection = selection
        
        self.swipeActions = swipeActions
        
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
    
    public func anyWasUpdated(comparedTo other : AnyItem) -> Bool
    {
        guard let other = other as? Item<Element> else {
            return true
        }
        
        return self.element.wasUpdated(comparedTo: other.element)
    }
    
    public func anyWasMoved(comparedTo other : AnyItem) -> Bool
    {
        guard let other = other as? Item<Element> else {
            return true
        }
        
        return self.element.wasMoved(comparedTo: other.element)
    }
    
    public func newPresentationItemState() -> Any
    {
        return PresentationState.ItemState(self)
    }
}


public extension Item where Element.Appearance == Element
{
    init(
        with element : Element,
        sizing : Sizing = .default,
        layout : ItemLayout = ItemLayout(),
        selection : ItemSelection = .notSelectable,
        swipeActions : SwipeActions? = nil,
        bind : CreateBinding? = nil,
        onDisplay : OnDisplay? = nil,
        onEndDisplay : OnEndDisplay? = nil,
        onSelect : OnSelect? = nil,
        onDeselect : OnDeselect? = nil
        )
    {
        self.init(
            with: element,
            appearance: element,
            sizing: sizing,
            layout: layout,
            selection: selection,
            swipeActions: swipeActions,
            bind: bind,
            onDisplay: onDisplay,
            onEndDisplay: onEndDisplay,
            onSelect: onSelect,
            onDeselect: onDeselect
        )
    }
}


public struct ItemLayout : Equatable
{
    public var width : CustomWidth
    
    public init(width : CustomWidth = .default)
    {
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


public enum ItemSelection : Equatable
{
    case notSelectable
    case isSelectable(isSelected : Bool)
    
    public var isSelected : Bool {
        switch self {
        case .notSelectable: return false
        case .isSelectable(let selected): return selected
        }
    }
    
    public var isSelectable : Bool {
        switch self {
        case .notSelectable: return false
        case .isSelectable(_): return true
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
