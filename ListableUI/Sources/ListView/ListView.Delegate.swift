//
//  ListView.Delegate.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 11/19/19.
//

import UIKit


extension ListView
{
    final class Delegate : NSObject, UICollectionViewDelegate, CollectionViewLayoutDelegate
    {
        unowned var view : ListView!
        unowned var presentationState : PresentationState!
        unowned var layoutManager : LayoutManager!
        
        // MARK: UICollectionViewDelegate
        
        func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool
        {
            guard view.behavior.selectionMode != .none else { return false }
            
            let item = self.presentationState.item(at: indexPath)
            
            return item.anyModel.selectionStyle.isSelectable
        }
        
        func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath)
        {
            let item = self.presentationState.item(at: indexPath)
            
            item.applyToVisibleCell(with: self.view.environment)
        }
        
        func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath)
        {
            let item = self.presentationState.item(at: indexPath)
            
            item.applyToVisibleCell(with: self.view.environment)
        }
        
        func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool
        {
            guard view.behavior.selectionMode != .none else { return false }
            
            let item = self.presentationState.item(at: indexPath)
            
            if case .toggles = item.anyModel.selectionStyle {
                
                if item.isSelected {
                    item.set(isSelected: false, performCallbacks: true)
                    collectionView.deselectItem(at: indexPath, animated: false)
                    item.applyToVisibleCell(with: self.view.environment)
                    
                    self.performOnSelectChanged()
                    
                    return false
                } else {
                    return true
                }
            } else {
                return item.anyModel.selectionStyle.isSelectable
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool
        {
            return true
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
        {
            let item = self.presentationState.item(at: indexPath)
            
            item.set(isSelected: true, performCallbacks: true)
            item.applyToVisibleCell(with: self.view.environment)
            
            self.performOnSelectChanged()
            
            if item.anyModel.selectionStyle == .tappable {
                item.set(isSelected: false, performCallbacks: true)
                collectionView.deselectItem(at: indexPath, animated: true)
                item.applyToVisibleCell(with: self.view.environment)
                
                self.performOnSelectChanged()
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
        {
            let item = self.presentationState.item(at: indexPath)
            
            item.set(isSelected: false, performCallbacks: true)
            item.applyToVisibleCell(with: self.view.environment)
            
            self.performOnSelectChanged()
        }

        func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView)
        {
            ListStateObserver.perform(self.view.stateObserver.onDidEndScrollingAnimation, "Did End Scrolling Animation", with: self.view) { _ in
                ListStateObserver.DidEndScrollingAnimation(
                    positionInfo: self.view.scrollPositionInfo
                )
            }
        }

        private var oldSelectedItems : Set<AnyIdentifier> = []
        
        private func performOnSelectChanged() {
            
            let old = self.oldSelectedItems
            
            let new = Set(self.presentationState.selectedItems.map(\.anyModel.anyIdentifier))
            
            guard old != new else {
                return
            }
            
            self.oldSelectedItems = new
            
            ListStateObserver.perform(self.view.stateObserver.onSelectionChanged, "Selection Changed", with: self.view) {
                ListStateObserver.SelectionChanged(
                    actions: $0,
                    positionInfo: self.view.scrollPositionInfo,
                    old: old,
                    new: new
                )
            }
        }
        
        private var displayedItems : [ObjectIdentifier:AnyPresentationItemState] = [:]
        
        func collectionView(
            _ collectionView: UICollectionView,
            willDisplay cell: UICollectionViewCell,
            forItemAt indexPath: IndexPath
            )
        {
            let item = self.presentationState.item(at: indexPath)
            
            item.willDisplay(cell: cell, in: collectionView, for: indexPath)
            
            self.displayedItems[ObjectIdentifier(cell)] = item
        }
        
        func collectionView(
            _ collectionView: UICollectionView,
            didEndDisplaying cell: UICollectionViewCell,
            forItemAt indexPath: IndexPath
            )
        {
            guard let item = self.displayedItems.removeValue(forKey: ObjectIdentifier(cell)) else {
                return
            }
            
            item.didEndDisplay()
        }
                
        private var displayedSupplementaryItems : [ObjectIdentifier:PresentationState.HeaderFooterViewStatePair] = [:]
        
        func collectionView(
            _ collectionView: UICollectionView,
            willDisplaySupplementaryView anyView: UICollectionReusableView,
            forElementKind kindString: String,
            at indexPath: IndexPath
            )
        {
            let container = anyView as! SupplementaryContainerView
            let kind = SupplementaryKind(rawValue: kindString)!
            
            let headerFooter = self.presentationState.headerFooter(
                of: kind,
                in: indexPath.section
            )
            
            headerFooter.collectionViewWillDisplay(view: container)
            
            self.displayedSupplementaryItems[ObjectIdentifier(container)] = headerFooter
        }
        
        func collectionView(
            _ collectionView: UICollectionView,
            didEndDisplayingSupplementaryView anyView: UICollectionReusableView,
            forElementOfKind kindString: String,
            at indexPath: IndexPath
            )
        {
            let container = anyView as! SupplementaryContainerView
            
            guard let headerFooter = self.displayedSupplementaryItems.removeValue(forKey: ObjectIdentifier(container)) else {
                return
            }
                        
            headerFooter.collectionViewDidEndDisplay(of: container)
        }
        
        func collectionView(
            _ collectionView: UICollectionView,
            targetIndexPathForMoveFromItemAt from: IndexPath,
            toProposedIndexPath to: IndexPath
        ) -> IndexPath
        {
            ///
            /// **Note**: We do not use either `from` or `to` index paths passed to this method to
            /// index into the `presentationState`'s content – it has not yet been updated
            /// to reflect the move, because the move has not yet been committed. The `from` parameter
            /// is instead reflecting the current `UICollectionViewLayout`'s state – which will not match
            /// the data source / `presentationState`.
            ///
            /// Instead, read the `stateForItem(at:)` off of the `layoutManager`. This will reflect
            /// the right index path.
            ///
            /// iOS 15 resolves this issue, by introducing
            /// ```
            /// func collectionView(
            ///     _ collectionView: UICollectionView,
            ///     targetIndexPathForMoveOfItemFromOriginalIndexPath originalIndexPath: IndexPath,
            ///     atCurrentIndexPath currentIndexPath: IndexPath,
            ///     toProposedIndexPath proposedIndexPath: IndexPath
            /// ) -> IndexPath
            /// ```
            /// Which passes the **original** index path, allowing a direct index into your data source.
            /// Alas, we do not yet support only iOS 15 and later, so, here we are.
            ///
            
            guard from != to else {
                return from
            }
            
            let item = self.layoutManager.stateForItem(at: from)
            
            // An item is not reorderable if it has no reordering config.
            guard let reordering = item.anyModel.reordering else {
                return from
            }
            
            // If we're moving the item back to its original position,
            // allow regardless of any other rules.
            if to == item.activeReorderEventInfo?.originalIndexPath {
                return to
            }
            
            // Finally, perform validation based on item and section validations.
            
            let fromSection = self.presentationState.sections[from.section]
            let toSection = self.presentationState.sections[to.section]
            
            return reordering.destination(
                from: from,
                fromSection: fromSection,
                to: to,
                toSection: toSection
            )
        }
        
        // MARK: CollectionViewLayoutDelegate
        
        func listViewLayoutUpdatedItemPositions()
        {
            /// During reordering; our index paths will not match the index paths of the collection view;
            /// our index paths are not updated until the move is committed.
            if self.layoutManager.collectionViewLayout.isReordering {
                return
            }
            
            self.view.setPresentationStateItemPositions()
        }
        
        func listLayoutContent(
            defaults: ListLayoutDefaults
        ) -> ListLayoutContent
        {
            self.presentationState.toListLayoutContent(
                defaults: defaults,
                environment: self.view.environment
            )
        }
        
        func listViewLayoutCurrentEnvironment() -> ListEnvironment {
            self.view.environment
        }
        
        func listViewLayoutDidLayoutContents() {
            self.view.visibleContent.update(with: self.view)
        }
        
        func listViewShouldEndQueueingEditsForReorder() {
            self.view.updateQueue.isQueuingToApplyReorderEvent = false
        }

        // MARK: UIScrollViewDelegate
        
        func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
        {
            self.view.liveCells.perform {
                $0.closeSwipeActions()
            }
            
            ListStateObserver.perform(self.view.stateObserver.onBeginDrag, "Will Begin Drag", with: self.view) { _ in
                ListStateObserver.BeginDrag(
                    positionInfo: self.view.scrollPositionInfo
                )
            }
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
        {
            self.view.updatePresentationState(for: .didEndDecelerating)
            
            ListStateObserver.perform(self.view.stateObserver.onDidEndDeceleration, "Did End Deceleration", with: self.view) { _ in
                ListStateObserver.DidEndDeceleration(
                    positionInfo: self.view.scrollPositionInfo
                )
            }
        }
                
        func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool
        {
            switch view.behavior.scrollsToTop {
            case .disabled: return false
            case .enabled: return true
            }
        }
        
        func scrollViewDidScrollToTop(_ scrollView: UIScrollView)
        {
            self.view.updatePresentationState(for: .scrolledToTop)
        }
        
        private var lastPosition : CGFloat = 0.0
        
        func scrollViewDidScroll(_ scrollView: UIScrollView)
        {
            guard scrollView.bounds.size.height > 0 else { return }
                        
            SignpostLogger.log(.begin, log: .scrollView, name: "scrollViewDidScroll", for: self.view)
            
            defer {
                SignpostLogger.log(.end, log: .scrollView, name: "scrollViewDidScroll", for: self.view)
            }
            
            // Updating Paged Content
            
            let scrollingDown = self.lastPosition < scrollView.contentOffset.y
            
            self.lastPosition = scrollView.contentOffset.y
            
            if scrollingDown {
                self.view.updatePresentationState(for: .scrolledDown)
            }
            
            ListStateObserver.perform(self.view.stateObserver.onDidScroll, "Did Scroll", with: self.view) {
                ListStateObserver.DidScroll(
                    actions: $0,
                    positionInfo: self.view.scrollPositionInfo
                )
            }
        }
        
        func scrollViewWillEndDragging(
            _ scrollView: UIScrollView,
            withVelocity velocity: CGPoint,
            targetContentOffset: UnsafeMutablePointer<CGPoint>
        ) {
            func findTarget() -> CGPoint? {
                layoutManager.layout.onDidEndDraggingTargetContentOffset(
                    for: scrollView.contentOffset,
                    velocity: velocity,
                    visibleContentFrame: scrollView.visibleContentFrame
                )
            }
            
            switch layoutManager.layout.scrollViewProperties.pagingStyle {
            case .native:
                // With a native paging style, leverage the system's target offset.
                break
            case .custom:
                guard let target = findTarget() else { return }
                let mainAxisVelocity = layoutManager.layout.direction.switch(
                    vertical: { velocity.y.magnitude },
                    horizontal: { velocity.x.magnitude }
                )
                if mainAxisVelocity < 1.25 {
                    // With a custom paging style, when the velocity is low, programatically
                    // scroll to the target. This avoids cases where it takes too long for
                    // the scroll view to reach the target. This is dispatched to wait for
                    // scrollViewWillEndDragging(_:withVelocity:targetContentOffset:) to
                    // finish, identical to an async programmatic scroll while decelerating.
                    DispatchQueue.main.async {
                        scrollView.setContentOffset(target, animated: true)
                    }
                } else {
                    targetContentOffset.pointee = target
                }
            case .none:
                guard let target = findTarget() else { return }
                targetContentOffset.pointee = target
            }
        }
    }
}
