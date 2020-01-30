//
//  FlowLayoutViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 1/13/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//

import UIKit

/**
 Implements  a very basic UICollectionViewFlowLayout, so we can use the debugger and view inspector
 to determine how it implements various things like supplementary views, etc.
 */
final class FlowLayoutViewController : UIViewController
{
    let layout : UICollectionViewFlowLayout
    let collectionView : UICollectionView
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        self.layout = UICollectionViewFlowLayout()
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.layout)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.title = "Flow Layout Demo"
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func loadView()
    {
        self.view = self.collectionView
        
        self.collectionView.backgroundColor = .white
        
        self.collectionView.register(FlowCell.self, forCellWithReuseIdentifier: "Cell")
        self.collectionView.register(FlowHeader.self, forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        self.collectionView.register(FlowFooter.self, forSupplementaryViewOfKind:UICollectionView.elementKindSectionFooter , withReuseIdentifier: "Footer")
        
        self.layout.headerReferenceSize = CGSize(width: 300.0, height: 50.0)
        self.layout.footerReferenceSize = CGSize(width: 300.0, height: 50.0)
        self.layout.itemSize = CGSize(width: 300.0, height: 100.0)
        
        self.layout.minimumLineSpacing = 20.0
        self.layout.minimumInteritemSpacing = 20.0
                
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    fileprivate let items : [[FlowItem]] = [
        [
            // Empty section.
        ],
        [
            // Section with one item.
            
            FlowItem(title: "Item 0, Section 1")
        ],
        [
            // Section with two items.
            
            FlowItem(title: "Item 0, Section 2"),
            FlowItem(title: "Item 1, Section 2")
        ],
        [
            // Section with three items.
            
            FlowItem(title: "Item 0, Section 3"),
            FlowItem(title: "Item 1, Section 3"),
            FlowItem(title: "Item 2, Section 3")
        ]
    ]
}


extension FlowLayoutViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.items[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
        case UICollectionView.elementKindSectionFooter:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
        default: fatalError()
        }
    }
    
    // MARK: UICollectionViewDelegate
    
    // MARK: UICollectionViewDelegateFlowLayout
}


fileprivate struct FlowItem : Equatable
{
    var title : String
}


final fileprivate class FlowCell : UICollectionViewCell
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.backgroundColor = .init(white: 0.9, alpha: 1.0)
    }
    
    required init?(coder: NSCoder) { fatalError() }
}


final fileprivate class FlowHeader : UICollectionReusableView
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.backgroundColor = .init(white: 0.95, alpha: 1.0)
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

final fileprivate class FlowFooter : UICollectionReusableView
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.backgroundColor = .init(white: 0.8, alpha: 1.0)
    }
    
    required init?(coder: NSCoder) { fatalError() }
}
