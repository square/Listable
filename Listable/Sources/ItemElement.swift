//
//  ItemElement.swift
//  Listable
//
//  Created by Kyle Van Essen on 8/10/19.
//


/**
 TODO
 */
public protocol ItemElement
{
    //
    // MARK: Content Of ItemElement
    //
    
    /**
     The content used to visually represent your element.
     
     See the documentation on `associatedtype Content : Equatable` for more.
     */
    var content : Content { get }
    
    /**
     The content which visually affects the appearance of your element.
     This includes things like titles, detail strings, images, control states (on, off, enabled, disabled), etc.
     
     Content is `Equatable` because the collection view uses it to determine when to update content, recalculate row sizes, etc.
     
     If you have a simple ItemElement type, `Content` could be a `String`.
     If you have a complex `ItemElement` type, `Content` will likely be a struct (eg, view model) conforming to Equatable:
     
     ```
     struct Podcast : Equatable
     {
        var identifier : UUID
     
        var episodeName : String
        var showName : String
     
        var length : TimeInterval
     
        var playStatus : PlayStatus
     
        enum PlayStatus : Equatable
        {
            case .notStarted
            case .inProgress(percent : CGFloat)
            case .done
        }
     }
     ```
     
     This struct should NOT include closures or other events triggered later, such as `onTap`.
     Store these fields directly on your ItemElement. This allows Equatability to be implemented automatically by the compiler:
     
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
    // MARK: Identification
    //
    
    /**
     Iidentifies the element across updates to the list. This value must remain the same,
     otherwise the element will be considered a new item, and the old one removed from the list.
     
     Does not have to be globally unique – the list will make a "best guess" if there are multiple elements
     with the same identifier. However, diffing of changes will be more correct with a unique identifier.
     
     If you're backing your element with some sort of client or server-provided data, consider using its
     server or client UUID here, or some other unique identifier from the underlying data model.
     */
    var identifier : Identifier<Self> { get }
    
    //
    // MARK: Converting To Views For Display
    //
    
    /**
     How the element should be rendered within the list view.
     
     You provide an instance of the Appearance when initializing the Item<Element> object.
     
     If you have multiple elements with similar or identical appearances,
     they should likely share an ItemElementAppearance to reduce code duplication.
     */
    associatedtype Appearance:ItemElementAppearance
    
    //
    // MARK: Applying To Displayed View
    //
        
    /**
     Called when rendering the element. This is where you should push data from your
     element into the passed in views.
     
     Do not retain a reference to the passed in views – they are reused by the list.
     */
    func apply(to view : Appearance.View, with state : ItemState, reason: ApplyReason)
    
    //
    // MARK: Tracking Changes
    //
    
    /**
     Return true if the element's sort changed based on the old value passed into the function.
     
     The list view uses the value of this method to be more intelligent about what has moved within the list.
     
     There is a default implementation of this method which checks the equality of `content`.
     */
    func wasMoved(comparedTo other : Self) -> Bool
    
    /**
     Return true if the element' changed based on the old value passed into the function.
     
     If this method returns true, the row representing the element is reloaded.
     
     There is a default implementation of this method which checks the equality of `content`.
     */
    func wasUpdated(comparedTo other : Self) -> Bool
}


public extension ItemElement
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


/**
 Represents how your ItemElement should be rendered on screen by the list.
 
 The appearance conforms to Equatable – this is so apply(to:) is only called
 when the appearance of an element changes, versus on each display.
 */
public protocol ItemElementAppearance
{
    //
    // MARK: Creating & Providing Views
    //
    
    /// The type of the content view of the element.
    /// The content view is drawn at the top of the view hierarchy, above everything else,
    associatedtype ContentView:UIView
    /// The background view displayed behind the content view of the element.
    associatedtype BackgroundView:UIView
    /// The selected background view, which is displayed when the element is selected.
    associatedtype SelectedBackgroundView:UIView
    
    /// A struct representing all the views of the element.
    typealias View = ItemElementView<ContentView, BackgroundView, SelectedBackgroundView>
    
    /**
     Create and return a new set of views to be used to render the element.
     
     These views are reused by the list view, similar to collection view or table view cell recycling.
     
     Do not do configuration in this method that will be changed by your app's theme or appearance – instead
     do that work in apply(to:), so the appearance will be updated if the appearance of elements changes.
     */
    static func createReusableItemView() -> View
    
    //
    // MARK: Updating View State
    //
    
    /**
     Called when the position of an element within a section changes.
     
     If you are drawing dividers or borders on cells, use this method as a change to update those borders or dividers.
     */
    func update(view : View, with position : ItemPosition)
    
    /**
     Called to apply the appearance to a given set of views before they are displayed on screen.
     
     Eg, this is where you would set fonts, spacing, colors, etc, to apply your app's theme.
     */
    func apply(to view : View, with state : ItemState, previous : Self?)
}


public final class ItemElementView<Content:UIView, Background:UIView, SelectedBackground:UIView> : UIView
{
    //
    // MARK: Public Properties
    //
    
    public let content : Content
    public let background : Background
    public let selectedBackground : SelectedBackground
    
    public var contentInset : UIEdgeInsets = .zero {
        didSet {
            guard oldValue != self.contentInset else { return }
            
            self.setNeedsLayout()
        }
    }
        
    //
    // MARK: Initialization
    //
    
    public init(content : Content, background : Background, selectedBackground : SelectedBackground)
    {
        self.content = content
        self.background = background
        self.selectedBackground = selectedBackground
                
        super.init(frame: .zero)
        
        self.addSubview(self.content)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
        
    //
    // MARK: UIView
    //
 
    public override func sizeThatFits(_ size: CGSize) -> CGSize
    {
        let insetWidth = size.width - (self.contentInset.left + self.contentInset.right)
        let fittedSize = self.content.sizeThatFits(.init(width: insetWidth, height: size.height))
        
        var totalHeight = fittedSize.height
        totalHeight += self.contentInset.top
        totalHeight += self.contentInset.bottom
        
        return CGSize(width: size.width, height: totalHeight)
    }
    
    public override func layoutSubviews()
    {
        self.content.frame = self.bounds.inset(by: self.contentInset)
    }
}

