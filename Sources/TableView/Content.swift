//
//  Elements.swift
//  CheckoutApplet
//
//  Created by Kyle Van Essen on 6/21/19.
//

import Foundation


public protocol TableViewHeaderFooter : TableViewHeaderFooter_Internal
{
}

public protocol TableViewHeaderFooter_Internal
{
    func heightWith(width : CGFloat, default defaultHeight : CGFloat, measurementCache : ReusableViewCache) -> CGFloat
    
    func dequeueView(in tableView: UITableView) -> UITableViewHeaderFooterView
    
    func applyTo(headerFooterView : UITableViewHeaderFooterView, reason: ApplyReason)
    
    func updatedComparedTo(old : TableViewHeaderFooter) -> Bool
    func movedComparedTo(old : TableViewHeaderFooter) -> Bool
}

public protocol TableViewRow : TableViewRow_Internal
{
    var identifier : AnyIdentifier { get }
    
    func elementEqual(to other : TableViewRow) -> Bool
}

public protocol TableViewRow_Internal
{
    func heightWith(width : CGFloat, default defaultHeight : CGFloat, measurementCache : ReusableViewCache) -> CGFloat
    
    func dequeueCell(in tableView: UITableView) -> UITableViewCell
    
    func performOnTap()
    
    func updatedComparedTo(old : TableViewRow) -> Bool
    var updateStrategy : UpdateStrategy { get }
    
    func movedComparedTo(old : TableViewRow) -> Bool
    
    @available(iOS 11.0, *)
    var leadingSwipeActionsConfiguration : UISwipeActionsConfiguration? { get }
    
    @available(iOS 11.0, *)
    var trailingSwipeActionsConfiguration : UISwipeActionsConfiguration? { get }
    
    var swipeToDeleteType : TableView.SwipeToDelete { get }
    
    func newPresentationContainer() -> TableViewPresentationStateRow
}

public extension TableView
{
    struct Section
    {
        public let identifier : AnyHashable
        
        public var header : TableViewHeaderFooter?
        public var footer : TableViewHeaderFooter?
        
        public var rows : [TableViewRow]
        
        public init(
            header headerString: String,
            footer footerString: String? = nil,
            content contentBuilder : (inout SectionBuilder) -> ()
            )
        {
            var builder = SectionBuilder()
            
            contentBuilder(&builder)
            
            var footer : TableViewHeaderFooter?
            
            if let footerString = footerString {
                footer = TableView.HeaderFooter(footerString)
            }
            
            self.init(
                identifier: footerString,
                header: TableView.HeaderFooter(headerString),
                footer: footer,
                rows: builder.rows
            )
        }
        
        public init<Identifier:Hashable>(
            identifier : Identifier,
            header : TableViewHeaderFooter? = nil,
            footer : TableViewHeaderFooter? = nil,
            content contentBuilder : (inout SectionBuilder) -> ()
            )
        {
            var builder = SectionBuilder()
            
            contentBuilder(&builder)
            
            self.init(
                identifier: identifier,
                header: header,
                footer: footer,
                rows: builder.rows
            )
        }
        
        public init<Header:TableViewHeaderFooterElement>(
            header : TableView.HeaderFooter<Header>,
            footer : TableViewHeaderFooter? = nil,
            content contentBuilder : (inout SectionBuilder) -> ()
            )
        {
            var builder = SectionBuilder()
            
            contentBuilder(&builder)
            
            self.init(
                identifier: header.element.identifier,
                header: header,
                footer: footer,
                rows: builder.rows
            )
        }
        
        public init<Identifier:Hashable>(
            identifier : Identifier,
            header : TableViewHeaderFooter? = nil,
            footer : TableViewHeaderFooter? = nil,
            rows : [TableViewRow] = []
            )
        {
            self.identifier = AnyHashable(identifier)
            
            self.header = header
            self.footer = footer
            
            self.rows = rows
        }
        
        // MARK: TableViewSection
        
        public func updatedComparedTo(old : TableView.Section) -> Bool
        {
            let headerChanged = TableView.headerFooterChanged(self.header, old.header, { $0.updatedComparedTo(old: $1) })
            let footerChanged = TableView.headerFooterChanged(self.footer, old.footer, { $0.updatedComparedTo(old: $1) })
            
            return headerChanged || footerChanged
        }
        
