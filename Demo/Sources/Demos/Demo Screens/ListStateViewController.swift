//
//  ListStateViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 7/11/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//

import BlueprintUICommonControls
import BlueprintUILists
import Combine

/// Includes combine examples, so only available on iOS 13.0+.
@available(iOS 13.0, *)
final class ListStateViewController: ListViewController {
    let actions = ListActions()

    @Published var index: Int = 1

    override func configure(list: inout ListProperties) {
        list.appearance = .demoAppearance
        list.layout = .demoLayout

        list("1") { section in
            (1 ... 100).forEach { count in
                section += DemoItem(text: "Item #\(count)")
            }
        }

        list.actions = actions

        list.stateObserver = ListStateObserver { observer in
            observer.onDidScroll { _ in
                print("Did Scroll")
            }

            observer.onVisibilityChanged { info in
                print("Displayed: \(info.displayed.map(\.anyIdentifier))")
                print("Ended Display: \(info.endedDisplay.map(\.anyIdentifier))")
            }
        }
    }

    var cancel: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()

        /// Example of how to use the `actions` within a reactive framework like Combine or ReactiveSwift.

        cancel = $index.sink { [weak self] value in
            self?.actions.scrolling.scrollTo(
                item: DemoItem.identifier(with: "Item #\(value)"),
                position: .init(position: .top, ifAlreadyVisible: .scrollToPosition),
                animation: .default
            )
        }

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Up", style: .plain, target: self, action: #selector(scrollUp)),
            UIBarButtonItem(title: "Down", style: .plain, target: self, action: #selector(scrollDown)),
            UIBarButtonItem(title: "Signal", style: .plain, target: self, action: #selector(doSignal)),
        ]
    }

    @objc private func scrollUp() {
        actions.scrolling.scrollToTop(animation: .default)
    }

    @objc private func scrollDown() {
        actions.scrolling.scrollToLastItem(animation: .default)
    }

    @objc private func doSignal() {
        index += 1
    }
}
