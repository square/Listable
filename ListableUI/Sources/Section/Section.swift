//
//  Section.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 8/10/19.
//


public struct Section
{
    //
    // MARK: Public Properties
    //
    
    /// The value which uniquely identifies the section within a list.
    public var identifier : Identifier<Section, AnyHashable>
    
    /// The header, if any, associated with the section.
    public var header : AnyHeaderFooter?
    
    /// The footer, if any, associated with the section.
    public var footer : AnyHeaderFooter?
    
    /// The items, if any, associated with the section.
    public var items : [AnyItem]
    
    /// Controls re-ordering options when items are moved in or out of the section.
    public var reordering : SectionReordering
    
    /// Check if the section contains any of the given types, which you specify via the `filters`
    /// parameter. If you do not specify a `filters` parameter, `[.items]` is used.
    public func contains(any filters : Set<ContentFilters> = [.items]) -> Bool {
        
        for filter in filters {
            switch filter {
            case .listHeader: break
            case .listFooter: break
            case .overscrollFooter: break
                
            case .sectionHeaders:
                if self.header != nil {
                    return true
                }
            case .sectionFooters:
                if self.footer != nil {
                    return true
                }
            case .items:
                if items.isEmpty == false {
                    return true
                }
            }
        }
        
        return false
    }
    
    /// The number of ``Item``s within the section.
    public var count : Int {
        self.items.count
    }
    
    //
    // MARK: Layout Specific Parameters
    //
    
    public var layouts : SectionLayouts = .init()
    
    //
    // MARK: Initialization
    //
    
    public typealias Configure = (inout Section) -> ()
    
    public init<IdentifierType:Hashable>(
        _ identifier : IdentifierType,
        layouts : SectionLayouts = .init(),
        header : AnyHeaderFooter? = nil,
        footer : AnyHeaderFooter? = nil,
        reordering : SectionReordering = .init(),
        items : [AnyItem] = [],
        configure : Configure = { _ in }
        )
    {
        self.identifier = Identifier(identifier)
        
        self.layouts = layouts
        
        self.header = header
        self.footer = footer
        
        self.reordering = reordering
        
        self.items = items
        
        configure(&self)
    }
    
    //
    // MARK: Reading Items
    //
    
    /// Returns the content of the section, converted back to the provided type,
    /// stripping any content which does not conform to the given type.
    ///
    /// You usually use this method as part of committing a reorder event, in order to read
    /// the identifiers (or other properties), off of your items in order to commit the reorder
    /// event to your backing data store.
    /// ```swift
    /// item.onWasReordered = { item, reorder in
    ///     let items = reorder.toSection.filtered(to: MyContent.self)
    ///     controller.setItemOrders(with: items.map(\.content.model))
    /// }
    /// ```
    public func filtered<Content>(to: Content.Type) -> [Content] {
        self.items.compactMap { item in
            item.anyContent as? Content ?? nil
        }
    }
    
    /// Provides the content of the section, converted back to the provided type,
    /// stripping any content which does not conform to the given type.
    ///
    /// You usually use this method as part of committing a reorder event, in order to read
    /// the identifiers (or other properties), off of your items in order to commit the reorder
    /// event to your backing data store.
    /// ```swift
    /// item.onWasReordered = { item, reorder in
    ///     reorder.toSection.filtered(to: MyContent.self) { items in
    ///         controller.setItemOrders(with: items.map(\.content.model))
    ///     }
    /// }
    /// ```
    public func filtered<Content>(to: Content.Type, _ read : ([Content]) -> ()) {
        read(self.filtered(to: Content.self))
    }
    
    //
    // MARK: Adding & Removing Single Items
    //
    
    public mutating func add(_ item : AnyItem)
    {
        self.items.append(item)
    }
    
    public static func += (lhs : inout Section, rhs : AnyItem)
    {
        lhs.add(rhs)
    }
    
    public static func += <Content:ItemContent>(lhs : inout Section, rhs : Item<Content>)
    {
        lhs.add(rhs)
    }
    
    public static func += <Content:ItemContent>(lhs : inout Section, rhs : Content)
    {
        lhs += Item(rhs)
    }
    
    //
    // MARK: Adding & Removing Multiple Items
    //
    
    public static func += (lhs : inout Section, rhs : [AnyItem])
    {
        lhs.items += rhs
    }
    
    public static func += <Content:ItemContent>(lhs : inout Section, rhs : [Item<Content>])
    {
        lhs.items += rhs
    }
    
    public static func += <Content:ItemContent>(lhs : inout Section, rhs : [Content])
    {
        lhs.items += rhs.map { Item($0) }
    }
    
    //
    // MARK: Slicing
    //
    
    internal func itemsUpTo(limit : Int) -> [AnyItem]
    {
        let end = min(self.items.count, limit)
        
        return Array(self.items[0..<end])
    }
}


public extension Section {
    
    /// Provides a new identifier for a ``Section``, with the given underlying value.
    static func identifier<Value:Hashable>(for value : Value) -> Identifier<Section, AnyHashable> {
        Identifier(value)
    }
}
