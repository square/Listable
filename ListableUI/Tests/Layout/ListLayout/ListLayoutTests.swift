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
            
    func test_onDidEndDraggingTargetContentOffset_for_velocity() {
        
        self.testcase("no paging") {
            let layout = layoutForVisibleTests(direction: .vertical, pagingBehavior: .none)
            
            XCTAssertEqual(
                layout.onDidEndDraggingTargetContentOffset(
                    for: CGPoint(x: 0, y: 0),
                       velocity: CGPoint(x: 0, y: 1)
                ),
                nil
            )
        }
        
        self.testcase("vertical") {
            let layout = layoutForVisibleTests(direction: .vertical)
            
            self.testcase("forward") {
                XCTAssertEqual(
                    layout.onDidEndDraggingTargetContentOffset(
                        for: CGPoint(x: 0, y: 0),
                        velocity: CGPoint(x: 0, y: 1)
                    ),
                    CGPoint(x: 0, y: 0.0)
                )
                
                XCTAssertEqual(
                    layout.onDidEndDraggingTargetContentOffset(
                        for: CGPoint(x: 0, y: 100),
                        velocity: CGPoint(x: 0, y: 1)
                    ),
                    CGPoint(x: 0, y: 100.0)
                )
            }
            
            self.testcase("backward") {
                XCTAssertEqual(
                    layout.onDidEndDraggingTargetContentOffset(
                        for: CGPoint(x: 0, y: 0),
                        velocity: CGPoint(x: 0, y: -1)
                    ),
                    nil
                )
                
                XCTAssertEqual(
                    layout.onDidEndDraggingTargetContentOffset(
                        for: CGPoint(x: 0, y: 100),
                        velocity: CGPoint(x: 0, y: -1)
                    ),
                    CGPoint(x: 0, y: 0)
                )
            }
        }
        
        self.testcase("horizontal") {
            let layout = layoutForVisibleTests(direction: .horizontal)

            self.testcase("forward") {
                XCTAssertEqual(
                    layout.onDidEndDraggingTargetContentOffset(
                        for: CGPoint(x: 0, y: 0),
                        velocity: CGPoint(x: 1, y: 0)
                    ),
                    CGPoint(x: 0.0, y: 0.0)
                )
                
                
                XCTAssertEqual(
                    layout.onDidEndDraggingTargetContentOffset(
                        for: CGPoint(x: 100, y: 0),
                        velocity: CGPoint(x: 1, y: 0)
                    ),
                    CGPoint(x: 100, y: 0.0)
                )
            }

            self.testcase("backward") {
                XCTAssertEqual(
                    layout.onDidEndDraggingTargetContentOffset(
                        for: CGPoint(x: 0, y: 0),
                        velocity: CGPoint(x: -1, y: 0)
                    ),
                    nil
                )
                
                
                XCTAssertEqual(
                    layout.onDidEndDraggingTargetContentOffset(
                        for: CGPoint(x: 100, y: 0),
                        velocity: CGPoint(x: -1, y: 0)
                    ),
                    CGPoint(x: 0.0, y: 0.0)
                )
            }
        }
    }
    
    func test_itemToScrollToOnDidEndDragging_after_velocity() {
        
        self.testcase("vertical") {
            let layout = layoutForVisibleTests(direction: .vertical)
            
            self.testcase("forward") {
                XCTAssertEqual(
                    layout.itemToScrollToOnDidEndDragging(
                        after: CGPoint(x: 0, y: 0),
                        velocity: CGPoint(x: 0, y: 1)
                    )?.defaultFrame,
                    CGRect(x: 20, y: 10, width: 140, height: 100)
                )
                
                XCTAssertEqual(
                    layout.itemToScrollToOnDidEndDragging(
                        after: CGPoint(x: 0, y: 50),
                        velocity: CGPoint(x: 0, y: 1)
                    )?.defaultFrame,
                    CGRect(x: 20, y: 110, width: 140, height: 100)
                )
            }
            
            self.testcase("backward") {
                XCTAssertEqual(
                    layout.itemToScrollToOnDidEndDragging(
                        after: CGPoint(x: 0, y: 0),
                        velocity: CGPoint(x: 0, y: -1)
                    )?.defaultFrame,
                    nil
                )
                
                XCTAssertEqual(
                    layout.itemToScrollToOnDidEndDragging(
                        after: CGPoint(x: 0, y: 350),
                        velocity: CGPoint(x: 0, y: -1)
                    )?.defaultFrame,
                    CGRect(x: 20, y: 310, width: 140, height: 100)
                )
            }
        }
        
        self.testcase("horizontal") {
            let layout = layoutForVisibleTests(direction: .horizontal)
            
            self.testcase("forward") {
                XCTAssertEqual(
                    layout.itemToScrollToOnDidEndDragging(
                        after: CGPoint(x: 0, y: 0),
                        velocity: CGPoint(x: 1, y: 0)
                    )?.defaultFrame,
                    CGRect(x: 20, y: 10, width: 100, height: 160)
                )
                
                XCTAssertEqual(
                    layout.itemToScrollToOnDidEndDragging(
                        after: CGPoint(x: 50, y: 0),
                        velocity: CGPoint(x: 1, y: 0)
                    )?.defaultFrame,
                    CGRect(x: 120, y: 10, width: 100, height: 160)
                )
            }
            
            self.testcase("backward") {
                XCTAssertEqual(
                    layout.itemToScrollToOnDidEndDragging(
                        after: CGPoint(x: 0, y: 0),
                        velocity: CGPoint(x: -1, y: 0)
                    )?.defaultFrame,
                    nil
                )
                
                XCTAssertEqual(
                    layout.itemToScrollToOnDidEndDragging(
                        after: CGPoint(x: 350, y: 0),
                        velocity: CGPoint(x: -1, y: 0)
                    )?.defaultFrame,
                    CGRect(x: 320, y: 10, width: 100, height: 160)
                )
            }
        }
    }
    
    func test_rectForFindingItemToScrollToOnDidEndDragging_after_velocity() {

        self.testcase("vertical") {
            let layout = layoutForVisibleTests(direction: .vertical)

            self.testcase("forward") {
                XCTAssertEqual(
                    layout.rectForFindingItemToScrollToOnDidEndDragging(
                        after: CGPoint(x: 0, y: 100),
                        velocity: CGPoint(x: 0, y: 1)
                    ),
                    CGRect(x: 0, y: 100, width: 200, height: 1000)
                )
            }
            
            self.testcase("backward") {
                XCTAssertEqual(
                    layout.rectForFindingItemToScrollToOnDidEndDragging(
                        after: CGPoint(x: 0, y: 100),
                        velocity: CGPoint(x: 0, y: -1)
                    ),
                    CGRect(x: 0, y: -900, width: 200, height: 1000)
                )
            }
        }
        
        self.testcase("horizontal") {
            let layout = layoutForVisibleTests(direction: .horizontal)
            
            self.testcase("forward") {
                XCTAssertEqual(
                    layout.rectForFindingItemToScrollToOnDidEndDragging(
                        after: CGPoint(x: 100, y: 0),
                        velocity: CGPoint(x: 1, y: 0)
                    ),
                    CGRect(x: 100, y: 0, width: 1000, height: 200)
                )
            }
            
            self.testcase("backward") {
                XCTAssertEqual(
                    layout.rectForFindingItemToScrollToOnDidEndDragging(
                        after: CGPoint(x: 100, y: 0),
                        velocity: CGPoint(x: -1, y: 0)
                    ),
                    CGRect(x: -900, y: 0, width: 1000, height: 200)
                )
            }
        }
    }
    
    private func layoutForVisibleTests(
        direction: LayoutDirection,
        pagingBehavior : ListPagingBehavior = .firstVisibleItemEdge
    ) -> AnyListLayout {
        
        let list : ListProperties = .default { list in
            
            list.layout = .table {
                $0.direction = direction
                
                $0.bounds = .init(
                    padding: UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)
                )
                
                $0.pagingBehavior = pagingBehavior
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
