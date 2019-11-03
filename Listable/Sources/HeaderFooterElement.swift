//
//  HeaderFooterElement.swift
//  Listable
//
//  Created by Kyle Van Essen on 8/10/19.
//


public protocol HeaderFooterElement
{
    //
    // MARK: Identifying Content & Changes
    //
        
    func wasMoved(comparedTo other : Self) -> Bool
    func wasUpdated(comparedTo other : Self) -> Bool
    
    //
    // MARK: Converting To View For Display
    //
    
    associatedtype Appearance:HeaderFooterElementAppearance
    
    //
    // MARK: Applying To Displayed View
    //
    
    func apply(to view : Appearance.View, reason : ApplyReason)
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


public protocol HeaderFooterElementAppearance
{
    //
    // MARK: Creating & Providing Views
    //
    
    associatedtype ContentView:UIView
    associatedtype BackgroundView:UIView
    
    typealias View = HeaderFooterElementView<ContentView, BackgroundView>
    
    static func createReusableHeaderFooterView() -> View
    
    //
    // MARK: Updating View State
    //
    
    func apply(to view : View, previous : Self?)
}


public final class HeaderFooterElementView<Content:UIView, Background:UIView> : UIView
{
    //
    // MARK: Public Properties
    //
    
    public let content : Content
    public let background : Background
    
    public var contentInset : UIEdgeInsets = .zero {
        didSet {
            guard oldValue != self.contentInset else {
                return
            }
            
            self.setNeedsLayout()
        }
    }
    
    //
    // MARK: Initialization
    //
    
    public init(content : Content, background : Background)
    {
        self.content = content
        self.background = background
        
        super.init(frame: .zero)
        
        self.addSubview(self.background)
        self.addSubview(self.content)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    //
    // MARK: UIView
    //
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize
    {
        let fittingWidth = size.width - (self.contentInset.left + self.contentInset.right)
        
        let fittedSize = self.content.sizeThatFits(.init(width: fittingWidth, height: size.height))
        
        var totalSize = fittedSize
        totalSize.height += self.contentInset.top
        totalSize.height += self.contentInset.bottom
        
        return fittedSize
    }
    
    public override func layoutSubviews()
    {
        self.background.frame = self.bounds
        
        self.content.frame = self.bounds.inset(by: self.contentInset)
    }
}
