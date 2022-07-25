//
//  PresentationState.SectionState.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 5/22/20.
//

import Foundation

extension PresentationState {
    final class SectionState {
        var model: Section

        let header: HeaderFooterViewStatePair
        let footer: HeaderFooterViewStatePair

        var items: [AnyPresentationItemState]

        let performsContentCallbacks: Bool

        init(
            with model: Section,
            dependencies: ItemStateDependencies,
            updateCallbacks: UpdateCallbacks,
            performsContentCallbacks: Bool
        ) {
            self.model = model

            header = .init(state: SectionState.newHeaderFooterState(
                with: model.header,
                performsContentCallbacks: performsContentCallbacks
            ))

            footer = .init(state: SectionState.newHeaderFooterState(
                with: model.footer,
                performsContentCallbacks: performsContentCallbacks
            ))

            self.performsContentCallbacks = performsContentCallbacks

            items = self.model.items.map {
                $0.newPresentationItemState(
                    with: dependencies,
                    updateCallbacks: updateCallbacks,
                    performsContentCallbacks: performsContentCallbacks
                ) as! AnyPresentationItemState
            }
        }

        func resetAllCachedSizes() {
            header.state?.resetCachedSizes()
            footer.state?.resetCachedSizes()

            items.forEach { item in
                item.resetCachedSizes()
            }
        }

        func removeItem(at index: Int) -> AnyPresentationItemState {
            model.items.remove(at: index)
            return items.remove(at: index)
        }

        func insert(item: AnyPresentationItemState, at index: Int) {
            model.items.insert(item.anyModel, at: index)
            items.insert(item, at: index)
        }

        func update(
            with _: Section,
            new newSection: Section,
            changes: SectionedDiff<Section, AnyIdentifier, AnyItem, AnyIdentifier>.ItemChanges,
            reason: ApplyReason,
            animated: Bool,
            dependencies: ItemStateDependencies,
            updateCallbacks: UpdateCallbacks
        ) {
            model = newSection

            let environment = dependencies.environmentProvider()

            header.update(
                with: SectionState.headerFooterState(
                    current: header.state,
                    new: model.header,
                    performsContentCallbacks: performsContentCallbacks
                ),
                new: model.header,
                reason: reason,
                animated: animated,
                updateCallbacks: updateCallbacks,
                environment: environment
            )

            footer.update(
                with: SectionState.headerFooterState(
                    current: footer.state,
                    new: model.footer,
                    performsContentCallbacks: performsContentCallbacks
                ),
                new: model.footer,
                reason: reason,
                animated: animated,
                updateCallbacks: updateCallbacks,
                environment: environment
            )

            items = changes.transform(
                old: items,
                removed: {
                    _, item in item.wasRemoved(updateCallbacks: updateCallbacks)
                },
                added: {
                    $0.newPresentationItemState(
                        with: dependencies,
                        updateCallbacks: updateCallbacks,
                        performsContentCallbacks: self.performsContentCallbacks
                    ) as! AnyPresentationItemState
                },
                moved: { _, new, item in
                    item.set(new: new, reason: .moveFromList, updateCallbacks: updateCallbacks, environment: environment)
                },
                updated: { _, new, item in
                    item.set(new: new, reason: .updateFromList, updateCallbacks: updateCallbacks, environment: environment)
                },
                noChange: { _, new, item in
                    item.set(new: new, reason: .noChange, updateCallbacks: updateCallbacks, environment: environment)
                }
            )
        }

        func wasRemoved(updateCallbacks: UpdateCallbacks) {
            for item in items {
                item.wasRemoved(updateCallbacks: updateCallbacks)
            }
        }

        static func newHeaderFooterState(
            with new: AnyHeaderFooterConvertible?,
            performsContentCallbacks: Bool
        ) -> AnyPresentationHeaderFooterState? {
            if let new = new {
                return (new.asAnyHeaderFooter().newPresentationHeaderFooterState(performsContentCallbacks: performsContentCallbacks) as! AnyPresentationHeaderFooterState)
            } else {
                return nil
            }
        }

        static func headerFooterState(
            current: AnyPresentationHeaderFooterState?,
            new: AnyHeaderFooterConvertible?,
            performsContentCallbacks: Bool
        ) -> AnyPresentationHeaderFooterState? {
            /// Eagerly convert the header/footer to the correct final type, so the `type(of:)` check later
            /// on in the function is comparing `HeaderFooter<Content>` types.
            let new = new?.asAnyHeaderFooter()

            if let current = current {
                if let new = new {
                    let isSameType = type(of: current.anyModel) == type(of: new)

                    if isSameType {
                        return current
                    } else {
                        return (new.newPresentationHeaderFooterState(performsContentCallbacks: performsContentCallbacks) as! AnyPresentationHeaderFooterState)
                    }
                } else {
                    return nil
                }
            } else {
                if let new = new {
                    return (new.newPresentationHeaderFooterState(performsContentCallbacks: performsContentCallbacks) as! AnyPresentationHeaderFooterState)
                } else {
                    return nil
                }
            }
        }
    }
}
