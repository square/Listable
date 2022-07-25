//
//  PresentationState.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 7/22/19.
//

import UIKit

/// A class used to manage the "live" / mutable state of the visible items in the list,
/// which is persistent across diffs of content (instances are only created or destroyed when an item enters or leaves the list).
final class PresentationState {
    //

    // MARK: Properties

    //

    var refreshControl: RefreshControlState?

    var context: ContentContext? {
        didSet {
            guard oldValue != context else { return }

            resetAllCachedSizes()
        }
    }

    let containerHeader: HeaderFooterViewStatePair
    let header: HeaderFooterViewStatePair
    let footer: HeaderFooterViewStatePair
    let overscrollFooter: HeaderFooterViewStatePair

    var sections: [PresentationState.SectionState]

    var performsContentCallbacks: Bool = true

    private(set) var containsAllItems: Bool

    private(set) var contentIdentifier: AnyHashable?

    private let itemMeasurementCache: ReusableViewCache
    private let headerFooterMeasurementCache: ReusableViewCache

    //

    // MARK: Initialization

    //

    init() {
        refreshControl = nil

        containerHeader = .init(state: nil)
        header = .init(state: nil)
        footer = .init(state: nil)
        overscrollFooter = .init(state: nil)

        sections = []

        containsAllItems = true

        contentIdentifier = nil

        itemMeasurementCache = ReusableViewCache()
        headerFooterMeasurementCache = ReusableViewCache()
    }

    init(
        forMeasuringOrTestsWith content: Content,
        environment: ListEnvironment,
        itemMeasurementCache: ReusableViewCache,
        headerFooterMeasurementCache: ReusableViewCache
    ) {
        self.itemMeasurementCache = itemMeasurementCache
        self.headerFooterMeasurementCache = headerFooterMeasurementCache

        refreshControl = {
            if let refreshControl = content.refreshControl {
                return RefreshControlState(refreshControl)
            } else {
                return nil
            }
        }()

        /// Note: We are passing `performsContentCallbacks:false` because this
        /// initializer is only used for one-pass measurement provided by ``ListView/contentSize(in:for:itemLimit:)``,
        /// as well as for testing purposes.

        containerHeader = .init(state: SectionState.newHeaderFooterState(
            with: content.containerHeader,
            performsContentCallbacks: false
        ))

        header = .init(state: SectionState.newHeaderFooterState(
            with: content.header,
            performsContentCallbacks: false
        ))

        footer = .init(state: SectionState.newHeaderFooterState(
            with: content.footer,
            performsContentCallbacks: false
        ))

        overscrollFooter = .init(state: SectionState.newHeaderFooterState(
            with: content.overscrollFooter,
            performsContentCallbacks: false
        ))

        sections = content.sections.map { section in
            SectionState(
                with: section,
                dependencies: .init(reorderingDelegate: nil, coordinatorDelegate: nil, environmentProvider: { environment }),
                updateCallbacks: .init(.immediate, wantsAnimations: false),
                performsContentCallbacks: false
            )
        }

        containsAllItems = true

        contentIdentifier = content.identifier
    }

    //

    // MARK: Accessing Data

    //

    var sectionModels: [Section] {
        sections.map { section in
            var sectionModel = section.model

            sectionModel.items = section.items.map(\.anyModel)

            return sectionModel
        }
    }

    var selectedItems: [AnyPresentationItemState] {
        let items: [[AnyPresentationItemState]] = sections.compactMap { section in
            section.items.compactMap { item in
                item.isSelected ? item : nil
            }
        }

        return items.flatMap { $0 }
    }

    var selectedIndexPaths: [IndexPath] {
        let indexes: [[IndexPath]] = sections.compactMapWithIndex { sectionIndex, _, section in
            section.items.compactMapWithIndex { itemIndex, _, item in
                item.isSelected ? IndexPath(item: itemIndex, section: sectionIndex) : nil
            }
        }

        return indexes.flatMap { $0 }
    }

