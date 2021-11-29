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
        
        self.testcase("vertical, forward") {
            let layout = layoutForVisibleTests(direction: .vertical)

            XCTAssertEqual(
                layout.firstFullyVisibleItem(
                    after: CGPoint(x: 0, y: 0),
                    velocity: CGPoint(x: 0, y: 1)
                )?.defaultFrame,
                CGRect(x: 0, y: 0, width: 200, height: 100)
            )
            
            XCTAssertEqual(
                layout.firstFullyVisibleItem(
                    after: CGPoint(x: 0, y: 50),
                    velocity: CGPoint(x: 0, y: 1)
                )?.defaultFrame,
                CGRect(x: 0, y: 100, width: 200, height: 100)
            )
        }
        
        self.testcase("vertical, backward") {
            let layout = layoutForVisibleTests(direction: .vertical)
            
            XCTAssertEqual(
                layout.firstFullyVisibleItem(
                    after: CGPoint(x: 0, y: 150),
                    velocity: CGPoint(x: 0, y: -1)
                )?.defaultFrame,
                CGRect(x: 0, y: 0, width: 200, height: 100)
            )
            
            XCTAssertEqual(
                layout.firstFullyVisibleItem(
                    after: CGPoint(x: 0, y: 250),
                    velocity: CGPoint(x: 0, y: -1)
                )?.defaultFrame,
                CGRect(x: 0, y: 100, width: 200, height: 100)
            )
        }
    }
    
    func test_rectForFindingFirstFullyVisibleItem_after_velocity() {

        self.testcase("vertical") {
            let layout = layoutForVisibleTests(direction: .vertical)

            XCTAssertEqual(
                layout.rectForFindingFirstFullyVisibleItem(
                    after: CGPoint(x: 0, y: 100),
                    velocity: CGPoint(x: 0, y: 1)
                ),
                CGRect(x: 0, y: 100, width: 200, height: 1000)
            )
            
            XCTAssertEqual(
                layout.rectForFindingFirstFullyVisibleItem(
                    after: CGPoint(x: 0, y: 100),
                    velocity: CGPoint(x: 0, y: -1)
                ),
                CGRect(x: 0, y: -900, width: 200, height: 1000)
            )
        }
        
        self.testcase("horizontal") {
            let layout = layoutForVisibleTests(direction: .horizontal)
            
            XCTAssertEqual(
                layout.rectForFindingFirstFullyVisibleItem(
                    after: CGPoint(x: 100, y: 0),
                    velocity: CGPoint(x: 1, y: 0)
                ),
                CGRect(x: 100, y: 0, width: 1000, height: 200)
            )
            
            XCTAssertEqual(
                layout.rectForFindingFirstFullyVisibleItem(
                    after: CGPoint(x: 100, y: 0),
                    velocity: CGPoint(x: -1, y: 0)
                ),
                CGRect(x: -900, y: 0, width: 1000, height: 200)
            )
        }
        
    }
    
    private func layoutForVisibleTests(direction: LayoutDirection) -> AnyListLayout {
        
        let list : ListProperties = .default { list in
            
            list.layout = .table {
                $0.direction = direction
            }
            
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
