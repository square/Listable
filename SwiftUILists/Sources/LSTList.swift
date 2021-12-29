//
//  LSTList.swift
//  SwiftUILists
//
//  Created by Kyle Van Essen on 10/22/19.
//

import SwiftUI
@testable import ListableUI


@available(iOS 13.0, *)
public struct LSTList : UIViewControllerRepresentable
{
    public var properties : ListProperties

    //
    // MARK: Initialization
    //
        
    public init(
        configure : ListProperties.Configure
    ) {
        self.properties = .default(with: configure)
    }
    
    public init(
        configure : ListProperties.Configure = { _ in },
        @ListableBuilder<ListableUI.Section> sections : () -> [ListableUI.Section]
    ) {
        self.properties = .default(with: configure)
        
        self.properties.sections += sections()
    }
    
    //
    // MARK: UIViewRepresentable
    //
    
    public typealias UIViewControllerType = ViewController
    
    public func makeUIViewController(context: Context) -> ViewController
    {
        ViewController()
    }
    
    public func updateUIViewController(_ viewController: ViewController, context: Context)
    {
        viewController.properties = self.properties
    }
    
    public final class ViewController : ListViewController
    {
        var properties : ListProperties? {
            didSet {
                self.reload(animated: true)
            }
        }
        
        // MARK: UIViewController
        
        public override var shouldAutomaticallyForwardAppearanceMethods: Bool {
            // TODO: Handle these...
            false
        }
        
        // MARK: ListViewController
        
        public override func configure(list: inout ListProperties) {
            guard let properties = self.properties else {
                return
            }
            
            list = properties
        }
    }
}
