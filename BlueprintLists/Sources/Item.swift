//
//  Item.swift
//  BlueprintLists
//
//  Created by Kyle Van Essen on 10/22/19.
//

import BlueprintUI

import Listable


//
// MARK: Blueprint Elements
//

public protocol BlueprintItemElement : ItemElement where Appearance == BlueprintItemElementAppearance
{
    //
    // MARK: Creating Blueprint Element Representations (Required)
    //
    
    func element(with state : ItemState) -> BlueprintUI.Element
    
    //
    // MARK: Creating Background Blueprint Element Representations (Optional)
    //
    
    func backgroundElement(with state : ItemState) -> BlueprintUI.Element?
    func selectedBackgroundElement(with state : ItemState) -> BlueprintUI.Element?
}


//
// MARK: Creating Blueprint Items
//


public extension Listable.Item where Element : BlueprintItemElement
{
    init(
        _ element : Element,
        height : Height = .default,
        selection : ItemSelection = .notSelectable,
        swipeActions : SwipeActions? = nil,
        bind : CreateBinding? = nil,
        onDisplay : OnDisplay? = nil,
        onSelect : OnSelect? = nil,
        onDeselect : OnDeselect? = nil
        )
    {
        self.init(
            element,
            appearance: BlueprintItemElementAppearance(),
            height: height,
            selection: selection,
            swipeActions: swipeActions,
            bind: bind,
            onDisplay: onDisplay,
            onSelect: onSelect,
            onDeselect: onDeselect
        )
    }
}


//
// MARK: Applying Blueprint Elements
//

public extension BlueprintItemElement
{
    //
    // MARK: BlueprintItemElement
    //
    
    func backgroundElement(with state : ItemState) -> BlueprintUI.Element?
    {
        return nil
    }
    
    func selectedBackgroundElement(with state : ItemState) -> BlueprintUI.Element?
    {
        return nil
    }
    
    //
    // MARK: ItemElement
    //
    
    func apply(to view: Appearance.View, with state : ItemState, reason: ApplyReason)
    {
        view.content.element = self.element(with: state)
        
        let background = self.backgroundElement(with: state)
        let selectedBackground = self.selectedBackgroundElement(with: state)
        
        if background != nil {
            view.content.backgroundColor = .clear
        } else {
            view.content.backgroundColor = .white
        }
        
        view.background.element = background
        view.selectedBackground.element = selectedBackground != nil ? selectedBackground : background
    }
}


public struct BlueprintItemElementAppearance : ItemElementAppearance
{
    //
    // MARK: ItemElementAppearance
    //
    
    public typealias ContentView = BlueprintView
    public typealias BackgroundView = BlueprintView
    public typealias SelectedBackgroundView = BlueprintView
    
    public static func createReusableItemView() -> View
    {
        return ItemElementView(content: BlueprintView(), background: BlueprintView(), selectedBackground: BlueprintView())
    }
    
    public func update(view: View, with position: ItemPosition) {}
    
    public func apply(to view: View, with state : ItemState, previous: BlueprintItemElementAppearance?) {}
}
