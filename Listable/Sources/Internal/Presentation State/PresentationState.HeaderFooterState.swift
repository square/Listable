//
//  PresentationState.HeaderFooterState.swift
//  Listable
//
//  Created by Kyle Van Essen on 5/22/20.
//

import Foundation


protocol AnyPresentationHeaderFooterState : AnyObject
{
    var anyModel : AnyHeaderFooter { get }
        
    func dequeueAndPrepareReusableHeaderFooterView(in cache : ReusableViewCache, frame : CGRect) -> UIView
    func enqueueReusableHeaderFooterView(_ view : UIView, in cache : ReusableViewCache)
    
    func applyTo(view anyView : UIView, reason : ApplyReason)
    
    func setNew(headerFooter anyHeaderFooter : AnyHeaderFooter)
    
    func resetCachedSizes()
    func size(for info : Sizing.MeasureInfo, cache : ReusableViewCache) -> CGSize
}


extension PresentationState
{
    final class HeaderFooterViewStatePair
    {
        var state : AnyPresentationHeaderFooterState? {
            didSet {
                guard oldValue !== self.state else {
                    return
                }
                
                guard let container = self.visibleContainer else {
                    return
                }
                
                container.headerFooter = self.state
            }
        }
        
        private(set) var visibleContainer : SupplementaryContainerView?
        
        func willDisplay(view : SupplementaryContainerView)
        {
            self.visibleContainer = view
        }
        
        func didEndDisplay()
        {
            self.visibleContainer = nil
        }
        
        func applyToVisibleView(reason : ApplyReason)
        {
            guard let view = visibleContainer?.content, let state = self.state else {
                return
            }
            
            state.applyTo(view: view, reason: reason)
        }
    }
    
    final class HeaderFooterState<Content:HeaderFooterContent> : AnyPresentationHeaderFooterState
    {
        var model : HeaderFooter<Content>
                
        init(_ model : HeaderFooter<Content>)
        {
            self.model = model
        }
        
        // MARK: AnyPresentationHeaderFooterState
        
        var anyModel: AnyHeaderFooter {
            return self.model
        }
                
        func dequeueAndPrepareReusableHeaderFooterView(in cache : ReusableViewCache, frame : CGRect) -> UIView
        {
            let view = cache.pop(with: self.model.reuseIdentifier) {
                return Content.createReusableHeaderFooterView(frame: frame)
            }
            
            self.applyTo(view: view, reason: .willDisplay)
            
            return view
        }
        
        func enqueueReusableHeaderFooterView(_ view : UIView, in cache : ReusableViewCache)
        {
            cache.push(view, with: self.model.reuseIdentifier)
        }
        
        func createReusableHeaderFooterView(frame : CGRect) -> UIView
        {
            return Content.createReusableHeaderFooterView(frame: frame)
        }
        
        func applyTo(view : UIView, reason : ApplyReason)
        {
            let view = view as! Content.ContentView
            
            self.model.content.apply(to: view, reason: reason)
        }
        
        func setNew(headerFooter anyHeaderFooter: AnyHeaderFooter)
        {
            let oldModel = self.model
            
            self.model = anyHeaderFooter as! HeaderFooter<Content>
            
            let isEquivalent = self.model.anyIsEquivalent(to: oldModel)
            
            if isEquivalent == false {
                self.resetCachedSizes()
            }
        }
        
        private var cachedSizes : [SizeKey:CGSize] = [:]
        
        func resetCachedSizes()
        {
            self.cachedSizes.removeAll()
        }
        
        func size(for info : Sizing.MeasureInfo, cache : ReusableViewCache) -> CGSize
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
                        return Content.createReusableHeaderFooterView(frame: .zero)
                }, { view in
                    self.model.content.apply(to: view, reason: .willDisplay)
                    
                    return self.model.sizing.measure(with: view, info: info)
                })
                
                self.cachedSizes[key] = size
                
                SignpostLogger.log(.end, log: .updateContent, name: "Measure HeaderFooter", for: self.model)
                
                return size
            }
        }
    }
}
