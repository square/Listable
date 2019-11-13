//
//  ItemElementCell.swift
//  Listable
//
//  Created by Kyle Van Essen on 9/22/19.
//

import UIKit


final class ItemElementCell<Element:ItemElement> : UICollectionViewCell
{
    let content : Element.Appearance.View
    
    var appearance : Element.Appearance? = nil
    
    override init(frame: CGRect)
    {
        self.content = Element.Appearance.createReusableItemView(frame: frame)
        
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        
        self.layer.masksToBounds = false
        self.contentView.layer.masksToBounds = false

        self.contentView.addSubview(self.content)
        self.backgroundView = self.content.background
        self.selectedBackgroundView = self.content.selectedBackground
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: UIView
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
                
        self.content.frame = self.contentView.bounds
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize
    {
        return self.content.sizeThatFits(size)
    }
}

