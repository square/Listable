//
//  SupplementaryItemView.swift
//  Listable
//
//  Created by Kyle Van Essen on 9/30/19.
//

import UIKit


final class SupplementaryItemView<Element:HeaderFooterElement> : UICollectionReusableView
{
    let content : Element.Appearance.View
    
    var appearance : Element.Appearance? = nil
    
    override init(frame: CGRect)
    {
        self.content = Element.Appearance.createReusableHeaderFooterView()
        
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        self.layer.masksToBounds = false
        
        self.addSubview(self.content)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: UIView
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        self.content.frame = self.bounds
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize
    {
        return self.content.sizeThatFits(size)
    }
}
