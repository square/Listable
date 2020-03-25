//
//  ItemCellView.swift
//  Listable
//
//  Created by Kyle Van Essen on 3/23/20.
//

import UIKit


extension ItemElementCell
{
    final class ContentView : UIView
    {
        private(set) var contentScrollView : UIScrollView
        
        private(set) var contentView : Element.Appearance.ContentView
        
        private(set) var swipeView : Element.SwipeActionsAppearance.ContentView
        
        override init(frame : CGRect)
        {
            let bounds = CGRect(origin: .zero, size: frame.size)
            
            self.contentView = Element.Appearance.createReusableItemView(frame: bounds)
            self.swipeView = Element.SwipeActionsAppearance.createView(frame: bounds)
            
            self.contentScrollView = UIScrollView()
            
            super.init(frame: frame)
            
            self.addSubview(self.contentView)
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) { fatalError() }
        
        override func layoutSubviews()
        {
            super.layoutSubviews()
            
            self.contentView.frame = self.bounds
        }
    }
}
