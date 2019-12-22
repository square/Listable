//
//  ListView.StorageTests.swift
//  Listable-Unit-Tests
//
//  Created by Kyle Van Essen on 11/27/19.
//

import XCTest

@testable import Listable


class ListView_StorageTests: XCTestCase
{
    func test_moveItem()
    {
        let fixture = self.newFixture()
        
        fixture.storage.moveItem(from: IndexPath(item: 0, section: 0), to: IndexPath(item: 1, section: 1))
        
        let content = fixture.storage.allContent.sections.mapElements(as: TestElement.self) { $0.name }
        let presentation = fixture.storage.presentationState.sections.mapElements(as: TestElement.self) { $0.name }
        
        let expected = [
            [
                "row-2",
            ],
            [
                "row-3",
                "row-1",
                "row-4",
                "row-5",
            ],
        ]
        
        XCTAssertEqual(expected, content)
        XCTAssertEqual(expected, presentation)
    }
    
    func test_remove()
    {
        self.testcase("Result is found") {
            let fixture = self.newFixture()
            
            let item = fixture.storage.presentationState.item(at: IndexPath(item: 1, section: 1))
            
            let removed = fixture.storage.remove(item: item)
            
            XCTAssertEqual(removed, IndexPath(item: 1, section: 1))
            
            let content = fixture.storage.allContent.sections.mapElements(as: TestElement.self) { $0.name }
            let presentation = fixture.storage.presentationState.sections.mapElements(as: TestElement.self) { $0.name }
            
            let expected = [
                [
                    "row-1",
                    "row-2",
                ],
                [
                    "row-3",
                    "row-5",
                ],
            ]
            
            XCTAssertEqual(expected, content)
            XCTAssertEqual(expected, presentation)
        }
        
        self.testcase("Result is not found") {
            let fixture = self.newFixture()
            
            let item = PresentationState.ItemState(
                with: Item<TestElement>(
                    with: TestElement(name: "an-item"),
                    appearance: TestElement.Appearance()
                ),
                reorderingDelegate: fixture.reordering
            )
            
            let removed = fixture.storage.remove(item: item)
            
            XCTAssertEqual(removed, nil)
            
            let content = fixture.storage.allContent.sections.mapElements(as: TestElement.self) { $0.name }
            let presentation = fixture.storage.presentationState.sections.mapElements(as: TestElement.self) { $0.name }
            
            let expected = [
                [
                    "row-1",
                    "row-2",
                ],
                [
                    "row-3",
                    "row-4",
                    "row-5",
                ],
            ]
            
            XCTAssertEqual(expected, content)
            XCTAssertEqual(expected, presentation)
        }
    }
    
    struct Fixture
    {
        let reordering : ReorderingActionsDelegate
        
        let storage : ListView.Storage
    }
    
    func newFixture() -> Fixture
    {
        let reordering = ReorderingDelegate_Stub()
        
        let storage = ListView.Storage()
        
        storage.allContent = Content { content in
            content += Section(identifier: "section-1") { section in
                section += Item(with: TestElement(name: "row-1"), appearance: TestElement.Appearance())
                section += Item(with: TestElement(name: "row-2"), appearance: TestElement.Appearance())
            }
            
            content += Section(identifier: "section-2") { section in
                section += Item(with: TestElement(name: "row-3"), appearance: TestElement.Appearance())
                section += Item(with: TestElement(name: "row-4"), appearance: TestElement.Appearance())
                section += Item(with: TestElement(name: "row-5"), appearance: TestElement.Appearance())
            }
        }
        
        let diff = ListView.diffWith(old : [], new: storage.allContent.sections)
        
        storage.presentationState.update(
            with: diff,
            slice: Content.Slice(containsAllItems: true, content: storage.allContent),
            reorderingDelegate: reordering
        )
        
        return Fixture(reordering: reordering, storage: storage)
    }
}
