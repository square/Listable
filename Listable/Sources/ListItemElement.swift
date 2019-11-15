//
//  ListItemElement.swift
//  Listable
//
//  Created by Kyle Van Essen on 11/10/19.
//


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
        
        self.listDescription = ListDescription(build: build)
    }
    
    //
    // MARK: ItemElement
    //
    
    public typealias Appearance = ListItemElement
    
    public var identifier: Identifier<ListItemElement> {
        return .init(self.contentIdentifier)
    }
    
    public func apply(to view: ContentView, with state: ItemState, reason: ApplyReason)
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
    
    public func apply(to view: ListView, with state: ItemState, previous: ListItemElement.Appearance?) {}
}
