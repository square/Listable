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
    
    var appearance : Appearance { get }
    var behavior : Behavior { get }
    
    var content : ListLayoutContent { get }
    
    //
    // MARK: Initialization
    //
    
    init()
    
    init(
        delegate : CollectionViewLayoutDelegate,
        appearance : Appearance,
        behavior : Behavior,
        in collectionView : UICollectionView
    )
    
    //
    // MARK: Performing Layouts
    //
    
    @discardableResult
    func updateLayout(in collectionView : UICollectionView) -> Bool
    
    func layout(
        delegate : CollectionViewLayoutDelegate,
        in collectionView : UICollectionView
    ) -> Bool
}


public extension ListLayout
{
    func visibleContentFrame(for collectionView : UICollectionView) -> CGRect
    {
        CGRect(
            x: collectionView.contentOffset.x + collectionView.lst_safeAreaInsets.left,
            y: collectionView.contentOffset.y + collectionView.lst_safeAreaInsets.top,
            width: collectionView.bounds.size.width,
            height: collectionView.bounds.size.height
        )
    }
    
    @discardableResult
    func updateHeaderPositions(in collectionView : UICollectionView) -> Bool
    {
        guard self.appearance.stickySectionHeaders else {
            return true
        }
        
        guard collectionView.frame.size.isEmpty == false else {
            return false
        }
        
        let direction = self.appearance.direction

        let visibleFrame = self.visibleContentFrame(for: collectionView)
        
        self.content.sections.forEachWithIndex { sectionIndex, isLast, section in
            let sectionMaxY = direction.maxY(for: section.frame)
            
            let header = section.header
            
            if direction.y(for: header.defaultFrame.origin) < direction.y(for: visibleFrame.origin) {
                
                // Make sure the pinned origin stays within the section's frame.
                
                header.pinnedY = min(
                    direction.y(for: visibleFrame.origin),
                    sectionMaxY - direction.height(for: header.size)
                )
            } else {
                header.pinnedY = nil
            }
        }
        
        return true
    }
    
    @discardableResult
    func updateOverscrollFooterPosition(in collectionView : UICollectionView) -> Bool
    {
        guard collectionView.frame.size.isEmpty == false else {
            return false
        }
        
        let footer = self.content.overscrollFooter
        
        let direction = self.appearance.direction
        
        let contentHeight = direction.height(for: self.contentSize)
        let viewHeight = direction.height(for: collectionView.contentFrame.size)
        
        // Overscroll positioning is done after we've sized the layout, because the overscroll footer does not actually
        // affect any form of layout or sizing. It appears only once the scroll view has been scrolled outside of its normal bounds.
        
        if contentHeight >= viewHeight {
            footer.y = contentHeight + direction.bottom(with: collectionView.contentInset) + direction.bottom(with: collectionView.lst_safeAreaInsets)
        } else {
            footer.y = viewHeight - direction.top(with: collectionView.contentInset) - direction.top(with: collectionView.lst_safeAreaInsets)
        }
        
        return true
    }
    
