//
//  ListLayoutContent.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 6/7/20.
//

import Foundation
import UIKit


public final class ListLayoutContent
{
    /// The full scrollable size of the content, provided by the layout's `ListLayoutResult` return value.
    public private(set) var contentSize : CGSize
    
    /// The natural width of the content, provided by the layout's `ListLayoutResult` return value.
    public private(set) var naturalContentWidth : CGFloat?
    
    public let containerHeader : SupplementaryItemInfo
    public let header : SupplementaryItemInfo
    public let footer : SupplementaryItemInfo
    
    public let overscrollFooter : SupplementaryItemInfo
    
    public let sections : [SectionInfo]
    
    public var all : [ListLayoutContentItem] {
        var all : [ListLayoutContentItem] = []
        
        if header.isPopulated {
            all.append(header)
        }
        
        all += sections.flatMap { $0.all }
        
        if footer.isPopulated {
            all.append(footer)
        }
        
        return all
    }
    
    public func maxValue(for keyPath : KeyPath<ListLayoutContentItem, CGFloat>) -> CGFloat {
        self.all.reduce(0) { value, item in
            max(value, item[keyPath: keyPath])
        }
    }
    
    init()
    {
        self.contentSize = .zero
        self.naturalContentWidth = nil
        
        self.containerHeader = .empty(.listContainerHeader)
        self.header = .empty(.listHeader)
        self.footer = .empty(.listFooter)
        self.overscrollFooter = .empty(.overscrollFooter)
        
        self.sections = []
    }
    
    init(
        containerHeader : SupplementaryItemInfo?,
        header : SupplementaryItemInfo?,
        footer : SupplementaryItemInfo?,
        overscrollFooter : SupplementaryItemInfo?,
        sections : [SectionInfo]
    ) {
        self.contentSize = .zero
        self.naturalContentWidth = nil
        
        self.containerHeader = containerHeader ?? .empty(.listContainerHeader)
        self.header = header ?? .empty(.listHeader)
        self.footer = footer ?? .empty(.listFooter)
        self.overscrollFooter = overscrollFooter ?? .empty(.overscrollFooter)
        self.sections = sections
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

        guard let typedKind = SupplementaryKind(rawValue: kind) else {
            return nil
        }

        switch typedKind {
        case .listContainerHeader: return self.containerHeader.layoutAttributes(with: indexPath)
        case .listHeader: return self.header.layoutAttributes(with: indexPath)
        case .listFooter: return self.footer.layoutAttributes(with: indexPath)
            
        case .sectionHeader: return section.header.layoutAttributes(with: indexPath)
        case .sectionFooter: return section.footer.layoutAttributes(with: indexPath)
            
        case .overscrollFooter: return self.overscrollFooter.layoutAttributes(with: indexPath)
        }
    }
    
    func layoutAttributes(in rect: CGRect, alwaysIncludeOverscroll : Bool) -> [UICollectionViewLayoutAttributes] {
        self
            .content(
                in: rect,
                alwaysIncludeOverscroll: alwaysIncludeOverscroll,
                includeUnpopulated: true
            )
            .map(\.collectionViewLayoutAttributes)
    }
    
