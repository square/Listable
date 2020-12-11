//
//  HeaderFooterContentView.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 8/11/20.
//

import UIKit


final class HeaderFooterContentView<Content:HeaderFooterContent> : UIView
{
    //
    // MARK: Properties
    //
    
    typealias OnTap = () -> ()
    
    var onTap : OnTap? = nil {
        didSet { self.updateIsTappable() }
    }
    
    let content : Content.ContentView
    let background : Content.BackgroundView
    let pressedBackground : Content.PressedBackgroundView
    
    private let pressRecognizer : PressGestureRecognizer
    
    //
    // MARK: Initialization
    //
    
    override init(frame: CGRect) {
        
        let bounds = CGRect(origin: .zero, size: frame.size)
        
        self.content = Content.createReusableContentView(frame: bounds)
        self.background = Content.createReusableBackgroundView(frame: bounds)
        self.pressedBackground = Content.createReusablePressedBackgroundView(frame: bounds)
        
        self.pressRecognizer = PressGestureRecognizer()
        self.pressRecognizer.minimumPressDuration = 0.0
        self.pressRecognizer.allowableMovementAfterBegin = 5.0
        
        super.init(frame: frame)
        
        self.pressRecognizer.addTarget(self, action: #selector(pressStateChanged))
     
        self.addSubview(self.background)
        self.addSubview(self.pressedBackground)
        self.addSubview(self.content)
        
        self.updateIsTappable()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    //
    // MARK: UIView
    //
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        self.content.sizeThatFits(size)
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        self.content.systemLayoutSizeFitting(targetSize)
    }
    
    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        self.content.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: verticalFittingPriority
        )
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.content.frame = self.bounds
        self.background.frame = self.bounds
        self.pressedBackground.frame = self.bounds
    }
    
    //
    // MARK: Tap Handling
    //
    
    private func updateIsTappable()
    {
        self.removeGestureRecognizer(self.pressRecognizer)
        
        if self.onTap != nil {
            self.accessibilityTraits = [.header, .button]
            
            self.pressedBackground.isHidden = false
            self.pressedBackground.alpha = 0.0
            
            self.addGestureRecognizer(self.pressRecognizer)
        } else {
            self.accessibilityTraits = [.header]
            
            self.pressedBackground.isHidden = true
        }
    }
    
    @objc private func pressStateChanged() {
        
        let state = self.pressRecognizer.state
        
        switch state {

        case .possible:
            break
        
        case .began, .changed:
            self.pressedBackground.alpha = 1.0
            
        case .ended, .cancelled, .failed:
            let didEnd = state == .ended
            
            UIView.animate(withDuration: didEnd ? 0.1 : 0.0) {
                self.pressedBackground.alpha = 0.0
            }
            
            if didEnd {
                self.onTap?()
            }
            
        @unknown default: break
        }
    }
}


fileprivate final class PressGestureRecognizer : UILongPressGestureRecognizer {
    
    var allowableMovementAfterBegin : CGFloat = 0.0
    
    private var initialPoint : CGPoint? = nil
    
    override func reset() {
        super.reset()
        
        self.initialPoint = nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        
        self.initialPoint = self.location(in: self.view)
    }
    
    override func canPrevent(_ gesture: UIGestureRecognizer) -> Bool {
        
        // We want to allow the pan gesture of our containing scroll view to continue to track
        // when the user moves their finger vertically or horizontally, when we are cancelled.
        
        if let panGesture = gesture as? UIPanGestureRecognizer, panGesture.view is UIScrollView {
            return false
        }
        
        return super.canPrevent(gesture)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        
        if let initialPoint = self.initialPoint {
            let currentPoint = self.location(in: self.view)
            
            let distance = sqrt(pow(abs(initialPoint.x - currentPoint.x), 2) + pow(abs(initialPoint.y - currentPoint.y), 2))
            
            if distance > self.allowableMovementAfterBegin {
                self.state = .failed
            }
        }
    }
}
