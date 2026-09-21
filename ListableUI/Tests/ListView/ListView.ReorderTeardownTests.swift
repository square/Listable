//
//  ListView.ReorderTeardownTests.swift
//  ListableUI-Unit-Tests
//

@testable import ListableUI
import XCTest


class ListView_ReorderTeardownTests: XCTestCase {

    /// A reorder that is still in flight when the list leaves the window — for example, the user
    /// navigates away while a drag is held — must be cancelled during teardown. This asserts the
    /// observable state: after leaving the window, the list reports no in-progress reorders.
    func test_reorder_is_cancelled_when_list_leaves_window() {

        let viewController = ReorderTestViewController()

        show(vc: viewController) { viewController in
            let listView = viewController.list

            // Force the collection view to build presentation state for the content.
            listView.collectionView.layoutIfNeeded()

            let indexPath = IndexPath(item: 0, section: 0)
            let item = listView.storage.presentationState.item(at: indexPath)

            item.beginReorder(from: indexPath, with: listView.environment)

            XCTAssertTrue(listView.hasInProgressReorders)
            XCTAssertTrue(item.isReordering)

            // Leaving the window is what navigating away mid-drag does to the list.
            listView.removeFromSuperview()

            XCTAssertFalse(
                listView.hasInProgressReorders,
                "Leaving the window should cancel any in-progress reorder."
            )
            XCTAssertFalse(item.isReordering)
        }
    }

    /// Reproduces the actual crash: a real `UICollectionView` interactive-movement session is
    /// started (the way a drag does), the list then leaves the window mid-drag, and its content
    /// is updated with index-affecting changes.
    ///
    /// Before the fix, the still-open interactive-movement session outlived the content it was
    /// started against, and applying the update resolved the move against now-stale index paths —
    /// an out-of-range access deep in `ListLayoutContent`. With the fix, leaving the window
    /// cancels the session first, so the update applies cleanly. Reaching the end of the test
    /// without crashing is the assertion (mirrors `test_changing_to_empty_frame_does_not_crash`).
    func test_reorder_interrupted_by_navigation_does_not_crash() {

        let viewController = ReorderTestViewController()

        show(vc: viewController) { viewController in
            let listView = viewController.list

            listView.collectionView.layoutIfNeeded()

            let indexPath = IndexPath(item: 0, section: 0)
            let item = listView.storage.presentationState.item(at: indexPath)

            // Start a real interactive-movement session through the same entry point a drag uses.
            _ = listView.beginReorder(for: item)

            // Navigate away mid-drag: the list leaves the window...
            listView.removeFromSuperview()

            // ...and its content is replaced with fewer items, an index-affecting change.
            listView.configure { list in
                list.animatesChanges = false
                list("section") { section in
                    for number in 1...3 {
                        section += Item(
                            ReorderTestContent(title: "Item \(number)"),
                            reordering: ItemReordering(sections: .all)
                        )
                    }
                }
            }

            listView.collectionView.layoutIfNeeded()
        }
    }

    /// A list deallocated with a reorder still in progress must not crash: teardown cancels the
    /// reorder while the data source and layout are still valid, and doing so introduces no
    /// retain cycle. The list becoming deallocated (via the weak pointer) is the assertion —
    /// deallocation is not synchronous, so we wait for it rather than asserting immediately.
    func test_reorder_in_progress_does_not_crash_on_deinit() {

        weak var weakList: ListView?

        autoreleasepool {
            var listView: ListView? = ListView(frame: CGRect(x: 0, y: 0, width: 400, height: 600))

            listView?.configure { list in
                list.animatesChanges = false
                list("section") { section in
                    for number in 1...10 {
                        section += Item(
                            ReorderTestContent(title: "Item \(number)"),
                            reordering: ItemReordering(sections: .all)
                        )
                    }
                }
            }

            listView?.collectionView.layoutIfNeeded()

            let indexPath = IndexPath(item: 0, section: 0)
            let item = listView?.storage.presentationState.item(at: indexPath)
            item?.beginReorder(from: indexPath, with: listView!.environment)

            XCTAssertEqual(listView?.hasInProgressReorders, true)

            self.waitForOneRunloop()

            weakList = listView
            listView = nil
        }

        self.waitFor {
            weakList == nil
        }
    }
}


fileprivate final class ReorderTestViewController: UIViewController {

    let list = ListView()

    override func loadView() {
        view = UIView()
        view.addSubview(list)
        list.frame = CGRect(x: 0, y: 0, width: 400, height: 600)

        list.configure { list in
            list.animatesChanges = false
            list("section") { section in
                for number in 1...10 {
                    section += Item(
                        ReorderTestContent(title: "Item \(number)"),
                        reordering: ItemReordering(sections: .all)
                    )
                }
            }
        }
    }
}


fileprivate struct ReorderTestContent: ItemContent, Equatable {

    var title: String

    var identifierValue: String { title }

    func apply(
        to views: ItemContentViews<Self>,
        for reason: ApplyReason,
        with info: ApplyItemContentInfo
    ) {
        views.content.backgroundColor = .red
    }

    typealias ContentView = UIView

    static func createReusableContentView(frame: CGRect) -> UIView {
        UIView(frame: frame)
    }

    var defaultItemProperties: DefaultProperties {
        .defaults { defaults in
            defaults.sizing = .fixed(height: 50)
        }
    }
}
