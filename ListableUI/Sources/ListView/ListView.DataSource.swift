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
            
            return cell
        }
        
        private let headerFooterReuseCache = ReusableViewCache()
        
        func collectionView(
            _ collectionView: UICollectionView,
            viewForSupplementaryElementOfKind kind: String,
            at indexPath: IndexPath
            ) -> UICollectionReusableView
        {
            let statePair : PresentationState.HeaderFooterViewStatePair = {
                switch SupplementaryKind(rawValue: kind)! {
                case .listContainerHeader: return self.presentationState.containerHeader
                case .listHeader: return self.presentationState.header
                case .listFooter: return self.presentationState.footer
                case .sectionHeader: return self.presentationState.sections[indexPath.section].header
                case .sectionFooter: return self.presentationState.sections[indexPath.section].footer
                case .overscrollFooter: return self.presentationState.overscrollFooter
                }
            }()
            
            let headerFooter = statePair.state
            
            let container : SupplementaryContainerView = {
                
                /// Fixes a bug (https://github.com/square/Listable/pull/507) wherein
                /// for supplementary views that contain a first responder, the collection view
                /// keeps them around... somewhere instead of immediately recycling the view, but then
                /// seems to later forget that that view is already being kept around, and then
                /// ends up requesting another view, leading to a phantom "left over" supplementary
                /// view. Our fix is to see if we already have a visible supplementary view, and just
                /// return it instead of dequeueing a new one.
                ///
                /// This is paired with a behavior change in `CollectionViewLayout`, where if a
                /// supplementary item contains a first responder, we never remove it from the
                /// list of items returned for the given rect, even if it's offscreen. That keeps the view
                /// alive so we can access it here.
                
                if let view = statePair.visibleContainer {
                    return view
                } else {
                    return SupplementaryContainerView.dequeue(
                        in: collectionView,
                        for: kind,
                        at: indexPath,
                        reuseCache: self.headerFooterReuseCache,
                        environment: self.view.environment
                    )
                }
            }()
            
            container.setHeaderFooter(headerFooter, animated: false)
            
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
