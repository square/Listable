//
//  PresentationState.SectionState.swift
//  Listable
//
//  Created by Kyle Van Essen on 5/22/20.
//

import Foundation


extension PresentationState
{
    final class SectionState
    {
        var model : Section
        
        var header : HeaderFooterViewStatePair = .init()
        var footer : HeaderFooterViewStatePair = .init()
        
        var items : [AnyPresentationItemState]
        
        init(
            with model : Section,
            dependencies : ItemStateDependencies,
            updateCallbacks : UpdateCallbacks
        ) {
            self.model = model
            
            self.header.state = SectionState.headerFooterState(with: self.header.state, new: model.header)
            self.footer.state = SectionState.headerFooterState(with: self.footer.state, new: model.footer)
            
            self.items = self.model.items.map {
                $0.newPresentationItemState(with: dependencies, updateCallbacks: updateCallbacks) as! AnyPresentationItemState
            }
        }
        
        func removeItem(at index : Int)
        {
            self.model.items.remove(at: index)
            self.items.remove(at: index)
        }
        
        func insert(item : AnyPresentationItemState, at index : Int)
        {
            self.model.items.insert(item.anyModel, at: index)
            self.items.insert(item, at: index)
        }
        
        func update(
            with oldSection : Section,
            new newSection : Section,
            changes : SectionedDiff<Section, AnyIdentifier, AnyItem, AnyIdentifier>.ItemChanges,
            dependencies : ItemStateDependencies,
            updateCallbacks : UpdateCallbacks
        ) {
            self.model = newSection
            
            self.header.state = SectionState.headerFooterState(with: self.header.state, new: self.model.header)
            self.footer.state = SectionState.headerFooterState(with: self.footer.state, new: self.model.footer)
            
            self.items = changes.transform(
                old: self.items,
                removed: {
                    _, item in item.wasRemoved(updateCallbacks: updateCallbacks)
                },
                added: {
                    $0.newPresentationItemState(with: dependencies, updateCallbacks: updateCallbacks) as! AnyPresentationItemState
                },
                moved: { old, new, item in
                    item.setNew(item: new, reason: .moveFromList, updateCallbacks: updateCallbacks)
                },
                updated: { old, new, item in
                    item.setNew(item: new, reason: .updateFromList, updateCallbacks: updateCallbacks)
                },
                noChange: { old, new, item in
                    item.setNew(item: new, reason: .noChange, updateCallbacks: updateCallbacks)
                }
            )
        }
        
        func wasRemoved(updateCallbacks : UpdateCallbacks)
        {
            for item in self.items {
                item.wasRemoved(updateCallbacks: updateCallbacks)
            }
        }
        
        static func headerFooterState(with current : AnyPresentationHeaderFooterState?, new : AnyHeaderFooter?) -> AnyPresentationHeaderFooterState?
        {
            if let current = current {
                if let new = new {
                    let isSameType = type(of: current.anyModel) == type(of: new)
                    
                    if isSameType {
                        current.setNew(headerFooter: new)
                        return current
                    } else {
                        return (new.newPresentationHeaderFooterState() as! AnyPresentationHeaderFooterState)
                    }
                } else {
                    return nil
                }
            } else {
                if let new = new {
                    return (new.newPresentationHeaderFooterState() as! AnyPresentationHeaderFooterState)
                } else {
                    return nil
                }
            }
        }
    }
}
