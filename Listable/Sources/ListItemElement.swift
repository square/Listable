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
            ListItemElement(identifier: identifier, build: build),
            sizing: sizing.toStandardSizing,
            layout: ItemLayout(width: .fill)
        )
    }
}


public enum ListItemSizing : Equatable
{
    case `default`
    case fixed(width: CGFloat = 0.0, height : CGFloat = 0.0)
    
    var toStandardSizing : Sizing {
        switch self {
        case .default: return .default
        case .fixed(let w, let h): return .fixed(width: w, height: h)
        }
    }
}


public struct ListItemElement : ItemElement
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
            animatesChanges: true,
            layoutType: .list,
            appearance: .init(),
            behavior: .init(),
            autoScrollAction: .none,
            scrollInsets: .init(),
            accessibilityIdentifier: nil,
            debuggingIdentifier: nil,
            build: build
        )
    }
    
    //
    // MARK: ItemElement
    //
        
    public typealias ContentView = ListView
    
    public var identifier: Identifier<ListItemElement> {
        return .init(self.contentIdentifier)
    }
    
    public func apply(to views : ItemElementViews<Self>, for reason: ApplyReason, with info : ApplyItemElementInfo)
    {
        views.content.setProperties(with: self.listDescription)
    }
    
    public func isEquivalent(to other: ListItemElement) -> Bool
    {
        return false
    }
    
    public static func createReusableContentView(frame : CGRect) -> ListView
    {
        ListView(frame: frame)
    }
}
