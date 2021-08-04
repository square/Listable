//
//  HeaderFooterContent.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 8/10/19.
//


public typealias HeaderContent = HeaderFooterContent
public typealias FooterContent = HeaderFooterContent


///
/// A `HeaderFooterContent` is a type which specifies the content of a header, footer,
/// or other supplementary view within a listable list.
///
/// A non-tappable header that shows a label and icon might look like this (implementation of `MyHeaderView` left up to the reader):
/// ```
/// struct MyHeaderContent : HeaderFooterContent, Equatable
/// {
///     var title : String
///
///     static func createReusableContentView(frame : CGRect) -> MyHeaderView {
///         MyHeaderView(frame: frame)
///     }
///
///     func apply(to views : HeaderFooterContentViews<Self>, reason : ApplyReason) {
///         views.content.text = self.title
///         views.content.leftIcon = UIImage(named: "person_icon")
///     }
/// }
/// ```
/// The header is made `Equatable` in order to synthesize automatic conformance to `isEquivalent`,
/// based on the header's properties.
///
/// If you want to add support for rendering a background view and a pressed state, you should provide
/// both `createReusableBackgroundView` and `createReusablePressedBackgroundView` methods,
/// and apply the desired content in your `apply(to:)` method.
///
/// The ordering of the elements by z-index is as follows:
/// z-Index 3) `ContentView`
/// z-Index 2) `PressedBackgroundView` (Only if the header/footer is pressed, eg if the wrapping `HeaderFooter` has an `onTap` handler.)
/// z-Index 1) `BackgroundView`
///
public protocol HeaderFooterContent
{
    //
    // MARK: Tracking Changes
    //
    
    func isEquivalent(to other : Self) -> Bool
    
    //
    // MARK: Default Properties
    //
    
    typealias DefaultProperties = DefaultHeaderFooterProperties<Self>
    
    /// Default values to assign to various properties on the `HeaderFooter` which wraps
    /// this `HeaderFooterContent`, if those values are not passed to the `HeaderFooter` initializer.
    var defaultHeaderFooterProperties : DefaultProperties { get }
    
    //
    // MARK: Applying To Displayed View
    //
    
    func apply(
        to views : HeaderFooterContentViews<Self>,
        for reason : ApplyReason,
        with info : ApplyHeaderFooterContentInfo
    )
    
    ///
    /// Called to prepare the view for reuse, when it is about to be recycled, ahead of
    /// being reused to display another `HeaderFooterContent` in the list.
    ///
    /// If you need to unwire any callbacks, or stop animations; you should do so in this method.
    ///
    func prepareViewsForReuse(_ views : HeaderFooterContentViews<Self>)
    
    //
    // MARK: Creating & Providing Content Views
    //
    
    /// The content view used to draw the content.
    /// The content view is drawn at the top of the view hierarchy, above the background views.
    associatedtype ContentView:UIView
    

    /// Create and return a new content view used to render the content.
    ///
    /// Note
    /// ----
    /// Do not do configuration in this method that will be changed by your view's theme or appearance – instead
    /// do that work in `apply(to:)`, so the appearance will be updated if the appearance of content changes.
    static func createReusableContentView(frame : CGRect) -> ContentView
    
    //
    // MARK: Creating & Providing Background Views
    //
    
    /// The background view used to draw the background of the content.
    /// The background view is drawn below the content view.
    ///
    /// Note
    /// ----
    /// Defaults to a `UIView` with no drawn appearance or state.
    /// You do not need to provide this `typealias` unless you would like
    /// to draw a background view.
    ///
    associatedtype BackgroundView:UIView = UIView
    
    /// Create and return a new background view used to render the content's background.
    ///
    /// Note
    /// ----
    /// Do not do configuration in this method that will be changed by your view's theme or appearance – instead
    /// do that work in `apply(to:)`, so the appearance will be updated if the appearance of content changes.
    static func createReusableBackgroundView(frame : CGRect) -> BackgroundView
    
    /// The selected background view used to draw the background of the content when it is selected or highlighted.
    /// The selected background view is drawn below the content view.
    ///
    /// Note
    /// ----
    /// Defaults to a `UIView` with no drawn appearance or state.
    /// You do not need to provide this `typealias` unless you would like
    /// to draw a selected background view.
    ///
    associatedtype PressedBackgroundView:UIView = UIView
    
    /// Create and return a new background view used to render the content's pressed background.
    ///
    /// This view is displayed when the user taps/presses the header / footer.
    ///
    /// If your `BackgroundView` and `SelectedBackgroundView` are the same type, this method
    /// is provided automatically by calling `createReusableBackgroundView`.
    ///
    /// Note
    /// ----
    /// Do not do configuration in this method that will be changed by your view's theme or appearance – instead
    /// do that work in `apply(to:)`, so the appearance will be updated if the appearance of content changes.
    static func createReusablePressedBackgroundView(frame : CGRect) -> PressedBackgroundView
}


/// Information about the current state of the content, which is passed to `apply(to:for:with:)`
/// during configuration and preparation for display.
///
/// TODO: Rename to `ApplyHeaderFooterContext`
public struct ApplyHeaderFooterContentInfo
{
    /// The environment of the containing list.
    /// See `ListEnvironment` for usage information.
    public var environment : ListEnvironment
}


/// The views owned by the item content, passed to the `apply(to:) method to theme and provide content.`
public struct HeaderFooterContentViews<Content:HeaderFooterContent>
{
    /// The content view of the content.
    public var content : Content.ContentView
    
    /// The background view of the content.
    public var background : Content.BackgroundView
    
    /// The background view of the content that's displayed while a press is active.
    public var pressed : Content.PressedBackgroundView
    
    init(view : HeaderFooterContentView<Content>) {
        self.content = view.content
        self.background = view.background
        self.pressed = view.pressedBackground
    }
}


public extension HeaderFooterContent {
    
    func prepareViewsForReuse(_ views : HeaderFooterContentViews<Self>) {
        // Default implementation does nothing.
    }
}

///
/// If your `HeaderFooterContent` is `Equatable`, you do not need to provide an `isEquivalent` method.
/// This default implementation will be provided for you.
///
public extension HeaderFooterContent where Self:Equatable
{    
    func isEquivalent(to other : Self) -> Bool
    {
        return self == other
    }
}


public extension HeaderFooterContent where Self.BackgroundView == UIView
{
    static func createReusableBackgroundView(frame : CGRect) -> BackgroundView
    {
        BackgroundView(frame: frame)
    }
}


public extension HeaderFooterContent where Self.PressedBackgroundView == UIView
{
    static func createReusablePressedBackgroundView(frame : CGRect) -> PressedBackgroundView
    {
        PressedBackgroundView(frame: frame)
    }
}


/// Provide a default implementation of `defaultHeaderFooterProperties` which returns an
/// empty instance that does not provide any defaults.
public extension HeaderFooterContent
{
    var defaultHeaderFooterProperties : DefaultProperties {
        .init()
    }
}
