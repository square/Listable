//
//  CollectionViewLayoutTests.swift
//  ListableUI-Unit-Tests
//
//  Created by Alex Odawa on 5/2/26.
//

import XCTest
@testable import ListableUI


final class CollectionViewLayoutTests : XCTestCase
{
    func test_prepare_whenDelegateHasBeenDeallocated()
    {
        weak var weakDelegate : CollectionViewLayoutDelegateMock?

        let layout : CollectionViewLayout = {
            let delegate = CollectionViewLayoutDelegateMock()
            weakDelegate = delegate

            return CollectionViewLayout(
                delegate: delegate,
                layoutDescription: .table(),
                appearance: Appearance(),
                behavior: Behavior()
            )
        }()

        XCTAssertNil(weakDelegate)
        XCTAssertNil(layout.delegate)

        layout.prepare()
    }

    /// Exercises the real production path that motivates the weak-delegate fix:
    /// `sendEndQueuingEditsAfterDelay` schedules a closure on `OperationQueue.main`
    /// that fires on a later runloop turn. If the owning `ListView` (and therefore
    /// the delegate) deallocates between scheduling and dispatch, the closure
    /// previously trapped on the `unowned` delegate access.
    func test_sendEndQueuingEditsAfterDelay_whenDelegateDeallocatesBeforeDispatch()
    {
        weak var weakDelegate : CollectionViewLayoutDelegateMock?

        autoreleasepool {
            let delegate = CollectionViewLayoutDelegateMock()
            weakDelegate = delegate

            let layout = CollectionViewLayout(
                delegate: delegate,
                layoutDescription: .table(),
                appearance: Appearance(),
                behavior: Behavior()
            )

            layout.sendEndQueuingEditsAfterDelay()
        }

        XCTAssertNil(weakDelegate)

        let drained = expectation(description: "main queue drained")
        OperationQueue.main.addOperation { drained.fulfill() }
        wait(for: [drained], timeout: 1.0)
    }
}


private final class CollectionViewLayoutDelegateMock : CollectionViewLayoutDelegate
{
    func listViewLayoutUpdatedItemPositions() {}

    func listLayoutContent(
        defaults: ListLayoutDefaults
    ) -> ListLayoutContent {
        ListLayoutContent()
    }

    func listViewLayoutCurrentEnvironment() -> ListEnvironment {
        .empty
    }

    func listViewLayoutDidLayoutContents() {}

    func listViewShouldEndQueueingEditsForReorder() {}
}
