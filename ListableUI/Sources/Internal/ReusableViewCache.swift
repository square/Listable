//
//  ReusableViewCache.swift
//  CheckoutApplet
//
//  Created by Kyle Van Essen on 6/21/19.
//

import Foundation


public final class ReusableViewCache
{
    private var views : [String:[AnyObject]] = [:]
    
    init() {}
    
    func count<Content>(for reuseIdentifier : ReuseIdentifier<Content>) -> Int
    {
        let views = self.views[reuseIdentifier.stringValue, default: []]

        return views.count
    }
    
    func push<Content,View:AnyObject>(_ view : View, with reuseIdentifier: ReuseIdentifier<Content>)
    {
        var views = self.views[reuseIdentifier.stringValue, default: []]
        
        listableInternalPrecondition(views.contains { $0 === view } == false, "Cannot push a view which is already in the cache.")
        
        views.append(view)
        
        self.views[reuseIdentifier.stringValue] = views
    }
    
    func pop<Content,View:AnyObject>(
        with reuseIdentifier: ReuseIdentifier<Content>,
        create : () -> View
    ) -> View
    {
        var views = self.views[reuseIdentifier.stringValue, default: []]
        
        if let view = views.popLast() {
            self.views[reuseIdentifier.stringValue] = views
            return view as! View
        } else {
            return create()
        }
    }
    
    func use<Content,View:AnyObject, Result>(
        with reuseIdentifier: ReuseIdentifier<Content>,
        create : () -> View,
        use : (View) -> Result
    ) -> Result
    {
        let views = self.views[reuseIdentifier.stringValue, default: []]
        
        if let view = views.last {
            // Fast path: Already in the cache, just reference it here.
            return use(view as! View)
        } else {
            // Create a new view since one is not available to be used.
            let view = self.pop(with: reuseIdentifier, create: create)
            let result = use(view)
            
            self.push(view, with: reuseIdentifier)
            
            return result
        }
    }
}
