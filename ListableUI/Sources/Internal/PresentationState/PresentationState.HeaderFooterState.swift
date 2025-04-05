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
    
    var kind : SupplementaryKind { get }
    
    var oldIndexPath : IndexPath? { get }
    
    var containsFirstResponder : Bool { get set }
    
    func updateOldIndexPath(in section : Int)
        
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
            animated : Bool,
            updateCallbacks : UpdateCallbacks,
            environment: ListEnvironment
        ) {
            self.visibleContainer?.environment = environment
            
            if self.state !== state {
                self.state = state
                self.visibleContainer?.setHeaderFooter(state, animated: reason.shouldAnimate && animated)
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
        
        func collectionViewWillDisplay(view : SupplementaryContainerView)
        {
            /// **Note**: It's possible for this method and the below
            /// to be called in an unbalanced manner (eg, we get moved to a new supplementary view),
            /// _without_ an associated call to `collectionViewDidEndDisplay(of:)`.
            ///
            /// Thus, if any logic added to this method depends on the instance
            /// of `visibleContainer` changing, wrap it in a `===` check.
            
            self.visibleContainer = view
        }
        
        func collectionViewDidEndDisplay(of view : SupplementaryContainerView)
        {
            /// **Note**: This method is called _after_ the animation that removes
            /// supplementary views from the collection view, so the ordering can be:
            ///
            /// 1) `collectionViewWillDisplay` of new supplementary view
            /// 2) We're moved to that new supplementary view.
            /// 2) Collection view finishes animation
            /// 3) `collectionViewDidEndDisplay` is called.
            ///
            /// Because we manage the `HeaderFooter` view instances ourselves,
            /// and simply insert them into a whatever supplementary view the collection view
            /// is currently vending us, it's possible that `collectionViewWillDisplay`
            /// has already assigned us a new supplementary view. Make sure the one
            /// we're being asked to remove is the one we know about, otherwise, do nothing.
            
            guard view === visibleContainer else {
                return
            }
            
            self.visibleContainer = nil
        }
        
        func updateOldIndexPath(in section : Int) {
            state?.updateOldIndexPath(in: section)
        }
    }
    
    
    final class HeaderFooterState<Content:HeaderFooterContent> : AnyPresentationHeaderFooterState
    {
        var model : HeaderFooter<Content>
        
        let performsContentCallbacks : Bool
                
        init(
            _ model : HeaderFooter<Content>,
            kind: SupplementaryKind,
            performsContentCallbacks : Bool
        )
        {
            self.model = model
            self.kind = kind
            self.performsContentCallbacks = performsContentCallbacks
        }
        
        // MARK: AnyPresentationHeaderFooterState
        
        var anyModel: AnyHeaderFooter {
            return self.model
        }
        
        private(set) var kind : SupplementaryKind
        
        var oldIndexPath : IndexPath? = nil
        
        var containsFirstResponder : Bool = false
        
        func updateOldIndexPath(in section : Int) {
            oldIndexPath = kind.indexPath(in: section)
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
            
            let views = HeaderFooterContentViews<Content>(view: view)
            
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
        
        private var cachedSizes : Cache<SizeKey,CGSize> = .init()
        
        func resetCachedSizes()
        {
            self.cachedSizes.clear()
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
            
            return self.cachedSizes.get(key) {
                SignpostLogger.log(.begin, log: .updateContent, name: "Measure HeaderFooter", for: self.model)
                
                let size : CGSize = cache.use(
                    with: self.model.reuseIdentifier,
                    create: {
                        return HeaderFooterContentView<Content>(frame: .zero)
                }, { view in
                    let views = HeaderFooterContentViews<Content>(view: view)
                    
                    self.model.content.apply(
                        to: views,
                        for: .measurement,
                        with: .init(environment: environment)
                    )
                    
                    return self.model.sizing.measure(with: view, info: info)
                })
                                
                SignpostLogger.log(.end, log: .updateContent, name: "Measure HeaderFooter", for: self.model)
                
                return size
            }
        }
    }
}
