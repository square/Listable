//
//  CollectionViewDemoFlowLayoutViewController.swift
//  Listable-DemoApp
//
//  Created by Kyle Van Essen on 7/9/19.
//

import UIKit
import ListableCollectionView


final class CollectionViewDemoFlowLayoutViewController : UIViewController
{
    let collectionView = CollectionView(layout: CollectionViewFlowLayout())
    
    override func loadView()
    {
        self.view = self.collectionView
        
        
    }
}
