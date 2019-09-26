//
//  HeaderFooterViewElement.swift
//  ListableTableView
//
//  Created by Kyle Van Essen on 8/10/19.
//

import ListableCore


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

    func apply(to headerFooterView: ElementHeaderFooterView<Self>, reason: ApplyReason) {
        self.apply(to: headerFooterView.view, reason: reason)
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
