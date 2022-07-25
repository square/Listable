//
//  ListView.Delegate.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 11/19/19.
//

import UIKit

extension ListView {
    final class Delegate: NSObject, UICollectionViewDelegate, CollectionViewLayoutDelegate {
        unowned var view: ListView!
        unowned var presentationState: PresentationState!
        unowned var layoutManager: LayoutManager!

        private let itemMeasurementCache = ReusableViewCache()
        private let headerFooterMeasurementCache = ReusableViewCache()

        private let headerFooterViewCache = ReusableViewCache()

        // MARK: UICollectionViewDelegate

        func collectionView(_: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool
        {
            guard view.behavior.selectionMode != .none else { return false }

            let item = presentationState.item(at: indexPath)

            return item.anyModel.selectionStyle.isSelectable
        }

        func collectionView(_: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
            let item = presentationState.item(at: indexPath)

            item.applyToVisibleCell(with: view.environment)
        }

        func collectionView(_: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
            let item = presentationState.item(at: indexPath)

            item.applyToVisibleCell(with: view.environment)
        }

        func collectionView(_: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
            guard view.behavior.selectionMode != .none else { return false }

            let item = presentationState.item(at: indexPath)

            return item.anyModel.selectionStyle.isSelectable
        }

        func collectionView(_: UICollectionView, shouldDeselectItemAt _: IndexPath) -> Bool {
            true
        }

        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
        {
            let item = presentationState.item(at: indexPath)

            item.set(isSelected: true, performCallbacks: true)
            item.applyToVisibleCell(with: view.environment)

            performOnSelectChanged()

            if item.anyModel.selectionStyle == .tappable {
                item.set(isSelected: false, performCallbacks: true)
                collectionView.deselectItem(at: indexPath, animated: true)
                item.applyToVisibleCell(with: view.environment)

                performOnSelectChanged()
            }
        }

        func collectionView(_: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
            let item = presentationState.item(at: indexPath)

            item.set(isSelected: false, performCallbacks: true)
            item.applyToVisibleCell(with: view.environment)

            performOnSelectChanged()
        }

        private var oldSelectedItems: Set<AnyIdentifier> = []

        private func performOnSelectChanged() {
            let old = oldSelectedItems

            let new = Set(presentationState.selectedItems.map(\.anyModel.anyIdentifier))

            guard old != new else {
                return
            }

            oldSelectedItems = new

            ListStateObserver.perform(view.stateObserver.onSelectionChanged, "Selection Changed", with: view) {
                ListStateObserver.SelectionChanged(
                    actions: $0,
                    positionInfo: self.view.scrollPositionInfo,
                    old: old,
                    new: new
                )
            }
        }

        private var displayedItems: [ObjectIdentifier: AnyPresentationItemState] = [:]

        func collectionView(
            _ collectionView: UICollectionView,
            willDisplay cell: UICollectionViewCell,
            forItemAt indexPath: IndexPath
        ) {
            let item = presentationState.item(at: indexPath)

            item.willDisplay(cell: cell, in: collectionView, for: indexPath)

            displayedItems[ObjectIdentifier(cell)] = item
        }

        func collectionView(
            _: UICollectionView,
            didEndDisplaying cell: UICollectionViewCell,
            forItemAt _: IndexPath
        ) {
            guard let item = displayedItems.removeValue(forKey: ObjectIdentifier(cell)) else {
                return
            }

            item.didEndDisplay()
        }

        private var displayedSupplementaryItems: [ObjectIdentifier: PresentationState.HeaderFooterViewStatePair] = [:]

        func collectionView(
            _: UICollectionView,
            willDisplaySupplementaryView anyView: UICollectionReusableView,
            forElementKind kindString: String,
            at indexPath: IndexPath
        ) {
            let container = anyView as! SupplementaryContainerView
            let kind = SupplementaryKind(rawValue: kindString)!

            let headerFooter: PresentationState.HeaderFooterViewStatePair = {
                switch kind {
                case .listContainerHeader: return self.presentationState.containerHeader
                case .listHeader: return self.presentationState.header
                case .listFooter: return self.presentationState.footer
                case .sectionHeader: return self.presentationState.sections[indexPath.section].header
                case .sectionFooter: return self.presentationState.sections[indexPath.section].footer
                case .overscrollFooter: return self.presentationState.overscrollFooter
                }
            }()

            headerFooter.willDisplay(view: container)

            displayedSupplementaryItems[ObjectIdentifier(container)] = headerFooter
        }

        func collectionView(
            _: UICollectionView,
            didEndDisplayingSupplementaryView view: UICollectionReusableView,
            forElementOfKind _: String,
            at _: IndexPath
        ) {
            guard let headerFooter = displayedSupplementaryItems.removeValue(forKey: ObjectIdentifier(view)) else {
                return
            }

            headerFooter.didEndDisplay()
        }

        func collectionView(
            _: UICollectionView,
            targetIndexPathForMoveFromItemAt from: IndexPath,
            toProposedIndexPath to: IndexPath
        ) -> IndexPath {
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

            let item = layoutManager.stateForItem(at: from)

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

            let fromSection = presentationState.sections[from.section]
            let toSection = presentationState.sections[to.section]

            return reordering.destination(
                from: from,
                fromSection: fromSection,
                to: to,
                toSection: toSection
            )
        }

        // MARK: CollectionViewLayoutDelegate

        func listViewLayoutUpdatedItemPositions() {
            /// During reordering; our index paths will not match the index paths of the collection view;
            /// our index paths are not updated until the move is committed.
            if layoutManager.collectionViewLayout.isReordering {
                return
            }

            view.setPresentationStateItemPositions()
        }

        func listLayoutContent(
            defaults: ListLayoutDefaults
        ) -> ListLayoutContent {
            presentationState.toListLayoutContent(
                defaults: defaults,
                environment: view.environment
            )
        }

        func listViewLayoutCurrentEnvironment() -> ListEnvironment {
            view.environment
        }

        func listViewLayoutDidLayoutContents() {
            view.visibleContent.update(with: view)
        }

        func listViewShouldEndQueueingEditsForReorder() {
            view.updateQueue.isQueuingForReorderEvent = false
        }

        // MARK: UIScrollViewDelegate

        func scrollViewWillBeginDragging(_: UIScrollView) {
            view.liveCells.perform {
                $0.closeSwipeActions()
            }
        }

        func scrollViewDidEndDecelerating(_: UIScrollView) {
            view.updatePresentationState(for: .didEndDecelerating)
        }

        func scrollViewShouldScrollToTop(_: UIScrollView) -> Bool {
            switch view.behavior.scrollsToTop {
            case .disabled: return false
            case .enabled: return true
            }
        }

        func scrollViewDidScrollToTop(_: UIScrollView) {
            view.updatePresentationState(for: .scrolledToTop)
        }

        private var lastPosition: CGFloat = 0.0

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            guard scrollView.bounds.size.height > 0 else { return }

            SignpostLogger.log(.begin, log: .scrollView, name: "scrollViewDidScroll", for: view)

            defer {
                SignpostLogger.log(.end, log: .scrollView, name: "scrollViewDidScroll", for: self.view)
            }

            // Updating Paged Content

            let scrollingDown = lastPosition < scrollView.contentOffset.y

            lastPosition = scrollView.contentOffset.y

            if scrollingDown {
                view.updatePresentationState(for: .scrolledDown)
            }

            ListStateObserver.perform(view.stateObserver.onDidScroll, "Did Scroll", with: view) {
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
            guard let target = layoutManager.layout.onDidEndDraggingTargetContentOffset(
                for: scrollView.contentOffset,
                velocity: velocity
            ) else {
                return
            }

            targetContentOffset.pointee = target
        }
    }
}
