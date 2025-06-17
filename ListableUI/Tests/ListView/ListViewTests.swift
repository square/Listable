//
//  ListViewTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 11/27/19.
//

import XCTest

@_spi(ListableKeyboard) @testable import ListableUI



class ListViewTests: XCTestCase
{
    func test_no_retain_cycles()
    {
        // Verify that there's no retain cycles within the list,
        // by making a list, putting content in it, and then waiting
        // for the list to be deallocated by testing a weak pointer.

        weak var weakList : ListView? = nil

        autoreleasepool {
            var listView : ListView? = ListView(frame: CGRect(x: 0, y: 0, width: 200, height: 400))

            listView?.configure { list in

                list.header = TestSupplementary()
                list.footer = TestSupplementary()
                list.overscrollFooter = TestSupplementary()

                list("content") { section in
                    section.header = TestSupplementary()
                    section.footer = TestSupplementary()

                    section += TestContent(content: "1")
                    section += TestContent(content: "2")
                    section += TestContent(content: "3")
                }
            }

            self.waitForOneRunloop()

            weakList = listView

            listView = nil
        }

        self.waitFor {
            weakList == nil
        }
    }

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
            list.content.overscrollFooter = TestSupplementary()
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
            list.content.overscrollFooter = TestSupplementary()
        }

        listView.collectionView.contentOffset.y = 100
        self.waitForOneRunloop()
    }

    func test_calculateScrollViewInsets()
    {
        let listView = ListView(frame: CGRect(x: 0, y: 0, width: 200, height: 400))

        listView.scrollIndicatorInsets = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)

        self.testcase("Nil Keyboard Frame") {
            let insets = listView.calculateScrollViewInsets(with: nil)

            XCTAssertEqual(
                insets.content,
                UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            )

            XCTAssertEqual(
                insets.horizontalScroll,
                UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 40)
            )

            XCTAssertEqual(
                insets.verticalScroll,
                UIEdgeInsets(top: 10, left: 0, bottom: 30, right: 0)
            )

        }

        self.testcase("Non-Overlapping Keyboard Frame") {
            let insets = listView.calculateScrollViewInsets(with: .nonOverlapping)

            XCTAssertEqual(
                insets.content,
                UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            )

            XCTAssertEqual(
                insets.horizontalScroll,
                UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 40)
            )

            XCTAssertEqual(
                insets.verticalScroll,
                UIEdgeInsets(top: 10, left: 0, bottom: 30, right: 0)
            )
        }

        self.testcase("Overlapping Keyboard Frame") {
            let insets = listView.calculateScrollViewInsets(
                with:.overlapping(frame: CGRect(x: 0, y: 200, width: 200, height: 200))
            )

            XCTAssertEqual(
                insets.content,
                UIEdgeInsets(top: 0, left: 0, bottom: 200, right: 0)
            )

            XCTAssertEqual(
                insets.horizontalScroll,
                UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 40)
            )

            XCTAssertEqual(
                insets.verticalScroll,
                UIEdgeInsets(top: 10, left: 0, bottom: 200, right: 0)
            )
        }
    }

    func test_change_size() {

        /// Ensure we respect the size of the view changing via both bounds and frame.
        /// Frame is usually used via manual layout or Blueprint, whereas bounds is
        /// set by autolayout if a developer is using autolayout.

        self.testcase("set bounds") {
            let view = ListView()
            view.bounds.size = CGSize(width: 200, height: 200)

            XCTAssertEqual(view.collectionView.bounds.size, CGSize(width: 200, height: 200))
        }

        self.testcase("set frame") {
            let view = ListView()
            view.frame.size = CGSize(width: 200, height: 200)

            XCTAssertEqual(view.collectionView.bounds.size, CGSize(width: 200, height: 200))
        }
    }

    func test_changing_to_empty_frame_does_not_crash() {

        let view = ListView()
        view.frame.size = CGSize(width: 200, height: 400)

        view.configure { list in

            for section in 1...5 {

                list(section) { section in
                    section.header = HeaderFooter(
                        TestSupplementary(),
                        sizing: .fixed(height: 50)
                    )

                    for row in 1...10 {
                        section += Item(
                            TestContent(content: row),
                            sizing: .fixed(height: 50)
                        )
                    }
                }
            }
        }

        /// Force the cells in the collection view to be updated.
        view.collectionView.layoutIfNeeded()

        /// Changing the view width to an empty size removes content
        /// from the inner collection view, because laying out content
        /// with zero area is meaningless.
        ///
        /// This test is here because this change would previously crash at this line,
        /// because the collection view layout's `visibleLayoutAttributesForElements`
        /// had not yet updated, leaving us with invalid index paths.
        view.frame.size.width = 0.0

        view.collectionView.layoutIfNeeded()

        view.frame.size.width = 200

        view.collectionView.layoutIfNeeded()
    }

    func test_reappliesToVisibleView() {

        self.testcase("always") {
            let view = ListView()
            view.frame.size = CGSize(width: 200, height: 400)

            var reappliedIDs = [AnyHashable]()

            view.configure { list in
                list("section") { section in
                    section.header = HeaderFooter(
                        ReapplySupplementary1(title: "title", reappliesToVisibleView: .always) {
                            reappliedIDs.append("header1")
                        },
                        sizing: .fixed(height: 50)
                    )

                    section.footer = HeaderFooter(
                        ReapplySupplementary1(title: "footer", reappliesToVisibleView: .always) {
                            reappliedIDs.append("footer1")
                        },
                        sizing: .fixed(height: 50)
                    )

                    section += Item(
                        ReapplyContent(title: "row", id: 1, reappliesToVisibleView: .always) {
                            reappliedIDs.append(1)
                        },
                        sizing: .fixed(height: 50)
                    )

                    section += Item(
                        ReapplyContent(title: "row", id: 2, reappliesToVisibleView: .always)  {
                            reappliedIDs.append(2)
                        },
                        sizing: .fixed(height: 50)
                    )
                }
            }

            /// Force the cells in the collection view to be updated.
            view.collectionView.layoutIfNeeded()

            XCTAssertEqual(reappliedIDs, [
                1,
                2,
                "header1",
                "footer1",
            ])

            reappliedIDs.removeAll()

            view.configure { list in
                list("section") { section in
                    section.header = HeaderFooter(
                        ReapplySupplementary1(title: "title", reappliesToVisibleView: .always) {
                            reappliedIDs.append("header1")
                        },
                        sizing: .fixed(height: 50)
                    )

                    section.footer = HeaderFooter(
                        ReapplySupplementary1(title: "footer", reappliesToVisibleView: .always) {
                            reappliedIDs.append("footer1")
                        },
                        sizing: .fixed(height: 50)
                    )

                    section += Item(
                        ReapplyContent(title: "row", id: 1, reappliesToVisibleView: .always) {
                            reappliedIDs.append(1)
                        },
                        sizing: .fixed(height: 50)
                    )

                    section += Item(
                        ReapplyContent(title: "row", id: 2, reappliesToVisibleView: .always)  {
                            reappliedIDs.append(2)
                        },
                        sizing: .fixed(height: 50)
                    )
                }
            }

            /// Force the cells in the collection view to be updated.
            view.collectionView.layoutIfNeeded()

            XCTAssertEqual(reappliedIDs, [
                "header1",
                "footer1",
                1,
                2
            ])
        }

        self.testcase("ifNotEquivalent") {
            let view = ListView()
            view.frame.size = CGSize(width: 200, height: 400)

            var reappliedIDs = [AnyHashable]()

            view.configure { list in
                list("section") { section in
                    section.header = HeaderFooter(
                        ReapplySupplementary1(title: "title", reappliesToVisibleView: .ifNotEquivalent) {
                            reappliedIDs.append("header1")
                        },
                        sizing: .fixed(height: 50)
                    )

                    section.footer = HeaderFooter(
                        ReapplySupplementary1(title: "footer", reappliesToVisibleView: .ifNotEquivalent) {
                            reappliedIDs.append("footer1")
                        },
                        sizing: .fixed(height: 50)
                    )

                    section += Item(
                        ReapplyContent(title: "row", id: 1, reappliesToVisibleView: .ifNotEquivalent) {
                            reappliedIDs.append(1)
                        },
                        sizing: .fixed(height: 50)
                    )

                    section += Item(
                        ReapplyContent(title: "row", id: 2, reappliesToVisibleView: .ifNotEquivalent)  {
                            reappliedIDs.append(2)
                        },
                        sizing: .fixed(height: 50)
                    )
                }
            }

            /// Force the cells in the collection view to be updated.
            view.collectionView.layoutIfNeeded()

            XCTAssertEqual(reappliedIDs, [
                1,
                2,
                "header1",
                "footer1",
            ])

            reappliedIDs.removeAll()

            view.configure { list in
                list("section") { section in
                    section.header = HeaderFooter(
                        ReapplySupplementary1(title: "title", reappliesToVisibleView: .ifNotEquivalent) {
                            reappliedIDs.append("header1")
                        },
                        sizing: .fixed(height: 50)
                    )

                    section.footer = HeaderFooter(
                        ReapplySupplementary1(title: "changed footer", reappliesToVisibleView: .ifNotEquivalent) {
                            reappliedIDs.append("footer1")
                        },
                        sizing: .fixed(height: 50)
                    )

                    section += Item(
                        ReapplyContent(title: "row", id: 1, reappliesToVisibleView: .ifNotEquivalent) {
                            reappliedIDs.append(1)
                        },
                        sizing: .fixed(height: 50)
                    )

                    section += Item(
                        ReapplyContent(title: "changed row", id: 2, reappliesToVisibleView: .ifNotEquivalent)  {
                            reappliedIDs.append(2)
                        },
                        sizing: .fixed(height: 50)
                    )
                }
            }

            /// Force the cells in the collection view to be updated.
            view.collectionView.layoutIfNeeded()

            XCTAssertEqual(reappliedIDs, [
                "footer1",
                2
            ])

            /// Ensure we can also safely swap out the header and footer kinds.

            reappliedIDs.removeAll()

            view.configure { list in
                list("section") { section in
                    section.header = HeaderFooter(
                        ReapplySupplementary2(title: "title", reappliesToVisibleView: .ifNotEquivalent) {
                            reappliedIDs.append("header2")
                        },
                        sizing: .fixed(height: 50)
                    )

                    section.footer = HeaderFooter(
                        ReapplySupplementary2(title: "footer", reappliesToVisibleView: .ifNotEquivalent) {
                            reappliedIDs.append("footer2")
                        },
                        sizing: .fixed(height: 50)
                    )
                }
            }

            /// Force the cells in the collection view to be updated.
            view.collectionView.layoutIfNeeded()

            XCTAssertEqual(reappliedIDs, [
                "header2",
                "footer2",
            ])

            /// ... Or just remove all the content.

            reappliedIDs.removeAll()

            view.configure { list in
                /// Intentionally empty.
            }

            /// Force the cells in the collection view to be updated.
            view.collectionView.layoutIfNeeded()

            XCTAssertEqual(reappliedIDs, [])
        }
    }

    func test_content_context() {

        let view = ListView()
        view.frame.size = CGSize(width: 200, height: 400)

        func configure(list : inout ListProperties) {
            list.header = HeaderFooter(
                ReapplySupplementary1(title: "title", reappliesToVisibleView: .ifNotEquivalent) {},
                sizing: .fixed(height: 50)
            )

            list.footer = HeaderFooter(
                ReapplySupplementary1(title: "title", reappliesToVisibleView: .ifNotEquivalent) {},
                sizing: .fixed(height: 50)
            )

            list("section") { section in
                section.header = HeaderFooter(
                    ReapplySupplementary1(title: "title", reappliesToVisibleView: .ifNotEquivalent) {},
                    sizing: .fixed(height: 50)
                )

                section.footer = HeaderFooter(
                    ReapplySupplementary1(title: "changed footer", reappliesToVisibleView: .ifNotEquivalent) {},
                    sizing: .fixed(height: 50)
                )

                section += Item(
                    ReapplyContent(title: "row", id: 1, reappliesToVisibleView: .ifNotEquivalent) {},
                    sizing: .fixed(height: 50)
                )
            }
        }

        view.configure { list in

            list.context = ContentContext(false)

            configure(list: &list)
        }

        /// Force the cells in the collection view to be updated.
        view.collectionView.layoutIfNeeded()

        var didResetSizesCount = 0

        view.storage.presentationState.onResetCachedSizes = {
            didResetSizesCount += 1
        }

        // Do it twice, should only be called once since the value is the same.

        for _ in 1...2 {
            view.configure { list in

                list.context = ContentContext(true)

                configure(list: &list)
            }
        }

        /// Force the cells in the collection view to be updated.
        view.collectionView.layoutIfNeeded()

        XCTAssertEqual(didResetSizesCount, 1)
    }

    /// An "integration" test that removes content from the list to verify we can round trip updates properly.
    func test_delete_all_content() {

        let base = Content { content in

            for sectionID in 1...50 {
                content += Section(sectionID) {
                    for itemID in 1...20 {
                        TestContent(content: itemID)
                    }
                }
            }
        }

        let vc = ViewController()

        show(vc: vc) { vc in
            var content = base

            self.waitFor(timeout: 100) {

                vc.list.configure { list in
                    list.content = content

                    list.layout = .table {
                        $0.layout.itemSpacing = 10
                    }
                }

                if var section = content.sections.popLast() {
                    section.items.removeLast()

                    if section.items.isEmpty == false {
                        content.add(section)
                    }
                }

                vc.list.collectionView.layoutIfNeeded()

                return content.sections.isEmpty
            }
        }
    }
    
    func test_updatePresentationState_respects_index_path_from_programaticScrollDownTo() {
                
        let content = Content { content in

            for sectionID in 1...50 {
                content += Section(sectionID) {
                    for itemID in 1...20 {
                        TestContent(content: itemID)
                    }
                }
            }
        }

        let vc = ViewController()

        show(vc: vc) { vc in
            self.waitFor {

                vc.list.configure { list in
                    list.content = content
                }
                
                /// The bug occurs when we try to scroll down, and then quickly try to deliver another
                /// update while the scroll event is in progress/enqueued, so the visible index paths
                /// haven't updated yet.
                
                vc.list.scrollToSection(
                    with: Section.identifier(with: 45),
                    scrollPosition: .init(position: .bottom),
                    animated: true
                )
                
                /// Ok, now push through another update.
                
                vc.list.configure { list in
                    list.content = content
                }

                /// Don't return until the list queue is empty.
                return vc.list.updateQueue.isEmpty
            }
        }
        
    }
    
    func test_auto_scroll_action() {
        
        self.testcase("on insert") {
            var didPerform : [ListScrollPositionInfo] = []
            
            var content = ListProperties.default { list in
                list.animatesChanges = false
                list.sections = (1...50).map { sectionID in
                    Section(sectionID) {
                        for itemNumber in 1...20 {
                            TestContent(content: "Section \(sectionID); Item \(itemNumber)")
                        }
                    }
                }
                
                let ID = TestContent.identifier(with: "A")
                list.autoScrollAction = .scrollTo(
                    .item(ID),
                    onInsertOf: ID,
                    position: .init(position: .centered),
                    animated: true,
                    shouldPerform: { _ in true },
                    didPerform: { didPerform.append($0) }
                )
            }

            let vc = ViewController()
            vc.listFramingBehavior = .exactly(CGSize(width: 400, height: 600))

            show(vc: vc) { vc in
                vc.list.configure(with: content)
                waitFor { vc.list.updateQueue.isEmpty }
                XCTAssertEqual(didPerform.count, 0)
                
                vc.list.configure(with: content)
                waitFor { vc.list.updateQueue.isEmpty }
                XCTAssertEqual(didPerform.count, 0)
                
                // Insert a new item & section at the very bottom.
                content.content += Section("new") {
                    TestContent(content: "A")
                }
                vc.list.configure(with: content)
                waitFor { vc.list.updateQueue.isEmpty }
                XCTAssertEqual(didPerform.count, 1)
                
                guard let visibleItems = didPerform.first?.visibleItems else {
                    XCTFail("There should be visible items after scrolling.")
                    return
                }
                
                // The bottom 12 items should be visible because the list has a height
                // of 600pts and each item has a height of 50pts.
                XCTAssertEqual(visibleItems.count, 12)
                // The last 11 items in section 50 are visible.
                for itemNumber in 10...20 {
                    XCTAssert(
                        visibleItems.contains(
                            ListScrollPositionInfo.VisibleItem(
                                identifier: Identifier<TestContent, String>("Section 50; Item \(itemNumber)"),
                                percentageVisible: 1.0
                            )
                        )
                    )
                }
                // The newly-added item in the last section is also visible.
                XCTAssert(
                    visibleItems.contains(
                        ListScrollPositionInfo.VisibleItem(
                            identifier: Identifier<TestContent, String>("A"),
                            percentageVisible: 1.0
                        )
                    )
                )
            }
        }
        
        self.testcase("on insert with bottom gravity") {
            var didPerform : [ListScrollPositionInfo] = []
            
            var content = ListProperties.default { list in
                list.animatesChanges = false
                list.behavior.verticalLayoutGravity = .bottom
                list.sections = (1...50).map { sectionID in
                    Section(sectionID) {
                        for itemNumber in 1...20 {
                            TestContent(content: "Section \(sectionID); Item \(itemNumber)")
                        }
                    }
                }
                
                let ID = TestContent.identifier(with: "A")
                list.autoScrollAction = .scrollTo(
                    .item(ID),
                    onInsertOf: ID,
                    position: .init(position: .centered), // Vertically center the item.
                    animated: true,
                    shouldPerform: { _ in true },
                    didPerform: { didPerform.append($0) }
                )
            }

            let vc = ViewController()
            vc.listFramingBehavior = .exactly(CGSize(width: 400, height: 600))

            show(vc: vc) { vc in
                vc.list.configure(with: content)
                waitFor { vc.list.updateQueue.isEmpty }
                XCTAssertEqual(didPerform.count, 0)
                
                vc.list.configure(with: content)
                waitFor { vc.list.updateQueue.isEmpty }
                XCTAssertEqual(didPerform.count, 0)
                
                // Insert a new item to the middle of the list's content.
                content.content.sections[25].items.insert(
                    TestContent(content: "A").toAnyItem(),
                    at: 10
                )
                
                vc.list.configure(with: content)
                waitFor { vc.list.updateQueue.isEmpty }
                XCTAssertEqual(didPerform.count, 1)
                
                guard let visibleItems = didPerform.first?.visibleItems else {
                    XCTFail("There should be visible items after scrolling.")
                    return
                }
                
                // The new item was inserted between items 10 and 11. After performing the
                // centered autoScrollAction, the viewport will display these items:
                //
                // [Item  5] The top 25pts of this item are out of view.
                // [Item  6]
                // ...
                // [Item 10]
                // [Item  A] Vertically centered within the viewport.
                // [Item 11]
                // ...
                // [Item 15]
                // [Item 16] The bottom 25pts of this item are out of view.
                XCTAssertEqual(visibleItems.count, 13)
                for itemNumber in 5...16 {
                    XCTAssert(
                        visibleItems.contains(
                            ListScrollPositionInfo.VisibleItem(
                                identifier: Identifier<TestContent, String>("Section 26; Item \(itemNumber)"),
                                percentageVisible: (itemNumber == 5 || itemNumber == 16) ? 0.5 : 1.0
                            )
                        )
                    )
                }
                XCTAssert(
                    visibleItems.contains(
                        ListScrollPositionInfo.VisibleItem(
                            identifier: Identifier<TestContent, String>("A"),
                            percentageVisible: 1.0
                        )
                    )
                )
            }
        }
        
        self.testcase("pin") {
            var didPerform : [ListScrollPositionInfo] = []
            
            var content = ListProperties.default { list in
                list.sections = (1...50).map { sectionID in
                    Section(sectionID) {
                        for itemNumber in 1...20 {
                            TestContent(content: "Section \(sectionID); Item \(itemNumber)")
                        }
                    }
                }
                
                let ID = TestContent.identifier(with: "A")
                list.autoScrollAction = .pin(
                    .item(ID),
                    position: .init(position: .bottom),
                    animated: true,
                    shouldPerform: { _ in true },
                    didPerform: { didPerform.append($0) }
                )
            }

            let vc = ViewController()
            vc.listFramingBehavior = .exactly(CGSize(width: 400, height: 1000))

            show(vc: vc) { vc in
                vc.list.configure(with: content)
                waitFor { vc.list.updateQueue.isEmpty }
                XCTAssertEqual(didPerform.count, 0)
                
                vc.list.configure(with: content)
                waitFor { vc.list.updateQueue.isEmpty }
                XCTAssertEqual(didPerform.count, 0)
                
                // Insert a new item & section at the very bottom.
                content.content += Section("new") {
                    TestContent(content: "A")
                }
                vc.list.configure(with: content)
                waitFor { vc.list.updateQueue.isEmpty }
                XCTAssertEqual(didPerform.count, 1)
                
                guard let visibleItems = didPerform.first?.visibleItems else {
                    XCTFail("There should be visible items after scrolling.")
                    return
                }
                
                // The bottom 20 items should be visible because the list has a height
                // of 1000pts and each item has a height of 50pts.
                XCTAssertEqual(visibleItems.count, 20)
                // The last 19 items in section 50 are visible.
                for itemNumber in 2...20 {
                    XCTAssert(
                        visibleItems.contains(
                            ListScrollPositionInfo.VisibleItem(
                                identifier: Identifier<TestContent, String>("Section 50; Item \(itemNumber)"),
                                percentageVisible: 1.0
                            )
                        )
                    )
                }
                // The newly-added item in the last section is also visible.
                XCTAssert(
                    visibleItems.contains(
                        ListScrollPositionInfo.VisibleItem(
                            identifier: Identifier<TestContent, String>("A"),
                            percentageVisible: 1.0
                        )
                    )
                )
            }
        }
    }
    
    func test_scroll_to_item_completion() throws {
        
        for animated in [true, false] {
            for visibilityRule in [ScrollPosition.IfAlreadyVisible.scrollToPosition, .doNothing] {
                
                try testControllerCase("scroll to offscreen item") { viewController in
                    let positionInfo = scrollTo(
                        item: TestContent.Identifier("Item 75"),
                        position: .centered,
                        using: viewController
                    )
                    let visibleItems = try XCTUnwrap(positionInfo?.visibleItems)
                    
                    // The viewport is 600pts in height. Each item is 50pts in height. Since we've
                    // centered an item, the top and bottom visible items should be halfway offscreen.
                    XCTAssertEqual(visibleItems.count, 13)
                    for itemNumber in 70...80 {
                        XCTAssert(
                            visibleItems.contains(
                                ListScrollPositionInfo.VisibleItem(
                                    identifier: Identifier<TestContent, String>("Item \(itemNumber)"),
                                    percentageVisible: 1.0
                                )
                            )
                        )
                    }
                    XCTAssert(
                        visibleItems.contains(
                            ListScrollPositionInfo.VisibleItem(
                                identifier: Identifier<TestContent, String>("Item 69"),
                                percentageVisible: 0.5 // Halfway off the top of the viewport.
                            )
                        )
                    )
                    XCTAssert(
                        visibleItems.contains(
                            ListScrollPositionInfo.VisibleItem(
                                identifier: Identifier<TestContent, String>("Item 81"),
                                percentageVisible: 0.5 // Halfway off the bottom of the viewport.
                            )
                        )
                    )
                }
                
                try testControllerCase("scroll to an already-positioned item") { viewController in
                    let positionInfo = scrollTo(
                        item: TestContent.Identifier("Item 1"),
                        position: .top,
                        using: viewController
                    )
                    let visibleItems = try XCTUnwrap(positionInfo?.visibleItems)
                    // The viewport is 600pts in height. Each item is 50pts in height. Since item 1 is at
                    // the top, we'll fit the first 12 items in the viewport.
                    XCTAssertEqual(visibleItems.count, 12)
                    for itemNumber in 1...12 {
                        XCTAssert(
                            visibleItems.contains(
                                ListScrollPositionInfo.VisibleItem(
                                    identifier: Identifier<TestContent, String>("Item \(itemNumber)"),
                                    percentageVisible: 1.0
                                )
                            )
                        )
                    }
                }
                
                try testControllerCase("scroll to unpositioned item") { viewController in
                    /// The collection view will need to scroll a few rows down so that item 3
                    /// is at the top of the list.
                    let positionInfo = scrollTo(
                        item: TestContent.Identifier("Item 3"),
                        position: .top,
                        using: viewController
                    )
                    let visibleItems = try XCTUnwrap(positionInfo?.visibleItems)
                    XCTAssertEqual(visibleItems.count, 12)
                    
                    let expectedItems: ClosedRange<Int>
                    if visibilityRule == .doNothing {
                        // If the list does not scroll when the item is already visible, then the visible
                        // items should reflect the intiail state since 3 is initially visible.
                        expectedItems = 1...12
                    } else {
                        // Otherwise, we do scroll even when visible and item 3 is scrolled to the top.
                        expectedItems = 3...14
                    }
                    
                    for itemNumber in expectedItems {
                        XCTAssert(
                            visibleItems.contains(
                                ListScrollPositionInfo.VisibleItem(
                                    identifier: Identifier<TestContent, String>("Item \(itemNumber)"),
                                    percentageVisible: 1.0
                                )
                            ),
                            "Item \(itemNumber)"
                        )
                    }
                }
                
                try testControllerCase("scroll to unpositioned item") { viewController in
                    /// The collection view will not need to scroll since it can't move the
                    /// viewport any higher.
                    let positionInfo = scrollTo(
                        item: TestContent.Identifier("Item 2"),
                        position: .centered,
                        using: viewController
                    )
                    let visibleItems = try XCTUnwrap(positionInfo?.visibleItems)
                    XCTAssertEqual(visibleItems.count, 12)
                    for itemNumber in 1...12 {
                        XCTAssert(
                            visibleItems.contains(
                                ListScrollPositionInfo.VisibleItem(
                                    identifier: Identifier<TestContent, String>("Item \(itemNumber)"),
                                    percentageVisible: 1.0
                                )
                            )
                        )
                    }
                }
                
                try testControllerCase("scroll to unpositioned item") { viewController in
                    // Scroll to the very bottom.
                    scrollTo(
                        item: TestContent.Identifier("Item 99"),
                        position: .centered,
                        using: viewController
                    )
                    // Attempt to scroll an item near the bottom to the top of the list.
                    let positionInfo = scrollTo(
                        item: TestContent.Identifier("Item 98"),
                        position: .top,
                        using: viewController
                    )
                    let visibleItems = try XCTUnwrap(positionInfo?.visibleItems)
                    // The bottom-most items remain visible.
                    XCTAssertEqual(visibleItems.count, 12)
                    for itemNumber in 89...100 {
                        XCTAssert(
                            visibleItems.contains(
                                ListScrollPositionInfo.VisibleItem(
                                    identifier: Identifier<TestContent, String>("Item \(itemNumber)"),
                                    percentageVisible: 1.0
                                )
                            )
                        )
                    }
                }
                
                // ListView has special logic to account for a sticky section header when scrolling an
                // item to the top position. In this case, scrolling uses a different internal API to
                // ensure the scrolled item rests directly below the sticky header and isn't covered.
                try testControllerCase("scroll to item with section header", sectionHeader: true) { viewController in
                    let positionInfo = scrollTo(
                        item: TestContent.Identifier("Item 75"),
                        position: .top,
                        using: viewController
                    )
                    let visibleItems = try XCTUnwrap(positionInfo?.visibleItems)
                    
                    // The viewport is 600pts in height and each item is 50pts in height, so there will
                    // be space for 12 items from the top. There's also a 50pt header which rests on top
                    // of the content, so item 75 will be directly below the header, with item 74 also
                    // inside the viewport.
                    XCTAssertEqual(visibleItems.count, 12)
                    for itemNumber in 74...85 {
                        XCTAssert(
                            visibleItems.contains(
                                ListScrollPositionInfo.VisibleItem(
                                    identifier: Identifier<TestContent, String>("Item \(itemNumber)"),
                                    percentageVisible: 1.0
                                )
                            )
                        )
                    }
                }
                
                /// A helper function to perform the scrolling and await the result, using the
                /// global animation flag and `IfAlreadyVisible` rule.
                @discardableResult
                func scrollTo(item: TestContent.Identifier, position: ScrollPosition.Position, using viewController: ViewController) -> ListScrollPositionInfo? {
                    var positionInfo: ListScrollPositionInfo?
                    let scrollExpectation = expectation(description: "Scroll completed")
                    viewController.list.scrollTo(
                        item: item,
                        position: ScrollPosition(
                            position: position,
                            ifAlreadyVisible: visibilityRule
                        ),
                        animated: animated,
                        completion: {
                            positionInfo = $0
                            scrollExpectation.fulfill()
                        }
                    )
                    wait(for: [scrollExpectation], timeout: 0.5)
                    return positionInfo
                }
            }
        }
    }
    
    /// A helper function for a test case that creates and presents a `ViewController`
    /// with a list of 100 rows. You can use the controller in the `completion` closure.
    /// - Parameters:
    ///   - name: The name of the test case.
    ///   - sectionHeader: When true, a 50pt section header will be drawn.
    ///   - completion: The closure executed when the view controller is shown.
    fileprivate func testControllerCase(_ name : String = "", sectionHeader: Bool = false, completion: (ViewController) throws -> Void) rethrows {
        try testcase(name) {
            let viewController = ViewController()
            viewController.listFramingBehavior = .exactly(CGSize(width: 400, height: 600))
            try show(vc: viewController) { viewController in
                viewController.list.configure { list in
                    list.layout = .table { layout in
                        layout.contentInsetAdjustmentBehavior = .never
                    }
                    list.animatesChanges = false
                    list("content") { section in
                        if sectionHeader {
                            section.header = HeaderFooter(
                                TestSupplementary(),
                                sizing: .fixed(height: 50)
                            )
                        }
                        for itemNumber in 1...100 {
                            section += TestContent(content: "Item \(itemNumber)")
                        }
                    }
                }
                try completion(viewController)
            }
        }
    }
}

