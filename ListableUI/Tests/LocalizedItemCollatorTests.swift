//
//  LocalizedItemCollatorTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 12/7/20.
//

import XCTest
@testable import ListableUI


class LocalizedItemCollatorTests : XCTestCase
{
    func test_init() {
        let collator = LocalizedItemCollator(
            collation: .current(),
            items: names.map {
                Item(CollatedContent(text: $0))
            }
        )
        
        let groupedNames : [[String]] = collator.collated.map { section in
            [section.title] + section.items.map { ($0.anyContent as! CollatedContent).text }
        }
        
        XCTAssertEqual(groupedNames,
            [
                [
                    "D",
                    "Delisa Leggio",
                    "Dionna Levering",
                    "Duane Norred"
                ],
                [
                    "J",
                    "Justin Lafrance",
                ],
                [
                    "K",
                    "Krystin Schoenberg",
                ],
                [
                    "#",
                    "",
                    " ",
                    "✅",
                    "🙏🏼🥺"
                ],
            ]
        )
    }
}


fileprivate struct CollatedContent : Equatable, ItemContent, LocalizedCollatableItemContent {
    
    var text : String
    
    var identifier: String {
        self.text
    }
    
    func apply(to views: ItemContentViews<CollatedContent>, for reason: ApplyReason, with info: ApplyItemContentInfo) {
        // Nothing needed.
    }
    
    static func createReusableContentView(frame: CGRect) -> UIView {
        UIView(frame: frame)
    }
    
    var collationString: String {
        self.text
    }
}


/// Via http://listofrandomnames.com

fileprivate let names : [String] = [
    "Delisa Leggio",
    "Krystin Schoenberg",
    "Dionna Levering",
    "Duane Norred",
    "Justin Lafrance",
    "",
    " ",
    "🙏🏼🥺",
    "✅"
]
