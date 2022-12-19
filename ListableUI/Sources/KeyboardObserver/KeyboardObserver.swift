//
//  KeyboardObserver.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 2/16/20.
//

import UIKit


@_spi(ListableKeyboard)
public protocol KeyboardObserverDelegate : AnyObject {

    func keyboardFrameWillChange(
        for observer : KeyboardObserver,
        animationDuration : Double,
        options : UIView.AnimationOptions
    )
}

/**
 Encapsulates listening for system keyboard updates, plus transforming the visible frame of the keyboard into the coordinates of a requested view.

 You use this class by providing a delegate, which receives callbacks when changes to the keyboard frame occur. You would usually implement
 the delegate somewhat like this:

 ```
 func keyboardFrameWillChange(
     for observer : KeyboardObserver,
     animationDuration : Double,
     options : UIView.AnimationOptions
 ) {
     UIView.animate(withDuration: animationDuration, delay: 0.0, options: options, animations: {
         // Use the frame from the keyboardObserver to update insets or sizing where relevant.
     })
 }
 ```

 Notes
 -----
 iOS Docs for keyboard management:
 https://developer.apple.com/library/archive/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html
 */
@_spi(ListableKeyboard)
public final class KeyboardObserver {

    /// The global shared keyboard observer. Why is it a global shared instance?
    /// We can only know the keyboard position via the keyboard frame notifications.
    ///
    /// If a `ListView` is created while a keyboard is already on-screen, we'd have
    /// no way to determine the keyboard frame, and thus couldn't provide the correct
    /// content insets to avoid the visible keyboard.
    ///
    /// Thus, the `shared` observer is set up on app startup
    /// (see `SetupKeyboardObserverOnAppStartup.m`) to avoid this problem.
    public static let shared : KeyboardObserver = KeyboardObserver(center: .default)

    /// Allow logging to the console if app startup-timed shared instance startup did not
    /// occur; this could cause bugs for the reasons outlined above.
    fileprivate static var didSetupSharedInstanceDuringAppStartup = false

    private let center : NotificationCenter

    internal private(set) var delegates : [Delegate] = []

    internal struct Delegate {
        private(set) weak var value : KeyboardObserverDelegate?
    }

    //
    // MARK: Initialization
    //

