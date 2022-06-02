//
//  SearchDemoViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 6/2/22.
//  Copyright © 2022 Kyle Van Essen. All rights reserved.
//

import Foundation
import UIKit
import BlueprintUI
import BlueprintUICommonControls
import BlueprintUILists


final class SearchDemoViewController : UIViewController {
    
    private let blueprintView = BlueprintView()
    
    private var searchTerm : String? = nil {
        didSet {
            update()
        }
    }
    
    override func loadView() {
        self.view = blueprintView
        update()
    }
    
    private func update() {
        blueprintView.element = element()
    }
    
    private func element() -> Element {
        
        EnvironmentReader { env in
            Column(alignment: .fill, underflow: .growUniformly) {
                TextField(text: self.searchTerm ?? "") { textField in
                    textField.placeholder = "Search..."
                    
                    textField.onChange = { string in
                        self.searchTerm = string.isEmpty ? nil : string
                    }
                }
                
                Overlay {
                    List {
                        Section("items") {
                            content.map {
                                ContentItem(text: $0)
                            }
                        }
                    }
                    
                    if let searchTerm = self.searchTerm {
                        List {
                            Section("items") {
                                content.compactMap {
                                    if $0.lowercased().contains(searchTerm.lowercased()) {
                                        return ContentItem(text: $0)
                                    } else {
                                        return nil
                                    }
                                }
                            }
                        }
                        .transition(.fade)
                    }
                }
            }
            .inset(top: env.safeAreaInsets.top)
        }
    }
}


fileprivate struct ContentItem : BlueprintItemContent, Equatable {
    
    var text : String
    
    var identifierValue: String {
        text
    }
    
    func element(with info: ApplyItemContentInfo) -> Element {
        Label(text: text)
    }
}


fileprivate let content : [String] = [
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
    "Nulla finibus dui purus.",
    "Praesent et vulputate purus.",
    "Sed pretium tellus et lorem congue porta.",
    "Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.",
    "Phasellus ac hendrerit mauris.",
    "Nulla augue est, malesuada eget semper at, hendrerit vitae nibh.",
    "Nunc porta sollicitudin diam eget laoreet.",
]
