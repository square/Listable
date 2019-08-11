//
//  RowElement.swift
//  ListableTableView
//
//  Created by Kyle Van Essen on 8/10/19.
//

import ListableCore


public protocol RowElement
{
    // MARK: Identifying Content & Changes
    
    var identifier : Identifier<Self> { get }
    
    func wasMoved(comparedTo other : Self) -> Bool
    func wasUpdated(comparedTo other : Self) -> Bool
    
    // MARK: Applying To Displayed Cell
    
    func apply(to cell : TableViewCell, reason : ApplyReason)
    
    var updateStrategy : UpdateStrategy { get }
    
    // MARK: Converting To Cell For Display
    
    associatedtype TableViewCell:UITableViewCell
    
    static func createReusableCell(with reuseIdentifier : ReuseIdentifier<Self>) -> TableViewCell
    
    // MARK: Dequeuing & Rendering
    
    func cellForDisplay(in tableView: UITableView) -> TableViewCell
    
    func measureCell(
        with sizing : AxisSizing,
        width : CGFloat,
        defaultHeight : CGFloat,
        in measurementCache : ReusableViewCache
        ) -> CGFloat
}

public extension RowElement
{
    // MARK: Applying To Displayed Cell
    
    var updateStrategy : UpdateStrategy {
        return .reload
    }
    
    // MARK: Dequeuing & Rendering
    
    func cellForDisplay(in tableView: UITableView) -> TableViewCell
    {
        let reuseIdentifier = ReuseIdentifier.identifier(for: self)
        
        let cell : TableViewCell = {
            if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier.stringValue) {
                return cell as! TableViewCell
            } else {
                return Self.createReusableCell(with: reuseIdentifier)
            }
        }()
        
        return cell
    }
    
    func measureCell(
        with sizing : AxisSizing,
        width : CGFloat,
        defaultHeight : CGFloat,
        in measurementCache : ReusableViewCache
        ) -> CGFloat
    {
        let reuseIdentifier = ReuseIdentifier.identifier(for: self)
        
        return measurementCache.use(with: reuseIdentifier, create: { Self.createReusableCell(with: reuseIdentifier) }) { cell in
            self.apply(to: cell, reason: .willDisplay)
            return sizing.height(with: cell, fittingWidth: width, default: defaultHeight)
        }
    }
}

public extension RowElement where Self:Equatable
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