    public init(center : NotificationCenter) {

        self.center = center

        /// We need to listen to both `will` and `keyboardDidChangeFrame` notifications. Why?
        ///
        /// When dealing with an undocked or floating keyboard, moving the keyboard
        /// around the screen does NOT call `willChangeFrame`; only `didChangeFrame` is called.
        ///
        /// Before calling the delegate, we compare `old.endingFrame != new.endingFrame`,
        /// which ensures that the delegate is notified if the frame really changes, and
        /// prevents duplicate calls.

        self.center.addObserver(self, selector: #selector(keyboardFrameChanged(_:)), name: UIWindow.keyboardWillChangeFrameNotification, object: nil)
        self.center.addObserver(self, selector: #selector(keyboardFrameChanged(_:)), name: UIWindow.keyboardDidChangeFrameNotification, object: nil)
    }

    private var latestNotification : NotificationInfo?

    //
    // MARK: Delegates
    //

    public func add(delegate : KeyboardObserverDelegate) {

        if self.delegates.contains(where: { $0.value === delegate}) {
            return
        }

        self.delegates.append(Delegate(value: delegate))

        self.removeDeallocatedDelegates()
    }

    public func remove(delegate : KeyboardObserverDelegate) {
        self.delegates.removeAll {
            $0.value === delegate
        }

        self.removeDeallocatedDelegates()
    }

    private func removeDeallocatedDelegates() {
        self.delegates.removeAll {
            $0.value == nil
        }
    }

    //
    // MARK: Handling Changes
    //

    public enum KeyboardFrame : Equatable {

        /// The current frame does not overlap the current view at all.
        case nonOverlapping

        /// The current frame does overlap the view, by the provided rect, in the view's coordinate space.
        case overlapping(frame: CGRect)
    }

    /// How the keyboard overlaps the view provided. If the view is not on screen (eg, no window),
    /// or the observer has not yet learned about the keyboard's position, this method returns nil.
    public func currentFrame(in view : UIView) -> KeyboardFrame? {

        guard view.window != nil else {
            return nil
        }

        guard let notification = self.latestNotification else {
            return nil
        }

        let frame = view.convert(notification.endingFrame, from: nil)

        if frame.intersects(view.bounds) {
            return .overlapping(frame: frame)
        } else {
            return .nonOverlapping
        }
    }

    //
    // MARK: Receiving Updates
    //

    private func receivedUpdatedKeyboardInfo(_ new : NotificationInfo) {

        let old = self.latestNotification

        self.latestNotification = new

        /// Only communicate a frame change to the delegate if the frame actually changed.

        if let old = old, old.endingFrame == new.endingFrame {
            return
        }

        /**
         Create an animation curve with the correct curve for showing or hiding the keyboard.

         This is unfortunately a private UIView curve. However, we can map it to the animation options' curve
         like so: https://stackoverflow.com/questions/26939105/keyboard-animation-curve-as-int
         */
        let animationOptions = UIView.AnimationOptions(rawValue: new.animationCurve << 16)

        self.delegates.forEach {
            $0.value?.keyboardFrameWillChange(
                for: self,
                animationDuration: new.animationDuration,
                options: animationOptions
            )
        }
    }

    //
    // MARK: Notification Listeners
    //

    @objc private func keyboardFrameChanged(_ notification : Notification) {

        do {
            let info = try NotificationInfo(with: notification)
            self.receivedUpdatedKeyboardInfo(info)
        } catch {
            assertionFailure("Blueprint could not read system keyboard notification. This error needs to be fixed in Blueprint. Error: \(error)")
        }
    }
}

extension KeyboardObserver
{
    struct NotificationInfo : Equatable {

        var endingFrame : CGRect = .zero

        var animationDuration : Double = 0.0
        var animationCurve : UInt = 0

        init(with notification : Notification) throws {

            guard let userInfo = notification.userInfo else {
                throw ParseError.missingUserInfo
            }

            guard let endingFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                throw ParseError.missingEndingFrame
            }

            self.endingFrame = endingFrame

            guard let animationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {
                throw ParseError.missingAnimationDuration
            }

            self.animationDuration = animationDuration

            guard let animationCurve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue else {
                throw ParseError.missingAnimationCurve
            }

            self.animationCurve = animationCurve
        }

        enum ParseError : Error, Equatable {

            case missingUserInfo
            case missingEndingFrame
            case missingAnimationDuration
            case missingAnimationCurve
        }
    }
}


extension KeyboardObserver {
    private static let isExtensionContext: Bool = {
        // This is our best guess for "is this executable an extension?"
        if let _ = Bundle.main.infoDictionary?["NSExtension"] {
            return true
        } else if Bundle.main.bundlePath.hasSuffix(".appex") {
            return true
        } else {
            return false
        }
    }()

    /// Called by `ListView` on setup, to warn developers
    /// if something has gone wrong with keyboard setup.
    static func logKeyboardSetupWarningIfNeeded() {
        guard !isExtensionContext else {
            return
        }

        if KeyboardObserver.didSetupSharedInstanceDuringAppStartup {
            return
        }

        print(
            """
            LISTABLE WARNING: The shared instance of the `KeyboardObserver` was not instantiated
            during app startup. While not fatal, this could result in a list being created
            that does not properly position itself to account for the keyboard, if the list is created
            while the keyboard is already visible.
            """
        )
    }
}

extension ListView {

    /// This should be called in UIApplicationDelegate.application(_:, didFinishLaunchingWithOption:)
    /// It ensures that all ListViews will correctly avoid the keyboard
    /// - Note: CocoaPods automatically calls this method
    @available(iOSApplicationExtension, unavailable, message: "This cannot be used in application extensions")
    @objc(configureWithApplication:)
    public static func configure(with application: UIApplication) {
        _ = KeyboardObserver.shared
        KeyboardObserver.didSetupSharedInstanceDuringAppStartup = true
    }
}
