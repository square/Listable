//
//  List.ContentContext.swift
//  BlueprintUILists
//
//  Created by Kyle Van Essen on 6/10/22.
//

import BlueprintUI
import ListableUI


public enum ListContentContextKey : EnvironmentKey {
    public static let defaultValue: ContentContext? = nil
}


extension Environment {
    
    public var listContentContext : ContentContext? {
        get { self[ListContentContextKey.self] }
        set { self[ListContentContextKey.self] = newValue }
    }
}


