//
//  ListContentView.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 12/29/21.
//

import Foundation


public protocol ListContentView : UIView
{
    func setContainingViewController(_ viewController : UIViewController)
    
    func willDisplay()
    func didEndDisplay()
    
    func listWillAppear(animated : Bool)
    func listWillDisappear(animated : Bool)
    func listEndedAppearanceTransition()
}
