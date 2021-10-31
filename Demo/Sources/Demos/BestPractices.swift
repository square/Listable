//
//  BestPractices.swift
//  Demo
//
//  Created by Kyle Van Essen on 10/31/21.
//  Copyright © 2021 Kyle Van Essen. All rights reserved.
//

import ListableUI
import BlueprintUILists


/// This file contains examples for best practices for how to build lists and sections.
enum BestPractices {
    
    static func make_list() -> List
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
            
            list.footer = ExampleFooter(title: "There are many like it, but this one is mine.")
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
    
    var content : String
    
    var elementRepresentation: Element {
        Empty()
    }
}


fileprivate struct ExampleContent : Equatable, BlueprintItemContent {
    
    var name : String
    
    var identifierValue : String {
        name
    }
    
    func element(with info: ApplyItemContentInfo) -> Element {
        Empty()
    }
}
