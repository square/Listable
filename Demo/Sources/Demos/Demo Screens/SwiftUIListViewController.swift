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
    let swiftUI : UIHostingController<Listable>
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    var body : Listable {
        Listable { list in
            
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
        return Text("Hello, World!")
    }
}
