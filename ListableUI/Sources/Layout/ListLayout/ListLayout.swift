//
//  ListLayout.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 5/2/20.
//

import Foundation
import UIKit


public protocol ListLayout : AnyListLayout
{
    associatedtype LayoutAppearance:ListLayoutAppearance
    
    static var defaults : ListLayoutDefaults { get }
    
    var layoutAppearance : LayoutAppearance { get }
            
    init(
        layoutAppearance : LayoutAppearance,
        appearance : Appearance,
        behavior : Behavior,
        content : ListLayoutContent
    )
}


public struct ListLayoutLayoutContext {
    
    public var viewBounds : CGRect
    public var safeAreaInsets : UIEdgeInsets
    public var contentInset : UIEdgeInsets
    public var adjustedContentInset : UIEdgeInsets
    
    public var environment : ListEnvironment
    
    public init(
        viewBounds : CGRect,
        safeAreaInsets : UIEdgeInsets,
        contentInset : UIEdgeInsets,
        adjustedContentInset : UIEdgeInsets,
        environment : ListEnvironment
    ) {
        self.viewBounds = viewBounds
        self.safeAreaInsets = safeAreaInsets
        self.contentInset = contentInset
        self.adjustedContentInset = adjustedContentInset
        self.environment = environment
    }
    
    init(
        collectionView : UICollectionView,
        environment : ListEnvironment
    ) {
        self.viewBounds = collectionView.bounds
        self.safeAreaInsets = collectionView.safeAreaInsets
        self.contentInset = collectionView.contentInset
        self.adjustedContentInset = collectionView.adjustedContentInset
        
        self.environment = environment
    }
}


extension ListLayout
{
    public var direction: LayoutDirection {
        self.layoutAppearance.direction
    }
    
    public var bounds : ListContentBounds? {
        self.layoutAppearance.bounds
    }

    public var listHeaderPosition: ListHeaderPosition {
        self.layoutAppearance.listHeaderPosition
    }
    
    public var stickySectionHeaders: Bool {
        self.layoutAppearance.stickySectionHeaders
    }
    
    public var pagingBehavior: ListPagingBehavior {
        self.layoutAppearance.pagingBehavior
    }
    
    public var scrollViewProperties: ListLayoutScrollViewProperties {
        self.layoutAppearance.scrollViewProperties
    }
}


public protocol AnyListLayout : AnyObject
{
    //
    // MARK: Public Properties
    //
    
    var appearance : Appearance { get }
    var behavior : Behavior { get }
    
    var content : ListLayoutContent { get }
    
    var direction : LayoutDirection { get }
    
    var bounds : ListContentBounds? { get }

    var listHeaderPosition : ListHeaderPosition { get }

    var stickySectionHeaders : Bool { get }
    
    var pagingBehavior : ListPagingBehavior { get }
    
    var scrollViewProperties : ListLayoutScrollViewProperties { get }
    
    //
    // MARK: Performing Layouts
    //
    
    func updateLayout(in context : ListLayoutLayoutContext)
    
    func layout(
        delegate : CollectionViewLayoutDelegate?,
        in context : ListLayoutLayoutContext
    ) -> ListLayoutResult
    
    func setZIndexes()
    
    //
    // MARK: Configuring Reordering
    //
    
    func adjust(
        layoutAttributesForReorderingItem attributes : inout ListContentLayoutAttributes,
        originalAttributes : ListContentLayoutAttributes,
        at indexPath: IndexPath,
        withTargetPosition position: CGPoint
    )
}


extension AnyListLayout
{
    func performLayout(
        with delegate : CollectionViewLayoutDelegate?,
        in context : ListLayoutLayoutContext
    ) {
        let result = self.layout(
            delegate: delegate,
            in: context
        )
        
        self.content.apply(result: result)
        
        self.content.setSectionContentsFrames()
        
        self.updateLayout(in: context)
        
        self.setZIndexes()
        
        self.updateOverscrollFooterPosition(in: context)
        self.adjustPositionsForLayoutUnderflow(in: context)
    }
    
    public func setZIndexes()
    {
        self.content.containerHeader.zIndex = 6
        
        self.content.header.zIndex = 5
        
        self.content.sections.forEachWithIndex { sectionIndex, _, section in
            section.header.zIndex = 4
            
            section.items.forEach { item in
                item.zIndex = 3
            }
            
            section.footer.zIndex = 2
        }
        
        self.content.footer.zIndex = 1
        self.content.overscrollFooter.zIndex = 0
    }
    
