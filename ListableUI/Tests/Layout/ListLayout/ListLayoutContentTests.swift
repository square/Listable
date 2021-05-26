//
//  ListLayoutContentTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 7/15/20.
//

import UIKit
import XCTest
@testable import ListableUI


class ListLayoutContentTests : XCTestCase
{
    func test_all()
    {
        let header = ListLayoutContent.SupplementaryItemInfo(
            state: PresentationState.HeaderFooterState(HeaderFooter(TestHeaderFooter())),
            kind: .listHeader,
            isPopulated: true,
            measurer: { _ in .zero }
        )
        
        let footer = ListLayoutContent.SupplementaryItemInfo(
            state: PresentationState.HeaderFooterState(HeaderFooter(TestHeaderFooter())),
            kind: .listFooter,
            isPopulated: true,
            measurer: { _ in .zero }
        )
        
        let overscroll = ListLayoutContent.SupplementaryItemInfo(
            state: PresentationState.HeaderFooterState(HeaderFooter(TestHeaderFooter())),
            kind: .overscrollFooter,
            isPopulated: true,
            measurer: { _ in .zero }
        )
        
        let items : [ListLayoutContent.ItemInfo] = (0...1).map { index in
            .init(
                state: PresentationState.ItemState(Item(TestItem())),
                indexPath: IndexPath(item: index, section: 0),
                insertAndRemoveAnimations: .fade,
                measurer: { _ in .zero }
            )
        }
                
        let section = ListLayoutContent.SectionInfo(
            state: PresentationState.SectionState(Section("1", items: items.map(\.state.anyModel))),
            header: nil,
            footer: nil,
            items: items
        )
        
        let content1 = ListLayoutContent(
            header: nil,
            footer: nil,
            overscrollFooter: nil,
            sections: [section]
        )
        
        // Shouldn't include header or footer if they are empty.
        
        AssertListLayoutContentItemEqual(content1.all, section.all)
        
        let content2 = ListLayoutContent(
            header: header,
            footer: footer,
            overscrollFooter: overscroll,
            sections: [section]
        )
        
        // Should include header and footer if they are populated.
        
        // Note that overscroll is explicitly not included, because it is a somewhat "special" case that
        // lives outside of the normal content bounds of the list.

        AssertListLayoutContentItemEqual(content2.all, [header] + section.all + [footer])
    }
    
    func test_setSectionContentsFrames()
    {
        /// This method only calls through to the section version, which is tested by `test_setContentsFrame` below.
    }
    
    func test_move() {
        
        let presentationState = PresentationState { content in
            
            content += Section("1") { section in
                section += TestItem()
                section += TestItem()
                section += TestItem()
            }
            
            content += Section("2") { section in
                section += TestItem()
                section += TestItem()
                section += TestItem()
            }
        }
                
        self.testcase("no-op") {
            let content = presentationState.toListLayoutContent()
            
            // Moving to the same index path should be a no-op.
            
            content.move(
                from: [IndexPath(item: 2, section: 0)],
                to: [IndexPath(item: 2, section: 0)]
            )
            
            XCTAssertEqual(content.sections[0].items.count, 3)
            XCTAssertEqual(content.sections[1].items.count, 3)
        }
        
        self.testcase("moving single") {
            let content = presentationState.toListLayoutContent()

            // Moving should re-index the index paths as well.
            
            content.move(
                from: [IndexPath(item: 2, section: 0)],
                to: [IndexPath(item: 3, section: 1)]
            )
            
            XCTAssertEqual(content.sections[0].items.count, 2)
            XCTAssertEqual(content.sections[1].items.count, 4)
            
            XCTAssertEqual(content.sections[1].items[3].indexPath, IndexPath(item: 3, section: 1))
            
            // Note that the underlying presentation state should NOT be updated in this case.
            // That is because the move has not yet been committed; only the view layer is updated.
            
            XCTAssertEqual(content.sections[0].state.items.count, 3)
            XCTAssertEqual(content.sections[1].state.items.count, 3)
        }
        
        self.testcase("moving multiple") {
            let content = presentationState.toListLayoutContent()

            // Ensure moving items uses the index paths in a stable way,
            // by applying removes + adds in the correct order (removals
            // last to first, additions first to last by index path).
            
            content.move(
                from: [
                    IndexPath(item: 0, section: 0),
                    IndexPath(item: 2, section: 0),
                ],
                to: [
                    IndexPath(item: 3, section: 1),
                    IndexPath(item: 1, section: 1)
                ]
            )
            
            XCTAssertEqual(content.sections[0].items.count, 1)
            XCTAssertTrue(presentationState.sections[0].items[1] === content.sections[0].items[0].state)
            
            XCTAssertEqual(content.sections[1].items.count, 5)
            XCTAssertTrue(presentationState.sections[1].items[0] === content.sections[1].items[0].state)
            XCTAssertTrue(presentationState.sections[0].items[2] === content.sections[1].items[1].state)
            XCTAssertTrue(presentationState.sections[1].items[1] === content.sections[1].items[2].state)
            
            XCTAssertTrue(presentationState.sections[0].items[0] === content.sections[1].items[3].state)
            XCTAssertTrue(presentationState.sections[1].items[2] === content.sections[1].items[4].state)
        }
    }
}


