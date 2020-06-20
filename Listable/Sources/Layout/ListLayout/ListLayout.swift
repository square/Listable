//
//  ListLayout.swift
//  Listable
//
//  Created by Kyle Van Essen on 5/2/20.
//

import Foundation


public protocol ListLayout : AnyListLayout
{
    associatedtype LayoutAppearance:ListLayoutAppearance
    
    var layoutAppearance : LayoutAppearance { get }
        
    init()
    
    init(
        layoutAppearance : LayoutAppearance,
        appearance : Appearance,
        behavior : Behavior,
        delegate : CollectionViewLayoutDelegate,
        in collectionView : UICollectionView
    )
}


public extension ListLayout
{
    var direction: LayoutDirection {
        self.layoutAppearance.direction
    }
    
    var stickySectionHeaders: Bool {
        self.layoutAppearance.stickySectionHeaders
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
            
    var scrollViewProperties : ListLayoutScrollViewProperties { get }
    
    var direction : LayoutDirection { get }
    var stickySectionHeaders : Bool { get }
    
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


public extension AnyListLayout
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
        guard self.stickySectionHeaders else {
            return true
        }
        
        guard collectionView.frame.size.isEmpty == false else {
            return false
        }
        
        let direction = self.direction

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
        
        let direction = self.direction
        
        let contentHeight = direction.height(for: self.content.contentSize)
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
            switch self.direction {
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

