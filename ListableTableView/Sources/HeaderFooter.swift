//
//  HeaderFooter.swift
//  ListableTableView
//
//  Created by Kyle Van Essen on 8/10/19.
//

import ListableCore


public protocol AnyHeaderFooter : AnyHeaderFooter_Internal
{
}


public protocol AnyHeaderFooter_Internal
{
    func heightWith(width : CGFloat, default defaultHeight : CGFloat, measurementCache : ReusableViewCache) -> CGFloat
    
    func dequeueView(in tableView: UITableView) -> UITableViewHeaderFooterView
    
    func applyTo(headerFooterView : UITableViewHeaderFooterView, reason: ApplyReason)
    
    func updatedComparedTo(old : AnyHeaderFooter) -> Bool
    func movedComparedTo(old : AnyHeaderFooter) -> Bool
}


public struct HeaderFooter<Element:HeaderFooterElement> : AnyHeaderFooter
{
    public var element : Element
    public var sizing : AxisSizing
    
    private let reuseIdentifier : ReuseIdentifier<Element>
    
    // MARK: Initialization
    
    public init(_ element : Element, sizing : AxisSizing = .default)
    {
        self.element = element
        self.sizing = sizing
        
        self.reuseIdentifier = ReuseIdentifier.identifier(for: self.element)
    }
    
    // MARK: AnyHeaderFooter_Internal
    
    public func heightWith(width : CGFloat, default defaultHeight : CGFloat, measurementCache : ReusableViewCache) -> CGFloat
    {
        return measurementCache.use(with: self.reuseIdentifier, create: { Element.createReusableHeaderFooterView(with: self.reuseIdentifier) }) { view in
            self.element.apply(to: view, reason: .willDisplay)
            
            return self.sizing.height(with: view, fittingWidth: width, default: defaultHeight)
        }
    }
    
    public func applyTo(headerFooterView : UITableViewHeaderFooterView, reason : ApplyReason)
    {
        guard let view = headerFooterView as? Element.HeaderFooterView else {
            return
        }
        
        self.element.apply(to: view, reason: reason)
    }
    
    public func dequeueView(in tableView: UITableView) -> UITableViewHeaderFooterView
    {
        let view : Element.HeaderFooterView = {
            if let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: self.reuseIdentifier.stringValue) {
                return view as! Element.HeaderFooterView
            } else {
                return Element.createReusableHeaderFooterView(with: self.reuseIdentifier)
            }
        }()
        
        self.element.apply(to: view, reason: .willDisplay)
        
        return view
    }
    
    public func updatedComparedTo(old : AnyHeaderFooter) -> Bool
    {
        guard let old = old as? HeaderFooter<Element> else {
            return true
        }
        
        return self.element.wasUpdated(comparedTo: old.element)
    }
    
    public func movedComparedTo(old : AnyHeaderFooter) -> Bool
    {
        guard let old = old as? HeaderFooter<Element> else {
            return true
        }
        
        return self.element.wasMoved(comparedTo: old.element)
    }
}
