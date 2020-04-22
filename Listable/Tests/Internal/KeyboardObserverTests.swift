//
//  KeyboardObserverTests.swift
//  Listable-Unit-Tests
//
//  Created by Kyle Van Essen on 11/22/19.
//

import UIKit.UIResponder
import XCTest

@testable import Listable

class KeyboardObserverTests: XCTestCase {
  func test_notifications() {
    let center = NotificationCenter()

    self.testcase("Will Change Frame") {
      let observer = KeyboardObserver(center: center)

      let delegate = Delegate()
      observer.delegate = delegate

      let userInfo: [AnyHashable: Any] = [
        UIResponder.keyboardFrameEndUserInfoKey: NSValue(
          cgRect: CGRect(x: 10.0, y: 10.0, width: 100.0, height: 200.0)),
        UIResponder.keyboardAnimationDurationUserInfoKey: NSNumber(value: 2.5),
        UIResponder.keyboardAnimationCurveUserInfoKey: NSNumber(value: 123),
      ]

      XCTAssertEqual(delegate.keyboardFrameWillChange_callCount, 0)
      center.post(
        Notification(
          name: UIWindow.keyboardWillChangeFrameNotification, object: nil, userInfo: userInfo))
      XCTAssertEqual(delegate.keyboardFrameWillChange_callCount, 1)
    }

    self.testcase("Did Change Frame") {
      let observer = KeyboardObserver(center: center)

      let delegate = Delegate()
      observer.delegate = delegate

      let userInfo: [AnyHashable: Any] = [
        UIResponder.keyboardFrameEndUserInfoKey: NSValue(
          cgRect: CGRect(x: 10.0, y: 10.0, width: 100.0, height: 200.0)),
        UIResponder.keyboardAnimationDurationUserInfoKey: NSNumber(value: 2.5),
        UIResponder.keyboardAnimationCurveUserInfoKey: NSNumber(value: 123),
      ]

      XCTAssertEqual(delegate.keyboardFrameWillChange_callCount, 0)
      center.post(
        Notification(
          name: UIWindow.keyboardDidChangeFrameNotification, object: nil, userInfo: userInfo))
      XCTAssertEqual(delegate.keyboardFrameWillChange_callCount, 1)
    }

    self.testcase("Only calls delegate for changed frame") {
      let observer = KeyboardObserver(center: center)

      let delegate = Delegate()
      observer.delegate = delegate

      let userInfo: [AnyHashable: Any] = [
        UIResponder.keyboardFrameEndUserInfoKey: NSValue(
          cgRect: CGRect(x: 10.0, y: 10.0, width: 100.0, height: 200.0)),
        UIResponder.keyboardAnimationDurationUserInfoKey: NSNumber(value: 2.5),
        UIResponder.keyboardAnimationCurveUserInfoKey: NSNumber(value: 123),
      ]

      XCTAssertEqual(delegate.keyboardFrameWillChange_callCount, 0)
      center.post(
        Notification(
          name: UIWindow.keyboardDidChangeFrameNotification, object: nil, userInfo: userInfo))
      XCTAssertEqual(delegate.keyboardFrameWillChange_callCount, 1)

      XCTAssertEqual(delegate.keyboardFrameWillChange_callCount, 1)
      center.post(
        Notification(
          name: UIWindow.keyboardDidChangeFrameNotification, object: nil, userInfo: userInfo))
      XCTAssertEqual(delegate.keyboardFrameWillChange_callCount, 1)
    }
  }

  final class Delegate: KeyboardObserverDelegate {
    var keyboardFrameWillChange_callCount: Int = 0

    func keyboardFrameWillChange(observer: KeyboardObserver) {
      self.keyboardFrameWillChange_callCount += 1

      XCTAssertTrue(UIView.inheritedAnimationDuration > 0.0)
    }
  }
}

class KeyboardObserver_NotificationInfo_Tests: XCTestCase {
  func test_init() {
    let defaultUserInfo: [AnyHashable: Any] = [
      UIResponder.keyboardFrameEndUserInfoKey: NSValue(
        cgRect: CGRect(x: 10.0, y: 10.0, width: 100.0, height: 200.0)),
      UIResponder.keyboardAnimationDurationUserInfoKey: NSNumber(value: 2.5),
      UIResponder.keyboardAnimationCurveUserInfoKey: NSNumber(value: 123),
    ]

    self.testcase("Successful Init") {
      let info = try! KeyboardObserver.NotificationInfo(
        with: Notification(
          name: UIResponder.keyboardDidShowNotification, object: nil, userInfo: defaultUserInfo)
      )

      XCTAssertEqual(info.endingFrame, CGRect(x: 10.0, y: 10.0, width: 100.0, height: 200.0))
      XCTAssertEqual(info.animationDuration, 2.5)
      XCTAssertEqual(info.animationCurve, 123)
    }

    self.testcase("Failed Inits") {

      self.testcase("No userInfo") {
        self.assertThrowsError(
          test: {
            try _ = KeyboardObserver.NotificationInfo(
              with: Notification(
                name: UIResponder.keyboardDidShowNotification, object: nil, userInfo: nil)
            )
          },
          verify: { error in
            XCTAssertEqual(error as? KeyboardObserver.NotificationInfo.ParseError, .missingUserInfo)
          })
      }

      self.testcase("No end frame") {

        var userInfo = defaultUserInfo
        userInfo.removeValue(forKey: UIResponder.keyboardFrameEndUserInfoKey)

        self.assertThrowsError(
          test: {
            try _ = KeyboardObserver.NotificationInfo(
              with: Notification(
                name: UIResponder.keyboardDidShowNotification, object: nil, userInfo: userInfo)
            )
          },
          verify: { error in
            XCTAssertEqual(
              error as? KeyboardObserver.NotificationInfo.ParseError, .missingEndingFrame)
          })
      }

      self.testcase("No animation duration") {

        var userInfo = defaultUserInfo
        userInfo.removeValue(forKey: UIResponder.keyboardAnimationDurationUserInfoKey)

        self.assertThrowsError(
          test: {
            try _ = KeyboardObserver.NotificationInfo(
              with: Notification(
                name: UIResponder.keyboardDidShowNotification, object: nil, userInfo: userInfo)
            )
          },
          verify: { error in
            XCTAssertEqual(
              error as? KeyboardObserver.NotificationInfo.ParseError, .missingAnimationDuration)
          })
      }

      self.testcase("No animation curve") {

        var userInfo = defaultUserInfo
        userInfo.removeValue(forKey: UIResponder.keyboardAnimationCurveUserInfoKey)

        self.assertThrowsError(
          test: {
            try _ = KeyboardObserver.NotificationInfo(
              with: Notification(
                name: UIResponder.keyboardDidShowNotification, object: nil, userInfo: userInfo)
            )
          },
          verify: { error in
            XCTAssertEqual(
              error as? KeyboardObserver.NotificationInfo.ParseError, .missingAnimationCurve)
          })
      }

    }
  }
}
