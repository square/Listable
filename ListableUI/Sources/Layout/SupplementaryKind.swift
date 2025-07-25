//
//  SupplementaryKind.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 5/2/20.
//

import Foundation


// TODO: Rename to HeaderFooterKind, since even Decorations are "supplementary" views?
public enum SupplementaryKind : CaseIterable, Codable
{
    case listContainerHeader
    
    case listHeader
    case listFooter
    
    case sectionHeader
    case sectionFooter
    
    
    // TODO: Convert to a decoration view
    case overscrollFooter
    
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
