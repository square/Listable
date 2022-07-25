//
//  LocalizedStrings.swift
//  BlueprintUILists
//
//  Created by Alex Odawa on 22/02/2022.
//

import Foundation

public enum ListableLocalizedStrings {
    public enum ReorderGesture {
        public static let accessibilityLabel = NSLocalizedString("reorder.AccessibilityLabel",
                                                                 tableName: nil,
                                                                 bundle: .listableUIResources,
                                                                 value: "Reorder",
                                                                 comment: "Accessibility label for the reorder control on an item")

        public static let accessibilityHint = NSLocalizedString("reorder.AccessibilityHint",
                                                                tableName: nil,
                                                                bundle: .listableUIResources,
                                                                value: "Double tap and hold, wait for the sound, then drag to rearrange.",
                                                                comment: "Accessibility hint for the reorder control in an item")

        public static let accessibilityMoveUp = NSLocalizedString("reorder.AccessibilityAction.MoveUp",
                                                                  tableName: nil,
                                                                  bundle: .listableUIResources,
                                                                  value: "Move up",
                                                                  comment: "title for an accessibility action that will move a selected cell up one position in the list.")

        public static let accessibilityMoveDown = NSLocalizedString("reorder.AccessibilityAction.MoveDown",
                                                                    tableName: nil,
                                                                    bundle: .listableUIResources,
                                                                    value: "Move down",
                                                                    comment: "title for an accessibility action that will move a selected cell down one position in the list.")
    }
}
