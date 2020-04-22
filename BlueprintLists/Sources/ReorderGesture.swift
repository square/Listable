//
//  ReorderGesture.swift
//  BlueprintLists
//
//  Created by Kyle Van Essen on 11/14/19.
//

import BlueprintUI
import Listable

public struct ReorderGesture: Element {
  public var element: Element
  public var isEnabled: Bool

  public typealias OnStart = () -> Bool
  public var onStart: OnStart

  public typealias OnMove = (UIPanGestureRecognizer) -> Void
  public var onMove: OnMove

  public typealias OnDone = () -> Void
  public var onDone: OnDone

  public init(
    isEnabled: Bool = true,
    reordering: ReorderingActions,
    wrapping element: Element
  ) {
    self.isEnabled = isEnabled
    self.onStart = { reordering.beginMoving() }
    self.onMove = { reordering.moved(with: $0) }
    self.onDone = { reordering.end() }
    self.element = element
  }

  //
  // MARK: Element
  //

  public var content: ElementContent {
    return ElementContent(child: self.element)
  }

  public func backingViewDescription(bounds: CGRect, subtreeExtent: CGRect?) -> ViewDescription? {
    return ViewDescription(WrapperView.self) { config in
      config.builder = {
        WrapperView(frame: bounds, wrapping: self)
      }

      config.apply { view in
        view.recognizer.isEnabled = self.isEnabled

        view.recognizer.onStart = self.onStart
        view.recognizer.onMove = self.onMove
        view.recognizer.onDone = self.onDone
      }
    }
  }

  private final class GestureRecognizer: UIPanGestureRecognizer {
    public var onStart: OnStart? = nil
    public var onMove: OnMove? = nil
    public var onDone: OnDone? = nil

    override init(target: Any?, action: Selector?) {
      super.init(target: target, action: action)

      self.addTarget(self, action: #selector(updated))

      self.minimumNumberOfTouches = 1
      self.maximumNumberOfTouches = 1
    }

    @objc func updated() {
      switch self.state {
      case .possible: break
      case .began:
        let canStart = self.onStart?()

        if canStart == false {
          self.state = .cancelled
        }
      case .changed:
        self.onMove?(self)

      case .ended: self.onDone?()
      case .cancelled, .failed: self.onDone?()
      @unknown default: listableFatal()
      }
    }
  }

  private final class WrapperView: UIView {
    let recognizer: GestureRecognizer

    init(frame: CGRect, wrapping: ReorderGesture) {
      self.recognizer = GestureRecognizer()

      super.init(frame: frame)

      self.isOpaque = false
      self.clipsToBounds = false
      self.backgroundColor = .clear

      self.addGestureRecognizer(self.recognizer)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
      listableFatal()
    }
  }
}
