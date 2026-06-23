//
//  ListStateObserverApproachingBottomTests.swift
//  ListableUI-Unit-Tests
//
//  Created by OpenAI Codex on 2026-04-24.
//

@testable import ListableUI
import XCTest

final class ListStateObserverApproachingBottomTests : XCTestCase
{
    func test_callsBackOnceWhileRemainingWithinThreshold()
    {
        var callCount = 0

        var observer = ListStateObserver()
        observer.onApproachingBottom(within: .offset(100.0)) { _ in
            callCount += 1
        }

        let info = makeInfo(bottomScrollOffset: 80.0)

        observer.onDidScroll.first?(didScroll(positionInfo: info))
        observer.onDidScroll.first?(didScroll(positionInfo: info))
        observer.onVisibilityChanged.first?(visibilityChanged(positionInfo: info))

        XCTAssertEqual(callCount, 1)
    }

    func test_rearmsAfterScrollingAwayFromThreshold()
    {
        var callCount = 0

        var observer = ListStateObserver()
        observer.onApproachingBottom(within: .offset(100.0)) { _ in
            callCount += 1
        }

        observer.onDidScroll.first?(didScroll(positionInfo: makeInfo(bottomScrollOffset: 80.0)))
        observer.onDidScroll.first?(didScroll(positionInfo: makeInfo(bottomScrollOffset: 180.0)))
        observer.onDidScroll.first?(didScroll(positionInfo: makeInfo(bottomScrollOffset: 60.0)))

        XCTAssertEqual(callCount, 2)
    }

    func test_rearmsAfterContentChangesWhileRemainingWithinThreshold()
    {
        var callCount = 0

        var observer = ListStateObserver()
        observer.onApproachingBottom(within: .offset(100.0)) { _ in
            callCount += 1
        }

        observer.onDidScroll.first?(didScroll(positionInfo: makeInfo(bottomScrollOffset: 80.0)))
        observer.onContentUpdated.first?(
            contentUpdated(
                positionInfo: makeInfo(bottomScrollOffset: 90.0),
                hadChanges: true
            )
        )

        XCTAssertEqual(callCount, 2)
    }

    func test_doesNotRearmForContentUpdatesWithoutChanges()
    {
        var callCount = 0

        var observer = ListStateObserver()
        observer.onApproachingBottom(within: .offset(100.0)) { _ in
            callCount += 1
        }

        observer.onDidScroll.first?(didScroll(positionInfo: makeInfo(bottomScrollOffset: 80.0)))
        observer.onContentUpdated.first?(
            contentUpdated(
                positionInfo: makeInfo(bottomScrollOffset: 80.0),
                hadChanges: false
            )
        )

        XCTAssertEqual(callCount, 1)
    }

    func test_shouldPerformCanDelayTheFirstCallback()
    {
        var callCount = 0
        var canLoadMore = false

        var observer = ListStateObserver()
        observer.onApproachingBottom(
            within: .offset(100.0),
            shouldPerform: { _ in canLoadMore }
        ) { _ in
            callCount += 1
        }

        let info = makeInfo(bottomScrollOffset: 80.0)

        observer.onDidScroll.first?(didScroll(positionInfo: info))
        canLoadMore = true
        observer.onDidScroll.first?(didScroll(positionInfo: info))

        XCTAssertEqual(callCount, 1)
    }

    func test_rearmsWhenViewportChanges()
    {
        var callCount = 0

        var observer = ListStateObserver()
        observer.onApproachingBottom(within: .screens(1.0)) { _ in
            callCount += 1
        }

        observer.onDidScroll.first?(
            didScroll(
                positionInfo: makeInfo(
                    bottomScrollOffset: 300.0,
                    boundsHeight: 400.0
                )
            )
        )

        observer.onFrameChanged.first?(
            frameChanged(
                positionInfo: makeInfo(
                    bottomScrollOffset: 300.0,
                    boundsHeight: 500.0
                )
            )
        )

        XCTAssertEqual(callCount, 2)
    }
}

private extension ListStateObserverApproachingBottomTests
{
    func didScroll(positionInfo : ListScrollPositionInfo) -> ListStateObserver.DidScroll
    {
        ListStateObserver.DidScroll(
            actions: ListActions(),
            positionInfo: positionInfo
        )
    }

    func visibilityChanged(positionInfo : ListScrollPositionInfo) -> ListStateObserver.VisibilityChanged
    {
        ListStateObserver.VisibilityChanged(
            actions: ListActions(),
            positionInfo: positionInfo,
            displayed: [],
            endedDisplay: []
        )
    }

    func contentUpdated(
        positionInfo : ListScrollPositionInfo,
        hadChanges : Bool
    ) -> ListStateObserver.ContentUpdated {
        ListStateObserver.ContentUpdated(
            hadChanges: hadChanges,
            insertionsAndRemovals: .init(),
            actions: ListActions(),
            positionInfo: positionInfo
        )
    }

    func frameChanged(positionInfo : ListScrollPositionInfo) -> ListStateObserver.FrameChanged
    {
        ListStateObserver.FrameChanged(
            actions: ListActions(),
            positionInfo: positionInfo,
            old: .zero,
            new: positionInfo.bounds
        )
    }

    func makeInfo(
        bottomScrollOffset : CGFloat,
        boundsHeight : CGFloat = 400.0,
        safeAreaInsets : UIEdgeInsets = .zero,
        isLastItemVisible : Bool = false
    ) -> ListScrollPositionInfo {
        let scrollView = TestScrollView()
        scrollView.bounds = CGRect(origin: .zero, size: CGSize(width: 100.0, height: boundsHeight))
        scrollView.contentSize = CGSize(width: 100.0, height: boundsHeight + bottomScrollOffset)
        scrollView.contentOffset = .zero
        scrollView.contentInset = .zero
        scrollView.verticalScrollIndicatorInsets = .zero
        scrollView.testSafeAreaInsets = safeAreaInsets

        return ListScrollPositionInfo(
            scrollView: scrollView,
            visibleItems: Set(),
            isFirstItemVisible: false,
            isLastItemVisible: isLastItemVisible
        )
    }
}

private final class TestScrollView : UIScrollView
{
    var testSafeAreaInsets: UIEdgeInsets = .zero

    override var safeAreaInsets: UIEdgeInsets {
        testSafeAreaInsets
    }
}
