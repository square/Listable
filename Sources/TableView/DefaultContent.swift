//
//  DefaultContent.swift
//  CheckoutApplet
//
//  Created by Kyle Van Essen on 6/21/19.
//

import Foundation


public struct DefaultHeaderFooter : TableViewHeaderFooterElement, Equatable
{
    var text : String
        
    public typealias HeaderFooterView = UITableViewHeaderFooterView
    
    public var identifier: Identifier<DefaultHeaderFooter> {
        return .init(self.text.count > 0 ? self.text : "EmptyIdentifier")
    }
    
    public static func createReusableHeaderFooterView(with reuseIdentifier: ReuseIdentifier<DefaultHeaderFooter>) -> UITableViewHeaderFooterView
    {
        return UITableViewHeaderFooterView(reuseIdentifier: reuseIdentifier.stringValue)
    }
    
    public func applyTo(headerFooterView: UITableViewHeaderFooterView, reason: ApplyReason)
    {
        headerFooterView.textLabel?.text = self.text
    }
}


public final class ViewInstance<View:UIView> : TableViewRowElement, Equatable
{
    public typealias TableViewCell = ViewRowTableViewCell
    
    public let view : View
    
    private let cell : ViewRowTableViewCell
    
    public init(view : View)
    {
        self.view = view
        self.cell = ViewRowTableViewCell(view: self.view)
    }
    
    // MARK: TableViewRowElement
    
    public func applyTo(cell: ViewInstance<View>.ViewRowTableViewCell, reason: ApplyReason)
    {
        // No Op
    }
    
    public var identifier: Identifier<ViewInstance<View>> {
        return .init(ObjectIdentifier(self.view))
    }
    
    public static func createReusableCell(with reuseIdentifier: ReuseIdentifier<ViewInstance<View>>) -> ViewRowTableViewCell
    {
        fatalError()
    }
    
    // TODO: Is this right? Do we need to always return the same cell? Or is the view sufficient?
    // If the view is sufficient and the cells are reused, then cellForDisplay can be made private like it is for header/footers.
    public func cellForDisplay(in tableView: UITableView) -> ViewRowTableViewCell
    {
        return self.cell
    }
    
    public func measureCell(
        with sizing: AxisSizing,
        width: CGFloat,
        defaultHeight: CGFloat,
        in measurementCache: ReusableViewCache
        ) -> CGFloat
    {
        return sizing.height(with: self.cell, fittingWidth: width, default: defaultHeight)
    }
    
    // MARK: Equatable
    
    public static func == (lhs : ViewInstance, rhs : ViewInstance) -> Bool
    {
        return lhs.view == rhs.view
    }
    
    public final class ViewRowTableViewCell : UITableViewCell
    {
        var view : View
        
        public init(view : View)
        {
            self.view = view
            
            super.init(style: .default, reuseIdentifier: nil)
            
            self.view.frame = self.contentView.bounds
            self.contentView.addSubview(self.view)
        }
        
        @available(*, unavailable)
        required init?(coder aDecoder: NSCoder) {
            fatalError()
        }
        
        public override func layoutSubviews()
        {
            super.layoutSubviews()
            
            self.view.frame = self.contentView.bounds
        }
    }
}

public struct SubtitleRow : TableViewRowElement, Equatable
{
    var text : String
    var textLineCount : Int
    
    var detail : String
    var detailLineCount : Int
    
    public init(text : String, textLineCount : Int = 1, detail : String, detailLineCount : Int = 1)
    {
        self.text = text
        self.textLineCount = textLineCount
        
        self.detail = detail
        self.detailLineCount = detailLineCount
    }
    
    // MARK: TableViewRowElement
    
    public typealias TableViewCell = UITableViewCell
    
    public var identifier: Identifier<SubtitleRow> {
        return .init(self.text.count > 0 ? self.text : "EmptyIdentifier")
    }
    
    public static func createReusableCell(with reuseIdentifier: ReuseIdentifier<SubtitleRow>) -> UITableViewCell
    {
        return UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier.stringValue)
    }
    
    public func applyTo(cell: UITableViewCell, reason: ApplyReason)
    {
        cell.textLabel?.numberOfLines = self.textLineCount
        cell.textLabel?.text = self.text
        
        cell.detailTextLabel?.numberOfLines = self.detailLineCount
        cell.detailTextLabel?.text = self.detail
    }
}

public struct DefaultRow : TableViewRowElement, Equatable
{
    var text : String
    var lineCount : Int
    
    public init(text : String, lineCount : Int = 1)
    {
        self.text = text
        self.lineCount = lineCount
    }
    
    // MARK: TableViewRowElement
    
    public typealias TableViewCell = UITableViewCell
    
    public var identifier: Identifier<DefaultRow> {
        return .init(self.text.count > 0 ? self.text : "EmptyIdentifier")
    }
    
    public static func createReusableCell(with reuseIdentifier: ReuseIdentifier<DefaultRow>) -> UITableViewCell
    {
        return UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier.stringValue)
    }
    
    public func applyTo(cell: UITableViewCell, reason : ApplyReason)
    {
        cell.textLabel?.numberOfLines = self.lineCount
        cell.textLabel?.text = self.text
    }
}

extension String : TableViewRowElement, TableViewHeaderFooterElement
{
    // MARK: TableViewRowElement
    
    public typealias Cell = UITableViewCell
    
    public var identifier: Identifier<String> {
        return .init(self)
    }
    
    public static func createReusableCell(with reuseIdentifier: ReuseIdentifier<String>) -> UITableViewCell
    {
        return UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier.stringValue)
    }
    
    public func applyTo(cell: UITableViewCell, reason: ApplyReason)
    {
        cell.textLabel?.text = self
    }
    
    // TableViewHeaderFooterElement
    
    public typealias HeaderFooterView = UITableViewHeaderFooterView
    
    public static func createReusableHeaderFooterView(with reuseIdentifier: ReuseIdentifier<String>) -> UITableViewHeaderFooterView
    {
        return UITableViewHeaderFooterView(reuseIdentifier: reuseIdentifier.stringValue)
    }
    
    public func applyTo(headerFooterView: UITableViewHeaderFooterView, reason: ApplyReason)
    {
        headerFooterView.textLabel?.text = self
    }
    
    public func wasMoved(comparedTo other : String) -> Bool
    {
        return self != other
    }
    
    public func wasUpdated(comparedTo other : String) -> Bool
    {
        return self != other
    }
}