    func adjustPositionsForLayoutUnderflow(contentHeight : CGFloat, viewHeight: CGFloat, in collectionView : UICollectionView)
    {
        // Take into account the safe area, since that pushes content alignment down within our view.
        
        let safeAreaInsets : CGFloat = {
            switch self.appearance.direction {
            case .vertical: return collectionView.lst_safeAreaInsets.top + collectionView.lst_safeAreaInsets.bottom
            case .horizontal: return collectionView.lst_safeAreaInsets.left + collectionView.lst_safeAreaInsets.right
            }
        }()
        
        let additionalOffset = self.behavior.underflow.alignment.offsetFor(
            contentHeight: contentHeight,
            viewHeight: viewHeight - safeAreaInsets
        )
        
        // If we're pinned to the top of the view, there's no adjustment needed.
        
        guard additionalOffset > 0.0 else {
            return
        }
        
        // Provide additional adjustment.
        
        for section in self.content.sections {
            section.header.y += additionalOffset
            section.footer.y += additionalOffset
            
            for item in section.items {
                item.y += additionalOffset
            }
        }
    }
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
        delegate : CollectionViewLayoutDelegate,
        appearance : Appearance,
        in collectionView : UICollectionView
        )
    {
        self.header = {
            guard delegate.hasListHeader(in: collectionView) else {
                return .empty(.listHeader, direction: appearance.direction)
            }
            
            return .init(
                kind: SupplementaryKind.listHeader,
                direction: appearance.direction,
                layout: delegate.layoutForListHeader(in: collectionView),
                isPopulated: true
            )
        }()
        
        self.footer = {
            guard delegate.hasListFooter(in: collectionView) else {
                return .empty(.listFooter, direction: appearance.direction)
            }
            
            return .init(
                kind: SupplementaryKind.listFooter,
                direction: appearance.direction,
                layout: delegate.layoutForListFooter(in: collectionView),
                isPopulated: true
            )
        }()
        
        self.overscrollFooter = {
            guard delegate.hasOverscrollFooter(in: collectionView) else {
                return .empty(.overscrollFooter, direction: appearance.direction)
            }
            
            return .init(
                kind: SupplementaryKind.overscrollFooter,
                direction: appearance.direction,
                layout: delegate.layoutForOverscrollFooter(in: collectionView),
                isPopulated: true
            )
        }()
        
        let sectionCount = collectionView.numberOfSections
        
        self.sections = (0..<sectionCount).map { sectionIndex in
            
            let itemCount = collectionView.numberOfItems(inSection: sectionIndex)
            
            return .init(
                direction: appearance.direction,
                
                layout : delegate.layoutFor(section: sectionIndex, in: collectionView),
                
                header: {
                    guard delegate.hasHeader(in: sectionIndex, in: collectionView) else {
                        return .empty(.sectionHeader, direction: appearance.direction)
                    }
                    
                    return .init(
                        kind: SupplementaryKind.sectionHeader,
                        direction: appearance.direction,
                        layout: delegate.layoutForHeader(in: sectionIndex, in: collectionView),
                        isPopulated: true
                    )
                }(),
                
                footer: {
                    guard delegate.hasFooter(in: sectionIndex, in: collectionView) else {
                        return .empty(.sectionFooter, direction: appearance.direction)
                    }
                    
                    return .init(
                        kind: SupplementaryKind.sectionFooter,
                        direction: appearance.direction,
                        layout: delegate.layoutForFooter(in: sectionIndex, in: collectionView),
                        isPopulated: true
                    )
                }(),
                
                columns: delegate.columnLayout(for: sectionIndex, in: collectionView),
                
                items: (0..<itemCount).map { itemIndex in
                    let indexPath = IndexPath(item: itemIndex, section: sectionIndex)
                    
                    return .init(
                        delegateProvidedIndexPath: indexPath,
                        liveIndexPath: indexPath,
                        direction: appearance.direction,
                        layout: delegate.layoutForItem(at: indexPath, in: collectionView)
                    )
                }
            )
        }
    }
    
    //
    // MARK: Fetching Elements
    //
    
    func layoutAttributes(at indexPath : IndexPath) -> UICollectionViewLayoutAttributes
    {
        let item = self.item(at: indexPath)
        
        return item.layoutAttributes(with: indexPath)
    }
    
    func item(at indexPath : IndexPath) -> ListLayoutContent.ItemInfo
    {
        return self.sections[indexPath.section].items[indexPath.item]
    }
    
    func supplementaryLayoutAttributes(of kind : String, at indexPath : IndexPath) -> UICollectionViewLayoutAttributes?
    {
        let section = self.sections[indexPath.section]
        
        switch SupplementaryKind(rawValue: kind)! {
        case .listHeader: return self.header.layoutAttributes(with: indexPath)
        case .listFooter: return self.footer.layoutAttributes(with: indexPath)
            
        case .sectionHeader: return section.header.layoutAttributes(with: indexPath)
        case .sectionFooter: return section.footer.layoutAttributes(with: indexPath)
            
        case .overscrollFooter: return self.overscrollFooter.layoutAttributes(with: indexPath)
        }
    }
    
    func layoutAttributes(in rect: CGRect) -> [UICollectionViewLayoutAttributes]
    {
        /**
         Supplementary items are technically attached to index paths. Eg, list headers
         and footers are attached to (0,0), and section headers and footers are attached to
         (sectionIndex, 0). Because of this, we can't return any list headers or footers
         unless there's at least one section – the collection view will not have anything to
         attach them to, and will then crash.
         */
        guard self.sections.isEmpty == false else {
            return []
        }
        
        var attributes = [UICollectionViewLayoutAttributes]()
        
        // List Header
        
        if rect.intersects(self.header.visibleFrame) {
            attributes.append(self.header.layoutAttributes(with: self.header.kind.indexPath(in: 0)))
        }
        
        // Sections
        
        for (sectionIndex, section) in self.sections.enumerated() {
            
            guard rect.intersects(section.frame) else {
                continue
            }
            
            // Section Header
            
            if rect.intersects(section.header.visibleFrame) {
                attributes.append(section.header.layoutAttributes(with: section.header.kind.indexPath(in: sectionIndex)))
            }
            
            // Items
            
            for item in section.items {
                if rect.intersects(item.frame) {
                    attributes.append(item.layoutAttributes(with: item.liveIndexPath))
                }
            }
            
            // Section Footer
            
            if rect.intersects(section.footer.visibleFrame) {
                attributes.append(section.footer.layoutAttributes(with: section.footer.kind.indexPath(in: sectionIndex)))
            }
        }
        
        // List Footer
        
        if rect.intersects(self.footer.visibleFrame) {
            attributes.append(self.footer.layoutAttributes(with: self.footer.kind.indexPath(in: 0)))
        }
        
        // Overscroll Footer
        
        // Don't check the rect for the overscroll view as we do with other views; it's always outside of the contentSize.
        // Instead, just return it all the time to ensure the collection view will display it when needed.
        
        attributes.append(self.overscrollFooter.layoutAttributes(with: self.overscrollFooter.kind.indexPath(in: 0)))
        
        return attributes
    }
    
    //
    // MARK: Performing Layouts
    //
    
    func setSectionContentsFrames() {
        self.sections.forEach {
            $0.setContentsFrameWithContent()
        }
    }
    
    func reindexLiveIndexPaths()
    {
        self.sections.forEachWithIndex { sectionIndex, _, section in
            section.items.forEachWithIndex { itemIndex, _, item in
                item.liveIndexPath = IndexPath(item: itemIndex, section: sectionIndex)
            }
        }
    }
    
    func reindexDelegateProvidedIndexPaths()
    {
        self.sections.forEachWithIndex { sectionIndex, _, section in
            section.items.forEachWithIndex { itemIndex, _, item in
                item.delegateProvidedIndexPath = IndexPath(item: itemIndex, section: sectionIndex)
            }
        }
    }
    
    func move(from : IndexPath, to : IndexPath)
    {
        guard from != to else {
            return
        }
        
        let info = self.item(at: from)
        
        self.sections[from.section].items.remove(at: from.item)
        self.sections[to.section].items.insert(info, at: to.item)
    }
    
    //
    // MARK: Layout Data
    //
    
    var layoutAttributes : ListLayoutAttributes {
        ListLayoutAttributes(
            header: self.header.isPopulated ? .init(frame: self.header.defaultFrame) : nil,
            footer: self.footer.isPopulated ? .init(frame: self.footer.defaultFrame) : nil,
            overscrollFooter: self.overscrollFooter.isPopulated ? .init(frame: self.overscrollFooter.defaultFrame) : nil,
            sections: self.sections.map { section in
                .init(
                    frame: section.frame,
                    header: section.header.isPopulated ? .init(frame: section.header.defaultFrame) : nil,
                    footer: section.footer.isPopulated ? .init(frame: section.footer.defaultFrame) : nil,
                    items: section.items.map { item in
                        .init(frame: item.frame)
                    }
                )
            }
        )
    }
}


//
// MARK: Layout Information
//


public struct ListLayoutAttributes : Equatable {
    
    var header : Supplementary?
    var footer : Supplementary?
    var overscrollFooter : Supplementary?
    
    var sections : [Section]
    
    public struct Section : Equatable {
        var frame : CGRect
        
        var header : Supplementary?
        var footer : Supplementary?
        var items : [Item]
    }
    
    public struct Supplementary : Equatable {
        var frame : CGRect
    }
    
    public struct Item : Equatable {
        var frame : CGRect
    }
}


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
