//
//  LayoutDescription.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 6/15/20.
//

import Foundation

///
/// A `LayoutDescription`, well, describes the type of and properties of a layout to apply to a list view.
///
/// You use a `LayoutDescription` by passing a closure to its initializer, which you use to
/// customize the `layoutAppearance` of the provided list type.
///
/// For example, to use a standard list layout, and customize the layout, your code would look something like this:
///
/// ```
/// listView.layout = .table {
///     $0.stickySectionHeaders = true
///
///     $0.layout.padding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
///     $0.layout.itemSpacing = 10.0
/// }
/// ```
///
/// Or a layout for your own custom layout type would look somewhat like this:
///
/// ```
/// MyCustomLayout.describe {
///     $0.myLayoutOption = true
///     $0.anotherLayoutOption = .polkadots
/// }
/// ```
///
/// Note
/// ----
/// Under the hood, Listable is smart, and will only re-create the underlying
/// layout object when needed (when the layout type or layout appearance changes).
///
public struct LayoutDescription: Equatable {
    let configuration: AnyLayoutDescriptionConfiguration

    /// Creates a new layout description for the provided layout type, with the provided optional layout configuration.
    public init<LayoutType: ListLayout>(
        layoutType: LayoutType.Type,
        appearance configure: (inout LayoutType.LayoutAppearance) -> Void = { _ in }
    ) {
        var appearance = LayoutType.LayoutAppearance.default
        configure(&appearance)

        self.init(layoutType: layoutType, appearance: appearance)
    }

    /// Creates a new layout description for the provided layout type, with the provided appearance.
    public init<LayoutType: ListLayout>(
        layoutType: LayoutType.Type,
        appearance: LayoutType.LayoutAppearance
    ) {
        configuration = Configuration(
            layoutType: layoutType,
            layoutAppearance: appearance
        )
    }

    /// Returns the standard layout properties, which apply to any kind of list layout.
    ///
    /// Calling this method is relatively inexpensive – it does not create an instance
    /// of the backing list layout.
    public var layoutAppearanceProperties: ListLayoutAppearanceProperties {
        configuration.layoutAppearanceProperties()
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.configuration.isEqual(to: rhs.configuration)
    }
}

public extension ListLayout {
    /// Creates a new layout description for a list layout, with the provided optional layout configuration.
    static func describe(
        appearance: (inout Self.LayoutAppearance) -> Void = { _ in }
    ) -> LayoutDescription {
        LayoutDescription(
            layoutType: Self.self,
            appearance: appearance
        )
    }
}

public extension LayoutDescription {
    struct Configuration<LayoutType: ListLayout>: AnyLayoutDescriptionConfiguration, Equatable {
        public let layoutType: LayoutType.Type

        public let layoutAppearance: LayoutType.LayoutAppearance

        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.layoutType == rhs.layoutType && lhs.layoutAppearance == rhs.layoutAppearance
        }

        // MARK: AnyLayoutDescriptionConfiguration

        public func createEmptyLayout(
            appearance: Appearance,
            behavior: Behavior
        ) -> AnyListLayout {
            LayoutType(
                layoutAppearance: layoutAppearance,
                appearance: appearance,
                behavior: behavior,
                content: .init()
            )
        }

        public func createPopulatedLayout(
            appearance: Appearance,
            behavior: Behavior,
            content: (ListLayoutDefaults) -> ListLayoutContent
        ) -> AnyListLayout {
            LayoutType(
                layoutAppearance: layoutAppearance,
                appearance: appearance,
                behavior: behavior,
                content: content(LayoutType.defaults)
            )
        }

        public func layoutAppearanceProperties() -> ListLayoutAppearanceProperties {
            .init(layoutAppearance)
        }

        public func shouldRebuild(layout anyLayout: AnyListLayout) -> Bool {
            let layout = anyLayout as! LayoutType
            let old = layout.layoutAppearance

            return old != layoutAppearance
        }

        public func isSameLayoutType(as anyOther: AnyLayoutDescriptionConfiguration) -> Bool {
            // TODO: We don't need both of these checks, just the second one.

            guard let other = anyOther as? Self else {
                return false
            }

            return layoutType == other.layoutType
        }

        public func isEqual(to other: AnyLayoutDescriptionConfiguration) -> Bool {
            self == (other as? Self)
        }
    }
}

public protocol AnyLayoutDescriptionConfiguration {
    func createEmptyLayout(
        appearance: Appearance,
        behavior: Behavior
    ) -> AnyListLayout

    func createPopulatedLayout(
        appearance: Appearance,
        behavior: Behavior,
        content: (ListLayoutDefaults) -> ListLayoutContent
    ) -> AnyListLayout

    func layoutAppearanceProperties() -> ListLayoutAppearanceProperties

    func shouldRebuild(layout anyLayout: AnyListLayout) -> Bool

    func isSameLayoutType(as other: AnyLayoutDescriptionConfiguration) -> Bool

    func isEqual(to other: AnyLayoutDescriptionConfiguration) -> Bool
}

extension LayoutDescription {
    var wantsKeyboardInsetAdjustment: Bool {
        layoutAppearanceProperties.direction == .vertical
    }

    func needsCollectionViewInsetUpdate(for other: LayoutDescription) -> Bool {
        guard layoutAppearanceProperties.direction == other.layoutAppearanceProperties.direction else {
            return true
        }

        return false
    }
}
