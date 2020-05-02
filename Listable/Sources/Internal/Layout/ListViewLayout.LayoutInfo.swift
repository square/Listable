//
//  ListViewLayout.LayoutInfo.swift
//  Listable
//
//  Created by Kyle Van Essen on 11/19/19.
//

import Foundation


extension CollectionViewLayout
{
    final class LayoutInfo
    {
        //
        // MARK: Public Properties
        //
        
        let collectionViewSize : CGSize
        var contentSize : CGSize
        
        let appearance : Appearance
        
        let header : SupplementaryItemLayoutInfo
        let footer : SupplementaryItemLayoutInfo
        
        let overscrollFooter : SupplementaryItemLayoutInfo
        
        private(set) var sections : [SectionLayoutInfo]
        
        //
        // MARK: Initialization
        //
        
        init()
        {
            self.collectionViewSize = .zero
            self.contentSize = .zero
            
            self.appearance = Appearance()
            
            self.header = SupplementaryItemLayoutInfo.empty(.listHeader, direction: appearance.direction)
            self.footer = SupplementaryItemLayoutInfo.empty(.listFooter, direction: appearance.direction)
            self.overscrollFooter = SupplementaryItemLayoutInfo.empty(.overscrollFooter, direction: appearance.direction)
            
            self.sections = []
        }
        
