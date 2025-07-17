//
//  BestPractices.swift
//  Demo
//
//  Created by Kyle Van Essen on 10/31/21.
//  Copyright © 2021 Kyle Van Essen. All rights reserved.
//

import ListableUI
import BlueprintUILists
import UIKit


/// This file contains examples for best practices for how to build lists and sections.
enum BestPractices {
        
    static func make_list_api() -> List
    {
        List { list in
            
            /// Configures the layout styling.
            /// You could, for example pass `.grid`  or `.paged` here as well.
            list.layout = .table { layout in
                layout.stickySectionHeaders = false
                
                layout.bounds = .init(
                    padding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
                    width: .atMost(600)
                )
            }
            
            list.header = ExampleHeader(title: "Welcome To My List")
            
            list.footer = ExampleFooter(text: "There are many like it, but this one is mine.")
            
        } sections: {
            
            /// Creating a section with no header or footer; just content.
            Section("First Section") {
                ExampleContent(text: "First Item")
                ExampleContent(text: "Second Item")
                ExampleContent(text: "Third Item")
            }
            
            /// Creating a second with headers and footers.
            Section("Second Section") {
                ExampleContent(text: "First Item")
                ExampleContent(text: "Second Item")
                ExampleContent(text: "Third Item")
            } header: {
                ExampleHeader(title: "This Is My Section")
            } footer: {
                ExampleFooter(text: "Rules apply. Prohibited where void.")
            }
        }
    }
}


fileprivate struct ExampleHeader : Equatable, BlueprintHeaderFooterContent {
    
    var title : String
    
    var elementRepresentation: Element {
        Empty()
    }
}


fileprivate struct ExampleFooter : Equatable, BlueprintHeaderFooterContent {
    
    var text : String
    
    var elementRepresentation: Element {
        Empty()
    }
}


fileprivate struct ExampleContent : Equatable, BlueprintItemContent {
    
    var text : String
    
    var identifierValue : String {
        text
    }
    
    func element(with info: ApplyItemContentInfo) -> Element {
        Empty()
    }
}
