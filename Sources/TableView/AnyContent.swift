//
//  AnyContent.swift
//  Listable
//
//  Created by Kyle Van Essen on 7/22/19.
//

import Foundation


/*
 An experiment to see if we can move the table view content types not be type erased by default.
 Instead, if we can make type erased boxes work, those can be used by those who want heterogeneous content.
 */
public struct AnyTableViewCellElement : TableViewCellElement
{
    public let base : Any
    
    public init<Element:TableViewCellElement>(_ element : Element)
    {
        self.base = element
        self.box = Box(element: element)
    }
    
    private let box : AnyTableViewCellElementBox
    
    private struct Box<Element:TableViewCellElement> : AnyTableViewCellElementBox
    {
        let element : Element
        
        // MARK: AnyTableViewCellElementBox
        
        var anyIdentifier: AnyIdentifier {
            return .init(self.element.identifier)
        }
        
        // MARK: TableViewCellElement - Type Erased Methods
        
        func anyWasMoved(comparedTo other : Any) -> Bool
        {
            guard let other = other as? AnyTableViewCellElement else { fatalError() }
            guard let box = other.box as? Box else { fatalError() }
            
            return self.element.wasMoved(comparedTo: box.element)
        }
        
        func anyWasUpdated(comparedTo other : Any) -> Bool
        {
            guard let other = other as? AnyTableViewCellElement else { fatalError() }
            guard let box = other.box as? Box else { fatalError() }
            
            return self.element.wasUpdated(comparedTo: box.element)
        }
        
        func anyApplyTo(cell : UITableViewCell, reason: ApplyReason)
        {
            guard let cell = cell as? Element.TableViewCell else { fatalError() }
            
            self.element.applyTo(cell: cell, reason: reason)
        }
        
        var anyUpdateStrategy : UpdateStrategy {
            return self.element.updateStrategy
        }
        
        func anyCreateReusableCell() -> UITableViewCell
        {
            return self.element.createReusableCell(with: ReuseIdentifier<Element>())
        }
        
        func anyCellForDisplay(in tableView: UITableView) -> UITableViewCell
        {
            return self.element.cellForDisplay(in: tableView)
        }
        
        func anyMeasureCell(
            with sizing : AxisSizing,
            width : CGFloat,
            defaultHeight : CGFloat,
            in measurementCache : ReusableViewCache
            ) -> CGFloat
        {
            return self.element.measureCell(with: sizing, width: width, defaultHeight: defaultHeight, in: measurementCache)
        }
    }
    
    // MARK: TableViewCellElement
    
    public typealias TableViewCell = UITableViewCell
    
    public var identifier : Identifier<AnyTableViewCellElement> {
        return .init(self.box.anyIdentifier)
    }
    
    public func wasMoved(comparedTo other : AnyTableViewCellElement) -> Bool
    {
        return self.box.anyWasMoved(comparedTo: other)
    }
    
    public func wasUpdated(comparedTo other : AnyTableViewCellElement) -> Bool
    {
        return self.box.anyWasUpdated(comparedTo: other)
    }
    
    public func applyTo(cell : TableViewCell, reason: ApplyReason)
    {
        self.box.anyApplyTo(cell: cell, reason: reason)
    }
    
    public var updateStrategy : UpdateStrategy {
        return self.box.anyUpdateStrategy
    }
    
    public func createReusableCell(with reuseIdentifier : ReuseIdentifier<AnyTableViewCellElement>) -> TableViewCell
    {
        return self.box.anyCreateReusableCell()
    }
    
    public func cellForDisplay(in tableView: UITableView) -> TableViewCell
    {
        return self.box.anyCellForDisplay(in: tableView)
    }
    
    public func measureCell(
        with sizing : AxisSizing,
        width : CGFloat,
        defaultHeight : CGFloat,
        in measurementCache : ReusableViewCache
        ) -> CGFloat
    {
        return self.box.anyMeasureCell(with: sizing, width: width, defaultHeight: defaultHeight, in: measurementCache)
    }
}

private protocol AnyTableViewCellElementBox
{
    var anyIdentifier : AnyIdentifier { get }
    
    func anyWasMoved(comparedTo other : Any) -> Bool
    
    func anyWasUpdated(comparedTo other : Any) -> Bool
    
    func anyApplyTo(cell : UITableViewCell, reason: ApplyReason)
    
    var anyUpdateStrategy : UpdateStrategy { get }
    
    func anyCreateReusableCell() -> UITableViewCell
    
    func anyCellForDisplay(in tableView: UITableView) -> UITableViewCell
    
    func anyMeasureCell(
        with sizing : AxisSizing,
        width : CGFloat,
        defaultHeight : CGFloat,
        in measurementCache : ReusableViewCache
        ) -> CGFloat
}
