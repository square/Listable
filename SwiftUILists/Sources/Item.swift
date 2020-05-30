//
//  Item.swift
//  SwiftUILists
//
//  Created by Kyle Van Essen on 10/22/19.
//

import Listable
import SwiftUI


//
// MARK: SwiftUI Elements
//

///
/// An `ItemContent` specialized for use with SwiftUI. Instead of providing
/// a custom view from `createReusableContentView`, and then updating it in `apply(to:)`,
/// you instead provide SwiftUI view trees, and `Listable` handles mapping this to an underlying `BlueprintView`.
///
@available(iOS 13.0, *)
public protocol SwiftUIItemContent : ItemContent
    where
    ContentView == SwiftUIContentView,
    BackgroundView == SwiftUIContentView,
    SelectedBackgroundView == SwiftUIContentView
{
    //
    // MARK: Creating SwiftUI View Representations
    //
    
    associatedtype ContentType : SwiftUI.View

    /// Required. Create and return the Blueprint element used to represent the content.
    ///
    /// You can use the provided `ApplyItemContentInfo` to vary the appearance of the element
    /// based on the current state of the item.
    ///
    func content(with info : ApplyItemContentInfo) -> ContentType
    
    associatedtype BackgroundType : SwiftUI.View = EmptyView

    /// Optional. Create and return the Blueprint element used to represent the background of the content.
    /// You usually provide this method alongside `selectedBackgroundElement`, if your content
    /// supports selection or highlighting.
    ///
    /// You can use the provided `ApplyItemContentInfo` to vary the appearance of the element
    /// based on the current state of the item.
    ///
    /// Note
    /// ----
    /// The default implementation of this method returns nil, and provides no background.
    ///
    func background(with info : ApplyItemContentInfo) -> BackgroundType?
    
    associatedtype SelectedBackgroundType : SwiftUI.View = EmptyView

    /// Optional. Create and return the Blueprint element used to represent the background of the content when it is selected or highlighted.
    /// You usually provide this method alongside `backgroundElement`, if your content supports selection or highlighting.
    ///
    /// You can use the provided `ApplyItemContentInfo` to vary the appearance of the element
    /// based on the current state of the item.
    ///
    /// Note
    /// ----
    /// The default implementation of this method returns nil, and provides no selected background.
    ///
    func selectedBackground(with info : ApplyItemContentInfo) -> SelectedBackgroundType?
}


@available(iOS 13.0, *)
public extension SwiftUIItemContent
{
    //
    // MARK: Default Implementations
    //

    /// By default, content has no background.
    func background(with info : ApplyItemContentInfo) -> BackgroundType?
    {
        nil
    }

    /// By default, content has no selected background.
    func selectedBackground(with info : ApplyItemContentInfo) -> SelectedBackgroundType?
    {
        nil
    }
}


@available(iOS 13.0, *)
public extension SwiftUIItemContent
{
    //
    // MARK: ItemContent
    //

    /// Maps the `BlueprintItemContent` methods into the underlying `BlueprintView`s used to render the element.
    func apply(to views : ItemContentViews<Self>, for reason: ApplyReason, with info : ApplyItemContentInfo)
    {
        views.content.rootView = AnyView(self.content(with: info))
        views.background.rootView = AnyView(self.background(with: info))
        views.selectedBackground.rootView = AnyView(self.selectedBackground(with: info))
    }

    /// Creates the view used to render the content of the item.
    static func createReusableContentView(frame: CGRect) -> ContentView
    {
        let view = SwiftUIContentView(frame: frame)
        view.backgroundColor = .clear

        return view
    }

    /// Creates the view used to render the background of the item.
    static func createReusableBackgroundView(frame: CGRect) -> BackgroundView
    {
        let view = SwiftUIContentView(frame: frame)
        view.backgroundColor = .clear

        return view
    }
    
    /// Creates the view used to render the background of the item.
    static func createReusableSelectedBackgroundView(frame: CGRect) -> SelectedBackgroundView
    {
        let view = SwiftUIContentView(frame: frame)
        view.backgroundColor = .clear

        return view
    }
}


@available(iOS 13.0, *)
public final class SwiftUIContentView : UIView, CollectionViewContainedView
{
    var rootView : AnyView {
        get {
            self.controller.rootView
        }
        set {
            self.controller.rootView = newValue
        }
    }
    
    private let controller : UIHostingController<AnyView>
    
    public func containerViewWillMove(toSuperview newSuperview: UIView?)
    {
        if let superview = newSuperview {
            let parent = superview.findParentListableViewController()!
            
            parent.addChild(self.controller)
            self.controller.didMove(toParent: parent)
            self.addSubview(self.controller.view)
            print("")
        } else {
            self.controller.willMove(toParent: nil)
            self.controller.removeFromParent()
        }
    }
    
    public override init(frame: CGRect)
    {
        self.controller = UIHostingController(rootView: AnyView(EmptyView()))

        super.init(frame: frame)
        
        
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    public override func layoutSubviews()
    {
        super.layoutSubviews()
        
        self.controller.view.frame = self.bounds
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize
    {
        return self.controller.view.sizeThatFits(size)
    }
}
