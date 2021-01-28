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
    
    /// Data backing the identity and updates to the section – for example
    /// if the section has been moved, plus the identifier for the section's content.
    public var info : AnySectionInfo
    
    /// The header, if any, associated with the section.
    public var header : AnyHeaderFooter?
    
    /// The footer, if any, associated with the section.
    public var footer : AnyHeaderFooter?
    
    /// The items, if any, associated with the section.
    public var items : [AnyItem]
    
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
    
    //
    // MARK: Layout Specific Parameters
    //
    
    public var layouts : SectionLayouts = .init()
    
    //
    // MARK: Initialization
    //
    
    public typealias Configure = (inout Section) -> ()
        
    public init<Info:SectionInfo>(
        _ info: Info,
        configure : Configure
        )
    {
        self.init(info)
        
        configure(&self)
    }
    
    public init<Identifier:Hashable>(
        _ identifier : Identifier,
        layouts : SectionLayouts = .init(),
        header : AnyHeaderFooter? = nil,
        footer : AnyHeaderFooter? = nil,
        items : [AnyItem] = [],
        configure : Configure = { _ in }
        )
    {
        self.init(
            HashableSectionInfo(identifier),
            header: header,
            footer: footer,
            items: items,
            configure: configure
        )
    }
    
    public init<Info:SectionInfo>(
        _ info: Info,
        layouts : SectionLayouts = .init(),
        header : AnyHeaderFooter? = nil,
        footer : AnyHeaderFooter? = nil,
        items : [AnyItem] = [],
        configure : Configure = { _ in }
        )
    {
        self.info = info
        
        self.layouts = layouts
        
        self.header = header
        self.footer = footer
        
        self.items = items
        
        configure(&self)
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


public protocol SectionInfo : AnySectionInfo
{
    //
    // MARK: Identifying Content & Changes
    //
    
    var identifier : Identifier<Self> { get }
    
    func wasMoved(comparedTo other : Self) -> Bool
}


public protocol AnySectionInfo
{
    //
    // MARK: Identifying Content & Changes
    //
    
    var anyIdentifier : AnyIdentifier { get }
    
    func anyWasMoved(comparedTo other : AnySectionInfo) -> Bool
}


public extension SectionInfo
{
    var anyIdentifier : AnyIdentifier {
        self.identifier
    }
    
    func anyWasMoved(comparedTo other : AnySectionInfo) -> Bool
    {
        guard let other = other as? Self else {
            return true
        }
        
        return self.wasMoved(comparedTo: other)
    }
}


private struct HashableSectionInfo<Value:Hashable> : SectionInfo
{
    var value : Value
    
    init(_ value : Value)
    {
        self.value = value
    }
    
    // MARK: SectionInfo
    
    var identifier : Identifier<HashableSectionInfo> {
        return .init(self.value)
    }
    
    func wasMoved(comparedTo other : HashableSectionInfo) -> Bool
    {
        return self.value != other.value
    }
}