    func headerFooter(of kind: SupplementaryKind, in section: Int) -> HeaderFooterViewStatePair {
        switch kind {
        case .listContainerHeader: return containerHeader
        case .listHeader: return header
        case .listFooter: return footer
        case .sectionHeader: return sections[section].header
        case .sectionFooter: return sections[section].footer
        case .overscrollFooter: return overscrollFooter
        }
    }

    func item(at indexPath: IndexPath) -> AnyPresentationItemState {
        let section = sections[indexPath.section]
        let item = section.items[indexPath.item]

        return item
    }

    func sections(at indexes: [Int]) -> [SectionState] {
        var sections: [SectionState] = []

        indexes.forEach {
            sections.append(self.sections[$0])
        }

        return sections
    }

    public var lastIndexPath: IndexPath? {
        let nonEmptySections: [(index: Int, section: SectionState)] = sections.compactMapWithIndex { index, _, state in
            state.items.isEmpty ? nil : (index, state)
        }

        guard let lastSection = nonEmptySections.last else {
            return nil
        }

        return IndexPath(item: lastSection.section.items.count - 1, section: lastSection.index)
    }

    internal func indexPath(for itemToFind: AnyPresentationItemState) -> IndexPath? {
        for (sectionIndex, section) in sections.enumerated() {
            for (itemIndex, item) in section.items.enumerated() {
                if item === itemToFind {
                    return IndexPath(item: itemIndex, section: sectionIndex)
                }
            }
        }

        return nil
    }

    internal func forEachItem(_ block: (IndexPath, AnyPresentationItemState) -> Void) {
        sections.forEachWithIndex { sectionIndex, _, section in
            section.items.forEachWithIndex { itemIndex, _, item in
                block(IndexPath(item: itemIndex, section: sectionIndex), item)
            }
        }
    }

    //

    // MARK: Mutating Data

    //

    func moveItem(from: IndexPath, to: IndexPath) {
        guard from != to else {
            return
        }

        let item = item(at: from)

        remove(at: from)
        insert(item: item, at: to)
    }

    @discardableResult
    func remove(at indexPath: IndexPath) -> AnyPresentationItemState {
        let section = sections[indexPath.section]

        return section.removeItem(at: indexPath.item)
    }

    func remove(item itemToRemove: AnyPresentationItemState) -> IndexPath? {
        guard let indexPath = indexPath(for: itemToRemove) else {
            return nil
        }

        remove(at: indexPath)

        return indexPath
    }

    func insert(item: AnyPresentationItemState, at indexPath: IndexPath) {
        let section = sections[indexPath.section]

        section.insert(item: item, at: indexPath.item)
    }

    //

    // MARK: Height Caching

    //

    // Exposed for testing only.
    var onResetCachedSizes: () -> Void = {}

    func resetAllCachedSizes() {
        containerHeader.state?.resetCachedSizes()
        header.state?.resetCachedSizes()
        footer.state?.resetCachedSizes()
        overscrollFooter.state?.resetCachedSizes()

        sections.forEach { section in
            section.resetAllCachedSizes()
        }

        onResetCachedSizes()
    }

    //

    // MARK: Updating Content & State

    //