    func content(
        in rect: CGRect,
        alwaysIncludeOverscroll : Bool,
        includeUnpopulated: Bool
    ) -> [ListLayoutContent.ContentItem]
    {
        /**
         Supplementary items are technically attached to index paths. Eg, list headers
         and footers are attached to (0,0), and section headers and footers are attached to
         (sectionIndex, 0). Because of this, we can't return any list headers or footers
         unless there's at least one section – the collection view will not have anything to
         attach them to, and will then crash.
         */
        if self.sections.isEmpty { return [] }
        
        var attributes = [ListLayoutContent.ContentItem]()
        
        func include(_ supplementary : ListLayoutContent.SupplementaryItemInfo) -> Bool {
            return includeUnpopulated || supplementary.isPopulated
        }
        
        // Container Header
        
        if (rect.intersects(self.containerHeader.visibleFrame) || self.containerHeader.containsFirstResponder) && include(self.containerHeader) {
            attributes.append(
                .supplementary(
                    self.containerHeader,
                    self.containerHeader.layoutAttributes(with: self.containerHeader.kind.indexPath(in: 0))
                )
            )
        }
        
        // List Header
        
        if (rect.intersects(self.header.visibleFrame) || self.header.containsFirstResponder) && include(self.header) {
            attributes.append(
                .supplementary(
                    self.header,
                    self.header.layoutAttributes(with: self.header.kind.indexPath(in: 0))
                )
            )
        }
        
        // Sections
        
        for (sectionIndex, section) in self.sections.enumerated() {
            
            guard rect.intersects(section.contentsFrame) else {
                continue
            }
            
            // Section Header
            
            if (rect.intersects(section.header.visibleFrame) || section.header.containsFirstResponder) && include(section.header) {
                attributes.append(
                    .supplementary(
                        section.header,
                        section.header.layoutAttributes(with: section.header.kind.indexPath(in: sectionIndex))
                    )
                )
            }
            
            // Items
            
            for item in section.items {
                if rect.intersects(item.frame) {
                    attributes.append(
                        .item(
                            item,
                            item.layoutAttributes(with: item.indexPath)
                        )
                    )
                }
            }
            
            // Section Footer
            
            if (rect.intersects(section.footer.visibleFrame) || section.footer.containsFirstResponder) && include(section.footer) {
                attributes.append(
                    .supplementary(
                        section.footer,
                        section.footer.layoutAttributes(with: section.footer.kind.indexPath(in: sectionIndex))
                    )
                )
            }
        }
        
        // List Footer
        
        if (rect.intersects(self.footer.visibleFrame) || self.footer.containsFirstResponder) && include(self.footer) {
            attributes.append(
                .supplementary(
                    self.footer,
                    self.footer.layoutAttributes(with: self.footer.kind.indexPath(in: 0))
                )
            )
        }
        
        // Overscroll Footer
        
        if alwaysIncludeOverscroll || (rect.intersects(self.overscrollFooter.visibleFrame) && include(self.overscrollFooter)) {
            
            // Don't check the rect for the overscroll view as we do with other views; it's always outside of the contentSize.
            // Instead, just return it all the time to ensure the collection view will display it when needed.
            
            attributes.append(
                .supplementary(
                    self.overscrollFooter,
                    self.overscrollFooter.layoutAttributes(with: self.overscrollFooter.kind.indexPath(in: 0))
                )
            )
        }
        
        return attributes
    }
    
    //
    // MARK: Performing Layouts
    //
    
    func apply(result : ListLayoutResult) {
        self.contentSize = result.contentSize
        self.naturalContentWidth = result.naturalContentWidth
    }
    
    func setSectionContentsFrames() {
        self.sections.forEach {
            $0.setContentsFrame()
        }
    }
    
    func move(from : [IndexPath], to : [IndexPath])
    {
        precondition(from.count == to.count, "Counts did not match: \(from.count) vs \(to.count).")
        
        guard from != to else {
            return
        }
        
        struct Move {
            let from : IndexPath
            let to : IndexPath
            let item : ItemInfo
        }
        
        let moves = zip(from, to).map { from, to in
            Move(from: from, to: to, item: self.item(at: from))
        }
        
        /// 1) Remove the moves backwards, so that the removals do not affect earlier indexes.
        
        moves.sorted { $0.from > $1.from }.forEach {
            self.sections[$0.from.section].items.remove(at: $0.from.item)
        }
        
        /// 2) In the opposite order, now add back the items in their new orders. This is done
        /// in the opposite order so index paths remain stable.
        
        moves.sorted { $0.to < $1.to }.forEach {
            self.sections[$0.to.section].items.insert($0.item, at: $0.to.item)
        }
        
        self.reindexIndexPaths()
    }
    
