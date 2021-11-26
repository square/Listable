//
//  FlowListLayoutTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 11/25/21.
//

import XCTest
import Snapshot

@testable import ListableUI


class FlowListLayoutTests : XCTestCase
{    
    func test_layout_vertical()
    {
        let listView = self.list(direction: .vertical)
        
        let snapshot = Snapshot(for: SizedViewIteration(size: listView.contentSize), input: listView)
        
        snapshot.test(output: ViewImageSnapshot.self)
        snapshot.test(output: LayoutAttributesSnapshot.self)
    }
    
    func test_layout_horizontal()
    {
        let listView = self.list(direction: .horizontal)
        
        let snapshot = Snapshot(for: SizedViewIteration(size: listView.contentSize), input: listView)
        
        snapshot.test(output: ViewImageSnapshot.self)
        snapshot.test(output: LayoutAttributesSnapshot.self)
    }
    
    func list(direction: LayoutDirection) -> ListView
    {
        /// 500x500 so the layout will support both horizontal and vertical layouts.
        let listView = ListView(frame: CGRect(origin: .zero, size: CGSize(width: 500.0, height: 500.0)))
        
        listView.configure { list in
            
            list.layout = .flow {
                
                $0.direction = direction
                
                $0.bounds = .init(
                    padding: UIEdgeInsets(top: 10.0, left: 20.0, bottom: 30.0, right: 40.0)
                )
                
                $0.spacings = .init(
                    headerToFirstSectionSpacing: 20,
                    interSectionSpacing: .init(30),
                    sectionHeaderBottomSpacing: 10,
                    itemSpacing: 10,
                    rowSpacing: 10,
                    rowToSectionFooterSpacing: 10,
                    lastSectionToFooterSpacing: 20
                )
            }
            
            list.content.containerHeader = HeaderFooter(
                TestingHeaderFooterContent(color: .red),
                sizing: .fixed(width: 50.0, height: 50.0)
            )
            
            list.header = HeaderFooter(
                TestingHeaderFooterContent(color: .blue),
                sizing: .fixed(width: 50.0, height: 50.0)
            )
            
            list.footer = HeaderFooter(
                TestingHeaderFooterContent(color: .blue),
                sizing: .fixed(width: 70.0, height: 70.0)
            )
            
            list.add {
                Section("empty") { _ in }
                
                Section("empty with header & footer") { section in
                    section.header = HeaderFooter(
                        TestingHeaderFooterContent(color: .orange),
                        sizing: .fixed(width: 40.0, height: 40.0)
                    )
                    
                    section.footer = HeaderFooter(
                        TestingHeaderFooterContent(color: .blue),
                        sizing: .fixed(width: 20.0, height: 20.0)
                    )
                }
                
                for (underflow, _) in FlowAppearance.RowUnderflowAlignment.allTestCases {
                    Section("\(underflow)") { section in
                        section.layouts.flow.rowUnderflowAlignment = underflow
                        
                        section.layouts.flow.width = .custom(
                            .init(
                                padding: .init(leading: 10, trailing: 10),
                                width: .noConstraint,
                                alignment: .center
                            )
                        )
                        
                        section.header = HeaderFooter(
                            TestingHeaderFooterContent(color: .magenta),
                            sizing: .fixed(width: 40.0, height: 40.0)
                        )
                        
                        section.footer = HeaderFooter(
                            TestingHeaderFooterContent(color: .purple),
                            sizing: .fixed(width: 20.0, height: 20.0)
                        )
                        
                        for index in 1...5 {
                            let index = CGFloat(index)

                            section += Item(
                                TestingItemContent(color: .init(white: 0.0, alpha: 0.1 * index)),
                                sizing: .fixed(width: 120.0, height: 120.0)
                            )
                        }
                    }
                }
                
                for (alignment, _) in FlowAppearance.RowItemsAlignment.allTestCases {
                    Section("\(alignment)") { section in
                        section.layouts.flow.rowItemsAlignment = alignment
                        section.layouts.flow.itemSizing = .columns(4)
                        
                        for index in 1...6 {
                            let index = CGFloat(index)
                            
                            section += Item(
                                TestingItemContent(color: .init(white: 0.0, alpha: 0.1 * index)),
                                sizing: direction.switch {
                                    .fixed(width: 50.0, height: 50.0 + (10 * index))
                                } horizontal: {
                                    .fixed(width: 50.0 + (10 * index), height: 50.0)
                                }
                            )
                        }
                    }
                }
            }
        }
        
        listView.collectionView.layoutIfNeeded()
        
        return listView
    }
}


class FlowListLayout_CGFloatTests : XCTestCase {
    
    func test_sliceIntoSpacings_with_using() {
                
        let elements = [1, 2, 3, 4]
        
        struct Output : Equatable {
            var spacing : CGFloat.SliceSpacing
            var element : Int
        }
        
        var spacings = [Output]()
        
        CGFloat(10).sliceIntoSpacings(with: elements) { spacing, element in
            spacings.append(.init(spacing: spacing, element: element))
        }
        
        XCTAssertEqual(spacings, [
            .init(spacing: .value(3), element: 1),
            .init(spacing: .value(4), element: 2),
            .init(spacing: .value(3), element: 3),
            .init(spacing: .last, element: 4),
        ])
    }
    
    func test_sliceIntoSpacings() {
        let spacings = CGFloat(10).sliceIntoSpacings(for: 4)
        
        let total = spacings.reduce(0) { $0 + $1 }
        
        XCTAssertEqual(total, 10)
        
        XCTAssertEqual(spacings, [
            3,
            4,
            3
        ])
    }
}


fileprivate struct TestingHeaderFooterContent : HeaderFooterContent {
    
    var color : UIColor
    
    func apply(
        to views: HeaderFooterContentViews<Self>,
        for reason: ApplyReason,
        with info: ApplyHeaderFooterContentInfo
    ) {
        views.content.backgroundColor = self.color
    }
    
    func isEquivalent(to other: TestingHeaderFooterContent) -> Bool {
        false
    }
    
    typealias ContentView = UIView
    
    static func createReusableContentView(frame: CGRect) -> UIView {
        UIView(frame: frame)
    }
}


fileprivate struct TestingItemContent : ItemContent {
    
    var color : UIColor
    
    var identifierValue: String {
        ""
    }
    
    func apply(to views: ItemContentViews<Self>, for reason: ApplyReason, with info: ApplyItemContentInfo)
    {
        views.content.backgroundColor = self.color
    }
    
    func isEquivalent(to other: TestingItemContent) -> Bool {
        false
    }
    
    typealias ContentView = UIView
    
    static func createReusableContentView(frame: CGRect) -> UIView {
        UIView(frame: frame)
    }
}
