//
//  ListLayoutType.swift
//  Listable
//
//  Created by Kyle Van Essen on 5/3/20.
//

import Foundation


public enum ListLayoutType : Equatable
{
    case list
    case grid
    
    case custom(Custom)
    
    public var layoutType : ListLayout.Type {
        switch self {
        case .list: return DefaultListLayout.self
        case .grid: return GridListLayout.self
        case .custom(let custom): return custom.layoutType
        }
    }
    
    public static func custom(_ layoutType : ListLayout.Type) -> Self
    {
        .custom(Custom(layoutType))
    }
    
    public struct Custom : Equatable
    {
        var layoutType : ListLayout.Type
        
        public init(_ layoutType : ListLayout.Type)
        {
            self.layoutType = layoutType
        }
        
        public static func == (lhs : Self, rhs : Self) -> Bool
        {
            ObjectIdentifier(lhs.layoutType) == ObjectIdentifier(rhs.layoutType)
        }
    }
}
