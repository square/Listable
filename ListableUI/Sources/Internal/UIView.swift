//
//  UIView.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 10/28/20.
//

import Foundation
import UIKit


extension UIView {
    
    func contains(touch : UITouch) -> Bool {
        let location = touch.location(in: self)
        
        return bounds.contains(location)
    }
    
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
    
    func isInside(superview : UIView) -> Bool {
        
        sequence(first: self, next: \.superview)
            .contains(superview)
    }
}
