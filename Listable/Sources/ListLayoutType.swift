//
//  ListLayoutType.swift
//  Listable
//
//  Created by Kyle Van Essen on 5/2/20.
//

import Foundation

/**
 The type of layout to use to draw and lay out the list.
 
 WARNING
 -------
 This is still highly experimental, and the layout API is in the process of being teased out
 from the core collection view implementation. As such, you should **really** only be using
 the `.list` type here. Doing otherwise is unsupported and will likely break or crash.
 */
public enum ListLayoutType : Equatable
{
    case list
    case grid

    case experimental(Custom)
    
    public static func experimental(_ type : ListLayout.Type) -> ListLayoutType {
        .experimental(.init(type))
    }
    
    public var layoutType : ListLayout.Type {
        switch self {
        case .list: return DefaultListLayout.self
        case .grid: fatalError() //return GridListLayout.self
        case .experimental(let custom): return custom.type
        }
    }
    
    public struct Custom : Equatable {
        public var type : ListLayout.Type
        
        public init(_ type : ListLayout.Type) {
            self.type = type
        }
        
        public static func == (lhs : Self, rhs : Self) -> Bool {
            ObjectIdentifier(lhs.type) == ObjectIdentifier(rhs.type)
        }
    }
}
