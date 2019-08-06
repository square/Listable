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
    func leadingSwipeActionsConfiguration(onPerform : @escaping TableView.SwipeAction.OnPerform) -> UISwipeActionsConfiguration?

    @available(iOS 11.0, *)
    func trailingSwipeActionsConfiguration(onPerform : @escaping TableView.SwipeAction.OnPerform) -> UISwipeActionsConfiguration?
    
    func trailingTableViewRowActions(onPerform : @escaping TableView.SwipeAction.OnPerform) -> [UITableViewRowAction]?
    
    func newPresentationRow() -> TableViewPresentationStateRow
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
        
        func rowsUpTo(limit : Int) -> [TableViewRow]
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
    
    struct Row<Element:TableViewRowElement> : TableViewRow
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
        public func leadingSwipeActionsConfiguration(onPerform : @escaping SwipeAction.OnPerform) -> UISwipeActionsConfiguration?
        {
            return self.leadingActions?.toUISwipeActionsConfiguration(onPerform: onPerform)
        }
        
        @available(iOS 11.0, *)
        public func trailingSwipeActionsConfiguration(onPerform : @escaping SwipeAction.OnPerform) -> UISwipeActionsConfiguration?
        {
            return self.trailingActions?.toUISwipeActionsConfiguration(onPerform: onPerform)
        }
        
        public func trailingTableViewRowActions(onPerform : @escaping TableView.SwipeAction.OnPerform) -> [UITableViewRowAction]?
        {
            return self.trailingActions?.toUITableViewRowActions(onPerform: onPerform)
        }
        
        public func newPresentationRow() -> TableViewPresentationStateRow
        {
            return TableView.PresentationState.Row(self)
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
        internal func toUISwipeActionsConfiguration(onPerform : @escaping SwipeAction.OnPerform) -> UISwipeActionsConfiguration
        {
            let config = UISwipeActionsConfiguration(actions: self.actions.map {
                $0.toUIContextualAction(onPerform: onPerform)
            })
            
            config.performsFirstActionWithFullSwipe = self.performsFirstOnFullSwipe
            
            return config
        }
        
        internal func toUITableViewRowActions(onPerform : @escaping SwipeAction.OnPerform) -> [UITableViewRowAction]?
        {
            return self.actions.map {
                $0.toUITableViewRowAction(onPerform: onPerform)
            }
        }
    }
    
    struct SwipeAction
    {
        public typealias OnPerform = (Style) -> ()
        
        public var title: String?
        
        public var style: Style = .normal
        
        public var backgroundColor: UIColor?
        public var image: UIImage?
        
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
        internal func toUIContextualAction(onPerform : @escaping OnPerform) -> UIContextualAction
        {
            return UIContextualAction(
                style: self.style.toUIContextualActionStyle(),
                title: self.title,
                handler: { action, view, didComplete in
                    let completed = self.onTap(self)
                    
                    didComplete(completed)
                    
                    if completed {
                        onPerform(self.style)
                    }
            })
        }
        
        internal func toUITableViewRowAction(onPerform : @escaping OnPerform) -> UITableViewRowAction
        {
            return UITableViewRowAction(
                style: self.style.toUITableViewRowActionStyle(),
                title: self.title,
                handler: { _, _ in
                    let completed = self.onTap(self)
                    
                    if completed {
                        onPerform(self.style)
                    }
            })
        }
        
        public enum Style
        {
            case normal
            case destructive
            
            public var deletesRow : Bool {
                switch self {
                case .normal: return false
                case .destructive: return true
                }
            }
            
            @available(iOS 11.0, *)
            func toUIContextualActionStyle() -> UIContextualAction.Style
            {
                switch self {
                case .normal: return .normal
                case .destructive: return .destructive
                }
            }
            
            func toUITableViewRowActionStyle() -> UITableViewRowAction.Style
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
        public let refreshControl : RefreshControl?
        
        public let header : TableViewHeaderFooter?
        public let footer : TableViewHeaderFooter?
        
        public var sections : [TableView.Section]
        
        public var rowCount : Int {
            return self.sections.reduce(0, { $0 + $1.rows.count })
        }
        
        public init(
            refreshControl : RefreshControl? = nil,
            header : TableViewHeaderFooter? = nil,
            footer : TableViewHeaderFooter? = nil,
            sections : [TableView.Section] = []
            )
        {
            self.refreshControl = refreshControl
            
            self.header = header
            self.footer = footer
            
            self.sections = sections
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
        
        mutating func remove(at indexPath : IndexPath)
        {
            self.sections[indexPath.section].rows.remove(at: indexPath.row)
        }
        
        //
        // MARK: Slicing
        //
        
        struct Slice
        {
            static let defaultSize : Int = 250
            
            let containsAllRows : Bool
            var content : Content
            
            init(containsAllRows : Bool, content : Content)
            {
                self.containsAllRows = containsAllRows
                self.content = content
            }
            
            init()
            {
                self.containsAllRows = true
                self.content = Content(sections: [])
            }
            
            enum UpdateReason : Equatable
            {
                case scrolledDown
                case didEndDecelerating
                
                case scrolledToTop
                
                case contentChanged(animated : Bool)
                
                var diffsChanges : Bool {
                    /*
                     We only diff in the case of content change to avoid visual artifacts in the table view;
                     even with no animation type provided to batch update methods, the table view still moves
                     rows around in an animated manner.
                     */
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
            var sliced = self
            
            var remainingRowsCount : Int = additionalRows
            
            sliced.sections = self.sections.compactMapWithIndex { sectionIndex, section in
                if sectionIndex < indexPath.section {
                    return section
                } else {
                    if remainingRowsCount > 0 {
                        var section = section
                        section.rows = section.rowsUpTo(limit: remainingRowsCount)
                        remainingRowsCount -= section.rows.count
                        
                        return section
                    } else {
                        return nil
                    }
                }
            }
            
            print("Row Count: \(sliced.rowCount)")
            
            return Slice(
                containsAllRows: self.rowCount == sliced.rowCount,
                content: sliced
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

private extension Array
{
    func compactMapWithIndex<Mapped>(_ block : (Int, Element) -> Mapped?) -> [Mapped]
    {
        var mapped = [Mapped]()
        mapped.reserveCapacity(self.count)
        
        for (index, element) in self.enumerated() {
            if let value = block(index, element) {
                mapped.append(value)
            }
        }
        
        return mapped
    }
}
