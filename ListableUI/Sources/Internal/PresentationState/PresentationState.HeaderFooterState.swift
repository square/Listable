//
//  PresentationState.HeaderFooterState.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 5/22/20.
//

import Foundation
import UIKit


protocol AnyPresentationHeaderFooterState : AnyObject
{
    var anyModel : AnyHeaderFooter { get }
        
    func dequeueAndPrepareReusableHeaderFooterView(
        in cache : ReusableViewCache,
        frame : CGRect,
        environment : ListEnvironment
    ) -> UIView
    
    func enqueueReusableHeaderFooterView(_ view : UIView, in cache : ReusableViewCache)
    
    func applyTo(
        view : UIView,
        for reason : ApplyReason,
        with info : ApplyHeaderFooterContentInfo
    )

    func set(
        new : AnyHeaderFooter,
        reason : ApplyReason,
        visibleView : UIView?,
        updateCallbacks : UpdateCallbacks,
        info : ApplyHeaderFooterContentInfo
    )
    
    func resetCachedSizes()
    
    func size(
        for info : Sizing.MeasureInfo,
        cache : ReusableViewCache,
        environment : ListEnvironment
    ) -> CGSize
}


extension PresentationState
{
    final class HeaderFooterViewStatePair
    {
        private(set) var state : AnyPresentationHeaderFooterState?
        
        private(set) var visibleContainer : SupplementaryContainerView?
        
        init(state : AnyPresentationHeaderFooterState?) {
            self.state = state
        }
        
        func update(
            with state : AnyPresentationHeaderFooterState?,
            new: AnyHeaderFooterConvertible?,
            reason: ApplyReason,
            updateCallbacks : UpdateCallbacks,
            environment: ListEnvironment
        ) {
            self.visibleContainer?.environment = environment
            
            if self.state !== state {
                self.state = state
                self.visibleContainer?.headerFooter = state
            } else {
                if let state = state, let new = new {
                    state.set(
                        new: new.asAnyHeaderFooter(),
                        reason: reason,
                        visibleView: self.visibleContainer?.content,
                        updateCallbacks: updateCallbacks,
                        info: .init(environment: environment)
                    )
                }
            }
        }
        
        func willDisplay(view : SupplementaryContainerView)
        {
            self.visibleContainer = view
        }
        
        func didEndDisplay()
        {
            self.visibleContainer = nil
        }
    }
    
    
    final class HeaderFooterState<Content:HeaderFooterContent> : AnyPresentationHeaderFooterState
    {
        var model : HeaderFooter<Content>
        
        let performsContentCallbacks : Bool
                
        init(_ model : HeaderFooter<Content>, performsContentCallbacks : Bool)
        {
            self.model = model
            self.performsContentCallbacks = performsContentCallbacks
        }
        
        // MARK: AnyPresentationHeaderFooterState
        
        var anyModel: AnyHeaderFooter {
            return self.model
        }
                
        func dequeueAndPrepareReusableHeaderFooterView(
            in cache : ReusableViewCache,
            frame : CGRect,
            environment : ListEnvironment
        ) -> UIView
        {
            let view = cache.pop(with: self.model.reuseIdentifier) {
                HeaderFooterContentView<Content>(frame: frame)
            }
            
            self.applyTo(
                view: view,
                for: .willDisplay,
                with: .init(environment: environment)
            )
            
            return view
        }
        
        func enqueueReusableHeaderFooterView(_ view : UIView, in cache : ReusableViewCache)
        {
            cache.push(view, with: self.model.reuseIdentifier)
        }
        
        func applyTo(
            view : UIView,
            for reason : ApplyReason,
            with info : ApplyHeaderFooterContentInfo
        ) {
            let view = view as! HeaderFooterContentView<Content>
            
            let views = HeaderFooterContentViews<Content>(
                content: view.content,
                background: view.background,
                pressed: view.pressedBackground
            )
            
            view.onTap = self.model.onTap
            
            self.model.content.apply(to: views, for: reason, with: info)
        }
        
        func set(
            new : AnyHeaderFooter,
            reason : ApplyReason,
            visibleView : UIView?,
            updateCallbacks : UpdateCallbacks,
            info : ApplyHeaderFooterContentInfo
        ) {
            let old = self.model
            
            self.model = new as! HeaderFooter<Content>
            
            let isEquivalent = self.model.anyIsEquivalent(to: old)
            
            let wantsReapplication = self.model.reappliesToVisibleView.shouldReapply(
                comparing: old.reappliesToVisibleView,
                isEquivalent: isEquivalent
            )
            
            if isEquivalent == false {
                self.resetCachedSizes()
            }
            
            if let view = visibleView, wantsReapplication {
                updateCallbacks.performAnimation {
                    self.applyTo(view: view, for: reason, with: info)
                }
            }
        }
        
        private var cachedSizes : [SizeKey:CGSize] = [:]
        
        func resetCachedSizes()
        {
            self.cachedSizes.removeAll()
        }
        
        func size(
            for info : Sizing.MeasureInfo,
            cache : ReusableViewCache,
            environment : ListEnvironment
        ) -> CGSize
        {
            guard info.sizeConstraint.isEmpty == false else {
                return .zero
            }
            
            let key = SizeKey(
                width: info.sizeConstraint.width,
                height: info.sizeConstraint.height,
                layoutDirection: info.direction,
                sizing: self.model.sizing
            )
            
            if let size = self.cachedSizes[key] {
                return size
            } else {
                SignpostLogger.log(.begin, log: .updateContent, name: "Measure HeaderFooter", for: self.model)
                
                let size : CGSize = cache.use(
                    with: self.model.reuseIdentifier,
                    create: {
                        return HeaderFooterContentView<Content>(frame: .zero)
                }, { view in
                    let views = HeaderFooterContentViews<Content>(
                        content: view.content,
                        background: view.background,
                        pressed: view.pressedBackground
                    )
                    
                    self.model.content.apply(
                        to: views,
                        for: .measurement,
                        with: .init(environment: environment)
                    )
                    
                    return self.model.sizing.measure(with: view, info: info)
                })
                
                self.cachedSizes[key] = size
                
                SignpostLogger.log(.end, log: .updateContent, name: "Measure HeaderFooter", for: self.model)
                
                return size
            }
        }
    }
}
