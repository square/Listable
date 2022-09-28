//
//  ItemSelectionStyle.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 12/14/20.
//

import Foundation


/// Controls the selection style and behavior of an item in a list.
public enum ItemSelectionStyle : Equatable
{
    /// The item is not selectable at all.
    case notSelectable
    
    /// The item is temporarily selectable. Once the user lifts their finger, the item is deselected.
    case tappable
    
    /// The item is persistently selectable. Once the user lifts their finger, the item is maintained.
    case selectable(isSelected : Bool = false)
    
    /// The item is persistently selectable. Once the user lifts their finger, the item is maintained.
    /// If the user taps again, the item will be deselected.
    case toggles(isSelected : Bool = false)
    
    var isSelected : Bool {
        switch self {
        case .notSelectable: return false
        case .tappable: return false
        case .selectable(let selected): return selected
        case .toggles(let selected): return selected
        }
    }
    
    var isSelectable : Bool {
        switch self {
        case .notSelectable: return false
        case .tappable: return true
        case .selectable: return true
        case .toggles: return true
        }
    }
}