class ListLayoutContent_SectionInfo_Tests : XCTestCase
{
    func test_all()
    {
        let header = ListLayoutContent.SupplementaryItemInfo(
            state: PresentationState.HeaderFooterState(HeaderFooter(TestHeaderFooter())),
            kind: .sectionHeader,
            isPopulated: true,
            measurer: { _ in .zero }
        )
        
        let footer = ListLayoutContent.SupplementaryItemInfo(
            state: PresentationState.HeaderFooterState(HeaderFooter(TestHeaderFooter())),
            kind: .sectionHeader,
            isPopulated: true,
            measurer: { _ in .zero }
        )
        
        let items : [ListLayoutContent.ItemInfo] = (0...1).map { index in
            .init(
                state: PresentationState.ItemState(Item(TestItem())),
                indexPath: IndexPath(item: index, section: 0),
                insertAndRemoveAnimations: .fade,
                measurer: { _ in .zero }
            )
        }
        
        // Shouldn't include header or footer if they are empty.
        
        let section1 = ListLayoutContent.SectionInfo(
            state: PresentationState.SectionState(Section("1", items: items.map(\.state.anyModel))),
            header: nil,
            footer: nil,
            items: items
        )
        
        AssertListLayoutContentItemEqual(section1.all, items as [ListLayoutContentItem])
        
        // Should include header and footer if they are populated.
        
        let section2 = ListLayoutContent.SectionInfo(
            state: PresentationState.SectionState(Section("1", items: items.map(\.state.anyModel))),
            header: header,
            footer: footer,
            items: items
        )
        
        AssertListLayoutContentItemEqual(section2.all, [header] + items + [footer] as [ListLayoutContentItem])
    }
    
    func test_setContentsFrame()
    {
        let header = ListLayoutContent.SupplementaryItemInfo(
            state: PresentationState.HeaderFooterState(HeaderFooter(TestHeaderFooter())),
            kind: .sectionHeader,
            isPopulated: true,
            measurer: { _ in .zero }
        )
        
        let footer = ListLayoutContent.SupplementaryItemInfo(
            state: PresentationState.HeaderFooterState(HeaderFooter(TestHeaderFooter())),
            kind: .sectionHeader,
            isPopulated: true,
            measurer: { _ in .zero }
        )
        
        let items : [ListLayoutContent.ItemInfo] = (0...1).map { index in
            .init(
                state: PresentationState.ItemState(Item(TestItem())),
                indexPath: IndexPath(item: index, section: 0),
                insertAndRemoveAnimations: .fade,
                measurer: { _ in .zero }
            )
        }
                
        let section = ListLayoutContent.SectionInfo(
            state: PresentationState.SectionState(Section("1", items: items.map(\.state.anyModel))),
            header: header,
            footer: footer,
            items: items
        )
        
        header.size = CGSize(width: 80.0, height: 30.0)
        header.x = 10.0
        header.y = 10.0
        
        items[0].size = CGSize(width: 80.0, height: 30.0)
        items[0].x = 10.0
        items[0].y = 40.0
        
        items[1].size = CGSize(width: 80.0, height: 30.0)
        items[1].x = 10.0
        items[1].y = 70.0
        
        footer.size = CGSize(width: 80.0, height: 30.0)
        footer.x = 10.0
        footer.y = 100.0
        
        section.setContentsFrame()
        
        XCTAssertEqual(
            section.contentsFrame,
            CGRect(x: 10.0, y: 10.0, width: 80.0, height: 120.0)
        )
    }
}


class ListLayoutContent_SupplementaryItemInfo_Tests : XCTestCase
{
    
}


class ListLayoutContent_ItemInfo_Tests : XCTestCase
{
    
}

class ListLayoutContent_CGRect_Tests : XCTestCase
{
    func test_unioned()
    {
        // No rects
        
        XCTAssertEqual(CGRect.unioned(from: []), CGRect.zero)
        
        // Create our rects for testing.
        
        let rects : [CGRect] = [
            CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0),
            CGRect(x: 10.0, y: 10.0, width: 1.0, height: 1.0),
            CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0),
            CGRect(x: 20.0, y: 20.0, width: 90.0, height: 190.0),
            CGRect(x: 30.0, y: 30.0, width: 80.0, height: 180.0),
            CGRect(x: 50.0, y: 50.0, width: 20.0, height: 50.0),
        ]
        
        // Try in differing orders to ensure the same result is always produced.
        
        for _ in (0...100) {
            XCTAssertEqual(
                CGRect.unioned(from: rects.shuffled()),
                CGRect(x: 10.0, y: 10.0, width: 100.0, height: 200.0)
            )
        }
    }
}


fileprivate func AssertListLayoutContentItemEqual(
    _ lhs : [ListLayoutContentItem],
    _ rhs : [ListLayoutContentItem],
    file : StaticString = #file,
    line : UInt = #line
) {
    guard lhs.count == rhs.count else {
        XCTFail("Counts did not match.", file: (file), line: line)
        return
    }
    
    for (lhs, rhs) in zip(lhs, rhs) {
        XCTAssertTrue(lhs === rhs, "")
    }
}


fileprivate struct TestItem : ItemContent, Equatable {
    
    var identifier: String {
        ""
    }
    
    typealias ContentView = UIView
    
    static func createReusableContentView(frame: CGRect) -> UIView {
        UIView(frame: frame)
    }
    
    func apply(to views: ItemContentViews<TestItem>, for reason: ApplyReason, with info: ApplyItemContentInfo) {}
}


fileprivate struct TestHeaderFooter : HeaderFooterContent, Equatable {
    
    typealias ContentView = UIView
    
    static func createReusableContentView(frame: CGRect) -> UIView {
        UIView(frame: frame)
    }
    
    func apply(
        to views: HeaderFooterContentViews<Self>,
        for reason: ApplyReason,
        with info: ApplyHeaderFooterContentInfo
    ) {
        // Nothing.
    }
}
