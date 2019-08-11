//
//  Row.swift
//  ListableTableView
//
//  Created by Kyle Van Essen on 8/10/19.
//

import ListableCore


public protocol AnyRow : AnyRow_Internal
{
    var identifier : AnyIdentifier { get }
    
    func elementEqual(to other : AnyRow) -> Bool
}


public protocol AnyRow_Internal
{
    func heightWith(width : CGFloat, default defaultHeight : CGFloat, measurementCache : ReusableViewCache) -> CGFloat
    
    func dequeueCell(in tableView: UITableView) -> UITableViewCell
    
    func performOnTap()
    
    func updatedComparedTo(old : AnyRow) -> Bool
    var updateStrategy : UpdateStrategy { get }
    
    func movedComparedTo(old : AnyRow) -> Bool
    
    @available(iOS 11.0, *)
    func leadingSwipeActionsConfiguration(onPerform : @escaping SwipeAction.OnPerform) -> UISwipeActionsConfiguration?
    
    @available(iOS 11.0, *)
    func trailingSwipeActionsConfiguration(onPerform : @escaping SwipeAction.OnPerform) -> UISwipeActionsConfiguration?
    
    func trailingTableViewRowActions(onPerform : @escaping SwipeAction.OnPerform) -> [UITableViewRowAction]?
    
    func newPresentationContainer() -> PresentationStateRowState
}

public struct Row<Element:RowElement> : AnyRow
{
    public var identifier : AnyIdentifier
    
    public var element : Element
    
    public var sizing : AxisSizing
    
    public var configuration : CellConfiguration
    
    public var leadingActions : SwipeActions?
    public var trailingActions : SwipeActions?
    
    public typealias OnTap = (Element) -> ()
    public var onTap : OnTap?
    
    public typealias OnDisplay = (Element) -> ()
    public var onDisplay : OnDisplay?
    
    private let reuseIdentifier : ReuseIdentifier<Element>
    
    public typealias CreateBinding = (Element) -> Binding<Element>
    internal let bind : CreateBinding?
    
    public init(
        _ element : Element,
        sizing : AxisSizing = .default,
        configuration : CellConfiguration = .default,
        leadingActions : SwipeActions? = nil,
        trailingActions : SwipeActions? = nil,
        bind : CreateBinding? = nil,
        onDisplay : OnDisplay? = nil,
        onTap : OnTap? = nil
        )
    {
        self.element = element
        
        self.reuseIdentifier = ReuseIdentifier.identifier(for: self.element)
        
        self.identifier = AnyIdentifier(element.identifier)
        
        self.sizing = sizing
        
        self.configuration = configuration
        
        self.leadingActions = leadingActions
        self.trailingActions = trailingActions
        
        self.bind = bind
        
        self.onDisplay = onDisplay
        
        if onTap == nil {
            self.configuration.selectionStyle = .none
        }
        
        self.onTap = onTap
    }
    
    // MARK: AnyRow
    
    public func elementEqual(to other : AnyRow) -> Bool
    {
        guard let other = other as? Row<Element> else {
            return false
        }
        
        return self.elementEqual(to: other)
    }
    
    internal func elementEqual(to other : Row<Element>) -> Bool
    {
        return false
    }
    
    // MARK: AnyRow_Internal
    
    public func heightWith(width : CGFloat, default defaultHeight : CGFloat, measurementCache : ReusableViewCache) -> CGFloat
    {
        return self.element.measureCell(with: self.sizing, width: width, defaultHeight: defaultHeight, in: measurementCache)
    }
    
    public func dequeueCell(in tableView: UITableView) -> UITableViewCell
    {
        let cell = self.element.cellForDisplay(in: tableView)
        
        self.element.apply(to: cell, reason: .willDisplay)
        self.configuration.apply(to: cell)
        
        return cell
    }
    
    public func performOnTap()
    {
        self.onTap?(self.element)
    }
    
    public func updatedComparedTo(old : AnyRow) -> Bool
    {
        guard let old = old as? Row<Element> else {
            return true
        }
        
        return self.element.wasUpdated(comparedTo: old.element)
    }
    
    public var updateStrategy : UpdateStrategy {
        return self.element.updateStrategy
    }
    
    public func movedComparedTo(old : AnyRow) -> Bool
    {
        guard let old = old as? Row<Element> else {
            return true
        }
        
        return self.element.wasMoved(comparedTo: old.element)
    }
    
    @available(iOS 11.0, *)
    public func leadingSwipeActionsConfiguration(onPerform : @escaping SwipeAction.OnPerform) -> UISwipeActionsConfiguration?
    {
        return self.leadingActions?.toUISwipeActionsConfiguration(onPerform: onPerform)
    }
    
    @available(iOS 11.0, *)
    public func trailingSwipeActionsConfiguration(onPerform : @escaping SwipeAction.OnPerform) -> UISwipeActionsConfiguration?
    {
        return self.trailingActions?.toUISwipeActionsConfiguration(onPerform: onPerform)
    }
    
    public func trailingTableViewRowActions(onPerform : @escaping SwipeAction.OnPerform) -> [UITableViewRowAction]?
    {
        return self.trailingActions?.toUITableViewRowActions(onPerform: onPerform)
    }
    
    public func newPresentationContainer() -> PresentationStateRowState
    {
        return PresentationState.RowState(self)
    }
}


public struct CellConfiguration
{
    public static var `default` : CellConfiguration {
        return CellConfiguration()
    }
    
    public init() {}
    
    public var accessoryType : UITableViewCell.AccessoryType = .none
    public var selectionStyle : UITableViewCell.SelectionStyle = .default
    
    public func apply(to cell : UITableViewCell)
    {
        cell.accessoryType = self.accessoryType
        cell.selectionStyle = self.selectionStyle
    }
}


public extension Row where Element:Equatable
{
    func elementEqual(to other : Row<Element>) -> Bool
    {
        return self.element == other.element
    }
}


public extension Array where Element == AnyRow
{
    func elementsEqual(to other : [AnyRow]) -> Bool
    {
        if self.count != other.count {
            return false
        }
        
        let rows = zip(self, other)
        
        return rows.allSatisfy { both in
            both.0.elementEqual(to: both.1)
        }
    }
}
