//
//  ListViewTests.swift
//  Listable-Unit-Tests
//
//  Created by Kyle Van Essen on 11/27/19.
//

import XCTest

@testable import Listable



class ListViewTests: XCTestCase
{
    func test_changing_supplementary_views()
    {
        // Ensure that we can swap out a supplementary view without any other changes.
        // Before nesting the supplementary views provided by the developer in a container
        // view that is always present, this code would crash because the collection
        // view does not know to refresh the views.
        
        let listView = ListView(frame: CGRect(x: 0, y: 0, width: 200, height: 400))
                
        listView.setContent { list in
            list.animatesChanges = false
            
            list += Section("a-section")
            list.content.overscrollFooter = HeaderFooter(TestSupplementary())
        }
        
        listView.collectionView.contentOffset.y = 100
        self.waitForOneRunloop()
        
        listView.setContent { list in
            list.animatesChanges = false
            
            list += Section("a-section")
            list.content.overscrollFooter = nil
        }
        
        listView.collectionView.contentOffset.y = 100
        self.waitForOneRunloop()
        
        listView.setContent { list in
            list.animatesChanges = false
            
            list += Section("a-section")
            list.content.overscrollFooter = HeaderFooter(TestSupplementary())
        }
        
        listView.collectionView.contentOffset.y = 100
        self.waitForOneRunloop()
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
    func apply(to view: UIView, reason: ApplyReason) {}
    
    typealias ContentView = UIView

    static func createReusableHeaderFooterView(frame: CGRect) -> UIView
    {
        return UIView(frame: frame)
    }
}
