//
//  List.swift
//  BlueprintLists
//
//  Created by Kyle Van Essen on 10/22/19.
//

import BlueprintUI

import Listable
import ListableCore


public struct List : BlueprintUI.Element
{
    public var appearance : Appearance
    public var listContent : Content
    
    //
    // MARK: Initialization
    //
    
    public init(appearance : Appearance = Appearance(), _ builder : ContentBuilder.Build)
    {
        self.appearance = appearance
        
        self.listContent = ContentBuilder.build(with: builder)
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
                return ListView(frame: .zero, appearance: self.appearance)
            }
            
            config.apply { listView in
                listView.appearance = self.appearance
                listView.setContent(animated: true, self.listContent)
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
