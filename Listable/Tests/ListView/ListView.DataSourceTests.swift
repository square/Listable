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
        /// Tested via integration tests.
        /// Can't test via unit tests as the collection view expects this method only to be called at specific times.
    }
    
    func test_collectionView_viewForSupplementaryElementOfKind_at()
    {
        /// Tested via integration tests.
        /// Can't test via unit tests as the collection view expects this method only to be called at specific times.
    }
    
    func test_collectionView_canMoveItemAt()
    {
        let fixture = self.newFixture()
        
        
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
            
            content.header = HeaderFooter(
                with: TestSupplementary(name: "list-header"),
                appearance: TestSupplementary.Appearance()
            )
            
            content.footer = HeaderFooter(
                with: TestSupplementary(name: "list-footer"),
                appearance: TestSupplementary.Appearance()
            )
            
            content.overscrollFooter = HeaderFooter(
                with: TestSupplementary(name: "overscroll-footer"),
                appearance: TestSupplementary.Appearance()
            )
            
            content += Section(identifier: "section-1") { section in
                
                section.header = HeaderFooter(
                    with: TestSupplementary(name: "header-1"),
                    appearance: TestSupplementary.Appearance()
                )
                
                section.footer = HeaderFooter(
                    with: TestSupplementary(name: "footer-1"),
                    appearance: TestSupplementary.Appearance()
                )
                
                section += Item(with: TestElement(name: "row-1"), appearance: TestElement.Appearance())
                section += Item(with: TestElement(name: "row-2"), appearance: TestElement.Appearance())
            }
            
            content += Section(identifier: "section-2") { section in
                
                section.header = HeaderFooter(
                    with: TestSupplementary(name: "header-2"),
                    appearance: TestSupplementary.Appearance()
                )
                
                section.footer = HeaderFooter(
                    with: TestSupplementary(name: "footer-2"),
                    appearance: TestSupplementary.Appearance()
                )
                
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
