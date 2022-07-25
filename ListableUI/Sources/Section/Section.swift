//
//  Section.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 8/10/19.
//

public struct Section {
    //

    // MARK: Public Properties

    //

    /// The `Identifier` type used for a `Section`.
    public typealias Identifier = ListableUI.Identifier<Section, AnyHashable>

    /// The value which uniquely identifies the section within a list.
    public var identifier: Identifier

    /// The header, if any, associated with the section.
    public var header: AnyHeaderFooterConvertible?

    /// The footer, if any, associated with the section.
    public var footer: AnyHeaderFooterConvertible?

    /// The items, if any, associated with the section.
    public var items: [AnyItem]

    /// Controls re-ordering options when items are moved in or out of the section.
    public var reordering: SectionReordering

    /// Check if the section contains any of the given types, which you specify via the `filters`
    /// parameter. If you do not specify a `filters` parameter, `[.items]` is used.
    public func contains(any filters: Set<ContentFilters> = [.items]) -> Bool {
        for filter in filters {
            switch filter {
            case .listContainerHeader: break
            case .listHeader: break
            case .listFooter: break
            case .overscrollFooter: break

            case .sectionHeaders:
                if header != nil {
                    return true
                }
            case .sectionFooters:
                if footer != nil {
                    return true
                }
            case .items:
                if items.isEmpty == false {
                    return true
                }
            }
        }

        return false
    }

    /// The number of ``Item``s within the section.
    public var count: Int {
        items.count
    }

    //

    // MARK: Layout Specific Parameters

    //

    public var layouts: SectionLayouts = .init()

    //

    // MARK: Initialization

    //

    /// Provides a mutable section for editing in an inline closure.
    public typealias Configure = (inout Section) -> Void

    /// Creates a new section with all of the provided values, plus an optional
    /// trailing closure to configure the section inline.
    public init<IdentifierValue: Hashable>(
        _ identifier: IdentifierValue,
        layouts: SectionLayouts = .init(),
        header: AnyHeaderFooterConvertible? = nil,
        footer: AnyHeaderFooterConvertible? = nil,
        reordering: SectionReordering = .init(),
        items: [AnyItemConvertible] = [],
        configure: Configure = { _ in }
    ) {
        self.identifier = Identifier(identifier)

        self.layouts = layouts

        self.header = header
        self.footer = footer

        self.reordering = reordering

        self.items = items.map { $0.toAnyItem() }

        configure(&self)
    }

    /// Creates a new section with a trailing closure to configure the section inline.
    public init<IdentifierValue: Hashable>(
        _ identifier: IdentifierValue,
        configure: Configure
    ) {
        self.identifier = Identifier(identifier)

        layouts = .init()
        header = nil
        footer = nil
        reordering = .init()
        items = []

        configure(&self)
    }

    /// Creates a new section with result builder-style APIs.
    public init<IdentifierValue: Hashable>(
        _ identifier: IdentifierValue,
        layouts: SectionLayouts = .init(),
        reordering: SectionReordering = .init(),
        @ListableBuilder<AnyItemConvertible> items: () -> [AnyItemConvertible],
        header: () -> AnyHeaderFooterConvertible? = { nil },
        footer: () -> AnyHeaderFooterConvertible? = { nil }
    ) {
        self.identifier = Identifier(identifier)

        self.layouts = layouts
        self.reordering = reordering

        self.items = items().map { $0.toAnyItem() }

        self.header = header()
        self.footer = footer()
    }

    /// Creates a new section with result builder-style APIs.
    public init<IdentifierValue: Hashable>(
        _ identifier: IdentifierValue,
        @ListableBuilder<AnyItemConvertible> items: () -> [AnyItemConvertible],
        header: () -> AnyHeaderFooterConvertible? = { nil },
        footer: () -> AnyHeaderFooterConvertible? = { nil }
    ) {
        self.identifier = Identifier(identifier)

        layouts = .init()
        reordering = .init()

        self.items = items().map { $0.toAnyItem() }

        self.header = header()
        self.footer = footer()
    }

    //

    // MARK: Reading Items

    //

    /// Returns the content of the section, converted back to the provided type,
    /// stripping any content which does not conform to the given type.
    ///
    /// You usually use this method as part of committing a reorder event, in order to read
    /// the identifiers (or other properties), off of your items in order to commit the reorder
    /// event to your backing data store.
    /// ```swift
    /// item.onWasReordered = { item, reorder in
    ///     let items = reorder.toSection.filtered(to: MyContent.self)
    ///     controller.setItemOrders(with: items.map(\.content.model))
    /// }
    /// ```
    public func filtered<Content>(to _: Content.Type) -> [Content] {
        items.compactMap { item in
            item.anyContent as? Content ?? nil
        }
    }

    /// Provides the content of the section, converted back to the provided type,
    /// stripping any content which does not conform to the given type.
    ///
    /// You usually use this method as part of committing a reorder event, in order to read
    /// the identifiers (or other properties), off of your items in order to commit the reorder
    /// event to your backing data store.
    /// ```swift
    /// item.onWasReordered = { item, reorder in
    ///     reorder.toSection.filtered(to: MyContent.self) { items in
    ///         controller.setItemOrders(with: items.map(\.content.model))
    ///     }
    /// }
    /// ```
    public func filtered<Content>(to _: Content.Type, _ read: ([Content]) -> Void) {
        read(filtered(to: Content.self))
    }

    //

    // MARK: Adding & Removing Single Items

    //

    public mutating func add(_ item: AnyItem) {
        items.append(item)
    }

    public static func += (lhs: inout Section, rhs: AnyItem) {
        lhs.add(rhs)
    }

    public static func += <Content: ItemContent>(lhs: inout Section, rhs: Item<Content>) {
        lhs.add(rhs)
    }

    public static func += <Content: ItemContent>(lhs: inout Section, rhs: Content) {
        lhs += Item(rhs)
    }

    //

    // MARK: Adding & Removing Multiple Items

    //

    /// Adds the provided items with the provided result builder.
    ///
    /// ```
    /// section.add {
    ///     MyContent(text: "Person 1")
    ///     MyContent(text: "Person 2")
    /// }
    /// ```
    public mutating func add(
        @ListableBuilder<AnyItemConvertible> items: () -> [AnyItemConvertible]
    ) {
        self.items += items().map { $0.toAnyItem() }
    }

    public static func += (lhs: inout Section, rhs: [AnyItem]) {
        lhs.items += rhs
    }

    public static func += <Content: ItemContent>(lhs: inout Section, rhs: [Item<Content>]) {
        lhs.items += rhs
    }

    public static func += <Content: ItemContent>(lhs: inout Section, rhs: [Content]) {
        lhs.items += rhs.map { Item($0) }
    }

    //

    // MARK: Slicing

    //

    internal func itemsUpTo(limit: Int) -> [AnyItem] {
        let end = min(items.count, limit)

        return Array(items[0 ..< end])
    }
}

public extension Section {
    /// Provides a new identifier for a ``Section``, with the given underlying value.
    static func identifier<Value: Hashable>(with value: Value) -> Identifier {
        Identifier(value)
    }
}
