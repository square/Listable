//
//  RowViewElement.swift
//  ListableTableView
//
//  Created by Kyle Van Essen on 8/10/19.
//

import ListableCore


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
