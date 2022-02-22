//
//  LocalizedStrings.swift
//  BlueprintUILists
//
//  Created by Alex Odawa on 22/02/2022.
//

import Foundation


struct LocalizedStrings {
    
    struct ReorderGesture{
        static var accessibilityLabel = NSLocalizedString("Reorder", comment: "Accessibility label for the reorder control on an item")
        static var accessibilityHint = NSLocalizedString("Double tap and hold, wait for the sound, then drag to rearrange.", comment: "Accessibility hint for the reorder control in an item")
        static var accessibilityMoveUp = NSLocalizedString("Move up", comment:"title for an accessibility action that will move a selected cell up one position in the list.")
        static var accessibilityMoveDown = NSLocalizedString("Move down", comment:"title for an accessibility action that will move a selected cell down one position in the list.")
    }
    
}

