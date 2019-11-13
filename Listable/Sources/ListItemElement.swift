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
    
    public func apply(to view: Appearance.View, with state: ItemState, reason: ApplyReason)
    {
        view.content.setProperties(with: self.listDescription, animated: true)
    }
    
    public func wasUpdated(comparedTo other: ListItemElement) -> Bool
    {
        return true
    }
    
    //
    // MARK: ItemElementAppearance
    //
    
    public typealias ContentView = ListView
    public typealias BackgroundView = UIView
    public typealias SelectedBackgroundView = UIView
    
    public static func createReusableItemView(frame : CGRect) -> ItemElementView<ListView, UIView, UIView>
    {
        return ItemElementView(content: ListView(frame: frame), background: UIView(), selectedBackground: UIView())
    }
    
    public func update(view: ItemElementView<ListView, UIView, UIView>, with position: ItemPosition) { }
    
    public func apply(to view: ItemElementView<ListView, UIView, UIView>, with state: ItemState, previous: ListItemElement.Appearance?) {}
}
