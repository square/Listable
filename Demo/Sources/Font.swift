//
//  Fonts.swift
//  CheckoutApplet
//
//  Created by Kyle Van Essen on 6/17/19.
//

import UIKit.UIFont

enum Font {
  case display
  case display2

  case heading
  case heading2

  case body
  case body2

  case label
  case label2

  case specific(CGFloat, Weight)

  enum Weight {
    case regular
    case medium
  }

  var font: UIFont {
    switch self.weight {
    case .regular:
      return UIFont.systemFont(ofSize: self.size, weight: .regular)
    case .medium:
      return UIFont.systemFont(ofSize: self.size, weight: .medium)
    }
  }

  var weight: Weight {
    switch self {
    case .display: return .regular
    case .display2: return .regular

    case .heading: return .medium
    case .heading2: return .medium

    case .body: return .regular
    case .body2: return .regular

    case .label: return .medium
    case .label2: return .medium

    case .specific(_, let weight): return weight
    }
  }

  var size: CGFloat {
    switch self {
    case .display: return 44
    case .display2: return 32

    case .heading: return 24
    case .heading2: return 18

    case .body: return 16
    case .body2: return 14

    case .label: return 16
    case .label2: return 14

    case .specific(let size, _): return size
    }
  }
}
