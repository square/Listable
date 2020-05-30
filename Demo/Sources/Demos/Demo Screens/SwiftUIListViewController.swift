//
//  SwiftUIListViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 5/29/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//

import SwiftUILists


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
        
        self.hosting.rootView = AnyView(self.body)
        
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
    
    var body : some View {
        ListableList { list in
//            list += Listable.Section(identifier: "section") { section in
//                section += SwiftUIDemoItem()
//                section += SwiftUIDemoItem()
//                section += SwiftUIDemoItem()
//                section += SwiftUIDemoItem()
//            }
        }
    }
}

@available(iOS 13.0, *)
fileprivate struct SwiftUIDemoItem : SwiftUIItemContent, Equatable
{
    var identifier: Identifier<SwiftUIDemoItem> {
        .init()
    }
    
    func content(with info: ApplyItemContentInfo) -> some View {
        Text("Hello, World!")
            .font(.system(.headline))
            .frame(maxWidth: .infinity)
            .padding(4)
            .border(Color.red, width: 4)
            .padding(4)
            .border(Color.green, width: 4)
    }
}

