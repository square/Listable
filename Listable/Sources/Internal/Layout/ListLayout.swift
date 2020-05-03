//
//  ListLayout.swift
//  Listable
//
//  Created by Kyle Van Essen on 5/2/20.
//

import Foundation


public protocol ListLayout : AnyObject
{
    //
    // MARK: Public Properties
    //
    
    var contentSize : CGSize { get }
    
    //
    // MARK: Initialization
    //
    
    init()
    
    init(
        delegate : CollectionViewLayoutDelegate,
        appearance : Appearance,
        in collectionView : UICollectionView
    )
    
    //
    // MARK: Fetching Elements
    //
    
    func layoutAttributes(in rect: CGRect) -> [UICollectionViewLayoutAttributes]
    
    func item(at indexPath : IndexPath) -> ListLayoutContent.ItemInfo
    
    func layoutAttributes(at indexPath : IndexPath) -> UICollectionViewLayoutAttributes
    
    func supplementaryLayoutAttributes(of kind : String, at indexPath : IndexPath) -> UICollectionViewLayoutAttributes?
    
    //
    // MARK: Peforming Layouts
    //
    
    func reindexLiveIndexPaths()
    
    func reindexDelegateProvidedIndexPaths()
    
    func move(from : IndexPath, to : IndexPath)
    
    func shouldInvalidateLayoutFor(collectionView : UICollectionView) -> Bool
    
    @discardableResult
    func updateHeaders(in collectionView : UICollectionView) -> Bool
    
    @discardableResult
    func updateOverscrollPosition(in collectionView : UICollectionView) -> Bool
    
    func layout(
        delegate : CollectionViewLayoutDelegate,
        in collectionView : UICollectionView
    ) -> Bool
}


public final class ListLayoutContent
{
    let header : SupplementaryItemInfo
    let footer : SupplementaryItemInfo
    
    let overscrollFooter : SupplementaryItemInfo
    
    let sections : [SectionInfo]
    
    init(with appearance : Appearance)
    {
        self.header = SupplementaryItemInfo.empty(.listHeader, direction: appearance.direction)
        self.footer = SupplementaryItemInfo.empty(.listFooter, direction: appearance.direction)
        self.overscrollFooter = SupplementaryItemInfo.empty(.overscrollFooter, direction: appearance.direction)
        
        self.sections = []
    }
    
    init(
        with appearance : Appearance,
        header : SupplementaryItemInfo,
        footer : SupplementaryItemInfo,
        overscrollFooter : SupplementaryItemInfo,
        sections : [SectionInfo]
    )
    {
        self.header = header
        self.footer = footer
        self.overscrollFooter = overscrollFooter
        
        self.sections = sections
    }
}


//
// MARK: Layout Information
//


public extension ListLayoutContent
{
    final class SectionInfo
    {
        let direction : LayoutDirection
        let layout : Section.Layout
        
        let header : SupplementaryItemInfo
        let footer : SupplementaryItemInfo
        
        let columns : Section.Columns
        
        var items : [ItemInfo]
        
        var size : CGSize = .zero
        var x : CGFloat = .zero
        var y : CGFloat = .zero
        
        var frame : CGRect {
            return CGRect(
                origin: self.direction.point(x: self.x, y: self.y),
                size: self.size
            )
        }
        
        init(
            direction : LayoutDirection,
            layout : Section.Layout,
            header : SupplementaryItemInfo,
            footer : SupplementaryItemInfo,
            columns : Section.Columns,
            items : [ItemInfo]
            )
        {
            self.direction = direction
            self.layout = layout
            
            self.header = header
            self.footer = footer
            
            self.columns = columns
            
            self.items = items
        }
        
