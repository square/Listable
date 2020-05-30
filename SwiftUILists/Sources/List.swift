//
//  List.swift
//  SwiftUILists
//
//  Created by Kyle Van Essen on 10/22/19.
//


import Listable
import SwiftUI


@available(iOS 13.0, *)
public struct ListableList : UIViewRepresentable
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
    // MARK: UIViewRepresentable
    //
    
    public typealias UIViewType = ListView
    
    public func makeUIView(context: Context) -> ListView {
        ListView(frame: .zero, appearance: self.listDescription.appearance)
    }
    
    public func updateUIView(_ listView: ListView, context: Context) {
        listView.setProperties(with: self.listDescription)
    }
}
