//
//  PresentationStateTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 11/22/19.
//

@testable import ListableUI

import XCTest


class PresentationStateTests: XCTestCase
{
    func new() -> PresentationState {
        PresentationState { content in
            content += Section("1") { section in
                section += TestItem()
                section += TestItem()
            }
            
            content += Section("2") { section in
                section += TestItem()
            }
        }
    }
    
    func test_remove_at() {
        let state = self.new()
        
        state.remove(at: .init(item: 1, section: 0))
        
        XCTAssertEqual(state.sections[0].items.count, 1)
        XCTAssertEqual(state.sections[0].model.items.count, 1)
        
        state.remove(at: .init(item: 0, section: 0))
        
        XCTAssertEqual(state.sections[0].items.count, 0)
        XCTAssertEqual(state.sections[0].model.items.count, 0)
    }
    
    func test_remove_item() {
        let state = self.new()
        
        let item = state.sections[0].items[0]
        
        let indexPath = state.remove(item: item)
        
        XCTAssertEqual(indexPath, IndexPath(item: 0, section: 0))
        
        XCTAssertEqual(state.sections[0].items.count, 1)
        XCTAssertEqual(state.sections[0].model.items.count, 1)
    }
    
    func test_insert_item_at() {
        let state = self.new()
        
        let newItem = PresentationState.ItemState(Item(TestItem()))
        
        state.insert(item: newItem, at: IndexPath(item: 1, section: 1))
                                                  
        XCTAssertEqual(state.sections[1].items.count, 2)
        XCTAssertEqual(state.sections[1].model.items.count, 2)
    }
}


fileprivate struct TestItem : ItemContent, Equatable {
    
    var identifierValue : String {
        ""
    }
    
    typealias ContentView = UIView
    
    static func createReusableContentView(frame: CGRect) -> UIView {
        UIView(frame: frame)
    }
    
    func apply(to views: ItemContentViews<TestItem>, for reason: ApplyReason, with info: ApplyItemContentInfo) {}
}
