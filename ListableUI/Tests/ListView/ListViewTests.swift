//
//  ListViewTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 11/27/19.
//

import XCTest

@testable import ListableUI



class ListViewTests: XCTestCase
{
    func test_changing_supplementary_views()
    {
        // Ensure that we can swap out a supplementary view without any other changes.
        // Before nesting the supplementary views provided by the developer in a container
        // view that is always present, this code would crash because the collection
        // view does not know to refresh the views.
        
        let listView = ListView(frame: CGRect(x: 0, y: 0, width: 200, height: 400))
                
        listView.configure { list in
            list.animatesChanges = false
            
            list += Section("a-section")
            list.content.overscrollFooter = HeaderFooter(TestSupplementary())
        }
        
        listView.collectionView.contentOffset.y = 100
        self.waitForOneRunloop()
        
        listView.configure { list in
            list.animatesChanges = false
            
            list += Section("a-section")
            list.content.overscrollFooter = nil
        }
        
        listView.collectionView.contentOffset.y = 100
        self.waitForOneRunloop()
        
        listView.configure { list in
            list.animatesChanges = false
            
            list += Section("a-section")
            list.content.overscrollFooter = HeaderFooter(TestSupplementary())
        }
        
        listView.collectionView.contentOffset.y = 100
        self.waitForOneRunloop()
    }
    
    func test_calculateScrollViewInsets()
    {
        let listView = ListView(frame: CGRect(x: 0, y: 0, width: 200, height: 400))
        
        listView.scrollIndicatorInsets = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)
        
        self.testcase("Nil Keyboard Frame") {
            let (content, scroll) = listView.calculateScrollViewInsets(with: nil)
            
            XCTAssertEqual(
                content,
                UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            )
            
            XCTAssertEqual(
                scroll,
                UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)
            )
        }
        
        self.testcase("Non-Overlapping Keyboard Frame") {
            let (content, scroll) = listView.calculateScrollViewInsets(with: .nonOverlapping)
            
            XCTAssertEqual(
                content,
                UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            )
            
            XCTAssertEqual(
                scroll,
                UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)
            )
        }
        
        self.testcase("Overlapping Keyboard Frame") {
            let (content, scroll) = listView.calculateScrollViewInsets(
                with:.overlapping(frame: CGRect(x: 0, y: 200, width: 200, height: 200))
            )
            
            XCTAssertEqual(
                content,
                UIEdgeInsets(top: 0, left: 0, bottom: 200, right: 0)
            )
            
            XCTAssertEqual(
                scroll,
                UIEdgeInsets(top: 10, left: 20, bottom: 200, right: 40)
            )
        }
    }
}


fileprivate struct TestContent : ItemContent, Equatable
{
    var title : String
    
    var identifier: Identifier<TestContent> {
        return .init(self.title)
    }
    
    func apply(to views: ItemContentViews<Self>, for reason: ApplyReason, with info: ApplyItemContentInfo) {}
    
    typealias ContentView = UIView
    
    static func createReusableContentView(frame: CGRect) -> UIView
    {
        return UIView(frame: frame)
    }
}


fileprivate struct TestSupplementary : HeaderFooterContent, Equatable
{
    func apply(
        to views: HeaderFooterContentViews<Self>,
        for reason: ApplyReason,
        with info: ApplyHeaderFooterContentInfo
    ) {
        // Nothing.
    }
    
    typealias ContentView = UIView

    static func createReusableContentView(frame: CGRect) -> UIView
    {
        return UIView(frame: frame)
    }
}
