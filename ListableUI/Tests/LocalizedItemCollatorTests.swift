//
//  LocalizedItemCollatorTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 12/7/20.
//

@testable import ListableUI
import XCTest

class LocalizedItemCollatorTests: XCTestCase {
    func test_init() {
        let collator = LocalizedItemCollator(
            collation: .current(),
            items: names.map {
                Item(CollatedContent(text: $0))
            }
        )

        let groupedNames: [[String]] = collator.collated.map { section in
            [section.title] + section.items.map { ($0.anyContent as! CollatedContent).text }
        }

        XCTAssertEqual(groupedNames,
                       [
                           [
                               "D",
                               "Delisa Leggio",
                               "Dionna Levering",
                               "Duane Norred",
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
                               "🙏🏼🥺",
                           ],
                       ])
    }
}

private struct CollatedContent: Equatable, ItemContent, LocalizedCollatableItemContent {
    var text: String

    var identifierValue: String {
        text
    }

    func apply(to _: ItemContentViews<CollatedContent>, for _: ApplyReason, with _: ApplyItemContentInfo) {
        // Nothing needed.
    }

    static func createReusableContentView(frame: CGRect) -> UIView {
        UIView(frame: frame)
    }

    var collationString: String {
        text
    }
}

/// Via http://listofrandomnames.com

private let names: [String] = [
    "Delisa Leggio",
    "Krystin Schoenberg",
    "Dionna Levering",
    "Duane Norred",
    "Justin Lafrance",
    "",
    " ",
    "🙏🏼🥺",
    "✅",
]
