//
//  ItemTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 11/27/19.
//

import ListableUI
import XCTest

class ItemTests: XCTestCase
{
    func test_defaultValues() {
        
        let content = TestContent(
            name: "test",
            defaultItemProperties: .defaults { defaults in
                defaults.trailingSwipeActions = .init(
                    action: .init(
                        title: "Test",
                        backgroundColor: .blue,
                        handler: { _ in }
                    )
                )
            }
        )
        
        // Make sure the defaults are actually passed through.
        
        let item = Item(content)
        
        XCTAssertEqual(item.trailingSwipeActions?.actions.count, 1)
        XCTAssertEqual(item.trailingSwipeActions?.actions[0].title, "Test")
    }
}

fileprivate struct TestContent : ItemContent {
    
    typealias ContentView = UIView
    typealias IdentifierValue = String
    
    var name : String
    
    var defaultItemProperties: DefaultProperties = .defaults()
    
    var identifierValue: String {
        name
    }
    
    func isEquivalent(to other: TestContent) -> Bool {
        true
    }
    
    static func createReusableContentView(frame: CGRect) -> UIView {
        UIView(frame: frame)
    }
    
    func apply(to views: ItemContentViews<TestContent>, for reason: ApplyReason, with info: ApplyItemContentInfo) {
        
    }
}
