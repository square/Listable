//
//  Views.swift
//  CheckoutApplet
//
//  Created by Kyle Van Essen on 6/21/19.
//

import Foundation


public enum UpdateStrategy : Hashable
{
    case reload
    case apply
}


public enum ApplyReason : Hashable
{
    case willDisplay
    case wasUpdated
    
    var animated : Bool {
        switch self {
        case .willDisplay: return false
        case .wasUpdated: return true
        }
    }
}

// TODO: TableViewRowElement?
public protocol TableViewCellElement
{
    // MARK: Identifying Content & Changes
    
    var identifier : Identifier<Self> { get }
    
    func wasMoved(comparedTo other : Self) -> Bool
    func wasUpdated(comparedTo other : Self) -> Bool
    
    // MARK: Applying To Displayed Cell
    
    func applyTo(cell : TableViewCell, reason : ApplyReason)
    
    var updateStrategy : UpdateStrategy { get }
    
    // MARK: Converting To Cell For Display
    
    associatedtype TableViewCell:UITableViewCell
    
    //var reuseIdentifier : ReuseIdentifier<Self> { get }
    
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

public extension TableViewCellElement
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
            self.applyTo(cell: cell, reason: .willDisplay)
            return sizing.height(with: cell, fittingWidth: width, default: defaultHeight)
        }
    }
}

public extension TableViewCellElement where Self:Equatable
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

public protocol TableViewCellViewElement : TableViewCellElement where TableViewCell == TableView.ElementCell<Self>
{
    // MARK: Converting To View For Display
    
    associatedtype View:UIView
    
    static func createReusableView() -> View
    
    func applyTo(view : View, reason : ApplyReason)
}

public extension TableViewCellViewElement
{
    static func createReusableCell(with reuseIdentifier : ReuseIdentifier<Self>) -> TableView.ElementCell<Self>
    {
        return TableView.ElementCell(
            view: Self.createReusableView(),
            style: UITableViewCell.CellStyle.default,
            reuseIdentifier: reuseIdentifier.stringValue
        )
    }
    
    func applyTo(cell : TableView.ElementCell<Self>, reason : ApplyReason)
    {
        self.applyTo(view: cell.view, reason: reason)
    }
}

public protocol TableViewHeaderFooterElement
{
    // MARK: Identifying Content & Changes
    
    var identifier : Identifier<Self> { get }
    
    func wasMoved(comparedTo other : Self) -> Bool
    func wasUpdated(comparedTo other : Self) -> Bool
    
    // MARK: Applying To Displayed View
    
    func applyTo(headerFooterView : HeaderFooterView, reason : ApplyReason)
    
    // MARK: Converting To View For Display
    
    associatedtype HeaderFooterView:UITableViewHeaderFooterView
    
    static func createReusableHeaderFooterView(with reuseIdentifier : ReuseIdentifier<Self>) -> HeaderFooterView
}

public extension TableViewHeaderFooterElement where Self:Equatable
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

public protocol TableViewHeaderFooterViewElement : TableViewHeaderFooterElement where HeaderFooterView == TableView.ElementHeaderFooterView<Self>
{
    associatedtype View:UIView
    
    static func createReusableView() -> View
    
    func applyTo(view : View, reason : ApplyReason)
}

public extension TableViewHeaderFooterViewElement
{
    static func createReusableHeaderFooterView(with reuseIdentifier : ReuseIdentifier<Self>) -> TableView.ElementHeaderFooterView<Self>
    {
        return TableView.ElementHeaderFooterView(
            view:Self.createReusableView(),
            reuseIdentifier: reuseIdentifier.stringValue
        )
    }
    
    func applyTo(headerFooter : TableView.ElementHeaderFooterView<Self>, reason : ApplyReason)
    {
        self.applyTo(view: headerFooter.view, reason: reason)
    }
}


public extension TableView
{    
    final class ElementHeaderFooterView<Element:TableViewHeaderFooterViewElement> : UITableViewHeaderFooterView
    {
        var view : Element.View
        
        public init(view : Element.View, reuseIdentifier: String)
        {
            self.view = view
            
            super.init(reuseIdentifier: reuseIdentifier)
            
            self.view.frame = self.contentView.bounds
            self.contentView.addSubview(self.view)
        }
        
        @available(*, unavailable)
        override public init(reuseIdentifier: String?) {
            fatalError()
        }
        
        @available(*, unavailable)
        required init?(coder aDecoder: NSCoder) {
            fatalError()
        }
        
        // MARK: UIView
        
        public override func layoutSubviews()
        {
            super.layoutSubviews()
            
            self.view.frame = self.contentView.bounds
        }
        
        public override func sizeThatFits(_ size: CGSize) -> CGSize
        {
            let viewSize = CGSize(width: self.view.bounds.size.width, height: size.height)
            
            return view.sizeThatFits(viewSize)
        }
        
        public override func systemLayoutSizeFitting(
            _ targetSize: CGSize,
            withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
            verticalFittingPriority: UILayoutPriority
            ) -> CGSize
        {
            let viewSize = CGSize(width: self.view.bounds.size.width, height: targetSize.height)
            
            return view.systemLayoutSizeFitting(
                viewSize,
                withHorizontalFittingPriority: horizontalFittingPriority,
                verticalFittingPriority: verticalFittingPriority
            )
        }
    }
    
    
    final class ElementCell<Element:TableViewCellViewElement> : UITableViewCell
    {
        var view : Element.View
        
        public init(view : Element.View, style: UITableViewCell.CellStyle, reuseIdentifier: String)
        {
            self.view = view
            
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            self.view.frame = self.contentView.bounds
            self.contentView.addSubview(self.view)
        }
        
        @available(*, unavailable)
        override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            fatalError()
        }
        
        @available(*, unavailable)
        required init?(coder aDecoder: NSCoder) {
            fatalError()
        }
        
        // MARK: UIView
        
        public override func layoutSubviews()
        {
            super.layoutSubviews()
            
            self.view.frame = self.contentView.bounds
        }
        
        public override func sizeThatFits(_ size: CGSize) -> CGSize
        {
            let viewSize = CGSize(width: self.view.bounds.size.width, height: size.height)
            
            return view.sizeThatFits(viewSize)
        }
        
        public override func systemLayoutSizeFitting(
            _ targetSize: CGSize,
            withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
            verticalFittingPriority: UILayoutPriority
            ) -> CGSize
        {
            let viewSize = CGSize(width: self.view.bounds.size.width, height: targetSize.height)
            
            return view.systemLayoutSizeFitting(
                viewSize,
                withHorizontalFittingPriority: horizontalFittingPriority,
                verticalFittingPriority: verticalFittingPriority
            )
        }
    }
}
