//
//  List.swift
//  BlueprintLists
//
//  Created by Kyle Van Essen on 10/22/19.
//

import BlueprintUI

import Listable


public struct List : BlueprintUI.Element
{
    public var listDescription : ListDescription
    
    //
    // MARK: Initialization
    //
        
    public init(build : ListDescription.Build)
    {
        self.listDescription = ListDescription(appearance: .init(), behavior: .init(), scrollInsets: .init(), build: build)
    }
    
    //
    // MARK: BlueprintUI.Element
    //
    
    public var content : ElementContent {
        return ElementContent(layout: Layout())
    }
    
    public func backingViewDescription(bounds: CGRect, subtreeExtent: CGRect?) -> ViewDescription?
    {
        return ListView.describe { config in
            config.builder = {
                return ListView(frame: bounds, appearance: self.listDescription.appearance)
            }
            
            config.apply { listView in
                listView.setProperties(with: self.listDescription, animated: true)
            }
        }
    }
    
    //
    // MARK: Blueprint Layout Definition
    //
    
    private struct Layout : BlueprintUI.Layout
    {
        func measure(in constraint: SizeConstraint, items: [(traits: (), content: Measurable)]) -> CGSize
        {
            return constraint.maximum
        }
        
        func layout(size: CGSize, items: [(traits: (), content: Measurable)]) -> [LayoutAttributes]
        {
            return []
        }
    }
}

