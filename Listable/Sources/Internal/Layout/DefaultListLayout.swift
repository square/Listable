//
//  DefaultListLayout.swift
//  Listable
//
//  Created by Kyle Van Essen on 11/19/19.
//

import Foundation


final class DefaultListLayout : ListLayout
{
    //
    // MARK: Public Properties
    //
    
    var contentSize : CGSize
        
    let appearance : Appearance
    
    let content : ListLayoutContent
    
    //
    // MARK: Initialization
    //
    
    init()
    {
        self.contentSize = .zero
                
        self.appearance = Appearance()
        
        self.content = ListLayoutContent(with: self.appearance)
    }
    
    init(
        delegate : CollectionViewLayoutDelegate,
        appearance : Appearance,
        in collectionView : UICollectionView
        )
    {
        self.contentSize = .zero
                
        self.appearance = appearance
        
        self.content = ListLayoutContent(
            delegate: delegate,
            appearance: appearance,
            in: collectionView
        )
    }
    
    //
    // MARK: Performing Layouts
    //
    
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
    func updateOverscrollPosition(in collectionView : UICollectionView) -> Bool
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
    
    func layout(
        delegate : CollectionViewLayoutDelegate,
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
        
        let rootWidth = Appearance.Layout.width(
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
        
        performLayout(for: self.content.header) { header in
            let hasListHeader = self.content.header.isPopulated
            
            let position = header.layout.width.position(with: viewSize, defaultWidth: rootWidth, layoutDirection: direction)
            
            let height : CGFloat
            
            if hasListHeader {
                height = delegate.sizeForListHeader(
                    in: collectionView,
                    measuredIn: CGSize(width: position.width, height: .greatestFiniteMagnitude),
                    defaultSize: CGSize(width: 0.0, height: self.appearance.sizing.listHeaderHeight),
                    layoutDirection: direction
                ).height
            } else {
                height = 0.0
            }
            
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
        
        self.content.sections.forEachWithIndex { sectionIndex, isLast, section in
            
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
                let height : CGFloat
                
                if hasSectionHeader {
                    height = delegate.sizeForHeader(
                        in: sectionIndex,
                        in: collectionView,
                        measuredIn: CGSize(width: position.width, height: .greatestFiniteMagnitude),
                        defaultSize: CGSize(width: 0.0, height: self.appearance.sizing.sectionHeaderHeight),
                        layoutDirection: direction
                    ).height
                } else {
                    height = 0.0
                }
                
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
                    
                    let height = delegate.sizeForItem(
                        at: indexPath,
                        in: collectionView,
                        measuredIn: CGSize(width: itemPosition.width, height: .greatestFiniteMagnitude),
                        defaultSize: CGSize(width: 0.0, height: self.appearance.sizing.itemHeight),
                        layoutDirection: direction
                    ).height
                    
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
                                                
                        let height = delegate.sizeForItem(
                            at: indexPath,
                            in: collectionView,
                            measuredIn: CGSize(width: itemWidth, height: .greatestFiniteMagnitude),
                            defaultSize: CGSize(width: 0.0, height: self.appearance.sizing.itemHeight),
                            layoutDirection: direction
                        ).height
                        
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
                
                let height : CGFloat
                
                if hasSectionFooter {
                    height = delegate.sizeForFooter(
                        in: sectionIndex,
                        in: collectionView,
                        measuredIn: CGSize(width: position.width, height: .greatestFiniteMagnitude),
                        defaultSize: CGSize(width: 0.0, height: self.appearance.sizing.sectionFooterHeight),
                        layoutDirection: direction
                    ).height
                } else {
                    height = 0.0
                }
                
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
        
        performLayout(for: self.content.footer) { footer in
            let hasFooter = footer.isPopulated
            
            let position = footer.layout.width.position(with: viewSize, defaultWidth: rootWidth, layoutDirection: direction)
            
            let height : CGFloat
            
            if hasFooter {
                height = delegate.sizeForListFooter(
                    in: collectionView,
                    measuredIn: CGSize(width: position.width, height: .greatestFiniteMagnitude),
                    defaultSize: CGSize(width: 0.0, height: self.appearance.sizing.listFooterHeight),
                    layoutDirection: direction
                ).height
            } else {
                height = 0.0
            }
            
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
                    
        performLayout(for: self.content.overscrollFooter) { footer in
            let hasFooter = footer.isPopulated

            let position = footer.layout.width.position(with: viewSize, defaultWidth: rootWidth, layoutDirection: direction)
            
            let height : CGFloat
            
            if hasFooter {
                height = delegate.sizeForOverscrollFooter(
                    in: collectionView,
                    measuredIn: CGSize(width: position.width, height: .greatestFiniteMagnitude),
                    defaultSize: CGSize(width: 0.0, height: self.appearance.sizing.overscrollFooterHeight),
                    layoutDirection: direction
                ).height
            } else {
                height = 0.0
            }
            
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
        self.content.sections.forEach { section in
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
        
        for section in self.content.sections {
            section.header.y += additionalOffset
            section.footer.y += additionalOffset
            
            for item in section.items {
                item.y += additionalOffset
            }
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


fileprivate func performLayout<Input>(for input : Input, _ block : (Input) -> ())
{
    block(input)
}
