//
//  HeaderFooterContent.swift
//  Listable
//
//  Created by Kyle Van Essen on 8/10/19.
//


public typealias HeaderContent = HeaderFooterContent
public typealias FooterContent = HeaderFooterContent


public protocol HeaderFooterContent
{    
    //
    // MARK: Applying To Displayed View
    //
    
    func apply(to views : HeaderFooterContentViews<Self>, reason : ApplyReason)
    
    //
    // MARK: Default Header / Footer Properties
    //
    
    /// Default values to assign to various properties on the `Item` which wraps
    /// this `ItemContent`, if those values are not passed to the `Item` initializer.
    var defaultProperties : DefaultHeaderFooterProperties<Self> { get }
    
    //
    // MARK: Tracking Changes
    //
    
    func isEquivalent(to other : Self) -> Bool
    
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
    associatedtype PressedBackgroundView:UIView = BackgroundView
    
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


/// The views owned by the item content, passed to the `apply(to:) method to theme and provide content.`
public struct HeaderFooterContentViews<Content:HeaderFooterContent>
{
    /// The content view of the content.
    public var content : Content.ContentView
    
    /// The background view of the content.
    public var background : Content.BackgroundView
    
    /// The background view of the content that's displayed while a press is active.
    public var pressed : Content.PressedBackgroundView
}


/// Provide a default implementation of `defaultProperties` which returns an
/// empty instance that does not provide any defaults.
public extension HeaderFooterContent {
    
    var defaultProperties : DefaultHeaderFooterProperties<Self> {
        .init()
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

public extension HeaderFooterContent where Self.PressedBackgroundView == BackgroundView
{
    static func createReusablePressedBackgroundView(frame : CGRect) -> PressedBackgroundView
    {
        self.createReusableBackgroundView(frame: frame)
    }
}
