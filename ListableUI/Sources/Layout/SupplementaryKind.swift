//
//  SupplementaryKind.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 5/2/20.
//

import Foundation


// TODO: Rename to HeaderFooterKind, since even Decorations are "supplementary" views?
public enum SupplementaryKind : String, CaseIterable, Codable
{
    case listContainerHeader = "ListContainerHeader"
    case listHeader = "ListHeader"
    case listFooter = "ListFooter"
    
    case sectionHeader = "SectionHeader"
    case sectionFooter = "SectionFooter"
    
    // TODO: Convert to a decoration view eventually
    case overscrollFooter = "OverscrollFooter"
    
    func indexPath(in section : Int) -> IndexPath
    {
        switch self {
        case .listContainerHeader: return IndexPath(item: 0, section: 0)
        case .listHeader: return IndexPath(item: 0, section: 0)
        case .listFooter: return IndexPath(item: 0, section: 0)
            
        case .sectionHeader: return IndexPath(item: 0, section: section)
        case .sectionFooter: return IndexPath(item: 0, section: section)
            
        case .overscrollFooter: return IndexPath(item: 0, section: 0)
        }
    }
}
