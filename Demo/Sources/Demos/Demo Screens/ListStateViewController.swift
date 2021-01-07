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

/// Includes combine examples, so only available on iOS 13.0+.
@available(iOS 13.0, *)
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
            
            observer.onVisibilityChanged { info in
                print("Displayed: \(info.displayed.map { $0.identifier })")
                print("Ended Display: \(info.endedDisplay.map { $0.identifier })")
            }
        }
    }
    
    var cancel : AnyCancellable? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Example of how to use the `actions` within a reactive framwork like Combine or ReactiveSwift.
        
        cancel = $index.sink { [weak self] value in
            self?.actions.scrolling.scrollTo(
                item: Identifier<DemoItem>("Item #\(value)"),
                position: .init(position: .top, ifAlreadyVisible: .scrollToPosition),
                animation: .default
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
        self.actions.scrolling.scrollToTop(animation: .default)
    }
    
    @objc private func scrollDown()
    {
        self.actions.scrolling.scrollToLastItem(animation: .default)
    }
    
    @objc private func doSignal()
    {
        self.index += 1
    }
}