    private func reindexIndexPaths()
    {
        self.sections.forEachWithIndex { sectionIndex, _, section in
            section.items.forEachWithIndex { itemIndex, _, item in
                item.indexPath = IndexPath(item: itemIndex, section: sectionIndex)
            }
        }
    }
    
    //
    // MARK: Layout Data
    //
    
    var layoutAttributes : ListLayoutAttributes {
        ListLayoutAttributes(
            contentSize: self.contentSize,
            naturalContentWidth : self.naturalContentWidth,
            containerHeader: self.containerHeader.isPopulated ? .init(frame: self.containerHeader.defaultFrame) : nil,
            header: self.header.isPopulated ? .init(frame: self.header.defaultFrame) : nil,
            footer: self.footer.isPopulated ? .init(frame: self.footer.defaultFrame) : nil,
            overscrollFooter: self.overscrollFooter.isPopulated ? .init(frame: self.overscrollFooter.defaultFrame) : nil,
            sections: self.sections.map { section in
                .init(
                    frame: section.contentsFrame,
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


// TODO: Consider `AnyListLayoutContentItem`
public protocol ListLayoutContentItem : AnyObject
{
    var measuredSize : CGSize { get set }
    
    var size : CGSize { get set }
    var x : CGFloat { get set }
    var y : CGFloat { get set }
    
    var zIndex : Int { get set }
}


extension ListLayoutContent
{
    public final class SectionInfo
    {
        let state : PresentationState.SectionState
        
        public let header : SupplementaryItemInfo
        public let footer : SupplementaryItemInfo
                
        public internal(set) var items : [ItemInfo]
        
        public var layouts : SectionLayouts {
            self.state.model.layouts
        }
        
        public var isHeaderSticky : Bool? {
            state.header.state?.anyModel.isStickySectionHeader
        }
        
        var all : [ListLayoutContentItem] {
            var all : [ListLayoutContentItem] = []
            
            if header.isPopulated {
                all.append(header)
            }
            
            all += self.items
            
            if footer.isPopulated {
                all.append(footer)
            }
            
            return all
        }
        
        private(set) var contentsFrame : CGRect
                
        init(
            state : PresentationState.SectionState,
            header : SupplementaryItemInfo?,
            footer : SupplementaryItemInfo?,
            items : [ItemInfo]
        ) {
            self.state = state
            
            self.contentsFrame = .zero
            
            self.header = header ?? .empty(.sectionHeader)
            self.footer = footer ?? .empty(.sectionFooter)
            
            self.items = items
        }
        
        func setContentsFrame() {
            
            var allFrames : [CGRect] = []
            
            if header.isPopulated {
                allFrames.append(header.defaultFrame)
            }
            
            allFrames += items.map { $0.frame }
            
            if footer.isPopulated {
                allFrames.append(footer.defaultFrame)
            }

            self.contentsFrame = .unioned(from: allFrames)
        }
    }

    public final class SupplementaryItemInfo : ListLayoutContentItem
    {
        static func empty(_ kind : SupplementaryKind) -> SupplementaryItemInfo
        {
            SupplementaryItemInfo(
                state: nil,
                kind: kind,
                isPopulated: false, measurer: { _ in .zero }
            )
        }
        
        let state : AnyPresentationHeaderFooterState?
        
        let kind : SupplementaryKind
        public let measurer : (Sizing.MeasureInfo) -> CGSize
                
        public let isPopulated : Bool
                        
        public var measuredSize : CGSize = .zero
        
        public var size : CGSize = .zero
        
        public var x : CGFloat = .zero
        var pinnedX : CGFloat? = nil
        
        public var y : CGFloat = .zero
        var pinnedY : CGFloat? = nil
        
        public var zIndex : Int = 0
        
        public var layouts : HeaderFooterLayouts {
            self.state?.anyModel.layouts ?? .init()
        }
        
        public var containsFirstResponder : Bool {
            self.state?.containsFirstResponder ?? false
        }
        
        public var defaultFrame : CGRect {
            CGRect(
                origin: CGPoint(x: self.x, y: self.y),
                size: self.size
            )
        }
        
        public var visibleFrame : CGRect {
            CGRect(
                origin: CGPoint(
                    x: self.pinnedX ?? self.x,
                    y: self.pinnedY ?? self.y
                ),
                size: self.size
            )
        }
        
        init(
            state : AnyPresentationHeaderFooterState?,
            kind : SupplementaryKind,
            isPopulated: Bool,
            measurer : @escaping (Sizing.MeasureInfo) -> CGSize
        ) {
            self.state = state
            self.kind = kind
            self.isPopulated = isPopulated
            self.measurer = measurer
        }
        
        func layoutAttributes(with indexPath : IndexPath) -> UICollectionViewLayoutAttributes
        {
            let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: self.kind.rawValue, with: indexPath)
            
            attributes.frame = self.visibleFrame
            attributes.zIndex = self.zIndex
            
            return attributes
        }
    }
    

    public final class ItemInfo : ListLayoutContentItem
    {
        let state : AnyPresentationItemState
        
        var indexPath : IndexPath
                
        let insertAndRemoveAnimations : ItemInsertAndRemoveAnimations
        public let measurer : (Sizing.MeasureInfo) -> CGSize
        
        public var position : ItemPosition = .single
                
        public var measuredSize : CGSize = .zero
        
        public var size : CGSize = .zero
                
        public var x : CGFloat = .zero
        public var y : CGFloat = .zero
        
        public var zIndex : Int = 0
        
        public var layouts : ItemLayouts {
            self.state.anyModel.layouts
        }
        
        public var frame : CGRect {
            CGRect(
                origin: CGPoint(x: self.x, y: self.y),
                size: self.size
            )
        }
        
        init(
            state : AnyPresentationItemState,
            indexPath : IndexPath,
            insertAndRemoveAnimations : ItemInsertAndRemoveAnimations,
            measurer : @escaping (Sizing.MeasureInfo) -> CGSize
        ) {
            self.state = state
            self.indexPath = indexPath
            self.insertAndRemoveAnimations = insertAndRemoveAnimations
            self.measurer = measurer
        }
        
        func layoutAttributes(with indexPath : IndexPath) -> UICollectionViewLayoutAttributes
        {
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            attributes.frame = self.frame
            attributes.zIndex = self.zIndex
            
            return attributes
        }
    }
    
    enum ContentItem {
        
        case item(ListLayoutContent.ItemInfo, UICollectionViewLayoutAttributes)
        
        case supplementary(ListLayoutContent.SupplementaryItemInfo, UICollectionViewLayoutAttributes)
        
        public var collectionViewLayoutAttributes : UICollectionViewLayoutAttributes {
            switch self {
            case .item(_, let attributes): return attributes
            case .supplementary(_, let attributes): return attributes
            }
        }
        
        public var indexPath : IndexPath {
            self.collectionViewLayoutAttributes.indexPath
        }
        
        public var defaultFrame : CGRect {
            switch self {
            case .item(let item, _): return item.frame
            case .supplementary(let supplementary, _): return supplementary.defaultFrame
            }
        }
        
        /// Returns the percentage from `0.0` to `1.0` that this item overlaps `container`.
        func percentageVisible(inside container: CGRect) -> CGFloat {
            collectionViewLayoutAttributes.frame.percentageVisible(inside: container)
        }
    }
}


extension CGRect {
    static func unioned(from rects : [CGRect]) -> CGRect {
        
        let rects = rects.filter {
            $0.isEmpty == false
        }
        
        guard let first = rects.first else {
            return .zero
        }

        var frame = first
        
        for rect in rects {
            frame = frame.union(rect)
        }
        
        return frame
    }
}
