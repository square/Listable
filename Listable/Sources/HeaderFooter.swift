//
//  HeaderFooter.swift
//  Listable
//
//  Created by Kyle Van Essen on 8/10/19.
//

public protocol AnyHeaderFooter: AnyHeaderFooter_Internal {
}

public protocol AnyHeaderFooter_Internal {
  var layout: HeaderFooterLayout { get }

  func apply(to headerFooterView: UIView, reason: ApplyReason)

  func anyIsEquivalent(to other: AnyHeaderFooter) -> Bool

  func newPresentationHeaderFooterState() -> Any
}

public struct HeaderFooter<Element: HeaderFooterElement>: AnyHeaderFooter {
  public var element: Element
  public var appearance: Element.Appearance

  public var sizing: Sizing
  public var layout: HeaderFooterLayout

  internal let reuseIdentifier: ReuseIdentifier<Element>

  //
  // MARK: Initialization
  //

  public typealias Build = (inout HeaderFooter) -> Void

  public init(
    with element: Element,
    appearance: Element.Appearance,
    build: Build
  ) {
    self.init(with: element, appearance: appearance)

    build(&self)
  }

  public init(
    with element: Element,
    appearance: Element.Appearance,
    sizing: Sizing = .default,
    layout: HeaderFooterLayout = HeaderFooterLayout()
  ) {
    self.element = element
    self.appearance = appearance

    self.sizing = sizing
    self.layout = layout

    self.reuseIdentifier = ReuseIdentifier.identifier(for: Element.self)
  }

  // MARK: AnyHeaderFooter_Internal

  public func apply(to anyView: UIView, reason: ApplyReason) {
    let view = anyView as! Element.Appearance.ContentView

    self.element.apply(to: view, reason: reason)
  }

  public func anyIsEquivalent(to other: AnyHeaderFooter) -> Bool {
    guard let other = other as? HeaderFooter<Element> else {
      return false
    }

    return self.element.isEquivalent(to: other.element)
      && self.appearance.isEquivalent(to: other.appearance)
  }

  public func newPresentationHeaderFooterState() -> Any {
    return PresentationState.HeaderFooterState(self)
  }
}

public struct HeaderFooterLayout: Equatable {
  public var width: CustomWidth

  public init(width: CustomWidth = .default) {
    self.width = width
  }
}

extension HeaderFooter where Element.Appearance == Element {
  public init(
    with element: Element,
    sizing: Sizing = .default,
    layout: HeaderFooterLayout = HeaderFooterLayout()
  ) {
    self.init(
      with: element,
      appearance: element,
      sizing: sizing,
      layout: layout
    )
  }
}
