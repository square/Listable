//
//  HeaderFooterElement.swift
//  ListableTableView
//
//  Created by Kyle Van Essen on 8/10/19.
//

import ListableCore


public protocol HeaderFooterElement
{
    // MARK: Identifying Content & Changes
    
    var identifier : Identifier<Self> { get }
    
    func wasMoved(comparedTo other : Self) -> Bool
    func wasUpdated(comparedTo other : Self) -> Bool
    
    // MARK: Applying To Displayed View
    
    func apply(to headerFooterView : HeaderFooterView, reason : ApplyReason)
    
    // MARK: Converting To View For Display
    
    associatedtype HeaderFooterView:UITableViewHeaderFooterView
    
    static func createReusableHeaderFooterView(with reuseIdentifier : ReuseIdentifier<Self>) -> HeaderFooterView
}


public extension HeaderFooterElement where Self:Equatable
{
    func wasMoved(comparedTo other : Self) -> Bool
    {
        return self != other
    }
    
    func wasUpdated(comparedTo other : Self) -> Bool
    {
        return self != other
    }
}
