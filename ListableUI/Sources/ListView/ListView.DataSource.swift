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
                
                /// The below works around a (seeming?) bug or odd behavior in `UICollectionView`,
                /// where it tries to be smart about recycling supplementary views that contain a
                /// first responder such as a text field. Specifically, it holds onto a supplementary view
                /// that contains a first responder, not immediately recycling it when it is scrolled out
                /// of view. That ensures that the keyboard isn't immediately dismissed, which would
                /// be jarring.
                ///
                /// ...Unfortunately, this doesn't seem to actually work in practice very well. When the
                /// supplementary view  is scrolled back _into_ view, and we're asked to dequeue
                /// a view, the collection view hands us back a _different_ view, leading to double
                /// views that get stacked on top of each other in the layout, leading to a bunch
                /// of weirdness.
                ///
                /// So, to work around this, we do a few things:
                ///
                /// 1) We begin tracking which supplementary views currently contain a first responder.
                /// For practicality of implementation, we only track text fields right now. This could
                /// change, but is harder, given there's no generic "first responder changed" notification.
                /// This code lives in `ListView`.
                ///
                /// 2) We update `ListLayoutContent.content(in: ...)` to _always_ return
                /// supplementary info when a supplementary view contains a first responder,
                /// even when out of frame. This ensures the supplementary view
                /// instance is kept alive by the collection view.
                ///
                /// 3) Within this method, we check to see if there's a live, existing `visibleContainer`
                /// (aka the supplementary view) view, and if there is, we return _that_, instead of
                /// just dequeuing a new, wrong view.
                ///
                /// After all that, the correct thing happens.
                ///
                /// PR with more info and screenshots, etc:
                /// https://github.com/square/Listable/pull/507
                ///
                
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
