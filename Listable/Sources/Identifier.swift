//
//  Identifier.swift
//  Listable
//
//  Created by Kyle Van Essen on 7/1/19.
//

import Foundation

public final class AnyIdentifier: Hashable {
  private let value: AnyHashable

  private let hash: Int

  public init<Element>(_ value: Identifier<Element>) {
    self.value = AnyHashable(value)

    var hasher = Hasher()
    hasher.combine(self.value)
    self.hash = hasher.finalize()
  }

  // Equatable

  public static func == (lhs: AnyIdentifier, rhs: AnyIdentifier) -> Bool {
    return lhs.hash == rhs.hash && lhs.value == rhs.value
  }

  // Hashable

  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.hash)
  }
}

public final class Identifier<Element>: Hashable {
  private let type: ObjectIdentifier
  private let value: AnyHashable

  private let hash: Int

  public init<Value: Hashable>(_ value: Value) {
    self.value = AnyHashable(value)
    self.type = ObjectIdentifier(Element.self)

    var hasher = Hasher()
    hasher.combine(self.type)
    hasher.combine(self.value)
    self.hash = hasher.finalize()
  }

  // Equatable

  public static func == (lhs: Identifier<Element>, rhs: Identifier<Element>) -> Bool {
    return lhs.hash == rhs.hash && lhs.type == rhs.type && lhs.value == rhs.value
  }

  // Hashable

  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.hash)
  }
}

public protocol Identifiable {
  var identifier: Identifier<Self> { get }
}
