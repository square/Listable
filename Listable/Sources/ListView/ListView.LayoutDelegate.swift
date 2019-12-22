//
//  ListView.LayoutDelegate.swift
//  Listable
//
//  Created by Kyle Van Essen on 12/22/19.
//

import Foundation


extension ListView
{
    final class LayoutDelegate : ListViewLayoutDelegate
    {
        unowned let presentationState : PresentationState
        var appearance : Appearance
        
        init(presentationState : PresentationState, appearance : Appearance)
        {
            self.presentationState = presentationState
            self.appearance = appearance
        }
        
        private let itemMeasurementCache = ReusableViewCache()
        private let headerFooterMeasurementCache = ReusableViewCache()
        
        // MARK: ListViewLayoutDelegate
        
        func listViewLayoutUpdatedItemPositions(_ info : ListViewLayout.LayoutInfo)
        {
            self.presentationState.setItemPositions(from: info)
        }
                
        func heightForItem(
            at indexPath : IndexPath,
            in collectionView : UICollectionView,
            width : CGFloat,
            layoutDirection : LayoutDirection
            ) -> CGFloat
        {
            let item = self.presentationState.item(at: indexPath)
            
            return item.height(
                width: width,
                layoutDirection : layoutDirection,
                defaultHeight: self.appearance.sizing.itemHeight,
                measurementCache: self.itemMeasurementCache
            )
        }
        
        func layoutForItem(at indexPath : IndexPath, in collectionView : UICollectionView) -> ItemLayout
        {
            let item = self.presentationState.item(at: indexPath)
            
            return item.anyModel.layout
        }
        
        func hasListHeader(in collectionView : UICollectionView) -> Bool
        {
            return self.presentationState.header != nil
        }
        
        func heightForListHeader(
            in collectionView : UICollectionView,
            width : CGFloat,
            layoutDirection : LayoutDirection
            ) -> CGFloat
        {
            let header = self.presentationState.header!
            
            return header.height(
                width: width,
                layoutDirection : layoutDirection,
                defaultHeight: self.appearance.sizing.listHeaderHeight,
                measurementCache: self.headerFooterMeasurementCache
            )
        }
        
        func layoutForListHeader(in collectionView : UICollectionView) -> HeaderFooterLayout
        {
            let header = self.presentationState.header!
            
            return header.anyModel.layout
        }
        
        func hasListFooter(in collectionView : UICollectionView) -> Bool
        {
            return self.presentationState.footer != nil
        }
        
        func heightForListFooter(
            in collectionView : UICollectionView,
            width : CGFloat,
            layoutDirection : LayoutDirection
            ) -> CGFloat
        {
            let footer = self.presentationState.footer!
            
            return footer.height(
                width: width,
                layoutDirection: layoutDirection,
                defaultHeight: self.appearance.sizing.listFooterHeight,
                measurementCache: self.headerFooterMeasurementCache
            )
        }
        
        func layoutForListFooter(in collectionView : UICollectionView) -> HeaderFooterLayout
        {
            let footer = self.presentationState.footer!
            
            return footer.anyModel.layout
        }
        
        func hasOverscrollFooter(in collectionView : UICollectionView) -> Bool
        {
            return self.presentationState.overscrollFooter != nil
        }
        
        func heightForOverscrollFooter(
            in collectionView : UICollectionView,
            width : CGFloat,
            layoutDirection : LayoutDirection
            ) -> CGFloat
        {
            let footer = self.presentationState.overscrollFooter!
            
            return footer.height(
                width: width,
                layoutDirection: layoutDirection,
                defaultHeight: self.appearance.sizing.overscrollFooterHeight,
                measurementCache: self.headerFooterMeasurementCache
            )
        }
        
        func layoutForOverscrollFooter(in collectionView : UICollectionView) -> HeaderFooterLayout
        {
            let footer = self.presentationState.overscrollFooter!
            
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
            
            return section.header != nil
        }
                
        func heightForHeader(
            in sectionIndex : Int,
            in collectionView : UICollectionView,
            width : CGFloat,
            layoutDirection : LayoutDirection
            ) -> CGFloat
        {
            let section = self.presentationState.sections[sectionIndex]
            let header = section.header!
            
            return header.height(
                width: width,
                layoutDirection: layoutDirection,
                defaultHeight: self.appearance.sizing.sectionHeaderHeight,
                measurementCache: self.headerFooterMeasurementCache
            )
        }
        
        func layoutForHeader(in sectionIndex : Int, in collectionView : UICollectionView) -> HeaderFooterLayout
        {
            let section = self.presentationState.sections[sectionIndex]
            let header = section.header!
            
            return header.anyModel.layout
        }
        
        func hasFooter(in sectionIndex : Int, in collectionView : UICollectionView) -> Bool
        {
            let section = self.presentationState.sections[sectionIndex]
            
            return section.footer != nil
        }
                
        func heightForFooter(
            in sectionIndex : Int,
            in collectionView : UICollectionView,
            width : CGFloat,
            layoutDirection : LayoutDirection
            ) -> CGFloat
        {
            let section = self.presentationState.sections[sectionIndex]
            let footer = section.footer!
            
            return footer.height(
                width: width,
                layoutDirection: layoutDirection,
                defaultHeight: self.appearance.sizing.sectionFooterHeight,
                measurementCache: self.headerFooterMeasurementCache
            )
        }
        
        func layoutForFooter(in sectionIndex : Int, in collectionView : UICollectionView) -> HeaderFooterLayout
        {
            let section = self.presentationState.sections[sectionIndex]
            let footer = section.footer!
            
            return footer.anyModel.layout
        }
        
        func columnLayout(for sectionIndex : Int, in collectionView : UICollectionView) -> Section.Columns
        {
            let section = self.presentationState.sections[sectionIndex]
            
            return section.model.columns
        }
    }
}
