//
//  Views.swift
//  CheckoutApplet
//
//  Created by Kyle Van Essen on 6/21/19.
//

import UIKit
import ListableCore



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

public protocol RowViewElement : RowElement where TableViewCell == ElementCell<Self>
{
    // MARK: Converting To View For Display
    
    associatedtype View:UIView
    
    static func createReusableView() -> View
    
    func apply(to view : View, reason : ApplyReason)
}

public extension RowViewElement
{
    static func createReusableCell(with reuseIdentifier : ReuseIdentifier<Self>) -> ElementCell<Self>
    {
        return ElementCell(
            view: Self.createReusableView(),
            style: UITableViewCell.CellStyle.default,
            reuseIdentifier: reuseIdentifier.stringValue
        )
    }
    
    func apply(to cell : ElementCell<Self>, reason : ApplyReason)
    {
        self.apply(to: cell.view, reason: reason)
    }
}

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

public protocol HeaderFooterViewElement : HeaderFooterElement where HeaderFooterView == ElementHeaderFooterView<Self>
{
    associatedtype View:UIView
    
    static func createReusableView() -> View
    
    func apply(to view : View, reason : ApplyReason)
}

public extension HeaderFooterViewElement
{
    static func createReusableHeaderFooterView(with reuseIdentifier : ReuseIdentifier<Self>) -> ElementHeaderFooterView<Self>
    {
        return ElementHeaderFooterView(
            view:Self.createReusableView(),
            reuseIdentifier: reuseIdentifier.stringValue
        )
    }
    
    func applyTo(headerFooter : ElementHeaderFooterView<Self>, reason : ApplyReason)
    {
        self.apply(to: headerFooter.view, reason: reason)
    }
}


public final class ElementHeaderFooterView<Element:HeaderFooterViewElement> : UITableViewHeaderFooterView
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


public final class ElementCell<Element:RowViewElement> : UITableViewCell
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
