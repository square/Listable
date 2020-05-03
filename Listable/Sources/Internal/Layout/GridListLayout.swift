//
//  GridListLayout.swift
//  Listable
//
//  Created by Kyle Van Essen on 5/2/20.
//

import Foundation


final class GridListLayout : ListLayout
{
    //
    // MARK: Public Properties
    //
    
    var contentSize : CGSize
        
    let appearance : Appearance
    let behavior : Behavior
    
    let content : ListLayoutContent
    
    //
    // MARK: Initialization
    //
    
    init()
    {
        self.contentSize = .zero
                
        self.appearance = Appearance()
        self.behavior = Behavior()
        
        self.content = ListLayoutContent(with: self.appearance)
    }
    
    init(
        delegate : CollectionViewLayoutDelegate,
        appearance : Appearance,
        behavior : Behavior,
        in collectionView : UICollectionView
        )
    {
        self.contentSize = .zero
                
        self.appearance = appearance
        self.behavior = behavior
        
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
    func updateLayout(in collectionView: UICollectionView) -> Bool
    {
        return true
    }
    
    func layout(
        delegate : CollectionViewLayoutDelegate,
        in collectionView : UICollectionView
        ) -> Bool
    {
        fatalError()
    }
    
    private func setItemPositions()
    {
        fatalError()
    }
    
    private func adjustPositionsForLayoutUnderflow(contentHeight : CGFloat, viewHeight: CGFloat, in collectionView : UICollectionView)
    {
        fatalError()
    }
}
