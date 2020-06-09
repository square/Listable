//
//  ListLayoutContent.swift
//  Listable
//
//  Created by Kyle Van Essen on 6/7/20.
//

import Foundation


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
        
        func setContentsFrameWithContent() {
//            let allFrames : [CGRect] = [[
//                    self.header.defaultFrame,
//                    self.footer.defaultFrame
//                ],
//                self.items.map { $0.frame }
//                ].flatMap { $0 }
//
//            self.contentsFrame = .from(unioned: allFrames)
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


extension CGRect {
    static func from(unioned rects : [CGRect]) -> CGRect {
        
        // Only include non-empty frames.
        var rects = rects.filter {
            $0.isEmpty == false
        }
        
        guard let last = rects.popLast() else {
            return .zero
        }
        
        var frame = last
        
        for rect in rects {
            frame = frame.union(rect)
        }
        
        return frame
    }
}
