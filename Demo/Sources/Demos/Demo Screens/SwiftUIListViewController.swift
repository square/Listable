//
//  SwiftUIListViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 5/29/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//

import SwiftUILists
import SwiftUI


@available(iOS 13.0, *)
final class SwiftUIListViewController : UIViewController
{
    let hosting : UIHostingController<AnyView>
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        self.hosting = UIHostingController(rootView: AnyView(EmptyView()))
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.addChild(self.hosting)
        self.hosting.didMove(toParent: self)
        
        self.hosting.rootView = AnyView(self.listContent)
        
        self.title = "SwiftUI Integration"
    }
    
    override func loadView()
    {
        super.loadView()
        
        self.view.addSubview(self.hosting.view)
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        self.hosting.view.frame = self.view.bounds
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    var listContent : some View {
        ListableList { _ in }
    }
}

