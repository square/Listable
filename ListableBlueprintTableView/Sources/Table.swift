//
//  Table.swift
//  Pods
//
//  Created by Kyle Van Essen on 8/26/19.
//

import BlueprintUI

import ListableCore
import ListableTableView


public struct BlueprintRow : RowViewElement
{
    public var element : Element
    
    public init<Identifier:Hashable>(identifier : Identifier, _ element : Element)
    {
        self.identifier = ListableCore.Identifier(identifier)
        
        self.element = element
    }
    
    // MARK: RowViewElement
    
    public typealias View = BlueprintView
    
    public static func createReusableView() -> BlueprintView
    {
        return BlueprintView()
    }
    
    public func apply(to view: BlueprintView, reason: ApplyReason)
    {
        view.element = self.element
    }
    
    // MARK: RowElement
    
    public var identifier: Identifier<BlueprintRow>
    
    public func wasMoved(comparedTo other: BlueprintRow) -> Bool
    {
        return false
    }
    
    public func wasUpdated(comparedTo other: BlueprintRow) -> Bool
    {
        return false
    }
}


public struct Table<Source:TableViewSource> : Element
{
    public var initialSource : Source
    public var initialState : Source.State
    
    public var style : UITableView.Style
    
    // MARK: Element
    
    public var content: ElementContent {
        return ElementContent(layout: TableLayout())
    }
    
    public func backingViewDescription(bounds: CGRect, subtreeExtent: CGRect?) -> ViewDescription?
    {
        return TableView.describe { config in
            config.builder = {
                let view = TableView(style: self.style)
                view.setSource(initial: self.initialState, source: self.initialSource)
                return view
            }
        }
    }
    
    struct TableLayout : Layout
    {
        func measure(in constraint: SizeConstraint, items: [(traits: (), content: Measurable)]) -> CGSize
        {
            return constraint.maximum
        }
        
        func layout(size: CGSize, items: [(traits: (), content: Measurable)]) -> [LayoutAttributes]
        {
            return []
        }
    }
}


public extension Table where Source == StaticSource
{
    init(style : UITableView.Style, _ builder : (inout ContentBuilder) -> ())
    {
        self.style = style
        
        self.initialSource = StaticSource(with: builder)
        self.initialState = StaticSource.State()
    }
}
