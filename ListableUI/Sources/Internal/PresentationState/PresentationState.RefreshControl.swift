//
//  RefreshControl.PresentationState.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 12/14/20.
//

import Foundation


extension PresentationState
{
    internal final class RefreshControlState
    {
        public var model : RefreshControl
        public var view : UIRefreshControl
        
        public init(_ model : RefreshControl)
        {
            self.model = model
            self.view = UIRefreshControl()
            
            self.view.addTarget(self, action: #selector(refreshControlChanged), for: .valueChanged)
        }
        
        func update(with control : RefreshControl)
        {
            self.model = control
            
            if let title = self.model.title {
                switch title {
                case .string(let string): self.view.attributedTitle = NSAttributedString(string: string)
                case .attributed(let string): self.view.attributedTitle = string
                }
            } else {
                self.view.attributedTitle = nil
            }
            
            self.view.tintColor = self.model.tintColor
            
            if self.model.isRefreshing {
                self.view.beginRefreshing()
            } else {
                self.view.endRefreshing()
            }
        }
        
        @objc func refreshControlChanged()
        {
            self.model.onRefresh()
        }
    }
}
