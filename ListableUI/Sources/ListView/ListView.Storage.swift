//
//  ListView.Storage.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 11/19/19.
//

import UIKit

internal extension ListView {
    final class Storage {
        var allContent: Content = .init()

        let presentationState: PresentationState = .init()

        func moveItem(from: IndexPath, to: IndexPath) {
            allContent.moveItem(from: from, to: to)
            presentationState.moveItem(from: from, to: to)
        }

        func remove(item itemToRemove: AnyPresentationItemState) -> IndexPath? {
            if let indexPath = presentationState.remove(item: itemToRemove) {
                allContent.remove(at: indexPath)
                return indexPath
            } else {
                return nil
            }
        }
    }
}
