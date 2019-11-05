//
//  Elements.swift
//  Listable
//
//  Created by Kyle Van Essen on 6/21/19.
//



public struct Content
{
    //
    // MARK: Content Data
    //
    
    public var selectionMode : SelectionMode
    
    public enum SelectionMode : Equatable
    {
        case none, single, multiple
    }

    public var refreshControl : RefreshControl?
    
    public var header : AnyHeaderFooter?
    public var footer : AnyHeaderFooter?
    
    public var sections : [Section]
    
    public var itemCount : Int {
        return self.sections.reduce(0, { $0 + $1.items.count })
    }
    
    //
    // MARK: Initialization
    //
    
    public init(
        selectionMode : SelectionMode = .single,
        refreshControl : RefreshControl? = nil,
        header : AnyHeaderFooter? = nil,
        footer : AnyHeaderFooter? = nil,
        sections : [Section] = []
        )
    {
        self.selectionMode = selectionMode
        
        self.refreshControl = refreshControl
        
        self.header = header
        self.footer = footer
        
        self.sections = sections
    }
    
    //
    // MARK: Finding & Mutating Content
    //
    
    public func item(at indexPath : IndexPath) -> AnyItem
    {
        let section = self.sections[indexPath.section]
        let item = section.items[indexPath.item]
        
        return item
    }
    
    mutating func remove(at indexPath : IndexPath)
    {
        self.sections[indexPath.section].items.remove(at: indexPath.item)
    }
    
    public func indexPath(for identifier : AnyIdentifier) -> IndexPath?
    {
        for (sectionIndex, section) in self.sections.enumerated() {
            for (itemIndex, item) in section.items.enumerated() {
                if item.identifier == identifier {
                    return IndexPath(item: itemIndex, section: sectionIndex)
                }
            }
        }
        
        return nil
    }
    
    //
    // MARK: Slicing Content
    //
    
    internal func sliceTo(indexPath : IndexPath, plus additionalItems : Int) -> Slice
    {
        var sliced = self
        
        var remaining : Int = indexPath.item + additionalItems
        
        sliced.sections = self.sections.compactMapWithIndex { sectionIndex, section in
            if sectionIndex < indexPath.section {
                return section
            } else {
                guard remaining > 0 else {
                    return nil
                }
                
                var section = section
                section.items = section.itemsUpTo(limit: remaining)
                remaining -= section.items.count
                
                return section
            }
        }
        
        return Slice(
            containsAllItems: self.itemCount == sliced.itemCount,
            content: sliced
        )
    }
}


public extension Content
{
    func elementsEqual(to other : Content) -> Bool
    {
        if self.sections.count != other.sections.count {
            return false
        }
        
        let sections = zip(self.sections, other.sections)
        
        return sections.allSatisfy { both in
            both.0.elementsEqual(to: both.1)
        }
    }
}


internal extension Content
{
    struct Slice
    {
        static let defaultSize : Int = 250
        
        let containsAllItems : Bool
        var content : Content
        
        init(containsAllItems : Bool, content : Content)
        {
            self.containsAllItems = containsAllItems
            self.content = content
        }
        
        init()
        {
            self.containsAllItems = true
            self.content = Content()
        }
        
        enum UpdateReason : Equatable
        {
            case scrolledDown
            case didEndDecelerating
            
            case scrolledToTop
            
            case contentChanged(animated : Bool)
            
            case transitionedToBounds(isEmpty : Bool)
            
            case programaticScrollDownTo(IndexPath)
        
            var animated : Bool {
                switch self {
                case .scrolledDown: return false
                case .didEndDecelerating: return false
                case .scrolledToTop: return false
                    
                case .contentChanged(let animated): return animated
                    
                case .transitionedToBounds(_): return false
                    
                case .programaticScrollDownTo(_): return false
                }
            }
        }
    }
}


private extension Array
{
    func compactMapWithIndex<Mapped>(_ block : (Int, Element) -> Mapped?) -> [Mapped]
    {
        var mapped = [Mapped]()
        mapped.reserveCapacity(self.count)
        
        for (index, element) in self.enumerated() {
            if let value = block(index, element) {
                mapped.append(value)
            }
        }
        
        return mapped
    }
}
