//
//  SupplementaryKind.swift
//  Listable
//
//  Created by Kyle Van Essen on 5/2/20.
//

import Foundation


enum SupplementaryKind : String, CaseIterable
{
    case listHeader = "Listable.ListHeader"
    case listFooter = "Listable.ListFooter"
    
    case sectionHeader = "Listable.SectionHeader"
    case sectionFooter = "Listable.SectionFooter"
    
    case overscrollFooter = "Listable.OverscrollFooter"
        
    var zIndex : Int {
        switch self {
        case .listHeader: return 1
        case .listFooter: return 1
            
        case .sectionHeader: return 2
        case .sectionFooter: return 1
            
        case .overscrollFooter: return 1
        }
    }
    
    func indexPath(in section : Int) -> IndexPath
    {
        switch self {
        case .listHeader: return IndexPath(item: 0, section: 0)
        case .listFooter: return IndexPath(item: 0, section: 0)
            
        case .sectionHeader: return IndexPath(item: 0, section: section)
        case .sectionFooter: return IndexPath(item: 0, section: section)
            
        case .overscrollFooter: return IndexPath(item: 0, section: 0)
        }
    }
}