    public func adjust(
        layoutAttributesForReorderingItem attributes : inout ListContentLayoutAttributes,
        originalAttributes : ListContentLayoutAttributes,
        at indexPath: IndexPath,
        withTargetPosition position: CGPoint
    ) {
        // Nothing. Just a default implementation.
    }
}


extension AnyListLayout
{
    public func visibleContentFrame(for collectionView : UICollectionView) -> CGRect
    {
        CGRect(
            x: collectionView.contentOffset.x + collectionView.safeAreaInsets.left,
            y: collectionView.contentOffset.y + collectionView.safeAreaInsets.top,
            width: collectionView.bounds.size.width,
            height: collectionView.bounds.size.height
        )
    }

    public func positionStickyListHeaderIfNeeded(in collectionView: UICollectionView)
    {
        guard self.listHeaderPosition != .inline else { return }

        let visibleContentFrame = self.visibleContentFrame(for: collectionView)

        let header = self.content.header

        let headerOrigin = self.direction.y(for: header.defaultFrame.origin)
        let visibleContentOrigin = self.direction.y(for: visibleContentFrame.origin)

        /// `fixed` only works if there's no `containerHeader`.
        let shouldBeFixed =  listHeaderPosition == .fixed && !content.containerHeader.isPopulated

        if headerOrigin < visibleContentOrigin || shouldBeFixed {

            // Make sure the pinned origin stays within the list's frame.

            self.direction.switch(
                vertical: {
                    header.pinnedY = visibleContentFrame.origin.y
                },
                horizontal: {
                    header.pinnedX = visibleContentFrame.origin.x
                }
            )
        } else {
            header.pinnedY = nil
            header.pinnedX = nil
        }
    }
    
    // TODO: This should take in a `context` so we can call it in layout tests too,
    // when not using a collection view.
    public func positionStickySectionHeadersIfNeeded(in collectionView : UICollectionView)
    {
        guard self.stickySectionHeaders else { return }
        
        var visibleContentFrame = self.visibleContentFrame(for: collectionView)

        switch listHeaderPosition {
        case .inline:
            break
        case .sticky, .fixed:
            let listHeaderHeight = self.direction.height(for: self.content.header.size)
            self.direction.switch {
                visibleContentFrame.size.height -= listHeaderHeight
                visibleContentFrame.origin.y += listHeaderHeight
            } horizontal: {
                visibleContentFrame.size.width -= listHeaderHeight
                visibleContentFrame.origin.x += listHeaderHeight
            }
        }
        
        self.content.sections.forEachWithIndex { sectionIndex, isLast, section in
            let sectionBottom = self.direction.maxY(for: section.contentsFrame)
            
            let header = section.header
            
            let headerOrigin = self.direction.y(for: header.defaultFrame.origin)
            let visibleContentOrigin = self.direction.y(for: visibleContentFrame.origin)
            
            if headerOrigin < visibleContentOrigin {
                
                // Make sure the pinned origin stays within the section's frame.
                
                self.direction.switch(
                    vertical: {
                        header.pinnedY = min(
                            visibleContentFrame.origin.y,
                            sectionBottom - header.size.height
                        )
                    },
                    horizontal: {
                        header.pinnedX = min(
                            visibleContentFrame.origin.x,
                            sectionBottom - header.size.width
                        )
                    }
                )
            } else {
                header.pinnedY = nil
                header.pinnedX = nil
            }
        }
    }
    
    public func updateOverscrollFooterPosition(in context : ListLayoutLayoutContext)
    {
        /// TODO: This method should be using `adjustedContentInset`,
        /// not the safe area and content inset directly.
        
        let footer = self.content.overscrollFooter
                
        let contentHeight = self.direction.height(for: self.content.contentSize)
        let viewHeight = self.direction.height(for: context.viewBounds.inset(by: context.adjustedContentInset).size)
        
        // Overscroll positioning is done after we've sized the layout, because the overscroll footer does not actually
        // affect any form of layout or sizing. It appears only once the scroll view has been scrolled outside of its normal bounds.
        
        if contentHeight >= viewHeight {
            footer.y = self.direction.switch(
                vertical: contentHeight + context.contentInset.bottom + context.safeAreaInsets.bottom,
                horizontal: contentHeight + context.contentInset.right + context.safeAreaInsets.right
            )
        } else {
            footer.y = self.direction.switch(
                vertical: viewHeight - context.contentInset.top - context.safeAreaInsets.top,
                horizontal: viewHeight - context.contentInset.left - context.safeAreaInsets.left
            )
        }
    }
    
