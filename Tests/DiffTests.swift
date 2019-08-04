//
//  DiffTests.swift
//  CheckoutApplet-Unit-Tests
//
//  Created by Kyle Van Essen on 6/17/19.
//

import XCTest
@testable import CheckoutApplet

struct ItemSection
{
    var title : String
    
    var items : [Row]
    
    struct Row : Equatable
    {
        var name : String
        var detail : String
    }
}

class DiffTests: XCTestCase
{
    func test_performance()
    {
        let dictionary = EnglishDictionary()
        
        for count in 0..<dictionary.wordsByLetter.count {
            
            let includedLetters = Array(dictionary.wordsByLetter[0...count])
            
            let wordCount : Int = includedLetters.reduce(0, { $0 + $1.words.count })
            
            let start = DispatchTime.now()
            
            let diff = SectionedDiff(
                old: includedLetters,
                new: includedLetters,
                configuration: SectionedDiff.Configuration(
                    section: .init(
                        identifier: { AnyHashable($0.letter) },
                        rows: { $0.words },
                        updated: { $0.letter != $1.letter },
                        movedHint: { $0.letter != $1.letter }
                    ),
                    row: .init(
                        identifier: { AnyHashable($0.word) },
                        updated: { $0.word != $1.word },
                        movedHint: { $0.word != $1.word }
                    )
                )
            )
            
            let end = DispatchTime.now()
            
            let seconds = Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000.0
            
            print("Run Time for \(count) sections (\(wordCount) words): \(seconds).")
        }
    }
    
    func test_displayContent()
    {
        let content = TableView.Content(
            sections: [
                TableView.Section(
                    identifier: 0,
                    rows: [
                        TableView.Row("Row 1"),
                        TableView.Row("Row 2"),
                        TableView.Row("Row 3"),
                        TableView.Row("Row 4"),
                        TableView.Row("Row 5"),
                    ]
                ),
                TableView.Section(
                    identifier: 1,
                    rows: [
                        TableView.Row("Row 1"),
                        TableView.Row("Row 2"),
                        TableView.Row("Row 3"),
                        TableView.Row("Row 4"),
                        TableView.Row("Row 5"),
                    ]
                ),
                TableView.Section(
                    identifier: 2,
                    rows: [
                        TableView.Row("Row 1"),
                        TableView.Row("Row 2"),
                        TableView.Row("Row 3"),
                        TableView.Row("Row 4"),
                        TableView.Row("Row 5"),
                    ]
                ),
            ]
        )
        
        let upTo = content.sliceUpTo(indexPath: IndexPath(row: 1, section: 1), plus: 3)
        print(upTo)
    }
    
    func test_diff()
    {
        let first = [ItemSection]()
        
        let second = [
            ItemSection(
                title: "Coffees",
                items: [
                    ItemSection.Row(
                        name: "Cappucino",
                        detail: "5 Prices"
                    ),
                    ItemSection.Row(
                        name: "Americano",
                        detail: "2 Prices"
                    ),
                    ItemSection.Row(
                        name: "Latte",
                        detail: "3 Prices"
                    )
                ]
            )
        ]
        
        let third = [
            ItemSection(
            title: "Coffees",
            items: [
                ItemSection.Row(
                    name: "Cappucino",
                    detail: "5 Prices"
                ),
                ItemSection.Row(
                    name: "Americano",
                    detail: "2 Prices"
                ),
                ItemSection.Row(
                    name: "Espresso",
                    detail: "4 Prices"
                )
            ]),
            
            ItemSection(
                title: "Snacks",
                items: [
                    ItemSection.Row(
                        name: "Cookie",
                        detail: "5 Prices"
                    ),
                    ItemSection.Row(
                        name: "Bagel",
                        detail: "2 Prices"
                    ),
                ]
            )
        ]
        
        let config = SectionedDiff<ItemSection, ItemSection.Row>.Configuration(
            section: .init(
                identifier: { AnyHashable($0.title) },
                rows: { $0.items },
                updated: { $0.title != $1.title },
                movedHint: { $0.title != $1.title }
            ),
            row: .init(
                identifier: { AnyHashable($0.name) },
                updated: { $0 != $1 },
                movedHint: { $0.name != $1.name }
            )
        )
        
        let firstDiff = SectionedDiff(old: first, new: second, configuration: config)
        let secondDiff = SectionedDiff(old: second, new: third, configuration: config)
        
        print("")
    }
}
