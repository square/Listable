//
//  HeaderFooterElement.swift
//  Listable
//
//  Created by Kyle Van Essen on 8/10/19.
//


public protocol HeaderFooterElement
{
    //
    // MARK: Converting To View For Display
    //
    
    associatedtype Appearance:HeaderFooterElementAppearance
    
    //
    // MARK: Applying To Displayed View
    //
    
    func apply(to view : Appearance.ContentView, reason : ApplyReason)
    
    //
    // MARK: Tracking Changes
    //
    
    func wasUpdated(comparedTo other : Self) -> Bool
}


public extension HeaderFooterElement where Self:Equatable
{    
    func wasUpdated(comparedTo other : Self) -> Bool
    {
        return self != other
    }
}


public protocol HeaderFooterElementAppearance
{
    //
    // MARK: Creating & Providing Views
    //
    
    associatedtype ContentView:UIView
    
    static func createReusableHeaderFooterView(frame : CGRect) -> ContentView
    
    //
    // MARK: Updating View State
    //
    
    func apply(to view : ContentView)
    
    //
    // MARK: Tracking Changes
    //
    
    func wasUpdated(comparedTo other : Self) -> Bool
}


public extension HeaderFooterElementAppearance where Self:Equatable
{
    func wasUpdated(comparedTo other : Self) -> Bool
    {
        return self != other
    }
}
