//
//  ListView.LayoutManagerTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 6/17/20.
//

import XCTest
@testable import ListableUI


class LayoutManagerTests : XCTestCase
{
    func test_set_layout()
    {
        let startingLayout : LayoutDescription = .table()
        
        let listView = ListView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
        listView.layout = startingLayout
        listView.layoutIfNeeded()
        
        let manager = listView.layoutManager
        
        let collectionViewLayout1 = listView.collectionViewLayout
        let listLayout1 = listView.collectionViewLayout.layout
        
        // Setting the same layout should not change anything.
        
        manager.set(layout: startingLayout, animated: false, completion: {})
        listView.layoutIfNeeded()
        
        XCTAssertTrue(collectionViewLayout1 === listView.collectionViewLayout)
        XCTAssertTrue(listLayout1 === listView.collectionViewLayout.layout)
        
        /// Setting the same layout type, but changing the description should change the inner ListLayout.
        
        let newLayout1 : LayoutDescription = .table {
            $0.bounds = .init(padding: UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0))
        }
        
        manager.set(layout: newLayout1, animated: false, completion: {})
        listView.layoutIfNeeded()
        
        XCTAssertTrue(collectionViewLayout1 === listView.collectionViewLayout)
        XCTAssertTrue(listLayout1 !== listView.collectionViewLayout.layout)
        
        /// Changing the layout type should change both objects
        
        let newLayout2 : LayoutDescription = .paged()
        
        manager.set(layout: newLayout2, animated: false, completion: {})
        listView.layoutIfNeeded()
        
        XCTAssertTrue(collectionViewLayout1 !== listView.collectionViewLayout)
        XCTAssertTrue(listLayout1 !== listView.collectionViewLayout.layout)
    }
}