fileprivate final class ViewController : UIViewController {

    let list : ListView = ListView()
    
    /// Configure this before loading the controller's view.
    var listFramingBehavior: ListFramingBehavior = .hostSize
    
    enum ListFramingBehavior {
        
        /// The list will be the size of this view controller. This matches the
        /// host app's root view controller bounds.
        case hostSize
        
        /// The list will be position at 0,0 with the provided size. This allows
        /// for replicating an expected list size across any test device.
        case exactly(CGSize)
    }

    override func loadView() {
        switch listFramingBehavior {
        case .hostSize:
            view = list
        case .exactly(let size):
            view = UIView()
            view.addSubview(list)
            list.frame = CGRect(origin: .zero, size: size)
        }
    }
}

fileprivate struct TestContent : ItemContent, Equatable
{
    var content : AnyHashable

    var identifierValue: AnyHashable {
        self.content
    }

    func apply(
        to views: ItemContentViews<Self>,
        for reason: ApplyReason,
        with info: ApplyItemContentInfo
    ) {
        views.content.backgroundColor = .red
    }

    typealias ContentView = UIView

    static func createReusableContentView(frame: CGRect) -> UIView
    {
        return UIView(frame: frame)
    }

    var defaultItemProperties: DefaultProperties {
        .defaults { defaults in
            defaults.sizing = .fixed(height: 50)
        }
    }
}


