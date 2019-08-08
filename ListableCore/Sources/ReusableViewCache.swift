//
//  ReusableViewCache.swift
//  CheckoutApplet
//
//  Created by Kyle Van Essen on 6/21/19.
//

import Foundation


public final class ReusableViewCache
{
    private var views : [String:[Any]]
    
    public init()
    {
        self.views = [:]
    }
    
    public func push<Content,View>(_ view : View, with reuseIdentifier: ReuseIdentifier<Content>)
    {
        var views = self.views[reuseIdentifier.stringValue, default: []]
        
        views.append(view)
        
        self.views[reuseIdentifier.stringValue] = views
    }
    
    public func pop<Content,View>(with reuseIdentifier: ReuseIdentifier<Content>, _ create : () -> View) -> View
    {
        var views = self.views[reuseIdentifier.stringValue, default: []]
        
        if let view = views.popLast() {
            self.views[reuseIdentifier.stringValue] = views
            return view as! View
        } else {
            return create()
        }
    }
    
    public func use<Content,View, Result>(with reuseIdentifier: ReuseIdentifier<Content>, create : () -> View, _ use : (View) -> Result) -> Result
    {
        let views = self.views[reuseIdentifier.stringValue, default: []]
        
        if let view = views.last {
            // Fast path: Already in the cache, just reference it here.
            return use(view as! View)
        } else {
            // Create a new view since one is not available to be used.
            let view = self.pop(with: reuseIdentifier, create)
            let result = use(view)
            
            self.push(view, with: reuseIdentifier)
            
            return result
        }
    }
}
