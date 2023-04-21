//
//  PresentationState.SectionState.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 5/22/20.
//

import Foundation


extension PresentationState
{
    final class SectionState
    {
        var model : Section
        
        let header : HeaderFooterViewStatePair
        let footer : HeaderFooterViewStatePair
        
        var items : [AnyPresentationItemState]
        
        let performsContentCallbacks : Bool
        
        init(
            with model : Section,
            dependencies : ItemStateDependencies,
            updateCallbacks : UpdateCallbacks,
            performsContentCallbacks : Bool
        ) {
            self.model = model
                        
            self.header = .init(state: SectionState.newHeaderFooterState(
                with: model.header,
                kind: .sectionHeader,
                performsContentCallbacks: performsContentCallbacks
            ))
            
            self.footer = .init(state: SectionState.newHeaderFooterState(
                with: model.footer,
                kind: .sectionFooter,
                performsContentCallbacks: performsContentCallbacks
            ))
            
            self.performsContentCallbacks = performsContentCallbacks
            
            self.items = self.model.items.map {
                $0.newPresentationItemState(
                    with: dependencies,
                    updateCallbacks: updateCallbacks,
                    performsContentCallbacks: performsContentCallbacks
                ) as! AnyPresentationItemState
            }
        }
        
        func resetAllCachedSizes() {
            self.header.state?.resetCachedSizes()
            self.footer.state?.resetCachedSizes()
            
            self.items.forEach { item in
                item.resetCachedSizes()
            }
        }
        
        func removeItem(at index : Int) -> AnyPresentationItemState
        {
            self.model.items.remove(at: index)
            return self.items.remove(at: index)
        }
        
        func insert(item : AnyPresentationItemState, at index : Int)
        {
            self.model.items.insert(item.anyModel, at: index)
            self.items.insert(item, at: index)
        }
        
        func updateOldIndexPath(in section : Int) {
            header.updateOldIndexPath(in: section)
            footer.updateOldIndexPath(in: section)
        }
        
        func update(
            with oldSection : Section,
            new newSection : Section,
            changes : SectionedDiff<Section, AnyIdentifier, AnyItem, AnyIdentifier>.ItemChanges,
            reason: ApplyReason,
            animated : Bool,
            dependencies : ItemStateDependencies,
            updateCallbacks : UpdateCallbacks
        ) {
            self.model = newSection
            
            let environment = dependencies.environmentProvider()
            
            self.header.update(
                with: SectionState.headerFooterState(
                    current: self.header.state,
                    new: self.model.header,
                    kind: .sectionHeader,
                    performsContentCallbacks: self.performsContentCallbacks
                ),
                new: self.model.header,
                reason: reason,
                animated: animated,
                updateCallbacks: updateCallbacks,
                environment: environment
            )
            
            self.footer.update(
                with: SectionState.headerFooterState(
                    current: self.footer.state,
                    new: self.model.footer,
                    kind: .sectionFooter,
                    performsContentCallbacks: self.performsContentCallbacks
                ),
                new: self.model.footer,
                reason: reason,
                animated: animated,
                updateCallbacks: updateCallbacks,
                environment: environment
            )
            
            self.items = changes.transform(
                old: self.items,
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
                moved: { old, new, item in
                    item.set(new: new, reason: .moveFromList, updateCallbacks: updateCallbacks, environment: environment)
                },
                updated: { old, new, item in
                    item.set(new: new, reason: .updateFromList, updateCallbacks: updateCallbacks, environment: environment)
                },
                noChange: { old, new, item in
                    item.set(new: new, reason: .noChange, updateCallbacks: updateCallbacks, environment: environment)
                }
            )
        }
        
        func wasRemoved(updateCallbacks : UpdateCallbacks)
        {
            for item in self.items {
                item.wasRemoved(updateCallbacks: updateCallbacks)
            }
        }
        
        static func newHeaderFooterState(
            with new : AnyHeaderFooterConvertible?,
            kind: SupplementaryKind,
            performsContentCallbacks : Bool
        ) -> AnyPresentationHeaderFooterState?
        {
            if let new = new {
                return (new
                    .asAnyHeaderFooter()
                    .newPresentationHeaderFooterState(
                        kind: kind,
                        performsContentCallbacks: performsContentCallbacks
                    ) as! AnyPresentationHeaderFooterState)
            } else {
                return nil
            }
        }
        
        static func headerFooterState(
            current : AnyPresentationHeaderFooterState?,
            new : AnyHeaderFooterConvertible?,
            kind: SupplementaryKind,
            performsContentCallbacks : Bool
        ) -> AnyPresentationHeaderFooterState?
        {
            /// Eagerly convert the header/footer to the correct final type, so the `type(of:)` check later
            /// on in the function is comparing `HeaderFooter<Content>` types.
            let new = new?.asAnyHeaderFooter()
            
            if let current = current {
                if let new = new {
                    let isSameType = type(of: current.anyModel) == type(of: new)
                    
                    if isSameType {
                        return current
                    } else {
                        return (new
                            .newPresentationHeaderFooterState(
                                kind: kind,
                                performsContentCallbacks: performsContentCallbacks
                            ) as! AnyPresentationHeaderFooterState)
                    }
                } else {
                    return nil
                }
            } else {
                if let new = new {
                    return (new
                        .newPresentationHeaderFooterState(
                            kind: kind,
                            performsContentCallbacks: performsContentCallbacks
                        ) as! AnyPresentationHeaderFooterState)
                } else {
                    return nil
                }
            }
        }
    }
}