        init(
            delegate : ListViewLayoutDelegate,
            appearance : Appearance,
            in collectionView : UICollectionView
            )
        {
            let sectionCount = collectionView.numberOfSections
            
            self.collectionViewSize = collectionView.bounds.size
            self.contentSize = .zero
            
            self.appearance = appearance
            
            self.header = {
                guard delegate.hasListHeader(in: collectionView) else {
                    return SupplementaryItemLayoutInfo.empty(.listHeader, direction: appearance.direction)
                }
                
                return SupplementaryItemLayoutInfo(
                    kind: SupplementaryKind.listHeader,
                    direction: appearance.direction,
                    layout: delegate.layoutForListHeader(in: collectionView),
                    isPopulated: true
                )
            }()
            
            self.footer = {
                guard delegate.hasListFooter(in: collectionView) else {
                    return SupplementaryItemLayoutInfo.empty(.listFooter, direction: appearance.direction)
                }
                
                return SupplementaryItemLayoutInfo(
                    kind: SupplementaryKind.listFooter,
                    direction: appearance.direction,
                    layout: delegate.layoutForListFooter(in: collectionView),
                    isPopulated: true
                )
            }()
            
            self.overscrollFooter = {
                guard delegate.hasOverscrollFooter(in: collectionView) else {
                    return SupplementaryItemLayoutInfo.empty(.overscrollFooter, direction: appearance.direction)
                }
                
                return SupplementaryItemLayoutInfo(
                    kind: SupplementaryKind.overscrollFooter,
                    direction: appearance.direction,
                    layout: delegate.layoutForOverscrollFooter(in: collectionView),
                    isPopulated: true
                )
            }()
            
            self.sections = sectionCount.mapEach { sectionIndex in
                
                let itemCount = collectionView.numberOfItems(inSection: sectionIndex)
                
                return SectionLayoutInfo(
                    direction: appearance.direction,
                    layout : delegate.layoutFor(section: sectionIndex, in: collectionView),
                    header: {
                        guard delegate.hasHeader(in: sectionIndex, in: collectionView) else {
                            return SupplementaryItemLayoutInfo.empty(.sectionHeader, direction: appearance.direction)
                        }
                        
                        return SupplementaryItemLayoutInfo(
                            kind: SupplementaryKind.sectionHeader,
                            direction: appearance.direction,
                            layout: delegate.layoutForHeader(in: sectionIndex, in: collectionView),
                            isPopulated: true
                        )
                    }(),
                    footer: {
                        guard delegate.hasFooter(in: sectionIndex, in: collectionView) else {
                            return SupplementaryItemLayoutInfo.empty(.sectionFooter, direction: appearance.direction)
                        }
                        
                        return SupplementaryItemLayoutInfo(
                            kind: SupplementaryKind.sectionFooter,
                            direction: appearance.direction,
                            layout: delegate.layoutForFooter(in: sectionIndex, in: collectionView),
                            isPopulated: true
                        )
                    }(),
                    columns: delegate.columnLayout(for: sectionIndex, in: collectionView),
                    items: itemCount.mapEach { itemIndex in
                        let indexPath = IndexPath(item: itemIndex, section: sectionIndex)
                        
                        return ItemLayoutInfo(
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
            
        // TODO: This is called a lot! Optimize it by caching the layout attributes and by checking the passed in frames.
        
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
                attributes.append(self.header.layoutAttributes(with: header.kind.indexPath(in: 0)))
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
                attributes.append(self.footer.layoutAttributes(with: footer.kind.indexPath(in: 0)))
            }
            
            // Overscroll Footer
            
            // Don't check the rect for the overscroll view as we do with other views; it's always outside of the contentSize.
            // Instead, just return it all the time to ensure the collection view will display it when needed.
            
            attributes.append(self.overscrollFooter.layoutAttributes(with: self.overscrollFooter.kind.indexPath(in: 0)))
            
            return attributes
        }
        
        func item(at indexPath : IndexPath) -> ItemLayoutInfo
        {
            return self.sections[indexPath.section].items[indexPath.item]
        }
        
        func layoutAttributes(at indexPath : IndexPath) -> UICollectionViewLayoutAttributes
        {
            let item = self.item(at: indexPath)
            
            return item.layoutAttributes(with: indexPath)
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
        
        //
        // MARK: Peforming Layouts
        //
        
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
        
        func shouldInvalidateLayoutFor(newCollectionViewSize : CGSize) -> Bool
        {
            switch self.appearance.direction {
            case .vertical: return self.collectionViewSize.width != newCollectionViewSize.width
            case .horizontal: return self.collectionViewSize.height != newCollectionViewSize.height
            }
        }
        
        @discardableResult
        func updateHeaders(in collectionView : UICollectionView) -> Bool
        {
            guard self.appearance.layout.stickySectionHeaders else {
                return true
            }
            
            guard collectionView.frame.size.isEmpty == false else {
                return false
            }
            
            let direction = self.appearance.direction

            let visibleFrame = CGRect(
                x: collectionView.contentOffset.x + collectionView.lst_safeAreaInsets.left,
                y: collectionView.contentOffset.y + collectionView.lst_safeAreaInsets.top,
                width: collectionView.bounds.size.width,
                height: collectionView.bounds.size.height
            )
            
            self.sections.forEachWithIndex { sectionIndex, isLast, section in
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
        func updateOverscrollPosition(in collectionView : UICollectionView) -> Bool
        {
            guard collectionView.frame.size.isEmpty == false else {
                return false
            }
            
            let footer = self.overscrollFooter
            
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
        
        func layout(
            delegate : ListViewLayoutDelegate,
            in collectionView : UICollectionView
            ) -> Bool
        {
            guard collectionView.frame.size.isEmpty == false else {
                return false
            }
            
            let direction = self.appearance.direction
            let layout = self.appearance.layout
            
            let viewSize = collectionView.bounds.size
            
            let viewWidth = direction.width(for: collectionView.bounds.size)
            let viewHeight = direction.height(for: collectionView.bounds.size)
            
            let rootWidth = ListLayout.width(
                with: direction.width(for: viewSize),
                padding: direction.horizontalPadding(with: layout.padding),
                constraint: layout.width
            )
            
            //
            // Item Positioning
            //
            
            /**
             Item positions are set and sent to the delegate first,
             in case the position affects the height calculation later in the layout pass.
             */
            self.setItemPositions()
            
            delegate.listViewLayoutUpdatedItemPositions(collectionView)
            
            //
            // Set Frame Origins
            //
            
            var lastSectionMaxY : CGFloat = 0.0
            var lastContentMaxY : CGFloat = 0.0
            
            //
            // Header
            //
            
            performLayout(for: self.header) { header in
                let hasListHeader = self.header.isPopulated
                
                let position = header.layout.width.position(with: viewSize, defaultWidth: rootWidth, layoutDirection: direction)
                let height = hasListHeader ? delegate.heightForListHeader(in: collectionView, width: position.width, layoutDirection: direction) : 0.0
                
                header.x = position.origin
                header.size = direction.size(width: position.width, height: height)
                header.y = lastContentMaxY
                
                if hasListHeader {
                    lastContentMaxY = direction.maxY(for: header.defaultFrame)
                }
            }
            
            switch direction {
            case .vertical:
                lastSectionMaxY += layout.padding.top
                lastContentMaxY += layout.padding.top
                
            case .horizontal:
                lastSectionMaxY += layout.padding.left
                lastContentMaxY += layout.padding.left
            }
            
            //
            // Sections
            //
            
            self.sections.forEachWithIndex { sectionIndex, isLast, section in
                
                let sectionPosition = section.layout.width.position(with: viewSize, defaultWidth: rootWidth, layoutDirection: direction)
                
                section.x = sectionPosition.origin
                
                //
                // Section Header
                //
                
                let hasSectionHeader = section.header.isPopulated
                let hasSectionFooter = section.footer.isPopulated
                
                performLayout(for: section.header) { header in
                    let width = header.layout.width.merge(with: section.layout.width)
                    let position = width.position(with: viewSize, defaultWidth: sectionPosition.width, layoutDirection: direction)
                    let height = hasSectionHeader ? delegate.heightForHeader(in: sectionIndex, in: collectionView, width: position.width, layoutDirection: direction) : 0.0
                    
                    header.x = position.origin
                    header.size = direction.size(width: position.width, height: height)
                    header.y = lastContentMaxY
                    
                    if hasSectionHeader {
                        lastContentMaxY = direction.maxY(for: section.header.defaultFrame)
                        lastContentMaxY += layout.sectionHeaderBottomSpacing
                    }
                }
                
                //
                // Section Items
                //
                
                if section.columns.count == 1 {
                    section.items.forEachWithIndex { itemIndex, isLast, item in
                        let indexPath = item.liveIndexPath
                        
                        let width = item.layout.width.merge(with: section.layout.width)
                        let itemPosition = width.position(with: viewSize, defaultWidth: sectionPosition.width, layoutDirection: direction)
                        let height = delegate.heightForItem(at: indexPath, in: collectionView, width: itemPosition.width, layoutDirection: direction)
                        
                        item.x = itemPosition.origin
                        item.y = lastContentMaxY
                        item.size = direction.size(width: itemPosition.width, height: height)
                        
                        lastContentMaxY += height

                        if isLast {
                            if hasSectionFooter {
                                lastContentMaxY += item.layout.itemToSectionFooterSpacing ?? layout.itemToSectionFooterSpacing
                            }
                        } else {
                            lastContentMaxY += item.layout.itemSpacing ?? layout.itemSpacing
                        }
                    }
                } else {
                    let itemWidth = round((sectionPosition.width - (section.columns.spacing * CGFloat(section.columns.count - 1))) / CGFloat(section.columns.count))
                    
                    let groupedItems = section.columns.group(values: section.items)
                    
                    groupedItems.forEachWithIndex { rowIndex, isLast, row in
                        var maxHeight : CGFloat = 0.0
                        var maxItemSpacing : CGFloat = 0.0
                        var maxItemToSectionFooterSpacing : CGFloat = 0.0
                        var columnXOrigin = section.x
                        
                        row.forEachWithIndex { columnIndex, isLast, item in
                            item.value.x = columnXOrigin
                            item.value.y = lastContentMaxY
                            
                            let indexPath = item.value.liveIndexPath
                            
                            let height = delegate.heightForItem(at: indexPath, in: collectionView, width: itemWidth, layoutDirection: direction)
                            
                            let itemSpacing = item.value.layout.itemSpacing ?? layout.itemSpacing
                            let itemToSectionFooterSpacing = item.value.layout.itemToSectionFooterSpacing ?? layout.itemToSectionFooterSpacing
                            
                            item.value.size = direction.size(width: itemWidth, height: height)
                            
                            maxHeight = max(height, maxHeight)
                            maxItemSpacing = max(itemSpacing, maxItemSpacing)
                            maxItemToSectionFooterSpacing = max(itemToSectionFooterSpacing, maxItemToSectionFooterSpacing)
                            
                            columnXOrigin += (itemWidth + section.columns.spacing)
                        }
                        
                        lastContentMaxY += maxHeight
                        
                        if isLast {
                            if hasSectionFooter {
                                lastContentMaxY += maxItemToSectionFooterSpacing
                            }
                        } else {
                            lastContentMaxY += maxItemSpacing
                        }
                    }
                }
                
                //
                // Section Footer
                //
                
                performLayout(for: section.footer) { footer in
                    let width = footer.layout.width.merge(with: section.layout.width)
                    let position = width.position(with: viewSize, defaultWidth: sectionPosition.width, layoutDirection: direction)
                    let height = hasSectionFooter ? delegate.heightForFooter(in: sectionIndex, in: collectionView, width: position.width, layoutDirection: direction) : 0.0
                    
                    footer.size = direction.size(width: position.width, height: height)
                    footer.x = position.origin
                    footer.y = lastContentMaxY
                    
                    if hasSectionFooter {
                        lastContentMaxY = direction.maxY(for: footer.defaultFrame)
                    }
                }
                
                //
                // Size The Section
                //
                
                section.size = direction.size(width: viewWidth, height: lastContentMaxY - lastSectionMaxY)
                section.y = lastSectionMaxY
                
                lastSectionMaxY = direction.maxY(for: section.frame)
                
                // Add additional padding from config.
                
                if isLast == false {
                    let additionalSectionSpacing = hasSectionFooter ? layout.interSectionSpacingWithFooter : layout.interSectionSpacingWithNoFooter
                    
                    lastSectionMaxY += additionalSectionSpacing
                    lastContentMaxY += additionalSectionSpacing
                }
            }
            
            switch direction {
            case .vertical: lastContentMaxY += layout.padding.bottom
            case .horizontal: lastContentMaxY += layout.padding.right
            }
            
            //
            // Footer
            //
            
            performLayout(for: self.footer) { footer in
                let hasFooter = footer.isPopulated
                
                let position = footer.layout.width.position(with: viewSize, defaultWidth: rootWidth, layoutDirection: direction)
                let height = hasFooter ? delegate.heightForListFooter(in: collectionView, width: position.width, layoutDirection: direction) : 0.0
                
                footer.size = direction.size(width: position.width, height: height)
                footer.x = position.origin
                footer.y = lastContentMaxY
                
                if hasFooter {
                    lastContentMaxY = direction.maxY(for: footer.defaultFrame)
                    lastContentMaxY += layout.sectionHeaderBottomSpacing
                }
            }
            
            //
            // Overscroll Footer
            //
                        
            performLayout(for: self.overscrollFooter) { footer in
                let hasFooter = footer.isPopulated

                let position = footer.layout.width.position(with: viewSize, defaultWidth: rootWidth, layoutDirection: direction)
                let height = hasFooter ? delegate.heightForOverscrollFooter(in: collectionView, width: position.width, layoutDirection: direction) : 0.0
                
                footer.x = position.origin
                footer.size = direction.size(width: position.width, height: height)
            }
            
            //
            // Remaining Calculations
            //
            
            self.contentSize = direction.size(width: viewWidth, height: lastContentMaxY)
            
            self.adjustPositionsForLayoutUnderflow(contentHeight: lastContentMaxY, viewHeight: viewHeight, in: collectionView)
            
            self.updateHeaders(in: collectionView)
            self.updateOverscrollPosition(in: collectionView)
            
            return true
        }
        
        private func setItemPositions()
        {
            self.sections.forEach { section in
                section.setItemPositions(with: self.appearance)
            }
        }
        
        private func adjustPositionsForLayoutUnderflow(contentHeight : CGFloat, viewHeight: CGFloat, in collectionView : UICollectionView)
        {
            // Take into account the safe area, since that pushes content alignment down within our view.
            
            let safeAreaInsets : CGFloat = {
                switch self.appearance.direction {
                case .vertical: return collectionView.lst_safeAreaInsets.top + collectionView.lst_safeAreaInsets.bottom
                case .horizontal: return collectionView.lst_safeAreaInsets.left + collectionView.lst_safeAreaInsets.right
                }
            }()
            
            let additionalOffset = self.appearance.underflow.alignment.offsetFor(
                contentHeight: contentHeight,
                viewHeight: viewHeight - safeAreaInsets
            )
            
            // If we're pinned to the top of the view, there's no adjustment needed.
            
            guard additionalOffset > 0.0 else {
                return
            }
            
            // Provide additional adjustment.
            
            for section in self.sections {
                section.header.y += additionalOffset
                section.footer.y += additionalOffset
                
                for item in section.items {
                    item.y += additionalOffset
                }
            }
        }
    }
}


extension CollectionViewLayout.LayoutInfo
{
    //
    // MARK: Layout Information
    //
    
    final class SectionLayoutInfo
    {
        let direction : LayoutDirection
        let layout : Section.Layout
        
        let header : SupplementaryItemLayoutInfo
        let footer : SupplementaryItemLayoutInfo
        
        let columns : Section.Columns
        
        var items : [ItemLayoutInfo]
        
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
            header : SupplementaryItemLayoutInfo,
            footer : SupplementaryItemLayoutInfo,
            columns : Section.Columns,
            items : [ItemLayoutInfo]
            )
        {
            self.direction = direction
            self.layout = layout
            
            self.header = header
            self.footer = footer
            
            self.columns = columns
            
            self.items = items
        }
        
        fileprivate func setItemPositions(with appearance : Appearance)
        {
            if self.columns.count == 1 {
                let groups = SectionLayoutInfo.grouped(
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
        
        private static func grouped(items : [ItemLayoutInfo], groupingHeight : CGFloat, appearance : Appearance) -> [[ItemLayoutInfo]]
        {
            var all = [[ItemLayoutInfo]]()
            var current = [ItemLayoutInfo]()
            
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
    
    final class SupplementaryItemLayoutInfo
    {
        static func empty(_ kind : CollectionViewLayout.SupplementaryKind, direction: LayoutDirection) -> SupplementaryItemLayoutInfo
        {
            return SupplementaryItemLayoutInfo(kind: kind, direction: direction, layout: .init(), isPopulated: false)
        }
        
        let kind : CollectionViewLayout.SupplementaryKind
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
        
        init(kind : CollectionViewLayout.SupplementaryKind, direction : LayoutDirection, layout : HeaderFooterLayout, isPopulated: Bool)
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
    
    final class ItemLayoutInfo
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


fileprivate extension Section.Columns
{
    struct Grouped<Value>
    {
        var value : Value
        var index : Int
    }
    
    func group<Value>(values input : [Value]) -> [[Grouped<Value>]]
    {
        var values : [Grouped<Value>] = input.mapWithIndex { index, _, value in
            return Grouped(value: value, index: index)
        }
        
        var grouped : [[Grouped<Value>]] = []
        
        while values.count > 0 {
            grouped.append(values.safeDropFirst(self.count))
        }
        
        return grouped
    }
}


fileprivate extension Array
{
    mutating func safeDropFirst(_ count : Int) -> [Element]
    {
        let safeCount = Swift.min(self.count, count)
        let values = self[0..<safeCount]
        
        self.removeFirst(safeCount)
        
        return Array(values)
    }
}


fileprivate extension Int
{
    func mapEach<Mapped>(_ block : (Int) -> Mapped) -> [Mapped]
    {
        var mapped = [Mapped]()
        
        for index in 0..<self {
            mapped.append(block(index))
        }
        
        return mapped
    }
}


internal extension UIView
{
    var lst_safeAreaInsets : UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return self.safeAreaInsets
        } else {
            return .zero
        }
    }
}

fileprivate func performLayout<Input>(for input : Input, _ block : (Input) -> ())
{
    block(input)
}
