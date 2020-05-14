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
        self.listDescription = ListDescription(
            animatesChanges: UIView.inheritedAnimationDuration > 0.0,
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
    // MARK: BlueprintUI.Element
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
                ListView(frame: bounds, appearance: self.listDescription.appearance)
            }
            
            config.apply { listView in
                listView.setProperties(with: self.listDescription)
            }
        }
    }
}