fileprivate struct TestSupplementary : HeaderFooterContent, Equatable
{
    func apply(
        to views: HeaderFooterContentViews<Self>,
        for reason: ApplyReason,
        with info: ApplyHeaderFooterContentInfo
    ) {
        views.content.backgroundColor = .blue
    }

    typealias ContentView = UIView

    static func createReusableContentView(frame: CGRect) -> UIView
    {
        return UIView(frame: frame)
    }
}


fileprivate struct ReapplyContent : ItemContent
{
    var title : String
    var id : AnyHashable

    func isEquivalent(to other: ReapplyContent) -> Bool {
        self.title == other.title
    }

    var identifierValue: AnyHashable {
        self.id
    }

    func apply(
        to views: ItemContentViews<Self>,
        for reason: ApplyReason,
        with info: ApplyItemContentInfo
    ) {
        if reason != .measurement {
            self.onApply()
        }
    }

    typealias ContentView = UIView

    static func createReusableContentView(frame: CGRect) -> UIView
    {
        return UIView(frame: frame)
    }

    var reappliesToVisibleView: ReappliesToVisibleView

    var onApply : () -> ()
}


fileprivate struct ReapplySupplementary1 : HeaderFooterContent
{
    var title : String

    func isEquivalent(to other: Self) -> Bool {
        self.title == other.title
    }

    func apply(
        to views: HeaderFooterContentViews<Self>,
        for reason: ApplyReason,
        with info: ApplyHeaderFooterContentInfo
    ) {
        if reason != .measurement {
            self.onApply()
        }
    }

    typealias ContentView = UIView

    static func createReusableContentView(frame: CGRect) -> UIView
    {
        return UIView(frame: frame)
    }

    var reappliesToVisibleView: ReappliesToVisibleView

    var onApply : () -> ()
}


fileprivate struct ReapplySupplementary2 : HeaderFooterContent
{
    var title : String

    func isEquivalent(to other: Self) -> Bool {
        self.title == other.title
    }

    func apply(
        to views: HeaderFooterContentViews<Self>,
        for reason: ApplyReason,
        with info: ApplyHeaderFooterContentInfo
    ) {
        if reason != .measurement {
            self.onApply()
        }
    }

    typealias ContentView = UIView

    static func createReusableContentView(frame: CGRect) -> UIView
    {
        return UIView(frame: frame)
    }

    var reappliesToVisibleView: ReappliesToVisibleView

    var onApply : () -> ()
}