    func update(
        with diff: SectionedDiff<Section, AnyIdentifier, AnyItem, AnyIdentifier>,
        slice: Content.Slice,
        reason: ApplyReason,
        animated: Bool,
        dependencies: ItemStateDependencies,
        updateCallbacks: UpdateCallbacks,
        loggable: SignpostLoggable?
    ) {
        SignpostLogger.log(.begin, log: .updateContent, name: "Update Presentation State", for: loggable)

        defer {
            SignpostLogger.log(.end, log: .updateContent, name: "Update Presentation State", for: loggable)
        }

        containsAllItems = slice.containsAllItems

        contentIdentifier = slice.content.identifier

        let environment = dependencies.environmentProvider()

        containerHeader.update(
            with: SectionState.headerFooterState(
                current: containerHeader.state,
                new: slice.content.containerHeader,
                performsContentCallbacks: performsContentCallbacks
            ),
            new: slice.content.containerHeader,
            reason: reason,
            animated: animated,
            updateCallbacks: updateCallbacks,
            environment: environment
        )

        header.update(
            with: SectionState.headerFooterState(
                current: header.state,
                new: slice.content.header,
                performsContentCallbacks: performsContentCallbacks
            ),
            new: slice.content.header,
            reason: reason,
            animated: animated,
            updateCallbacks: updateCallbacks,
            environment: environment
        )

        footer.update(
            with: SectionState.headerFooterState(
                current: footer.state,
                new: slice.content.footer,
                performsContentCallbacks: performsContentCallbacks
            ),
            new: slice.content.footer,
            reason: reason,
            animated: animated,
            updateCallbacks: updateCallbacks,
            environment: environment
        )

        overscrollFooter.update(
            with: SectionState.headerFooterState(
                current: overscrollFooter.state,
                new: slice.content.overscrollFooter,
                performsContentCallbacks: performsContentCallbacks
            ),
            new: slice.content.overscrollFooter,
            reason: reason,
            animated: animated,
            updateCallbacks: updateCallbacks,
            environment: environment
        )

        sections = diff.changes.transform(
            old: sections,
            removed: { _, section in
                section.wasRemoved(updateCallbacks: updateCallbacks)
            },
            added: { section in
                SectionState(
                    with: section,
                    dependencies: dependencies,
                    updateCallbacks: updateCallbacks,
                    performsContentCallbacks: self.performsContentCallbacks
                )
            },
            moved: { old, new, changes, section in
                section.update(
                    with: old,
                    new: new,
                    changes: changes,
                    reason: reason,
                    animated: animated,
                    dependencies: dependencies,
                    updateCallbacks: updateCallbacks
                )
            },
            noChange: { old, new, changes, section in
                section.update(
                    with: old,
                    new: new,
                    changes: changes,
                    reason: reason,
                    animated: animated,
                    dependencies: dependencies,
                    updateCallbacks: updateCallbacks
                )
            }
        )
    }

    internal func updateRefreshControl(with new: RefreshControl?, in view: UIScrollView) {
        if let existing = refreshControl, let new = new {
            existing.update(with: new)
        } else if refreshControl == nil, let new = new {
            let newControl = RefreshControlState(new)
            view.refreshControl = newControl.view
            refreshControl = newControl
            newControl.update(with: new)
        } else if refreshControl != nil, new == nil {
            view.refreshControl = nil
            refreshControl = nil
        }
    }

    internal func adjustContentOffsetForRefreshControl(in view: UIScrollView) {
        guard let control = refreshControl, control.model.isRefreshing else {
            return
        }

        switch control.model.offsetAdjustmentBehavior {
        case let .displayWhenRefreshing(animate, scrollToTop):
            // If we are not scrolled to the top or don't enable scroll to top, don't do anything
            guard view.isScrolledToTop || scrollToTop else {
                return
            }

            let contentOffset = CGPoint(x: 0, y: -view.adjustedContentInset.top)
            view.setContentOffset(contentOffset, animated: animate)

        case .none:
            return
        }
    }

    //

    // MARK: Cell & Supplementary View Registration

    //

    private var registeredCellObjectIdentifiers: Set<ObjectIdentifier> = Set()

    func registerCell(for item: AnyPresentationItemState, in view: UICollectionView) {
        let info = item.cellRegistrationInfo

        let identifier = ObjectIdentifier(info.class)

        guard registeredCellObjectIdentifiers.contains(identifier) == false else {
            return
        }

        registeredCellObjectIdentifiers.insert(identifier)

        view.register(info.class, forCellWithReuseIdentifier: info.reuseIdentifier)
    }
}

