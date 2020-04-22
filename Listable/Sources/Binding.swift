//
//  Binding.swift
//  Listable
//
//  Created by Kyle Van Essen on 6/27/19.
//

import Foundation

public final class Binding<Element> {
  private(set) public var element: Element

  private var state: State

  private typealias UpdateElement = (AnyBindingContext, Any, inout Element) -> Void

  private enum State {
    case initializing
    case new(New)
    case updating(Updating)
    case discarded

    struct New {
      let context: AnyBindingContext
      let updateElement: UpdateElement
    }

    struct Updating {
      let context: AnyBindingContext
      let updateElement: UpdateElement

      var onChange: OnChange? = nil
    }
  }

  public init<Context: BindingContext>(
    initial provider: () -> Element,
    bind bindingContext: (Element) -> Context,
    update updateElement: @escaping (Context, Context.Update, inout Element) -> Void
  ) {
    self.state = .initializing

    self.element = provider()

    let context = bindingContext(self.element)

    context.didUpdate = { [weak self] (update: Context.Update) -> () in
      self?.contextUpdated(with: update)
    }

    self.state = .new(
      .init(
        context: context,
        updateElement: { context, contextUpdate, element in
          updateElement(context as! Context, contextUpdate as! Context.Update, &element)
        }))
  }

  deinit {
    self.discard()
  }

  public typealias OnChange = (Element) -> Void

  public func onChange(_ onChange: OnChange?) {
    switch self.state {
    case .initializing, .new, .discarded: break

    case .updating(let state):
      var newState = state
      newState.onChange = onChange

      self.state = .updating(newState)
    }
  }

  public func start() {
    switch self.state {
    case .initializing, .updating, .discarded: break

    case .new(let new):
      self.state = .updating(
        .init(
          context: new.context,
          updateElement: new.updateElement,
          onChange: nil
        )
      )

      new.context.anyBind(to: self)
    }
  }

  public func discard() {
    switch self.state {
    case .initializing, .new, .discarded: break

    case .updating(let state):
      self.state = .discarded
      state.context.anyUnbind(from: self)
    }
  }

  private func contextUpdated(with update: Any) {
    switch self.state {
    case .initializing, .new, .discarded: break

    case .updating(let state):
      OperationQueue.main.addOperation {
        state.updateElement(state.context, update, &self.element)
        state.onChange?(self.element)
      }
    }
  }
}

public protocol AnyBindingContext: AnyObject {
  func anyBind<AnyElement>(to binding: Binding<AnyElement>)

  func anyUnbind<AnyElement>(from binding: Binding<AnyElement>)
}

public protocol BindingContext: AnyBindingContext {
  associatedtype Element
  associatedtype Update

  typealias DidUpdate = (Update) -> Void

  // Call this closure when your context needs to signal an update.
  // Set by the system when creating the context. You should not set this value yourself.
  var didUpdate: DidUpdate? { get set }

  func bind(to binding: Binding<Element>)
  func unbind(from binding: Binding<Element>)
}

// TODO: Rename to BindingDataSource? BindingSource?
extension BindingContext {
  // MARK: AnyBindingContext

  public func anyBind<AnyElement>(to binding: Binding<AnyElement>) {
    let binding = binding as! Binding<Element>

    self.bind(to: binding)
  }

  public func anyUnbind<AnyElement>(from binding: Binding<AnyElement>) {
    let binding = binding as! Binding<Element>

    self.unbind(from: binding)
  }
}

public final class KVOContext<Element, Observed: NSObject, Value>: BindingContext {
  public typealias Update = NSKeyValueObservedChange<Value>

  public var didUpdate: DidUpdate?

  public private(set) weak var observed: Observed?
  public let keyPath: KeyPath<Observed, Value>

  private var observation: NSKeyValueObservation?

  public init(with observed: Observed, keyPath: KeyPath<Observed, Value>) {
    self.observed = observed
    self.keyPath = keyPath
  }

  deinit {
    self.observation?.invalidate()
  }

  public func bind(to binding: Binding<Element>) {
    self.observation = self.observed?.observe(keyPath) { [weak self] observed, change in
      guard let self = self else { return }

      self.didUpdate?(change)
    }
  }

  public func unbind(from binding: Binding<Element>) {
    self.observation?.invalidate()
  }
}

public final class NotificationContext<Element, Update>: BindingContext {
  public var didUpdate: DidUpdate?

  public let center: NotificationCenter
  public let name: Notification.Name
  public let object: AnyObject?

  public let createUpdate: (Notification) -> Update

  public init(
    center: NotificationCenter = .default,
    name: Notification.Name,
    object: AnyObject? = nil,
    createUpdate: @escaping (Notification) -> Update
  ) {
    self.center = center
    self.name = name
    self.object = object

    self.createUpdate = createUpdate
  }

  deinit {
    self.center.removeObserver(self)
  }

  @objc private func recievedNotification(_ notification: Notification) {
    self.didUpdate?(self.createUpdate(notification))
  }

  // MARK: BindingContext

  public func bind(to binding: Binding<Element>) {
    self.center.addObserver(
      self, selector: #selector(recievedNotification(_:)), name: self.name, object: self.object)
  }

  public func unbind(from binding: Binding<Element>) {
    self.center.removeObserver(self)
  }
}

extension NotificationContext where Update == Notification {
  public convenience init(
    center: NotificationCenter = .default,
    name: Notification.Name,
    object: AnyObject? = nil
  ) {
    self.init(
      center: center,
      name: name,
      object: object,
      createUpdate: { $0 }
    )
  }
}
