//
//  ListStateViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 7/11/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//

import BlueprintUILists
import BlueprintUICommonControls
import Combine
import Foundation
import UIKit

/// Includes combine examples, so only available on iOS 13.0+.
final class ListStateViewController : ListViewController
{
    let actions = ListActions()
    
    @Published var index : Int = 1
    
    override func configure(list : inout ListProperties)
    {
        list.appearance = .demoAppearance
        list.layout = .demoLayout
        
        list("1") { section in
            (1...100).forEach { count in
                section += DemoItem(text: "Item #\(count)")
            }
        }
        
        list.actions = self.actions
        
        list.stateObserver = ListStateObserver { observer in
            observer.onDidScroll { info in
                print("Did Scroll")
            }
            
            observer.onBeginDrag { info in
                print("Will Begin Drag")
            }
            
            observer.onDidEndDeceleration { info in
                print("Did End Deceleration")
            }
            
            observer.onVisibilityChanged { info in
                print("Displayed: \(info.displayed.map { $0.anyIdentifier })")
                print("Ended Display: \(info.endedDisplay.map { $0.anyIdentifier })")
            }
        }
    }
    
    var cancel : AnyCancellable? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Example of how to use the `actions` within a reactive framework like Combine or ReactiveSwift.
        
        cancel = $index.sink { [weak self] value in
            self?.actions.scrolling.scrollTo(
                item: DemoItem.identifier(with: "Item #\(value)"),
                position: .init(position: .top, ifAlreadyVisible: .scrollToPosition),
                animated: true
            )
        }
        
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Up", style: .plain, target: self, action: #selector(scrollUp)),
            UIBarButtonItem(title: "Down", style: .plain, target: self, action: #selector(scrollDown)),
            UIBarButtonItem(title: "Signal", style: .plain, target: self, action: #selector(doSignal))
        ]
    }
    
    @objc private func scrollUp()
    {
        self.actions.scrolling.scrollToTop(animated: true)
    }
    
    @objc private func scrollDown()
    {
        self.actions.scrolling.scrollToLastItem(animated: true)
    }
    
    @objc private func doSignal()
    {
        self.index += 1
    }
}
