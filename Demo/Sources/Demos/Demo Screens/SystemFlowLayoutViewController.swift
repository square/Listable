//
//  SystemFlowLayoutViewController.swift
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
final class SystemFlowLayoutViewController : UIViewController
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
        
        self.layout.headerReferenceSize = CGSize(width: 300.0, height: 50.0)
        self.layout.itemSize = CGSize(width: 300.0, height: 100.0)
        
        self.layout.minimumLineSpacing = 20.0
        self.layout.minimumInteritemSpacing = 20.0
                
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    fileprivate let items : [[FlowItem]] = [
        [
            FlowItem(title: "Item 1, Section 1"),
        ],
        
        [
            FlowItem(title: "Item 1, Section 2"),
            FlowItem(title: "Item 2, Section 2"),
        ],
        
        [
            FlowItem(title: "Item 1, Section 3"),
            FlowItem(title: "Item 2, Section 3"),
            FlowItem(title: "Item 3, Section 3"),
        ]
    ]
}


extension SystemFlowLayoutViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
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
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "Header",
                for: indexPath
            ) as! FlowHeader
            
            header.textField.onFocus = { [weak collectionView] in
                
                /// ⚠️⚠️⚠️ Triggers the issue. ⚠️⚠️⚠️
                ///
                /// Even though we're not actually delivering any updates (`.performBatchUpdates({})`),
                /// `_resignOrRebaseFirstResponderViewWithIndexPathMapping` seems
                /// to come along after the update and undo our first responder.
                ///
                /// ```
                /// TextField.resignFirstResponder()
                /// @objc TextField.resignFirstResponder()
                /// -[UICollectionView _resignOrRebaseFirstResponderViewWithIndexPathMapping:]
                /// -[UICollectionView _updateWithItems:tentativelyForReordering:propertyAnimator:collectionViewAnimator:]
                /// -[UICollectionView _endItemAnimationsWithInvalidationContext:tentativelyForReordering:animator:collectionViewAnimator:]
                /// -[UICollectionView _performBatchUpdates:completion:invalidationContext:tentativelyForReordering:animator:animationHandler:]
                /// closure #1 in SystemFlowLayoutViewController.collectionView(_:viewForSupplementaryElementOfKind:at:)
                /// TextField.becomeFirstResponder()

                /// ```
                ///
                /// Note that even throwing this in a `DispathQueue.main.async`
                /// doesn't seem to resolve the issue.
                collectionView?.performBatchUpdates({})
                
            }
            
            return header
            
        default: fatalError()
        }
    }
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
    let textField : TextField
    
    override init(frame: CGRect)
    {
        self.textField = TextField()
        
        super.init(frame: frame)
        
        self.addSubview(textField)
        
        self.backgroundColor = .init(white: 0.95, alpha: 1.0)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textField.frame = bounds
    }
}


fileprivate final class TextField : UITextField {
    
    var onFocus : () -> () = {}
    
    override init(frame: CGRect) {
        print("Initializing NEW text field")
        super.init(frame: frame)
        
        self.placeholder = "I'm a text field, type in me!"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func becomeFirstResponder() -> Bool {
        let became = super.becomeFirstResponder()
        
        if became {
            print("BECAME First Responder")
            onFocus()
        }

        return became
    }
    
    override func resignFirstResponder() -> Bool {
        let resigned = super.resignFirstResponder()
        
        if resigned {
            print("RESIGNED First Responder")
        }
        
        return resigned
    }
}
