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
    
    func isEquivalent(to other : Self) -> Bool
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

///
/// Note
/// ----
/// This extension is provided alongside the `extension HeaderFooterElement where Self:Equatable`
/// extension, to avoid ambiguous conformance issues from the swift compiler.
///
public extension HeaderFooterElement where Self:Equatable, Self:HeaderFooterElementAppearance
{
    func isEquivalent(to other : Self) -> Bool
    {
        return self == other
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
    
    func isEquivalent(to other : Self) -> Bool
}


///
/// If your `HeaderFooterElementAppearance` is `Equatable`, you do not need to provide an `isEquivalent` method.
/// This default implementation will be provided for you.
///
public extension HeaderFooterElementAppearance where Self:Equatable
{
    func isEquivalent(to other : Self) -> Bool
    {
        return self == other
    }
}
