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
    
    func test_contentSize()
    {
        self.testcase("vertical") {
            let properties = ListProperties.default { list in
                
                list.layout = .paged {
                    $0.direction = .vertical
                    $0.pagingSize = .fixed(100.0)
                }
                
                list("section") { section in
                    section += TestContent(title: "first item")
                    section += TestContent(title: "second item")
                    section += TestContent(title: "third item")
                }
            }
            
            let size = ListView.contentSize(in: CGSize(width: 100.0, height: 0), for: properties)
            
            XCTAssertEqual(size, CGSize(width: 100.0, height: 300.0))
        }
        
        self.testcase("horizontal") {
            let properties = ListProperties.default { list in
                
                list.layout = .paged {
                    $0.direction = .horizontal
                    $0.pagingSize = .fixed(100.0)
                }
                
                list("section") { section in
                    section += TestContent(title: "first item")
                    section += TestContent(title: "second item")
                    section += TestContent(title: "third item")
                }
            }
            
            let size = ListView.contentSize(in: CGSize(width: 0.0, height: 100.0), for: properties)
            
            XCTAssertEqual(size, CGSize(width: 300.0, height: 100.0))
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
    func apply(to views : HeaderFooterContentViews<Self>, reason: ApplyReason) {}
    
    typealias ContentView = UIView

    static func createReusableContentView(frame: CGRect) -> UIView
    {
        return UIView(frame: frame)
    }
}
