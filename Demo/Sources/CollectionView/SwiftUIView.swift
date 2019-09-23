//
//  SwiftUIView.swift
//  Demo
//
//  Created by Kyle Van Essen on 10/20/19.
//  Copyright © 2019 Kyle Van Essen. All rights reserved.
//

import SwiftUI


@available(iOS 13.0, *)
struct SwiftUIView: View {
    var body: some View {
        UIViewControllerWrapperView(
            UINavigationController(rootViewController: CollectionViewBasicDemoViewController())
        )
    }
}

@available(iOS 13.0, *)
struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SwiftUIView()
            .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
            .previewDisplayName("iPhone SE")
            
            SwiftUIView()
            .previewDevice(PreviewDevice(rawValue: "iPhone XS Max"))
            .previewDisplayName("iPhone XS Max")
        }
    }
}

@available(iOS 13.0, *)
struct UIViewControllerWrapperView<ViewController:UIViewController> : UIViewControllerRepresentable
{
    typealias UIViewControllerType = ViewController
    
    let viewController : ViewController
    
    init()
    {
        self.viewController = ViewController()
    }
    
    init(_ viewController : ViewController)
    {
        self.viewController = viewController
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> ViewController
    {
        return self.viewController
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: UIViewControllerRepresentableContext<Self>)
    {
        // Nothing for now.
    }
}