    public func adjustPositionsForLayoutUnderflow(in context : ListLayoutLayoutContext)
    {
        // Take into account the safe area, since that pushes content alignment down within our view.
        
        let safeAreaInsets : CGFloat = self.direction.switch(
            vertical: context.safeAreaInsets.top + context.safeAreaInsets.bottom,
            horizontal: context.safeAreaInsets.left + context.safeAreaInsets.right
        )

        let contentHeight = self.direction.height(for: self.content.contentSize)
        let viewHeight = self.direction.height(for: context.viewBounds.size)
        
        let additionalOffset = self.behavior.underflow.alignment.offsetFor(
            contentHeight: contentHeight,
            viewHeight: viewHeight - safeAreaInsets
        )
        
        // If we're pinned to the top of the view, there's no adjustment needed.
        
        guard additionalOffset > 0.0 else {
            return
        }
        
        // Provide additional adjustment.
                
        self.direction.mutate(self.content.header, vertical: \.y, horizontal: \.x) {
            $0 += additionalOffset
        }
        
        self.direction.mutate(self.content.footer, vertical: \.y, horizontal: \.x) {
            $0 += additionalOffset
        }
        
        for section in self.content.sections {
            
            self.direction.mutate(section.header, vertical: \.y, horizontal: \.x) {
                $0 += additionalOffset
            }
            
            self.direction.mutate(section.footer, vertical: \.y, horizontal: \.x) {
                $0 += additionalOffset
            }
            
            for item in section.items {
                self.direction.mutate(item, vertical: \.y, horizontal: \.x) {
                    $0 += additionalOffset
                }
            }
        }
    }
}


extension AnyListLayout
{
    func onDidEndDraggingTargetContentOffset(
        for targetContentOffset : CGPoint,
        velocity : CGPoint
    ) -> CGPoint?
    {
        guard self.pagingBehavior == .firstVisibleItemEdge else { return nil }
        
        guard let item = self.itemToScrollToOnDidEndDragging(
            after: targetContentOffset,
            velocity: velocity
        ) else {
            return nil
        }
        
        let leadingEdge = direction.minY(for: item.defaultFrame)
        
        let padding = self.bounds?.padding ?? .zero
        
        return direction.switch {
            CGPoint(x: 0.0, y: leadingEdge - padding.top)
        } horizontal: {
            CGPoint(x: leadingEdge - padding.left, y: 0.0)
        }
    }
    
    func itemToScrollToOnDidEndDragging(
        after contentOffset : CGPoint,
        velocity : CGPoint
    ) -> ListLayoutContent.ContentItem?
    {
        let rect : CGRect = self.rectForFindingItemToScrollToOnDidEndDragging(
            after: contentOffset,
            velocity: velocity
        )
        
        let scrollDirection = ScrollVelocityDirection(direction.y(for: velocity))
        
        let items = self.content.content(
            in: rect,
            alwaysIncludeOverscroll: false,
            includeUnpopulated: false
        ).sorted { lhs, rhs in
            switch scrollDirection {
            case .forward:
                return direction.minY(for: lhs.defaultFrame) < direction.minY(for: rhs.defaultFrame)
            case .backward:
                return direction.maxY(for: lhs.defaultFrame) > direction.maxY(for: rhs.defaultFrame)
            }
        }

        return items.first { item in
            let edge = direction.minY(for: item.defaultFrame)
            let offset = direction.y(for: contentOffset)
            
            switch scrollDirection {
            case .forward:
                return edge >= offset
            case .backward:
                return edge <= offset
            }
        }
    }
    
    func rectForFindingItemToScrollToOnDidEndDragging(
        after contentOffset : CGPoint,
        velocity : CGPoint
    ) -> CGRect {
        
        /// The height used here doesn't really matter; it just needs to be
        /// tall enough to make sure we end up with at least one overlapping item,
        /// and thus we'll assume most layouts have at least one item in 1,000pts.
        
        let height : CGFloat = 1_000
        let scrollDirection = ScrollVelocityDirection(direction.y(for: velocity))
        let offset : CGFloat = scrollDirection == .backward ? 1_000 : 0
    
        return direction.switch {
            CGRect(x: 0, y: contentOffset.y - offset, width: content.contentSize.width, height: height)
        } horizontal: {
            CGRect(x: contentOffset.x - offset, y: 0, width: height, height: content.contentSize.height)
        }
    }
}


fileprivate enum ScrollVelocityDirection {
    case forward
    case backward
    
    init(_ velocity : CGFloat) {
        if velocity >= 0 {
            self = .forward
        } else {
            self = .backward
        }
    }
}
