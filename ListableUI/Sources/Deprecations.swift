//
//  Deprecations.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 5/29/20.
//

import Foundation

///
/// This file contains deprecations which have occurred in Listable, for which there are reasonable
/// forward-moving defaults (eg, renames), to ease transitions for consumers when they update their library version.
///
/// To add new deprecations and changes:
/// ------------------------------------
/// 1) Add a new `MARK: Deprecated <Date>` section for the deprecations you are adding.
///
/// 2) Add deprecation annotations like so:
///    ```
///    @available(*, deprecated, renamed: "ItemContent")
///    public typealias ItemElement = ItemContent
///    ```
///
///    Or, when deprecating properties, add a passthrough like so:
///    ```
///    public extension Item {
///       @available(*, deprecated, renamed: "content")
///       var element : Content {
///          self.content
///       }
///    }
///    ```
///
/// 3) After 1-2 months has passed, mark the previously `deprecated` items as `unavailable`:
///    ```
///    @available(*, unavailable, renamed: "ItemContent")
///    ```
///
/// 4) After another 1-2 months have passed, feel free to remove the `MARK: Deprecated` section you added.
///

//

// MARK: Deprecated Jan 22, 2021

//

public extension LayoutDescription {
    @available(*, unavailable, renamed: "table")
    static func list(_ configure: @escaping (inout TableAppearance) -> Void = { _ in }) -> Self {
        TableListLayout.describe(appearance: configure)
    }
}