        public func movedComparedTo(old : TableView.Section) -> Bool
        {
            let headerChanged = TableView.headerFooterChanged(self.header, old.header, { $0.movedComparedTo(old: $1) })
            let footerChanged = TableView.headerFooterChanged(self.footer, old.footer, { $0.movedComparedTo(old: $1) })
            
            return headerChanged || footerChanged
        }
        
        // MARK: Slicing
        
        func rowSlice(limit : Int) -> [TableViewRow]
        {
            let end = min(self.rows.count, limit)
            
            return Array(self.rows[0..<end])
        }
    }
    
    
    struct HeaderFooter<Element:TableViewHeaderFooterElement> : TableViewHeaderFooter
    {
        public var element : Element
        public var sizing : AxisSizing
        
        private let reuseIdentifier : ReuseIdentifier<Element>
        
        // MARK: Initialization
        
        public init(_ element : Element, sizing : AxisSizing = .default)
        {
            self.element = element
            self.sizing = sizing
            
            self.reuseIdentifier = ReuseIdentifier.identifier(for: self.element)
        }
        
        // MARK: TableViewHeaderFooter
        
        public func heightWith(width : CGFloat, default defaultHeight : CGFloat, measurementCache : ReusableViewCache) -> CGFloat
        {
            return measurementCache.use(with: self.reuseIdentifier, create: { Element.createReusableHeaderFooterView(with: self.reuseIdentifier) }) { view in
                self.element.applyTo(headerFooterView: view, reason: .willDisplay)
                
                return self.sizing.height(with: view, fittingWidth: width, default: defaultHeight)
            }
        }
        
        public func applyTo(headerFooterView : UITableViewHeaderFooterView, reason : ApplyReason)
        {
            guard let view = headerFooterView as? Element.HeaderFooterView else {
                return
            }
            
            self.element.applyTo(headerFooterView: view, reason: reason)
        }
        
        public func dequeueView(in tableView: UITableView) -> UITableViewHeaderFooterView
        {
            let view : Element.HeaderFooterView = {
                if let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: self.reuseIdentifier.stringValue) {
                    return view as! Element.HeaderFooterView
                } else {
                    return Element.createReusableHeaderFooterView(with: self.reuseIdentifier)
                }
            }()
            
            self.element.applyTo(headerFooterView: view, reason: .willDisplay)
            
            return view
        }
        
        public func updatedComparedTo(old : TableViewHeaderFooter) -> Bool
        {
            guard let old = old as? HeaderFooter<Element> else {
                return true
            }
            
            return self.element.wasUpdated(comparedTo: old.element)
        }
        
        public func movedComparedTo(old : TableViewHeaderFooter) -> Bool
        {
            guard let old = old as? HeaderFooter<Element> else {
                return true
            }
            
            return self.element.wasMoved(comparedTo: old.element)
        }
    }
    
    fileprivate class Reference<Value>
    {
        var value : Value
        
        init(_ value : Value)
        {
            self.value = value
        }
    }
    
    struct Row<Element:TableViewCellElement> : TableViewRow
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
        
        // MARK: TableViewRow
        
        public func elementEqual(to other : TableViewRow) -> Bool
        {
            guard let other = other as? TableView.Row<Element> else {
                return false
            }
            
            return self.elementEqual(to: other)
        }
        
        internal func elementEqual(to other : TableView.Row<Element>) -> Bool
        {
            return false
        }
        
        // MARK: TableViewRow_Internal
        
        public func heightWith(width : CGFloat, default defaultHeight : CGFloat, measurementCache : ReusableViewCache) -> CGFloat
        {
            return self.element.measureCell(with: self.sizing, width: width, defaultHeight: defaultHeight, in: measurementCache)
        }
        
        public func dequeueCell(in tableView: UITableView) -> UITableViewCell
        {
            let cell = self.element.cellForDisplay(in: tableView)
            
            self.element.applyTo(cell: cell, reason: .willDisplay)
            self.configuration.apply(to: cell)
            
            return cell
        }
        
        public func performOnTap()
        {
            self.onTap?(self.element)
        }
        
        public func updatedComparedTo(old : TableViewRow) -> Bool
        {
            guard let old = old as? TableView.Row<Element> else {
                return true
            }
            
            return self.element.wasUpdated(comparedTo: old.element)
        }
        
        public var updateStrategy : UpdateStrategy {
            return self.element.updateStrategy
        }
        
        public func movedComparedTo(old : TableViewRow) -> Bool
        {
            guard let old = old as? TableView.Row<Element> else {
                return true
            }
            
            return self.element.wasMoved(comparedTo: old.element)
        }
        
        @available(iOS 11.0, *)
        public var leadingSwipeActionsConfiguration : UISwipeActionsConfiguration? {
            return self.leadingActions?.toUISwipeActionsConfiguration()
        }
        
        @available(iOS 11.0, *)
        public var trailingSwipeActionsConfiguration : UISwipeActionsConfiguration? {
            return self.trailingActions?.toUISwipeActionsConfiguration()
        }
        
        public var swipeToDeleteType : TableView.SwipeToDelete
        {
            guard let action = self.trailingActions?.firstDestructiveAction else {
                return .none
            }
            
            if let title = action.title {
                return .custom(title)
            } else {
                return .standard
            }
        }
        
        public func newPresentationContainer() -> TableViewPresentationStateRow
        {
            return TableView.PresentationState.Row(row: self)
        }
    }
    
    fileprivate static func headerFooterChanged(
        _ lhs : TableViewHeaderFooter?,
        _ rhs : TableViewHeaderFooter?,
        _ compare : (TableViewHeaderFooter, TableViewHeaderFooter) -> Bool
        ) -> Bool
    {
        if let lhs = lhs, let rhs = rhs {
            return compare(lhs, rhs)
        } else {
            if lhs != nil && rhs == nil {
                return true
            } else if lhs == nil && rhs != nil {
                return true
            } else {
                return false
            }
        }
    }
}

