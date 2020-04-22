//
//  ApplyReason.swift
//  Listable
//
//  Created by Kyle Van Essen on 8/10/19.
//

public enum ApplyReason: Hashable {
  case willDisplay
  case wasUpdated

  public var shouldAnimate: Bool {
    switch self {
    case .willDisplay: return false
    case .wasUpdated: return true
    }
  }
}
