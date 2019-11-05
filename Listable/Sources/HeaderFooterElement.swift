//
//  HeaderFooterElement.swift
//  Listable
//
//  Created by Kyle Van Essen on 8/10/19.
//


public protocol HeaderFooterElement
{
    //
    // MARK: Content Of HeaderFooterElement
    //
    
    /**
     The content used to visually represent your header/footer.
     
     See the documentation on `associatedtype Content : Equatable` for more.
     */
    var content : Content { get }
    
    /**
     The content which visually affects the appearance of your header/footer.
     This includes things like titles, detail strings, images, etc.
     
     Content is `Equatable` because the collection view uses it to determine when to update content, recalculate header/footer sizes, etc.
     
     If you have a simple HeaderFooterElement type, `Content` could be a `String`.
     If you have a complex `HeaderFooterElement` type, `Content` will likely be a struct (eg, view model) conforming to Equatable:
     
     ```
     struct TVSeason : Equatable
     {
        var name : String
     
        var start : Date
        var end : Date
     
        var icon : UIImage
     }
     ```
     
     This struct should NOT include closures or other events triggered later, such as `onTap`.
     Store these fields directly on your HeaderFooterElement. This allows Equatability to be implemented automatically by the compiler:
     
     ```
     struct PodcastRow : ItemElement
     {
        var content : Podcast
     
        var onTap : (Podcast) -> ()
     }
     ```
     */
    associatedtype Content : Equatable
    
    //
    // MARK: Converting To View For Display
    //
    
    associatedtype Appearance:HeaderFooterElementAppearance
    
    //
    // MARK: Applying To Displayed View
    //
    
    func apply(to view : Appearance.View, reason : ApplyReason)
    
    //
    // MARK: Tracking Changes
    //
    
    func wasMoved(comparedTo other : Self) -> Bool
    func wasUpdated(comparedTo other : Self) -> Bool
}


public extension HeaderFooterElement
{
    func wasMoved(comparedTo other : Self) -> Bool
    {
        return self.content != other.content
    }
    
    func wasUpdated(comparedTo other : Self) -> Bool
    {
        return self.content != other.content
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
