//
//  ListEnvironment+Blueprint.swift
//  BlueprintUILists
//
//  Created by Kyle Van Essen on 10/27/20.
//


extension ListEnvironment {
    
    var blueprintEnvironment : Environment {
        get { self[BlueprintKey.self] }
        set { self[BlueprintKey.self] = newValue }
    }
    
    private enum BlueprintKey : ListEnvironmentKey {
        
        static var defaultValue : Environment {
            .empty
        }
    }
}
