//
//  SwipeActions.swift
//  Listable
//
//  Created by Kyle Van Essen on 8/10/19.
//

import Foundation

public struct SwipeActions {
  public var actions: [SwipeAction]

  public var performsFirstOnFullSwipe: Bool

  public init(_ action: SwipeAction, performsFirstOnFullSwipe: Bool = false) {
    self.init([action], performsFirstOnFullSwipe: performsFirstOnFullSwipe)
  }

  public init(_ actions: [SwipeAction], performsFirstOnFullSwipe: Bool = false) {
    self.actions = actions

    self.performsFirstOnFullSwipe = performsFirstOnFullSwipe
  }
}

public struct SwipeAction {
  public var title: String?

  public var backgroundColor: UIColor?
  public var image: UIImage?

  public typealias OnTap = (SwipeAction) -> Bool
  public var onTap: OnTap

  public init(
    title: String, backgroundColor: UIColor, image: UIImage? = nil, onTap: @escaping OnTap
  ) {
    self.title = title
    self.backgroundColor = backgroundColor
    self.image = image
    self.onTap = onTap
  }
}
