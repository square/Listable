//
//  ListView.Delegate.swift
//  Listable
//
//  Created by Kyle Van Essen on 11/19/19.
//


extension ListView
{
    final class Delegate : NSObject, UICollectionViewDelegate, CollectionViewLayoutDelegate
    {
        unowned var view : ListView!
        unowned var presentationState : PresentationState!
        
        private let itemMeasurementCache = ReusableViewCache()
        private let headerFooterMeasurementCache = ReusableViewCache()
        
        private let headerFooterViewCache = ReusableViewCache()
        
        // MARK: UICollectionViewDelegate
        
        func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool
        {
            return true
        }
        
        func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath)
        {
            let item = self.presentationState.item(at: indexPath)
            
            item.applyToVisibleCell()
        }
        
        func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath)
        {
            let item = self.presentationState.item(at: indexPath)
            
            item.applyToVisibleCell()
        }
        
        func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool
        {
            let item = self.presentationState.item(at: indexPath)
            
            return item.anyModel.selectionStyle.isSelectable
        }
        
        func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool
        {
            return true
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
        {
            let item = self.presentationState.item(at: indexPath)
            
            item.performUserDidSelectItem(isSelected: true)
            
            if item.anyModel.selectionStyle == .tappable {
                collectionView.deselectItem(at: indexPath, animated: true)
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
        {
            let item = self.presentationState.item(at: indexPath)
            
            item.performUserDidSelectItem(isSelected: false)
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
            
            let headerFooter : PresentationState.HeaderFooterViewStatePair = {
                switch kind {
                case .listHeader: return self.presentationState.header
                case .listFooter: return self.presentationState.footer
                case .sectionHeader: return self.presentationState.sections[indexPath.section].header
                case .sectionFooter: return self.presentationState.sections[indexPath.section].footer
                case .overscrollFooter: return self.presentationState.overscrollFooter
                }
            }()
            
            headerFooter.willDisplay(view: container)
            
            self.displayedSupplementaryItems[ObjectIdentifier(view)] = headerFooter
        }
        
        func collectionView(
            _ collectionView: UICollectionView,
            didEndDisplayingSupplementaryView view: UICollectionReusableView,
            forElementOfKind elementKind: String,
            at indexPath: IndexPath
            )
        {
            guard let headerFooter = self.displayedSupplementaryItems.removeValue(forKey: ObjectIdentifier(view)) else {
                return
            }
            
            headerFooter.didEndDisplay()
        }
        
        func collectionView(
            _ collectionView: UICollectionView,
            targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath,
            toProposedIndexPath proposedIndexPath: IndexPath
            ) -> IndexPath
        {
            
            if originalIndexPath != proposedIndexPath {
                // TODO: Validate
                // let item = self.presentationState.item(at: originalIndexPath)
                
                if originalIndexPath.section == proposedIndexPath.section {
                    self.view.storage.moveItem(from: originalIndexPath, to: proposedIndexPath)
                    
                    return proposedIndexPath
                } else {
                    return originalIndexPath
                }
            } else {
                return proposedIndexPath
            }
        }
        
        // MARK: ListViewLayoutDelegate
        
        func listViewLayoutUpdatedItemPositions(_ collectionView : UICollectionView)
        {
            self.view.setPresentationStateItemPositions()
        }
                
        func sizeForItem(
            at indexPath : IndexPath,
            in collectionView : UICollectionView,
            measuredIn sizeConstraint : CGSize,
            defaultSize : CGSize,
            layoutDirection : LayoutDirection
        ) -> CGSize
        {
            let item = self.presentationState.item(at: indexPath)
            
            return item.size(
                in: sizeConstraint,
                layoutDirection: layoutDirection,
                defaultSize: defaultSize,
                measurementCache: self.itemMeasurementCache
            )
        }
        
        func layoutForItem(at indexPath : IndexPath, in collectionView : UICollectionView) -> ItemLayout
        {
            let item = self.presentationState.item(at: indexPath)
            
            return item.anyModel.layout
        }
        
        func positioningTransformationForItem(at indexPath : IndexPath, in collectionView : UICollectionView) -> PositioningTransformation.Provider?
        {
            let item = self.presentationState.item(at: indexPath)
            
            return item.anyModel.positioningTransformation
        }
        
        func hasListHeader(in collectionView : UICollectionView) -> Bool
        {
            return self.presentationState.header.state != nil
        }
        
        func sizeForListHeader(
            in collectionView : UICollectionView,
            measuredIn sizeConstraint : CGSize,
            defaultSize : CGSize,
            layoutDirection : LayoutDirection
            ) -> CGSize
        {
            let header = self.presentationState.header.state!
                        
            return header.size(
                in: sizeConstraint,
                layoutDirection : layoutDirection,
                defaultSize: defaultSize,
                measurementCache: self.headerFooterMeasurementCache
            )
        }
        
        func layoutForListHeader(in collectionView : UICollectionView) -> HeaderFooterLayout
        {
            let header = self.presentationState.header.state!
            
            return header.anyModel.layout
        }
        
        func hasListFooter(in collectionView : UICollectionView) -> Bool
        {
            return self.presentationState.footer.state != nil
        }
        
        func sizeForListFooter(
            in collectionView : UICollectionView,
            measuredIn sizeConstraint : CGSize,
            defaultSize : CGSize,
            layoutDirection : LayoutDirection
            ) -> CGSize
        {
            let footer = self.presentationState.footer.state!
            
            return footer.size(
                in: sizeConstraint,
                layoutDirection: layoutDirection,
                defaultSize: defaultSize,
                measurementCache: self.headerFooterMeasurementCache
            )
        }
        
        func layoutForListFooter(in collectionView : UICollectionView) -> HeaderFooterLayout
        {
            let footer = self.presentationState.footer.state!
            
            return footer.anyModel.layout
        }
        
        func hasOverscrollFooter(in collectionView : UICollectionView) -> Bool
        {
            return self.presentationState.overscrollFooter.state != nil
        }
        
        func sizeForOverscrollFooter(
            in collectionView : UICollectionView,
            measuredIn sizeConstraint : CGSize,
            defaultSize : CGSize,
            layoutDirection : LayoutDirection
            ) -> CGSize
        {
            let footer = self.presentationState.overscrollFooter.state!
            
            return footer.size(
                in: sizeConstraint,
                layoutDirection: layoutDirection,
                defaultSize: defaultSize,
                measurementCache: self.headerFooterMeasurementCache
            )
        }
        
        func layoutForOverscrollFooter(in collectionView : UICollectionView) -> HeaderFooterLayout
        {
            let footer = self.presentationState.overscrollFooter.state!
            
            return footer.anyModel.layout
        }
        
        func layoutFor(section sectionIndex : Int, in collectionView : UICollectionView) -> Section.Layout
        {
            let section = self.presentationState.sections[sectionIndex]
            
            return section.model.layout
        }
        
        func hasHeader(in sectionIndex : Int, in collectionView : UICollectionView) -> Bool
        {
            let section = self.presentationState.sections[sectionIndex]
            
            return section.header.state != nil
        }
                
        func sizeForHeader(
            in sectionIndex : Int,
            in collectionView : UICollectionView,
            measuredIn sizeConstraint : CGSize,
            defaultSize : CGSize,
            layoutDirection : LayoutDirection
            ) -> CGSize
        {
            let section = self.presentationState.sections[sectionIndex]
            let header = section.header.state!
            
            return header.size(
                in: sizeConstraint,
                layoutDirection: layoutDirection,
                defaultSize: defaultSize,
                measurementCache: self.headerFooterMeasurementCache
            )
        }
        
        func layoutForHeader(in sectionIndex : Int, in collectionView : UICollectionView) -> HeaderFooterLayout
        {
            let section = self.presentationState.sections[sectionIndex]
            let header = section.header.state!
            
            return header.anyModel.layout
        }
        
        func hasFooter(in sectionIndex : Int, in collectionView : UICollectionView) -> Bool
        {
            let section = self.presentationState.sections[sectionIndex]
            
            return section.footer.state != nil
        }
                
        func sizeForFooter(
            in sectionIndex : Int,
            in collectionView : UICollectionView,
            measuredIn sizeConstraint : CGSize,
            defaultSize : CGSize,
            layoutDirection : LayoutDirection
            ) -> CGSize
        {
            let section = self.presentationState.sections[sectionIndex]
            let footer = section.footer.state!
            
            return footer.size(
                in: sizeConstraint,
                layoutDirection: layoutDirection,
                defaultSize: defaultSize,
                measurementCache: self.headerFooterMeasurementCache
            )
        }
        
        func layoutForFooter(in sectionIndex : Int, in collectionView : UICollectionView) -> HeaderFooterLayout
        {
            let section = self.presentationState.sections[sectionIndex]
            let footer = section.footer.state!
            
            return footer.anyModel.layout
        }
        
        func columnLayout(for sectionIndex : Int, in collectionView : UICollectionView) -> Section.Columns
        {
            let section = self.presentationState.sections[sectionIndex]
            
            return section.model.columns
        }
        
        // MARK: UIScrollViewDelegate
        
        func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
        {
            // Notify swipe actions to close

            let notification = Notification(name: .closeSwipeActions, object: self)
            NotificationCenter.default.post(notification)
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
        {
            self.view.updatePresentationState(for: .didEndDecelerating)
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
            
            // Update Item Visibility
            
            self.view.updateVisibleItemsAndSections()
        }
    }
}
