//
//  Content.swift
//  Listable
//
//  Created by Kyle Van Essen on 6/21/19.
//



public struct Content
{
    //
    // MARK: Content Data
    //
    
    /// The identifier for the content, defaults to nil.
    /// You don't need to set this value – but if you do, and change it to another value,
    /// the list will reload without animation.
    public var identifier : AnyHashable?

    /// The refresh control, if any, associated with the list.
    public var refreshControl : RefreshControl?
    
    /// The header for the list, usually displayed before all other content.
    public var header : AnyHeaderFooter?
    /// The footer for the list, usually displayed after all other content.
    public var footer : AnyHeaderFooter?
    
    /// The overscroll footer for the list, which is displayed below the bottom bounds of the visible frame,
    /// so it is only visible if the user manually scrolls the list up to make it visible.
    public var overscrollFooter : AnyHeaderFooter?
    
    /// All sections in the list.
    public var sections : [Section]
    
    /// Any sections that have a non-zero number of items.
    public var nonEmptySections : [Section] {
        self.sections.filter { $0.items.isEmpty == false }
    }
    
    /// The total number of items in all of the sections in the list.
    public var itemCount : Int {
        return self.sections.reduce(0, { $0 + $1.items.count })
    }
    
    /// Check if the content contains any of the given types, which you specify via the `filters`
    /// parameter. If you do not specify a `filters` parameter, `[.items]` is used.
    public func contains(any filters : Set<ContentFilters> = [.items]) -> Bool {
        
        for filter in filters {
            switch filter {
            case .listHeader:
                if self.header != nil {
                    return true
                }
            case .listFooter:
                if self.footer != nil {
                    return true
                }
            case .overscrollFooter:
                if self.overscrollFooter != nil {
                    return true
                }
                
            case .sectionHeaders: break
            case .sectionFooters: break
            case .items: break
            }
        }
        
        for section in self.sections {
            if section.contains(any: filters) {
                return true
            }
        }
        
        return false
    }
    
    //
    // MARK: Initialization
    //
    
    public typealias Build = (inout Content) -> ()
    
    public init(with build : Build)
    {
        self.init()
        
        build(&self)
    }
    
    public init(
        identifier : AnyHashable? = nil,
        refreshControl : RefreshControl? = nil,
        header : AnyHeaderFooter? = nil,
        footer : AnyHeaderFooter? = nil,
        overscrollFooter : AnyHeaderFooter? = nil,
        sections : [Section] = []
        )
    {
        self.identifier = identifier
        
        
        self.refreshControl = refreshControl
        
        self.header = header
        self.footer = footer
        
        self.overscrollFooter = overscrollFooter
        
        self.sections = sections
    }
    
    //
    // MARK: Finding Content
    //
    
    public var firstItem : AnyItem? {
        guard let first = self.nonEmptySections.first?.items.first else {
            return nil
        }
        
        return first
    }
    
    public var lastItem : AnyItem? {
        guard let last = self.nonEmptySections.last?.items.last else {
            return nil
        }
        
        return last
    }
    
    public func item(at indexPath : IndexPath) -> AnyItem
    {
        let section = self.sections[indexPath.section]
        let item = section.items[indexPath.item]
        
        return item
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

    /// Returns the true last index path of the content, while the one in PresentationState
    /// is the last index of the loaded content.
    public func lastIndexPath() -> IndexPath?
    {
        guard let lastSectionIndexWithItems = sections.lastIndex(where: { !$0.items.isEmpty }) else {
            return nil
        }

        return IndexPath(
            item: sections[lastSectionIndexWithItems].items.count,
            section: lastSectionIndexWithItems
        )
    }
    
    //
    // MARK: Mutating Content
    //
    
    mutating func moveItem(from : IndexPath, to : IndexPath)
    {
        guard from != to else {
            return
        }
        
        let item = self.item(at: from)
        
        self.remove(at: from)
        self.insert(item: item, at: to)
    }
    
    public mutating func removeEmpty()
    {
        self.sections.removeAll {
            $0.items.isEmpty
        }
    }
    
    public mutating func add(_ section : Section)
    {
        self.sections.append(section)
    }
    
    public static func += (lhs : inout Content, rhs : Section)
    {
        lhs.add(rhs)
    }
    
    public static func += (lhs : inout Content, rhs : [Section])
    {
        lhs.sections += rhs
    }
    
    /// Allows streamlined creation of sections when building a list.
    ///
    /// Example
    /// -------
    /// ```
    /// listView.configure { list in
    ///     list("section-id") { section in
    ///         ...
    ///     }
    /// }
    /// ```
    public mutating func callAsFunction<Identifier:Hashable>(_ identifier : Identifier, build : Section.Build)
    {
        self += Section(identifier, build: build)
    }
    
    internal mutating func remove(at indexPath : IndexPath)
    {
        self.sections[indexPath.section].items.remove(at: indexPath.item)
    }
    
    internal mutating func insert(item : AnyItem, at indexPath : IndexPath)
    {
        self.sections[indexPath.section].items.insert(item, at: indexPath.item)
    }
    
    //
    // MARK: Slicing Content
    //
    
    internal func sliceTo(indexPath : IndexPath, plus additionalItems : Int = Content.Slice.defaultCount) -> Slice
    {
        var sliced = self
        
        var remaining : Int = indexPath.item + additionalItems
        
        sliced.sections = self.sections.compactMapWithIndex { sectionIndex, _, section in
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


internal extension Content
{
    struct Slice
    {
        static let defaultCount : Int = 250
        
        let containsAllItems : Bool
        let content : Content
        
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
    }
}
