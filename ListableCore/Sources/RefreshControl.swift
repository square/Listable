//
//  RefreshControl.swift
//  Listable
//
//  Created by Kyle Van Essen on 8/4/19.
//

import Foundation


public struct RefreshControl
{
    public var title : NSAttributedString?
    public var tintColor : UIColor?
    
    public typealias EndRefreshing = () -> ()
    public typealias OnRefresh = (@escaping EndRefreshing) -> ()
    public var onRefresh : OnRefresh
    
    public typealias IsRefreshing = () -> Binding<Bool>
    public var isRefreshing : IsRefreshing?
    
    public init(
        title : NSAttributedString? = nil,
        tintColor : UIColor? = nil,
        isRefreshing: IsRefreshing? = nil,
        onRefresh : @escaping OnRefresh
        )
    {
        self.title = title
        self.tintColor = tintColor
        
        self.isRefreshing = isRefreshing
        self.onRefresh = onRefresh
    }
    
    public func apply(to refreshControl : UIRefreshControl)
    {
        refreshControl.tintColor = self.tintColor
        refreshControl.attributedTitle = self.title
    }
    
    public final class PresentationState
    {
        public var model : RefreshControl
        public var view : UIRefreshControl
        
        private var binding : Binding<Bool>?
        
        public init(_ model : RefreshControl)
        {
            self.model = model
            self.view = UIRefreshControl()
            
            if let isRefreshing = model.isRefreshing {
                let binding = isRefreshing()
                binding.start()
                
                binding.onChange { [weak self] refreshing in
                    guard let self = self else { return }
                    
                    if refreshing {
                        self.view.beginRefreshing()
                    } else {
                        self.view.endRefreshing()
                    }
                }
                
                self.binding = binding
            }
            
            self.view.addTarget(self, action: #selector(refreshControlChanged), for: .valueChanged)
        }
        
        @objc func refreshControlChanged()
        {
            self.model.onRefresh { [weak self] in
                guard let self = self else { return }

                self.view.endRefreshing()
            }
        }
    }

}
