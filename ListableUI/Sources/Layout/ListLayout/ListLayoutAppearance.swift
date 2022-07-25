//
//  ListLayoutAppearance.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 6/15/20.
//

import Foundation

public protocol ListLayoutAppearance: Equatable {
    static var `default`: Self { get }

    static func `default`(_ modifying: (inout Self) -> Void) -> Self

    var direction: LayoutDirection { get }

    var bounds: ListContentBounds? { get }

    var listHeaderPosition: ListHeaderPosition { get }

    var stickySectionHeaders: Bool { get }

    var pagingBehavior: ListPagingBehavior { get }

    var scrollViewProperties: ListLayoutScrollViewProperties { get }

    func toLayoutDescription() -> LayoutDescription
}

public extension ListLayoutAppearance {
    static func `default`(_ modifying: (inout Self) -> Void) -> Self {
        var appearance = Self.default
        modifying(&appearance)
        return appearance
    }
}

/// Represents the properties from a `ListLayoutAppearance`, which
/// are applicable to any kind of layout.
public struct ListLayoutAppearanceProperties: Equatable {
    public let direction: LayoutDirection
    public let bounds: ListContentBounds?
    public let stickySectionHeaders: Bool
    public let pagingBehavior: ListPagingBehavior
    public let scrollViewProperties: ListLayoutScrollViewProperties

    public init(
        direction: LayoutDirection,
        bounds: ListContentBounds?,
        stickySectionHeaders: Bool,
        pagingBehavior: ListPagingBehavior,
        scrollViewProperties: ListLayoutScrollViewProperties
    ) {
        self.direction = direction
        self.bounds = bounds
        self.stickySectionHeaders = stickySectionHeaders
        self.pagingBehavior = pagingBehavior
        self.scrollViewProperties = scrollViewProperties
    }

    public init<Appearance: ListLayoutAppearance>(_ appearance: Appearance) {
        direction = appearance.direction
        bounds = appearance.bounds
        stickySectionHeaders = appearance.stickySectionHeaders
        pagingBehavior = appearance.pagingBehavior
        scrollViewProperties = appearance.scrollViewProperties
    }
}
