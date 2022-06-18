//
//  List.ContentContext.swift
//  BlueprintUILists
//
//  Created by Kyle Van Essen on 6/10/22.
//

import BlueprintUI
import ListableUI


extension Environment {
    
    /// Applies the provided `ContentContext` to the list when it's updated by Blueprint.
    ///
    /// See `ContentContext` for more information.
    public var listContentContext : ContentContext? {
        get { self[ListContentContextKey.self] }
        set { self[ListContentContextKey.self] = newValue }
    }
}


public enum ListContentContextKey : EnvironmentKey {
    public static let defaultValue: ContentContext? = nil
}