extension PresentationState {
    enum UpdateReason: Equatable {
        case scrolledDown
        case didEndDecelerating

        case scrolledToTop

        case contentChanged(animated: Bool, identifierChanged: Bool)

        case transitionedToBounds(isEmpty: Bool)

        case programaticScrollDownTo(IndexPath)

        var animated: Bool {
            switch self {
            case .scrolledDown: return false
            case .didEndDecelerating: return false
            case .scrolledToTop: return false

            case let .contentChanged(animated, identifierChanged): return animated && identifierChanged == false

            case .transitionedToBounds: return false

            case .programaticScrollDownTo: return false
            }
        }
    }
}

extension PresentationState {
    struct SizeKey: Hashable {
        var width: CGFloat
        var height: CGFloat
        var layoutDirection: LayoutDirection
        var sizing: Sizing
    }
}

extension PresentationState {
    func toListLayoutContent(
        defaults: ListLayoutDefaults,
        environment: ListEnvironment
    ) -> ListLayoutContent {
        ListLayoutContent(
            containerHeader: {
                guard let header = self.containerHeader.state else { return nil }

                return .init(
                    state: header,
                    kind: .listContainerHeader,
                    isPopulated: true,
                    measurer: { info in
                        header.size(for: info, cache: self.headerFooterMeasurementCache, environment: environment)
                    }
                )
            }(),
            header: {
                guard let header = self.header.state else { return nil }

                return .init(
                    state: header,
                    kind: .listHeader,
                    isPopulated: true,
                    measurer: { info in
                        header.size(for: info, cache: self.headerFooterMeasurementCache, environment: environment)
                    }
                )
            }(),
            footer: {
                guard let footer = self.footer.state else { return nil }

                return .init(
                    state: footer,
                    kind: .listFooter,
                    isPopulated: true,
                    measurer: { info in
                        footer.size(for: info, cache: self.headerFooterMeasurementCache, environment: environment)
                    }
                )
            }(),
            overscrollFooter: {
                guard let footer = self.overscrollFooter.state else { return nil }

                return .init(
                    state: footer,
                    kind: .overscrollFooter,
                    isPopulated: true,
                    measurer: { info in
                        footer.size(for: info, cache: self.headerFooterMeasurementCache, environment: environment)
                    }
                )
            }(),
            sections: sections.mapWithIndex { sectionIndex, _, section in
                .init(
                    state: section,
                    header: {
                        guard let header = section.header.state else { return nil }

                        return .init(
                            state: header,
                            kind: .sectionHeader,
                            isPopulated: true,
                            measurer: { info in
                                header.size(for: info, cache: self.headerFooterMeasurementCache, environment: environment)
                            }
                        )
                    }(),
                    footer: {
                        guard let footer = section.footer.state else { return nil }

                        return .init(
                            state: footer,
                            kind: .sectionFooter,
                            isPopulated: true,
                            measurer: { info in
                                footer.size(for: info, cache: self.headerFooterMeasurementCache, environment: environment)
                            }
                        )
                    }(),
                    items: section.items.mapWithIndex { itemIndex, _, item in
                        .init(
                            state: item,
                            indexPath: IndexPath(item: itemIndex, section: sectionIndex),
                            insertAndRemoveAnimations: item.anyModel.insertAndRemoveAnimations ?? defaults.itemInsertAndRemoveAnimations,
                            measurer: { info in
                                item.size(for: info, cache: self.itemMeasurementCache, environment: environment)
                            }
                        )
                    }
                )
            }
        )
    }
}

private extension UIScrollView {
    var isScrolledToTop: Bool {
        // adjustedContentInset includes the refresh control height, subtract that to
        // get the top point at rest
        var topInset = adjustedContentInset.top
        if let refreshControl = refreshControl {
            topInset -= refreshControl.frame.height
        }

        return contentOffset.y <= -topInset
    }
}
