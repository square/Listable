//
//  ListView.DataSourceTests.swift
//  Listable-Unit-Tests
//
//  Created by Kyle Van Essen on 11/27/19.
//

import XCTest
import UIKit

@testable import Listable


class ListView_DataSourceTests: XCTestCase
{
    func test_numberOfSections()
    {
        let fixture = self.newFixture()
        
        XCTAssertEqual(fixture.dataSource.numberOfSections(in: fixture.collectionView), 2)
    }
    
    func test_collectionView_numberOfItemsInSection()
    {
        let fixture = self.newFixture()
        
        XCTAssertEqual(fixture.dataSource.collectionView(fixture.collectionView, numberOfItemsInSection: 0), 2)
        XCTAssertEqual(fixture.dataSource.collectionView(fixture.collectionView, numberOfItemsInSection: 1), 3)
    }
    
    func test_collectionView_cellForItemAt()
    {
        let fixture = self.newFixture()
        
        let anyCell = fixture.dataSource.collectionView(fixture.collectionView, cellForItemAt: IndexPath(item: 1, section: 1))
        let cell = anyCell as! ItemElementCell<TestElement>
        
        // Verify the cell is prepared for display.
        
        
    }
    
    func test_collectionView_viewForSupplementaryElementOfKind_at()
    {

    }
    
    func test_collectionView_canMoveItemAt()
    {

    }
    
    func test_collectionView_moveItemAt_to()
    {

    }
    
    struct Fixture
    {
        let reordering : ReorderingActionsDelegate
        let presentationState : PresentationState
        let collectionView : UICollectionView
        let dataSource : ListView.DataSource
        
        let layoutDelegate : ListViewLayoutDelegate
    }
    
    func newFixture() -> Fixture
    {
        let reordering = ReorderingDelegate_Stub()
        let presentationState = PresentationState()
        let dataSource = ListView.DataSource(presentationState: presentationState)
        let layoutDelegate = ListView.LayoutDelegate(presentationState: presentationState, appearance: Appearance())
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: ListViewLayout(delegate: layoutDelegate, appearance: Appearance()))
        
        let content = Content { content in
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
        
        let diff = ListView.diffWith(old : [], new: content.sections)
        
        presentationState.update(
            with: diff,
            slice: Content.Slice(containsAllItems: true, content: content),
            reorderingDelegate: reordering
        )
                
        return Fixture(
            reordering: reordering,
            presentationState: presentationState,
            collectionView: collectionView,
            dataSource: dataSource,
            layoutDelegate: layoutDelegate
        )
    }
}
