//
//  ListItemElement.swift
//  Listable
//
//  Created by Kyle Van Essen on 11/10/19.
//


public extension Item where Element == ListItemElement
{
    static func list<Identifier:Hashable>(identifier : Identifier, sizing : ListItemSizing, build : ListDescription.Build) -> Item<ListItemElement>
    {
        return Item(
            with: ListItemElement(identifier: identifier, build: build),
            sizing: sizing.toStandardSizing,
            layout: ItemLayout(width: .fill)
        )
    }
}


public enum ListItemSizing : Equatable
{
    case `default`
    case fixed(CGFloat)
    
    var toStandardSizing : Sizing {
        switch self {
        case .default: return .default
        case .fixed(let height): return .fixed(height)
        }
    }
}


public struct ListItemElement : ItemElement, ItemElementAppearance
{
    //
    // MARK: Public Properties
    //
    
    public var listDescription : ListDescription
    public var contentIdentifier : AnyHashable
    
    //
    // MARK: Initialization
    //
    
    public init<Identifier:Hashable>(identifier : Identifier, build : ListDescription.Build)
    {
        self.contentIdentifier = AnyHashable(identifier)
        
        self.listDescription = ListDescription(
            animated: true,
            appearance: .init(),
            behavior: .init(),
            scrollInsets: .init(),
            build: build
        )
    }
    
    //
    // MARK: ItemElement
    //
    
    public typealias Appearance = ListItemElement
    
    public var identifier: Identifier<ListItemElement> {
        return .init(self.contentIdentifier)
    }
    
    public func apply(to view : Appearance.ContentView, for reason: ApplyReason, with info : ApplyItemElementInfo)
    {
        view.setProperties(with: self.listDescription)
    }
    
    public func wasUpdated(comparedTo other: ListItemElement) -> Bool
    {
        return true
    }
    
    //
    // MARK: ItemElementAppearance
    //
    
    public typealias ContentView = ListView
    
    public static func createReusableItemView(frame : CGRect) -> ListView
    {
        return ListView(frame: frame)
    }
    
    public func update(view: ListView, with position: ItemPosition) { }
    
    public func apply(to view: ListView, with info : ApplyItemElementInfo) {}
}
