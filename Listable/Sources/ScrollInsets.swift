//
//  ScrollInsets.swift
//  Listable
//
//  Created by Kyle Van Essen on 11/13/19.
//

public struct ScrollInsets: Equatable {
  public var top: CGFloat?
  public var bottom: CGFloat?

  public init(top: CGFloat? = nil, bottom: CGFloat? = nil) {
    self.top = top
    self.bottom = bottom
  }

  func insets(with insets: UIEdgeInsets, layoutDirection: LayoutDirection) -> UIEdgeInsets {
    var insets = insets

    switch layoutDirection {
    case .vertical:
      insets.top = self.top ?? insets.top
      insets.bottom = self.bottom ?? insets.bottom

    case .horizontal:
      insets.left = self.top ?? insets.left
      insets.right = self.bottom ?? insets.right
    }

    return insets
  }
}
