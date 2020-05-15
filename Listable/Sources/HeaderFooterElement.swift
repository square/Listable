//
//  HeaderFooterElement.swift
//  Listable
//
//  Created by Kyle Van Essen on 8/10/19.
//


public protocol HeaderFooterElement
{    
    //
    // MARK: Applying To Displayed View
    //
    
    func apply(to view : ContentView, reason : ApplyReason)
    
    //
    // MARK: Tracking Changes
    //
    
    func isEquivalent(to other : Self) -> Bool
    
    //
    // MARK: Creating & Providing Views
    //
    
    associatedtype ContentView:UIView
    
    static func createReusableHeaderFooterView(frame : CGRect) -> ContentView
}


///
/// If your `HeaderFooterElement` is `Equatable`, you do not need to provide an `isEquivalent` method.
/// This default implementation will be provided for you.
///
public extension HeaderFooterElement where Self:Equatable
{    
    func isEquivalent(to other : Self) -> Bool
    {
        return self == other
    }
}
