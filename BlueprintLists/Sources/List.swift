//
//  List.swift
//  BlueprintLists
//
//  Created by Kyle Van Essen on 10/22/19.
//

import BlueprintUI

import Listable


public struct List : Element
{
    /// The values which back the on-screen list.
    public var properties : ListProperties
    
    //
    // MARK: Initialization
    //
        
    /// Create a new list with the provided options.
    public init(build : ListProperties.Build)
    {
        self.properties = ListProperties(
            animatesChanges: UIView.inheritedAnimationDuration > 0.0,
            layout: .list(),
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
    // MARK: Element
    //
    
    public var content : ElementContent {
        ElementContent { constraint in
            constraint.maximum
        }
    }
    
    public func backingViewDescription(bounds: CGRect, subtreeExtent: CGRect?) -> ViewDescription?
    {
        ListView.describe { config in
            config.builder = {
                ListView(frame: bounds, appearance: self.properties.appearance)
            }
            
            config.apply { listView in
                listView.setProperties(with: self.properties)
            }
        }
    }
}

