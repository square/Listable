//
//  UIView.swift
//  Listable
//
//  Created by Kyle Van Essen on 11/6/19.
//


internal extension UIView
{
    var lst_safeAreaInsets : UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return self.safeAreaInsets
        } else {
            return .zero
        }
    }
    
    func lst_findFirstResponder() -> UIView?
    {
        if self.isFirstResponder {
            return self
        }
        
        for view in self.subviews {
            if view.isFirstResponder {
                return view
            } else {
                if let firstResponder = view.lst_findFirstResponder() {
                    return firstResponder
                }
            }
        }
        
        return nil
    }
}
