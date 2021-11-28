//
//  ListLayoutTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 8/10/20.
//

import XCTest
@testable import ListableUI


final class ListLayoutTests : XCTestCase
{
    
}


final class AnyListLayoutTests : XCTestCase {
            
    func test_firstFullyVisibleItem_after_velocity() {
        
        let layout = makeLayoutForVisibleTests()
        
        XCTFail()
    }
    
    func test_rectForFindingFirstFullyVisibleItem_after_velocity() {
        XCTFail()
    }
    
    private func makeLayoutForVisibleTests() -> AnyListLayout {
        
        let list : ListProperties = .default { list in
            list.layout = .table()
            
            list.add {
                Section(1) {
                    TestingItemContent()
                    TestingItemContent()
                    TestingItemContent()
                } header: {
                    TestingHeaderFooterContent()
                }
                
                Section(2) {
                    TestingItemContent()
                    TestingItemContent()
                    TestingItemContent()
                } header: {
                    TestingHeaderFooterContent()
                }
            }
        }
        
        return list.makeLayout(
            in: CGSize(width: 200, height: 200),
            safeAreaInsets: .zero,
            itemLimit: nil
        )
    }
}


fileprivate struct TestingHeaderFooterContent : HeaderFooterContent {
        
    func apply(
        to views: HeaderFooterContentViews<Self>,
        for reason: ApplyReason,
        with info: ApplyHeaderFooterContentInfo
    ) {
        views.content.backgroundColor = .black
    }
    
    func isEquivalent(to other: TestingHeaderFooterContent) -> Bool {
        false
    }
    
    typealias ContentView = UIView
    
    static func createReusableContentView(frame: CGRect) -> UIView {
        UIView(frame: frame)
    }
    
    var defaultHeaderFooterProperties: DefaultProperties {
        .defaults {
            $0.sizing = .fixed(width: 100, height: 100)
        }
    }
}


fileprivate struct TestingItemContent : ItemContent {
        
    var identifierValue: String {
        ""
    }
    
    func apply(to views: ItemContentViews<Self>, for reason: ApplyReason, with info: ApplyItemContentInfo)
    {
        views.content.backgroundColor = .darkGray
    }
    
    func isEquivalent(to other: TestingItemContent) -> Bool {
        false
    }
    
    typealias ContentView = UIView
    
    static func createReusableContentView(frame: CGRect) -> UIView {
        UIView(frame: frame)
    }
    
    var defaultItemProperties: DefaultProperties {
        .defaults {
            $0.sizing = .fixed(width: 100, height: 100)
        }
    }
}
