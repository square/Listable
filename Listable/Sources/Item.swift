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
    var selection : ItemSelection { get set }
    
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
    public var appearance : Element.Appearance
    
    public var sizing : Sizing
    public var layout : ItemLayout
    
    public var selection : ItemSelection
    
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
    
    public typealias CreateBinding = (Element) -> Binding<Element>
    internal let bind : CreateBinding?
    
    public var debuggingIdentifier : String? = nil
    
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
        swipeActions : SwipeActionsConfiguration? = nil,
        reordering : Reordering? = nil,
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
        
        return self.element.isEquivalent(to: other.element) && self.appearance.isEquivalent(to: other.appearance)
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


public extension Item where Element.Appearance == Element
{
    init(
        with element : Element,
        sizing : Sizing = .default,
        layout : ItemLayout = ItemLayout(),
        selection : ItemSelection = .notSelectable,
        swipeActions : SwipeActionsConfiguration? = nil,
        reordering : Reordering? = nil,
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
            reordering: reordering,
            bind: bind,
            onDisplay: onDisplay,
            onEndDisplay: onEndDisplay,
            onSelect: onSelect,
            onDeselect: onDeselect
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
