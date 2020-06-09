//
//  ListView.LayoutManager.swift
//  Listable
//
//  Created by Kyle Van Essen on 5/3/20.
//

import Foundation


extension ListView
{
    final class LayoutManager
    {
        unowned let collectionView : UICollectionView
                
        private(set) var current : CollectionViewLayout
        
        init(layout : CollectionViewLayout, collectionView : UICollectionView)
        {
            self.current = layout
            self.collectionView = collectionView
        }
        
        func set(layoutType : ListLayoutType, animated : Bool, completion : @escaping () -> ())
        {
            guard self.current.layoutType != layoutType else {
                completion()
                return
            }
            
            self.current = CollectionViewLayout(
                delegate: self.current.delegate,
                layoutType: layoutType,
                appearance: self.current.appearance,
                behavior: self.current.behavior
            )
            
            self.current.applyLayoutScrollViewProperties()
            
            self.collectionView.setCollectionViewLayout(self.current, animated: animated) { _ in
                completion()
            }
        }
    }
}
