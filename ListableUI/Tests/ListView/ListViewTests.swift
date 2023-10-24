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
    
    func test_auto_scroll_action() {
        
        self.testcase("on insert") {
            var didPerform : [ListScrollPositionInfo] = []
            
            var content = ListProperties.default { list in
                
                list.sections = (1...50).map { sectionID in
                    Section(sectionID) {
                        for itemID in 1...20 {
                            TestContent(content: itemID)
                        }
                    }
                }
                
                let ID = TestContent.identifier(with: "A")
                
                list.autoScrollAction = .scrollTo(
                    .item(ID),
                    onInsertOf: ID,
                    position: .init(position: .centered),
                    animation: .default,
                    shouldPerform: { _ in true },
                    didPerform: { didPerform.append($0) }
                )
            }

            let vc = ViewController()

            show(vc: vc) { vc in
                vc.list.configure(with: content)

                waitFor { vc.list.updateQueue.isEmpty }
                
                XCTAssertEqual(didPerform.count, 0)
                
                vc.list.configure(with: content)

                waitFor { vc.list.updateQueue.isEmpty }
                
                XCTAssertEqual(didPerform.count, 0)
                
                content.content += Section("new") {
                    TestContent(content: "A")
                }
                
                vc.list.configure(with: content)
                
                waitFor { vc.list.updateQueue.isEmpty }
                
                XCTAssertEqual(didPerform.count, 1)
            }
        }
        
        self.testcase("pin") {
            var didPerform : [ListScrollPositionInfo] = []
            
            var content = ListProperties.default { list in
                
                list.sections = (1...50).map { sectionID in
                    Section(sectionID) {
                        for itemID in 1...20 {
                            TestContent(content: itemID)
                        }
                    }
                }
                
                let ID = TestContent.identifier(with: "A")
                
                list.autoScrollAction = .pin(
                    .item(ID),
                    position: .init(position: .bottom),
                    animation: .default,
                    shouldPerform: { _ in true },
                    didPerform: { didPerform.append($0) }
                )
            }

            let vc = ViewController()

            show(vc: vc) { vc in
                vc.list.configure(with: content)

                waitFor { vc.list.updateQueue.isEmpty }
                
                XCTAssertEqual(didPerform.count, 0)
                
                vc.list.configure(with: content)

                waitFor { vc.list.updateQueue.isEmpty }
                
                XCTAssertEqual(didPerform.count, 0)
                
                content.content += Section("new") {
                    TestContent(content: "A")
                }
                
                vc.list.configure(with: content)
                
                waitFor { vc.list.updateQueue.isEmpty }
                
                XCTAssertEqual(didPerform.count, 1)
            }
        }
    }
}

fileprivate final class ViewController : UIViewController {

    let list : ListView = ListView()

    override func loadView() {
        self.view = list
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
