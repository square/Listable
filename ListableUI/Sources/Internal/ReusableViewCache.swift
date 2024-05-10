//
//  ReusableViewCache.swift
//  CheckoutApplet
//
//  Created by Kyle Van Essen on 6/21/19.
//

import Foundation


final class ReusableViewCache
{
    private var views : [AnyHashable:[AnyObject]] = [:]
    
    func count<Content>(for reuseIdentifier : ReuseIdentifier<Content>) -> Int
    {
        let views = self.views[reuseIdentifier, default: []]

        return views.count
    }
    
    func push<Content,View:AnyObject>(_ view : View, with reuseIdentifier: ReuseIdentifier<Content>)
    {
        var views = self.views[reuseIdentifier, default: []]
        
        listableInternalPrecondition(views.contains { $0 === view } == false, "Cannot push a view which is already in the cache.")
        
        views.append(view)
        
        self.views[reuseIdentifier] = views
    }
    
    func pop<Content,View:AnyObject>(with reuseIdentifier: ReuseIdentifier<Content>, _ create : () -> View) -> View
    {
        var views = self.views[reuseIdentifier, default: []]
        
        if let view = views.popLast() {
            self.views[reuseIdentifier] = views
            return view as! View
        } else {
            return create()
        }
    }
    
    func use<Content,View:AnyObject, Result>(with reuseIdentifier: ReuseIdentifier<Content>, create : () -> View, _ use : (View) -> Result) -> Result
    {
        let views = self.views[reuseIdentifier, default: []]
        
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
