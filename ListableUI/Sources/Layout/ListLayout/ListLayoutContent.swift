//
//  ListLayoutContent.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 6/7/20.
//

import Foundation
import UIKit

public final class ListLayoutContent {
    /// The full scrollable size of the content, provided by the layout's `ListLayoutResult` return value.
    public private(set) var contentSize: CGSize

    /// The natural width of the content, provided by the layout's `ListLayoutResult` return value.
    public private(set) var naturalContentWidth: CGFloat?

    public let containerHeader: SupplementaryItemInfo
    public let header: SupplementaryItemInfo
    public let footer: SupplementaryItemInfo

    public let overscrollFooter: SupplementaryItemInfo

    public let sections: [SectionInfo]

    public var all: [ListLayoutContentItem] {
        var all: [ListLayoutContentItem] = []

        if header.isPopulated {
            all.append(header)
        }

        all += sections.flatMap(\.all)

        if footer.isPopulated {
            all.append(footer)
        }

        return all
    }

    public func maxValue(for keyPath: KeyPath<ListLayoutContentItem, CGFloat>) -> CGFloat {
        all.reduce(0) { value, item in
            max(value, item[keyPath: keyPath])
        }
    }

    init() {
        contentSize = .zero
        naturalContentWidth = nil

        containerHeader = .empty(.listContainerHeader)
        header = .empty(.listHeader)
        footer = .empty(.listFooter)
        overscrollFooter = .empty(.overscrollFooter)

        sections = []
    }

    init(
        containerHeader: SupplementaryItemInfo?,
        header: SupplementaryItemInfo?,
        footer: SupplementaryItemInfo?,
        overscrollFooter: SupplementaryItemInfo?,
        sections: [SectionInfo]
    ) {
        contentSize = .zero
        naturalContentWidth = nil

        self.containerHeader = containerHeader ?? .empty(.listContainerHeader)
        self.header = header ?? .empty(.listHeader)
        self.footer = footer ?? .empty(.listFooter)
        self.overscrollFooter = overscrollFooter ?? .empty(.overscrollFooter)
        self.sections = sections
    }

    //

    // MARK: Fetching Elements

    //

    func layoutAttributes(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
        let item = item(at: indexPath)

        return item.layoutAttributes(with: indexPath)
    }

    func item(at indexPath: IndexPath) -> ListLayoutContent.ItemInfo {
        sections[indexPath.section].items[indexPath.item]
    }

    func supplementaryLayoutAttributes(of kind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        let section = sections[indexPath.section]

        switch SupplementaryKind(rawValue: kind)! {
        case .listContainerHeader: return containerHeader.layoutAttributes(with: indexPath)
        case .listHeader: return header.layoutAttributes(with: indexPath)
        case .listFooter: return footer.layoutAttributes(with: indexPath)

        case .sectionHeader: return section.header.layoutAttributes(with: indexPath)
        case .sectionFooter: return section.footer.layoutAttributes(with: indexPath)

        case .overscrollFooter: return overscrollFooter.layoutAttributes(with: indexPath)
        }
    }

    func layoutAttributes(in rect: CGRect, alwaysIncludeOverscroll: Bool) -> [UICollectionViewLayoutAttributes] {
        content(
            in: rect,
            alwaysIncludeOverscroll: alwaysIncludeOverscroll,
            includeUnpopulated: true
        )
        .map(\.collectionViewLayoutAttributes)
    }

