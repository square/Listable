//
//  ListView+ContentSizeTests.swift
//  Listable-Unit-Tests
//
//  Created by Kyle Van Essen on 9/21/20.
//

import XCTest

@testable import ListableUI


class ListView_ContentSizeTests : XCTestCase
{
    func test_contentSize()
    {
        /// We are testing multiple cases here for a couple reasons:
        ///
        /// 1) Ensure that both horizontal and vertical layouts work; the implementation for sizing
        /// their measurement views is different.
        ///
        /// 2) We loop over the cases to ensure the measurement is reported reliably; eg it doesn't
        /// for some reason break after a few passes (eg due to measurement view cache reuse).
        
        let section = Section("section") { section in
            section += Item(TestContent(title: "first item"), sizing: .fixed(width: 100, height: 50))
            section += Item(TestContent(title: "second item"), sizing: .fixed(width: 150, height: 50))
            section += Item(TestContent(title: "third item"), sizing: .fixed(width: 200, height: 50))
        }
        
        for _ in 1...3 {
            self.testcase("vertical list") {
                let properties = ListProperties.default { list in
                    
                    list.layout = .table()
                    
                    list += section
                }
                                
                XCTAssertEqual(
                    ListView.contentSize(in: CGSize(width: 300.0, height: 0.0), for: properties, safeAreaInsets: .zero),
                    
                    MeasuredListSize(
                        contentSize: CGSize(width: 300.0, height: 150.0),
                        naturalWidth: 200.0
                    )
                )
            }
            
            self.testcase("vertical paged") {
                let properties = ListProperties.default { list in
                    
                    list.layout = .paged {
                        $0.direction = .vertical
                        $0.pagingSize = .fixed(100.0)
                    }
                    
                    list += section
                }
                                
                XCTAssertEqual(
                    ListView.contentSize(in: CGSize(width: 100.0, height: 0), for: properties, safeAreaInsets: .zero),
                    
                    MeasuredListSize(
                        contentSize: CGSize(width: 100.0, height: 300.0),
                        naturalWidth: nil
                    )
                )
            }
            
            self.testcase("horizontal paged") {
                let properties = ListProperties.default { list in
                    
                    list.layout = .paged {
                        $0.direction = .horizontal
                        $0.pagingSize = .fixed(100.0)
                    }
                    
                    list += section
                }
                
                XCTAssertEqual(
                    ListView.contentSize(in: CGSize(width: 0.0, height: 100.0), for: properties, safeAreaInsets: .zero),
                    
                    MeasuredListSize(
                        contentSize: CGSize(width: 300.0, height: 100.0),
                        naturalWidth: nil
                    )
                )
            }
        }
    }
}


fileprivate struct TestContent : ItemContent, Equatable
{
    var title : String
    
    var identifierValue: String {
        self.title
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
