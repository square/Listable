//
//  ListView.LayoutManager.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 5/3/20.
//

import Foundation
import UIKit

extension ListView {
    final class LayoutManager {
        unowned let collectionView: UICollectionView

        private(set) var collectionViewLayout: CollectionViewLayout

        var layout: AnyListLayout {
            collectionViewLayout.layout
        }

        init(layout collectionViewLayout: CollectionViewLayout, collectionView: UICollectionView) {
            self.collectionViewLayout = collectionViewLayout
            self.collectionView = collectionView
        }

        func stateForItem(at indexPath: IndexPath) -> AnyPresentationItemState {
            collectionViewLayout.layout.content.item(at: indexPath).state
        }

        func set(layout: LayoutDescription, animated: Bool, completion: @escaping () -> Void) {
            if collectionViewLayout.layoutDescription.configuration.isSameLayoutType(as: layout.configuration) {
                collectionViewLayout.layoutDescription = layout

                let shouldRebuild = collectionViewLayout.layoutDescription.configuration.shouldRebuild(
                    layout: collectionViewLayout.layout
                )

                if shouldRebuild {
                    // TODO: We shouldn't need to rebuild in any case here; just push the new values through to the ListLayout.
                    collectionViewLayout.setNeedsRebuild(animated: animated)
                }
            } else {
                collectionViewLayout = CollectionViewLayout(
                    delegate: collectionViewLayout.delegate,
                    layoutDescription: layout,
                    appearance: collectionViewLayout.appearance,
                    behavior: collectionViewLayout.behavior
                )

                collectionView.setCollectionViewLayout(collectionViewLayout, animated: animated) { _ in
                    completion()
                }
            }
        }
    }
}
