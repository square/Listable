//
//  KeyboardObserver.swift
//  Listable
//
//  Created by Kyle Van Essen on 11/5/19.
//

import Foundation


protocol KeyboardObserverDelegate : AnyObject
{
    func keyboardFrameWillChange(observer : KeyboardObserver)
}

/**
 iOS Docs: https://developer.apple.com/library/archive/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html
 */
final class KeyboardObserver
{
    private let center : NotificationCenter
    
    weak var delegate : KeyboardObserverDelegate?
    
    init(center : NotificationCenter = .default)
    {
        self.center = center

        self.center.addObserver(self, selector: #selector(keyboardFrameChanged(_:)), name: UIWindow.keyboardWillChangeFrameNotification, object: nil)
        self.center.addObserver(self, selector: #selector(keyboardFrameChanged(_:)), name: UIWindow.keyboardDidChangeFrameNotification, object: nil)
    }
    
    private var latestNotification : NotificationInfo?
    
    //
    // MARK: Handling Changes
    //
    
    internal enum KeyboardFrame : Equatable
    {
        case notVisible
        case visible(frame: CGRect)
    }
    
    internal func currentFrame(in view : UIView) -> KeyboardFrame?
    {
        guard view.window != nil else {
            return nil
        }
        
        guard let notification = self.latestNotification else {
            return nil
        }
        
        let frame = view.convert(notification.endingFrame, from: nil)
        
        if frame.intersects(view.bounds) {
            return .visible(frame: frame)
        } else {
            return .notVisible
        }
    }
    
    private func receivedUpdatedKeyboardInfo(_ new : NotificationInfo)
    {
        let old = self.latestNotification
        
        self.latestNotification = new
        
        if let old = old {
            guard old.endingFrame != new.endingFrame else {
                return
            }
        }
        
        self.animate(with: new) {
            self.delegate?.keyboardFrameWillChange(observer: self)
        }
    }
    
    private func animate(with info : NotificationInfo, _ block : @escaping () -> ())
    {
        if info.animationDuration > 0.0 {
            UIView.animate(
                withDuration: info.animationDuration,
                delay: 0.0,
                options: .init(rawValue: info.animationCurve << 16),
                animations: block
            )
        } else {
            block()
        }
    }
    
    //
    // MARK: Notification Listeners
    //
    
    @objc func keyboardFrameChanged(_ notification : Notification)
    {
        let info : NotificationInfo
        
        do {
            info = try NotificationInfo(with: notification)
        } catch {
            assert(false, "Listable could not read system keyboard notification. This error needs to be fixed in Listable. Error: \(error)")
            return
        }
        
        self.receivedUpdatedKeyboardInfo(info)
    }
}

extension KeyboardObserver
{
    struct NotificationInfo : Equatable
    {
        var endingFrame : CGRect = .zero
        
        var animationDuration : Double = 0.0
        var animationCurve : UInt = 0
        
        init() {}
        
        init(with notification : Notification) throws
        {
            guard let userInfo = notification.userInfo else {
                throw ParseError.missingUserInfo
            }
            
            guard let endingFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                throw ParseError.missingEndingFrame(userInfo: userInfo)
            }
            
            self.endingFrame = endingFrame
            
            guard let animationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {
                throw ParseError.missingAnimationDuration(userInfo: userInfo)
            }
            
            self.animationDuration = animationDuration
            
            guard let animationCurve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue else {
                throw ParseError.missingAnimationCurve(userInfo: userInfo)
            }
            
            self.animationCurve = animationCurve
        }
        
        enum ParseError : Error
        {
            case missingUserInfo
            case missingEndingFrame(userInfo: [AnyHashable:Any])
            case missingAnimationDuration(userInfo: [AnyHashable:Any])
            case missingAnimationCurve(userInfo: [AnyHashable:Any])
        }
    }
}