fileprivate extension TableView.Row where Element:Equatable
{
    func elementEqual(to other : TableView.Row<Element>) -> Bool
    {
        return self.element == other.element
    }
}

public extension TableView
{
    enum SwipeToDelete : Equatable
    {
        case none
        case standard
        case custom(String)
    }
    
    struct SwipeActions
    {
        public var actions : [SwipeAction]
        
        public var performsFirstOnFullSwipe : Bool
        
        public var firstDestructiveAction : SwipeAction? {
            return self.actions.first {
                $0.style == .destructive
            }
        }
        
        public init(_ action : SwipeAction, performsFirstOnFullSwipe : Bool = false)
        {
            self.init([action], performsFirstOnFullSwipe: performsFirstOnFullSwipe)
        }
        
        public init(_ actions : [SwipeAction], performsFirstOnFullSwipe : Bool = false)
        {
            self.actions = actions
            
            self.performsFirstOnFullSwipe = performsFirstOnFullSwipe
        }
        
        @available(iOS 11.0, *)
        internal func toUISwipeActionsConfiguration() -> UISwipeActionsConfiguration
        {
            let config = UISwipeActionsConfiguration(actions: self.actions.map { $0.toUIContextualAction() })
            
            config.performsFirstActionWithFullSwipe = self.performsFirstOnFullSwipe
            
            return config
        }
    }
    
    struct SwipeAction
    {
        public var title: String?
        
        public var style: Style = .normal
        
        public var backgroundColor: UIColor?
        public var image: UIImage?
        
        // TODO: Need to figure out how to pass through the element here...
        public typealias OnTap = (SwipeAction) -> Bool
        public var onTap : OnTap
        
        public init(title: String?, style: Style = .normal, backgroundColor: UIColor? = nil, image: UIImage? = nil, onTap : @escaping OnTap)
        {
            self.title = title
            self.style = style
            self.backgroundColor = backgroundColor
            self.image = image
            self.onTap = onTap
        }
        
        @available(iOS 11.0, *)
        internal func toUIContextualAction() -> UIContextualAction
        {
            let action = UIContextualAction(
                style: self.style.toUIContextualActionStyle(),
                title: self.title,
                handler: { action, view, didComplete in
                    let success = self.onTap(self)
                    didComplete(success)
            })
            
            return action
        }
        
        public enum Style
        {
            case normal
            case destructive
            
            @available(iOS 11.0, *)
            func toUIContextualActionStyle() -> UIContextualAction.Style
            {
                switch self {
                case .normal: return .normal
                case .destructive: return .destructive
                }
            }
        }
    }
}


public extension TableView
{
    struct Content
    {
        public let header : TableViewHeaderFooter?
        public let footer : TableViewHeaderFooter?
        
        public let sections : [TableView.Section]
        
