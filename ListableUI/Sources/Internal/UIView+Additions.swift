//
//  UIView+Additions.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 10/28/20.
//

import Foundation


extension UIView {
    
    func firstSuperview<ViewType:UIView>(ofType : ViewType.Type) -> ViewType? {
        var view = self.superview
        
        while view != nil {
            if let view = view as? ViewType {
                return view
            } else {
                view = view?.superview
            }
        }
        
        return nil
    }
}
