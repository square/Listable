//
//  KeyboardNavigationDemoViewController.swift
//  Development
//
//  Created by Listable Demo on 12/30/24.
//

import UIKit
import ListableUI

final class KeyboardNavigationDemoViewController: ListViewController {
    
    private var allowsFocus = true
    private var selectionFollowsFocus = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Keyboard Navigation Focus"
        
        // Add toggle buttons to the navigation bar
        let toggleFocusButton = UIBarButtonItem(
            title: "Toggle Focus",
            style: .plain,
            target: self,
            action: #selector(toggleAllowsFocus)
        )
        
        let toggleSelectionButton = UIBarButtonItem(
            title: "Toggle Selection",
            style: .plain,
            target: self,
            action: #selector(toggleSelectionFollowsFocus)
        )
        
        self.navigationItem.rightBarButtonItems = [toggleFocusButton, toggleSelectionButton]
    }
    
    @objc private func toggleAllowsFocus() {
        allowsFocus.toggle()
        self.reload(animated: true)
    }

    @objc private func toggleSelectionFollowsFocus() {
        selectionFollowsFocus.toggle()
        self.reload(animated: true)
    }

    override func configure(list: inout ListProperties) {
        
        list.appearance = .demoAppearance
        list.layout = .table()

        if allowsFocus {
            if selectionFollowsFocus {
                list.behavior.focus = .selectionFollowsFocus(showFocusRing: true)
            } else {
                list.behavior.focus = .allowsFocus
            }
        } else {
            list.behavior.focus = Behavior.FocusConfiguration.none
        }
        
        list.content.header = DemoHeader(
            title: "Keyboard Navigation Demo\nFocus: \(allowsFocus ? "ON" : "OFF") | Selection Follows: \(selectionFollowsFocus ? "ON" : "OFF")"
        )
        
        list.add {
            Section("instructions") {
                Item(
                    DemoItem(text: "Instructions:\n• Use Tab key to navigate between items\n• Use Arrow keys to navigate within the list\n• Press Return to select items\n• Space key works only with Full Keyboard Access enabled\n• Toggle settings with navigation buttons"),
                    selectionStyle: .none
                )
            } header: {
                DemoHeader(title: "How to Use")
            }

            Section("demo-items") {
                // Create a few selectable items for focus testing
                for i in 1...5 {
                    Item(
                        DemoItem(text: "Focusable Item \(i)"),
                        selectionStyle: .selectable(),
                        onSelect: { _ in
                            print("Selected Focusable Item \(i)")
                        }
                    )
                }
            } header: {
                DemoHeader(title: "Focusable Items")
            }
            
            Section("mixed-items") {
                Item(
                    DemoItem(text: "Tappable Item (Focus + Select)"),
                    selectionStyle: .tappable,
                    onSelect: { _ in
                        print("Selected Tappable Item")
                    }
                )
                
                Item(
                    DemoItem(text: "Toggle Item (Focus + Toggle)"),
                    selectionStyle: .toggles(),
                    onSelect: { _ in
                        print("Toggled Toggle Item")
                    }
                )
                
                Item(
                    DemoItem(text: "Non-selectable Item (No Focus)"),
                    selectionStyle: .none
                )
                
                Item(
                    DemoItem(text: "Another Selectable Item"),
                    selectionStyle: .selectable(),
                    onSelect: { _ in
                        print("Selected Another Selectable Item")
                    }
                )
            } header: {
                DemoHeader(title: "Mixed Selection Styles")
            }
        }
    }
}
