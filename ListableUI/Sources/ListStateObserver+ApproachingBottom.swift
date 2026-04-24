//
//  ListStateObserver+ApproachingBottom.swift
//  ListableUI
//
//  Created by OpenAI Codex on 2026-04-24.
//

import Foundation
import UIKit

public extension ListStateObserver {
    typealias OnApproachingBottom = (ApproachingBottom) -> Void

    /// Registers a callback which will be called when a vertically scrolling list approaches
    /// the bottom of its rendered content.
    ///
    /// This convenience observer de-duplicates callbacks while the list remains within the
    /// provided threshold. It re-arms once the list scrolls away from the threshold, the list's
    /// content changes, or the list's viewport changes size.
    ///
    /// Use `shouldPerform` to gate pagination work on external state such as `isLoading`
    /// or `hasMorePages`. The callback is only considered delivered once `shouldPerform`
    /// returns `true`.
    mutating func onApproachingBottom(
        within threshold: ListScrollPositionInfo.BottomThreshold = .screens(1.0),
        shouldPerform: @escaping (ListScrollPositionInfo) -> Bool = { _ in true },
        _ callback: @escaping OnApproachingBottom
    ) {
        let observer = ApproachingBottomObserver(
            threshold: threshold,
            shouldPerform: shouldPerform,
            callback: callback
        )

        onDidScroll(observer.didScroll)
        onVisibilityChanged(observer.visibilityChanged)
        onContentUpdated(observer.contentUpdated)
        onFrameChanged(observer.frameChanged)
    }

    /// Parameters available for ``OnApproachingBottom`` callbacks.
    struct ApproachingBottom {
        /// A set of methods you can use to perform actions on the list, eg scrolling to a given row.
        public let actions: ListActions

        /// The current scroll position of the list.
        public let positionInfo: ListScrollPositionInfo
    }
}

private extension ListStateObserver {
    final class ApproachingBottomObserver {
        let threshold: ListScrollPositionInfo.BottomThreshold
        let shouldPerform: (ListScrollPositionInfo) -> Bool
        let callback: OnApproachingBottom

        var contentVersion: Int = 0
        var lastTriggeredContext: TriggerContext?

        init(
            threshold: ListScrollPositionInfo.BottomThreshold,
            shouldPerform: @escaping (ListScrollPositionInfo) -> Bool,
            callback: @escaping OnApproachingBottom
        ) {
            self.threshold = threshold
            self.shouldPerform = shouldPerform
            self.callback = callback
        }

        func didScroll(_ info: DidScroll) {
            performIfNeeded(actions: info.actions, positionInfo: info.positionInfo)
        }

        func visibilityChanged(_ info: VisibilityChanged) {
            performIfNeeded(actions: info.actions, positionInfo: info.positionInfo)
        }

        func contentUpdated(_ info: ContentUpdated) {
            if info.hadChanges {
                contentVersion += 1
            }

            performIfNeeded(actions: info.actions, positionInfo: info.positionInfo)
        }

        func frameChanged(_ info: FrameChanged) {
            performIfNeeded(actions: info.actions, positionInfo: info.positionInfo)
        }

        private func performIfNeeded(actions: ListActions, positionInfo: ListScrollPositionInfo) {
            guard positionInfo.isApproachingBottom(within: threshold) else {
                lastTriggeredContext = nil
                return
            }

            guard shouldPerform(positionInfo) else {
                return
            }

            let currentContext = TriggerContext(
                contentVersion: contentVersion,
                boundsSize: positionInfo.bounds.size,
                safeAreaInsets: positionInfo.safeAreaInsets
            )

            guard lastTriggeredContext != currentContext else {
                return
            }

            lastTriggeredContext = currentContext

            callback(
                ApproachingBottom(
                    actions: actions,
                    positionInfo: positionInfo
                )
            )
        }
    }

    struct TriggerContext: Equatable {
        var contentVersion: Int
        var boundsSize: CGSize
        var safeAreaInsets: UIEdgeInsets
    }
}