    func content(
        in rect: CGRect,
        alwaysIncludeOverscroll: Bool,
        includeUnpopulated: Bool
    ) -> [ListLayoutContent.ContentItem] {
        /**
         Supplementary items are technically attached to index paths. Eg, list headers
         and footers are attached to (0,0), and section headers and footers are attached to
         (sectionIndex, 0). Because of this, we can't return any list headers or footers
         unless there's at least one section – the collection view will not have anything to
         attach them to, and will then crash.
         */
        if sections.isEmpty { return [] }

        var attributes = [ListLayoutContent.ContentItem]()

        func include(_ supplementary: ListLayoutContent.SupplementaryItemInfo) -> Bool {
            includeUnpopulated || supplementary.isPopulated
        }

        // Container Header

        if rect.intersects(containerHeader.visibleFrame) && include(containerHeader) {
            attributes.append(
                .supplementary(
                    containerHeader,
                    containerHeader.layoutAttributes(with: containerHeader.kind.indexPath(in: 0))
                )
            )
        }

        // List Header

        if rect.intersects(header.visibleFrame) && include(header) {
            attributes.append(
                .supplementary(
                    header,
                    header.layoutAttributes(with: header.kind.indexPath(in: 0))
                )
            )
        }

        // Sections

        for (sectionIndex, section) in sections.enumerated() {
            guard rect.intersects(section.contentsFrame) else {
                continue
            }

            // Section Header

            if rect.intersects(section.header.visibleFrame), include(section.header) {
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

            if rect.intersects(section.footer.visibleFrame), include(section.footer) {
                attributes.append(
                    .supplementary(
                        section.footer,
                        section.footer.layoutAttributes(with: section.footer.kind.indexPath(in: sectionIndex))
                    )
                )
            }
        }

        // List Footer

        if rect.intersects(footer.visibleFrame) && include(footer) {
            attributes.append(
                .supplementary(
                    footer,
                    footer.layoutAttributes(with: footer.kind.indexPath(in: 0))
                )
            )
        }

        // Overscroll Footer

        if alwaysIncludeOverscroll || (rect.intersects(overscrollFooter.visibleFrame) && include(overscrollFooter)) {
            // Don't check the rect for the overscroll view as we do with other views; it's always outside of the contentSize.
            // Instead, just return it all the time to ensure the collection view will display it when needed.
            attributes.append(
                .supplementary(
                    overscrollFooter,
                    overscrollFooter.layoutAttributes(with: overscrollFooter.kind.indexPath(in: 0))
                )
            )
        }

        return attributes
    }

    //

    // MARK: Performing Layouts

    //

    func apply(result: ListLayoutResult) {
        contentSize = result.contentSize
        naturalContentWidth = result.naturalContentWidth
    }

    func setSectionContentsFrames() {
        sections.forEach {
            $0.setContentsFrame()
        }
    }

    func move(from: [IndexPath], to: [IndexPath]) {
        precondition(from.count == to.count, "Counts did not match: \(from.count) vs \(to.count).")

        guard from != to else {
            return
        }

        struct Move {
            let from: IndexPath
            let to: IndexPath
            let item: ItemInfo
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

        reindexIndexPaths()
    }

    private func reindexIndexPaths() {
        sections.forEachWithIndex { sectionIndex, _, section in
            section.items.forEachWithIndex { itemIndex, _, item in
                item.indexPath = IndexPath(item: itemIndex, section: sectionIndex)
            }
        }
    }

    //

    // MARK: Layout Data

    //

    var layoutAttributes: ListLayoutAttributes {
        ListLayoutAttributes(
            contentSize: contentSize,
            naturalContentWidth: naturalContentWidth,
            containerHeader: containerHeader.isPopulated ? .init(frame: containerHeader.defaultFrame) : nil,
            header: header.isPopulated ? .init(frame: header.defaultFrame) : nil,
            footer: footer.isPopulated ? .init(frame: footer.defaultFrame) : nil,
            overscrollFooter: overscrollFooter.isPopulated ? .init(frame: overscrollFooter.defaultFrame) : nil,
            sections: sections.map { section in
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
public protocol ListLayoutContentItem: AnyObject {
    var measuredSize: CGSize { get set }

    var size: CGSize { get set }
    var x: CGFloat { get set }
    var y: CGFloat { get set }

    var zIndex: Int { get set }
}

public extension ListLayoutContent {
    final class SectionInfo {
        let state: PresentationState.SectionState

        public let header: SupplementaryItemInfo
        public let footer: SupplementaryItemInfo

        public internal(set) var items: [ItemInfo]

        public var layouts: SectionLayouts {
            state.model.layouts
        }

        var all: [ListLayoutContentItem] {
            var all: [ListLayoutContentItem] = []

            if header.isPopulated {
                all.append(header)
            }

            all += items

            if footer.isPopulated {
                all.append(footer)
            }

            return all
        }

        private(set) var contentsFrame: CGRect

        init(
            state: PresentationState.SectionState,
            header: SupplementaryItemInfo?,
            footer: SupplementaryItemInfo?,
            items: [ItemInfo]
        ) {
            self.state = state

            contentsFrame = .zero

            self.header = header ?? .empty(.sectionHeader)
            self.footer = footer ?? .empty(.sectionFooter)

            self.items = items
        }

        func setContentsFrame() {
            var allFrames: [CGRect] = []

            if header.isPopulated {
                allFrames.append(header.defaultFrame)
            }

            allFrames += items.map(\.frame)

            if footer.isPopulated {
                allFrames.append(footer.defaultFrame)
            }

            contentsFrame = .unioned(from: allFrames)
        }
    }

    final class SupplementaryItemInfo: ListLayoutContentItem {
        static func empty(_ kind: SupplementaryKind) -> SupplementaryItemInfo {
            SupplementaryItemInfo(
                state: nil,
                kind: kind,
                isPopulated: false, measurer: { _ in .zero }
            )
        }

        let state: AnyPresentationHeaderFooterState?

        let kind: SupplementaryKind
        public let measurer: (Sizing.MeasureInfo) -> CGSize

        public let isPopulated: Bool

        public var measuredSize: CGSize = .zero

        public var size: CGSize = .zero

        public var x: CGFloat = .zero
        var pinnedX: CGFloat?

        public var y: CGFloat = .zero
        var pinnedY: CGFloat?

        public var zIndex: Int = 0

        public var layouts: HeaderFooterLayouts {
            state?.anyModel.layouts ?? .init()
        }

        public var defaultFrame: CGRect {
            CGRect(
                origin: CGPoint(x: x, y: y),
                size: size
            )
        }

        public var visibleFrame: CGRect {
            CGRect(
                origin: CGPoint(
                    x: pinnedX ?? x,
                    y: pinnedY ?? y
                ),
                size: size
            )
        }

        init(
            state: AnyPresentationHeaderFooterState?,
            kind: SupplementaryKind,
            isPopulated: Bool,
            measurer: @escaping (Sizing.MeasureInfo) -> CGSize
        ) {
            self.state = state
            self.kind = kind
            self.isPopulated = isPopulated
            self.measurer = measurer
        }

        func layoutAttributes(with indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
            let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: kind.rawValue, with: indexPath)

            attributes.frame = visibleFrame
            attributes.zIndex = zIndex

            return attributes
        }
    }

    final class ItemInfo: ListLayoutContentItem {
        let state: AnyPresentationItemState

        var indexPath: IndexPath

        let insertAndRemoveAnimations: ItemInsertAndRemoveAnimations
        public let measurer: (Sizing.MeasureInfo) -> CGSize

        public var position: ItemPosition = .single

        public var measuredSize: CGSize = .zero

        public var size: CGSize = .zero

        public var x: CGFloat = .zero
        public var y: CGFloat = .zero

        public var zIndex: Int = 0

        public var layouts: ItemLayouts {
            state.anyModel.layouts
        }

        public var frame: CGRect {
            CGRect(
                origin: CGPoint(x: x, y: y),
                size: size
            )
        }

        init(
            state: AnyPresentationItemState,
            indexPath: IndexPath,
            insertAndRemoveAnimations: ItemInsertAndRemoveAnimations,
            measurer: @escaping (Sizing.MeasureInfo) -> CGSize
        ) {
            self.state = state
            self.indexPath = indexPath
            self.insertAndRemoveAnimations = insertAndRemoveAnimations
            self.measurer = measurer
        }

        func layoutAttributes(with indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)

            attributes.frame = frame
            attributes.zIndex = zIndex

            return attributes
        }
    }

    internal enum ContentItem {
        case item(ListLayoutContent.ItemInfo, UICollectionViewLayoutAttributes)

        case supplementary(ListLayoutContent.SupplementaryItemInfo, UICollectionViewLayoutAttributes)

        public var collectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
            switch self {
            case let .item(_, attributes): return attributes
            case let .supplementary(_, attributes): return attributes
            }
        }

        public var indexPath: IndexPath {
            collectionViewLayoutAttributes.indexPath
        }

        public var defaultFrame: CGRect {
            switch self {
            case let .item(item, _): return item.frame
            case let .supplementary(supplementary, _): return supplementary.defaultFrame
            }
        }
    }
}

extension CGRect {
    static func unioned(from rects: [CGRect]) -> CGRect {
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