        func setItemPositions(with appearance : Appearance)
        {
            if self.columns.count == 1 {
                let groups = SectionInfo.grouped(
                    items: self.items,
                    groupingHeight: appearance.sizing.itemPositionGroupingHeight,
                    appearance: appearance
                )
                
                groups.forEach { group in
                    let itemCount = group.count
                    
                    group.forEachWithIndex { index, isLast, item in
                        
                        if itemCount == 1 {
                            item.position = .single
                        } else {
                            if index == 0 {
                                item.position = .first
                            } else if isLast {
                                item.position = .last
                            } else {
                                item.position = .middle
                            }
                        }
                    }
                }
            } else {
                // If we have columns, every item will receive "single" positioning for now.
                // Depending on use, we may want to make this smarter.
                
                self.items.forEach { $0.position = .single }
            }
        }
        
        private static func grouped(items : [ItemInfo], groupingHeight : CGFloat, appearance : Appearance) -> [[ItemInfo]]
        {
            var all = [[ItemInfo]]()
            var current = [ItemInfo]()
            
            var lastSpacing : CGFloat = 0.0
            
            items.forEachWithIndex { index, isLast, item in
                let inNewGroup = groupingHeight == 0.0 ? lastSpacing > 0.0 : lastSpacing > groupingHeight
                
                if inNewGroup {
                    all.append(current)
                    current = []
                }
                
                current.append(item)
                
                lastSpacing = item.layout.itemSpacing ?? appearance.layout.itemSpacing
            }
            
            if current.isEmpty == false {
                all.append(current)
            }
            
            return all
        }
    }
    

    final class SupplementaryItemInfo
    {
        static func empty(_ kind : SupplementaryKind, direction: LayoutDirection) -> SupplementaryItemInfo
        {
            return SupplementaryItemInfo(kind: kind, direction: direction, layout: .init(), isPopulated: false)
        }
        
        let kind : SupplementaryKind
        let direction : LayoutDirection
        let layout : HeaderFooterLayout
        
        let isPopulated : Bool
        
        var size : CGSize = .zero
        var x : CGFloat = .zero
        var y : CGFloat = .zero
        var pinnedY : CGFloat? = nil
        
        var defaultFrame : CGRect {
            return CGRect(
                origin: self.direction.point(x: self.x, y: self.y),
                size: self.size
            )
        }
        
        var visibleFrame : CGRect {
            return CGRect(
                origin: self.direction.point(x: self.x, y: self.pinnedY ?? self.y),
                size: self.size
            )
        }
        
        init(kind : SupplementaryKind, direction : LayoutDirection, layout : HeaderFooterLayout, isPopulated: Bool)
        {
            self.kind = kind
            self.direction = direction
            self.layout = layout
            self.isPopulated = isPopulated
        }
        
        func layoutAttributes(with indexPath : IndexPath) -> UICollectionViewLayoutAttributes
        {
            let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: self.kind.rawValue, with: indexPath)
            
            attributes.frame = self.visibleFrame
            attributes.zIndex = self.kind.zIndex
            
            return attributes
        }
    }
    

    final class ItemInfo
    {
        var delegateProvidedIndexPath : IndexPath
        var liveIndexPath : IndexPath
        
        let direction : LayoutDirection
        let layout : ItemLayout
        
        var position : ItemPosition = .single
        
        var size : CGSize = .zero
        var x : CGFloat = .zero
        var y : CGFloat = .zero
        
        var frame : CGRect {
            return CGRect(
                origin: self.direction.point(x: self.x, y: self.y),
                size: self.size
            )
        }
        
        init(
            delegateProvidedIndexPath : IndexPath,
            liveIndexPath : IndexPath,
            direction : LayoutDirection,
            layout : ItemLayout
            )
        {
            self.delegateProvidedIndexPath = delegateProvidedIndexPath
            self.liveIndexPath = liveIndexPath
            
            self.direction = direction
            self.layout = layout
        }
        
        func layoutAttributes(with indexPath : IndexPath) -> UICollectionViewLayoutAttributes
        {
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            attributes.frame = self.frame
            attributes.zIndex = 0
            
            return attributes
        }
    }
}
