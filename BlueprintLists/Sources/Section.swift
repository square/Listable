//
//  Section.swift
//  BlueprintLists
//
//  Created by Kyle Van Essen on 11/20/19.
//

import Listable

//
// MARK: Building Content
//

extension Section {
  //
  // MARK: Adding Items
  //

  public static func += <Element: BlueprintItemElement>(lhs: inout Section, rhs: Element) {
    lhs += Item(with: rhs)
  }

  public static func += <Element: BlueprintItemElement>(lhs: inout Section, rhs: [Element]) {
    lhs.items += rhs.map { Item(with: $0) }
  }
}