        let rowCount : Int
        
        public init(header : TableViewHeaderFooter? = nil, footer : TableViewHeaderFooter? = nil, sections : [TableView.Section])
        {
            self.header = header
            self.footer = footer
            
            self.sections = sections
            
            self.rowCount = self.sections.reduce(0, { $0 + $1.rows.count })
        }
        
        public func row(at indexPath : IndexPath) -> TableViewRow
        {
            let section = self.sections[indexPath.section]
            let row = section.rows[indexPath.row]
            
            return row
        }
        
        public func indexPath(for identifier : AnyIdentifier) -> IndexPath?
        {
            return self.row(for: identifier)?.indexPath
        }
        
        func row(for identifier : AnyIdentifier) -> (indexPath:IndexPath, row:TableViewRow)?
        {
            for (sectionIndex, section) in self.sections.enumerated() {
                for (rowIndex, row) in section.rows.enumerated() {
                    if row.identifier == identifier {
                        return (IndexPath(row: rowIndex, section: sectionIndex), row)
                    }
                }
            }
            
            return nil
        }
        
        
        //
        // MARK: Slicing
        //
        
        
        struct Slice
        {
            let truncatedBottom : Bool
            let content : Content
            
            init(truncatedBottom : Bool, content : Content)
            {
                self.truncatedBottom = truncatedBottom
                self.content = content
            }
            
            init()
            {
                self.truncatedBottom = true
                self.content = Content(sections: [])
            }
            
            enum UpdateReason : Equatable
            {
                case scrolledDown
                case didEndDecelerating
                
                case scrolledToTop
                
                case contentChanged(animated : Bool)
                
                // TODO: Remove
                var diffsChanges : Bool {
                    switch self {
                    case .scrolledDown: return false
                    case .didEndDecelerating: return false
                    case .scrolledToTop: return false
                        
                    case .contentChanged(_): return true
                    }
                }
                
                var animated : Bool {
                    switch self {
                    case .scrolledDown: return false
                    case .didEndDecelerating: return false
                    case .scrolledToTop: return false
                        
                    case .contentChanged(let animated): return animated
                    }
                }
            }
        }
        
        internal func sliceUpTo(indexPath : IndexPath, plus additionalRows : Int) -> Slice
        {
            guard self.sections.count > 0 else {
                return Slice(
                    truncatedBottom: true,
                    content: Content(sections: [])
                )
            }
            
            // TOOD: Bail early if we're smaller than the requested size.
            
            let previousSections = Array(self.sections[0..<indexPath.section])
            let section = self.sections[indexPath.section]
            let laterSections = Array(self.sections[indexPath.section+1..<self.sections.count])
            
            let limit = indexPath.row + additionalRows
            let displayRows = section.rowSlice(limit: limit)
            
            var remainingNextRowCount = limit - displayRows.count
            
            let displaySection = Section(identifier:section.identifier, header: section.header, footer: section.footer, rows: displayRows)
            
            let nextDisplaySections : [TableView.Section] = laterSections.compactMap { section in
                if remainingNextRowCount <= 0 {
                    return nil
                }
                
                let rows = section.rowSlice(limit: remainingNextRowCount)
                remainingNextRowCount -= rows.count
                
                return Section(identifier:section.identifier, header: section.header, footer: section.footer, rows: rows)
            }
            
            var displaySections = [TableView.Section]()
            
            displaySections += previousSections
            displaySections.append(displaySection)
            displaySections += nextDisplaySections
            
            return Slice(
                truncatedBottom: remainingNextRowCount > 0,
                content: Content(
                    header: self.header,
                    footer: self.footer,
                    sections: displaySections
                )
            )
        }
    }
}


public extension TableView.Content
{
    func elementsEqual(to other : TableView.Content) -> Bool
    {
        if self.sections.count != other.sections.count {
            return false
        }
        
        let sections = zip(self.sections, other.sections)
        
        return sections.allSatisfy { both in
            both.0.elementsEqual(to: both.1)
        }
    }
}

public extension TableView.Section
{
    func elementsEqual(to other : TableView.Section) -> Bool
    {
        if self.rows.count != other.rows.count {
            return false
        }
        
        return self.rows.elementsEqual(to: other.rows)
    }
}

public extension Array where Element == TableViewRow
{
    func elementsEqual(to other : [TableViewRow]) -> Bool
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

