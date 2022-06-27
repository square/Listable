//
//  SwiftUIContentView.swift
//  SwiftUILists
//
//  Created by Kyle Van Essen on 5/31/20.
//

import SwiftUI


@available(iOS 13.0, *)
public final class SwiftUIContentView : UIView, ListContentView
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
    
    public override init(frame: CGRect)
    {
        self.controller = UIHostingController(rootView: AnyView(EmptyView()))

        super.init(frame: frame)
        
        self.addSubview(self.controller.view)
        
        self.backgroundColor = .clear
        self.isOpaque = false
        
        self.controller.view.backgroundColor = .clear
        self.controller.view.isOpaque = false
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: UIView
    
    public override func layoutSubviews()
    {
        super.layoutSubviews()
        
        self.controller.view.frame = self.bounds
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize
    {
        /// TODO: Return to `.view`?
        self.controller.sizeThatFits(in: size)
    }
    
    // MARK: ListContentView
    
    private weak var containingViewController : UIViewController? = nil
    
    public func setContainingViewController(_ viewController : UIViewController) {
        
        guard containingViewController == nil else { fatalError() }
        
        self.containingViewController = viewController
        
        viewController.addChild(self.controller)
        self.controller.didMove(toParent: viewController)
    }
    
    private var visibility = Visibility()
    
    public func willDisplay()
    {
        assertContainingViewController()
        
        visibility.isContentVisible = true
        
        if visibility.wantsAppearanceTransition {
            controller.beginAppearanceTransition(true, animated: false)
            controller.endAppearanceTransition()
        }
    }
    
    public func didEndDisplay() {
                
        if visibility.wantsAppearanceTransition {
            controller.beginAppearanceTransition(false, animated: false)
            controller.endAppearanceTransition()
        }
        
        visibility.isContentVisible = false
        
        fatalError()
    }
    
    public func listWillAppear(animated : Bool)
    {
        visibility.isListVisible = true
        
        if visibility.wantsAppearanceTransition {
            visibility.isInAppearanceTransition = true
            controller.beginAppearanceTransition(true, animated: animated)
        }
    }
    
    public func listWillDisappear(animated : Bool)
    {
        if visibility.wantsAppearanceTransition {
            visibility.isInAppearanceTransition = true
            controller.beginAppearanceTransition(false, animated: animated)
        }
        
        visibility.isListVisible = false
    }
    
    public func listEndedAppearanceTransition() {
        guard visibility.isInAppearanceTransition else { return }

        visibility.isInAppearanceTransition = false
        controller.endAppearanceTransition()
    }
    
    private func assertContainingViewController() {
        
        guard self.containingViewController == nil else {
            return
        }
        
        fatalError(
            """
            The `containingViewController` was not set on `SwiftUIContentView` before it was about \
            to be presented. This will break embedded view controllers in SwiftUI view trees. \
            This property is normally set automatically by Listable. If you are allocating \
            this view manually, set the `containingViewController` property manually.
            """
        )
    }
}


struct Visibility {
    
    var isListVisible : Bool = false
    var isContentVisible : Bool = false
    
    var isInAppearanceTransition : Bool = false
    
    var wantsAppearanceTransition : Bool {
        isListVisible && isContentVisible
    }
}
