//
//  ListView.DataSource.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 11/19/19.
//

import UIKit


internal extension ListView
{
    final class DataSource : NSObject, UICollectionViewDataSource
    {
        unowned var view : ListView!
        unowned var presentationState : PresentationState!
        unowned var storage : ListView.Storage!
        unowned var liveCells : LiveCells!

        func numberOfSections(in collectionView: UICollectionView) -> Int
        {
            return self.presentationState.sections.count
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
        {
            let section = self.presentationState.sections[section]
            
            return section.items.count
        }
        
        func collectionView(
            _ collectionView: UICollectionView,
            cellForItemAt indexPath: IndexPath
        ) -> UICollectionViewCell
        {
            let item = self.presentationState.item(at: indexPath)
            
            self.presentationState.registerCell(for: item, in: collectionView)
            
            let cell = item.dequeueAndPrepareCollectionViewCell(
                in: collectionView,
                for: indexPath,
                environment: self.view.environment
            )
            
            cell.wasDequeued(with: self.liveCells)
            cell.willBeProvided(to: self.view)
            
            return cell
        }
        
        private let headerFooterReuseCache = ReusableViewCache()
        
        func collectionView(
            _ collectionView: UICollectionView,
            viewForSupplementaryElementOfKind kind: String,
            at indexPath: IndexPath
            ) -> UICollectionReusableView
        {
            let container = SupplementaryContainerView.dequeue(
                in: collectionView,
                for: kind,
                at: indexPath,
                reuseCache: self.headerFooterReuseCache,
                environment: self.view.environment
            )
            
            container.headerFooter = {
                switch SupplementaryKind(rawValue: kind)! {
                case .listContainerHeader: return self.presentationState.containerHeader.state
                case .listHeader: return self.presentationState.header.state
                case .listFooter: return self.presentationState.footer.state
                case .sectionHeader: return self.presentationState.sections[indexPath.section].header.state
                case .sectionFooter: return self.presentationState.sections[indexPath.section].footer.state
                case .overscrollFooter: return self.presentationState.overscrollFooter.state
                }
            }()
            
            return container
        }
        
        func collectionView(
            _ collectionView: UICollectionView,
            canMoveItemAt indexPath: IndexPath
        ) -> Bool
        {            
            let item = self.presentationState.item(at: indexPath)
            
            return item.anyModel.reordering != nil
        }
        
        func collectionView(
            _ collectionView: UICollectionView,
            moveItemAt from: IndexPath,
            to: IndexPath
        ) {
            guard from != to else {
                return
            }
            
            ///
            /// Mark us as queuing for re-orders, to prevent destructive edits which could break the collection
            /// view's layout while the re-order event settles.
            ///
            /// Later on, the call to `listViewShouldEndQueueingEditsForReorder` will set this value to false.
            ///
            /// See `sendEndQueuingEditsAfterDelay` for a more in-depth explanation.
            ///
            self.view.updateQueue.isQueuingForReorderEvent = true
            
            /// Perform the change in our data source.
            
            self.storage.moveItem(from: from, to: to)

            /// Notify our observers about the change.

            let result = ItemReordering.Result(
                from: from,
                fromSection: self.presentationState.sections[from.section].model,
                to: to,
                toSection: self.presentationState.sections[to.section].model
            )
            
            let item = self.presentationState.item(at: to)
            
            let itemHadCallback = item.performDidReorder(with: result)
            let hasStateObservers = self.view.stateObserver.onItemReordered.isEmpty == false
            
            guard itemHadCallback || hasStateObservers else {
                fatalError(
                    """
                    Performed a reorder (\(result.indexPathsDescription)) of an Item \
                    with the identifier `\(item.anyModel.anyIdentifier)`, but the Item \
                    did not have a onWasReordered callback, and there were no onItemReordered \
                    callbacks registered with the ListStateObserver. You must register at least \
                    one of these callback types to update your data model with the result of the
                    reorder event.
                    """
                )
            }
            
            ListStateObserver.perform(self.view.stateObserver.onItemReordered, "Item Reordered", with: self.view) {
                ListStateObserver.ItemReordered(
                    actions: $0,
                    positionInfo: self.view.scrollPositionInfo,
                    item: item.anyModel,
                    sections: self.presentationState.sectionModels,
                    result: result
                )
            }
        }
    }
}
