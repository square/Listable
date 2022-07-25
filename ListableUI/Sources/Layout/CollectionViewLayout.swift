//
//  CollectionViewLayout.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 9/23/19.
//

import UIKit

final class CollectionViewLayout: UICollectionViewLayout {
    //

    // MARK: Properties

    //

    unowned let delegate: CollectionViewLayoutDelegate

    var layoutDescription: LayoutDescription

    var appearance: Appearance {
        didSet {
            guard oldValue != appearance else {
                return
            }

            applyAppearance()
        }
    }

    private(set) var isReordering: Bool = false

    private func applyAppearance() {
        guard collectionView != nil else {
            return
        }

        setNeedsRebuild(animated: false)
    }

    var behavior: Behavior {
        didSet {
            guard oldValue != behavior else {
                return
            }

            applyBehavior()
        }
    }

    private func applyBehavior() {
        guard collectionView != nil else {
            return
        }

        setNeedsRebuild(animated: false)
    }

    //

    // MARK: Initialization

    //

    init(
        delegate: CollectionViewLayoutDelegate,
        layoutDescription: LayoutDescription,
        appearance: Appearance,
        behavior: Behavior
    ) {
        self.delegate = delegate
        self.layoutDescription = layoutDescription
        self.appearance = appearance
        self.behavior = behavior

        layout = self.layoutDescription.configuration.createEmptyLayout(
            appearance: appearance,
            behavior: behavior
        )

        previousLayout = layout

        changesDuringCurrentUpdate = UpdateItems(with: [])

        viewProperties = CollectionViewLayoutProperties()

        super.init()

        applyAppearance()
        applyBehavior()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { listableInternalFatal() }

    //

    // MARK: Querying The Layout

    //

    func frameForItem(at indexPath: IndexPath) -> CGRect {
        layout.content.item(at: indexPath).frame
    }

    func positionForItem(at indexPath: IndexPath) -> ItemPosition {
        layout.content.item(at: indexPath).position
    }

    //

    // MARK: Private Properties

    //

    private(set) var layout: AnyListLayout

    private var previousLayout: AnyListLayout
    private var changesDuringCurrentUpdate: UpdateItems
    private var viewProperties: CollectionViewLayoutProperties

    //

    // MARK: Invalidation & Invalidation Contexts

    //

    func setNeedsRelayout() {
        neededLayoutType.merge(with: .relayout)

        invalidateLayout()
    }

    func setNeedsRebuild(animated: Bool) {
        neededLayoutType.merge(with: .rebuild)

        if animated {
            /// The collection view actually manages the animation, and the duration or curve doesn't matter.
            /// However, we need to be in an animation block for it to animate.
            UIView.animate(withDuration: 0.15, animations: invalidateLayout)
        } else {
            invalidateLayout()
        }
    }

    private(set) var shouldAskForItemSizesDuringLayoutInvalidation: Bool = false

    func setShouldAskForItemSizesDuringLayoutInvalidation() {
        shouldAskForItemSizesDuringLayoutInvalidation = true
    }

    override class var invalidationContextClass: AnyClass {
        InvalidationContext.self
    }

    override func invalidateLayout() {
        super.invalidateLayout()

        if shouldAskForItemSizesDuringLayoutInvalidation {
            neededLayoutType = .rebuild
            shouldAskForItemSizesDuringLayoutInvalidation = false
        }
    }

    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        let view = collectionView!
        let context = context as! InvalidationContext

        // Handle Moved Items

        if let action = context.interactiveMoveAction {
            switch action {
            case let .inProgress(info):
                if info.from != info.to {
                    layout.content.move(from: info.from, to: info.to)
                }

            case .complete:
                sendEndQueuingEditsAfterDelay()

            case let .cancelled(info):
                layout.content.move(from: info.from, to: info.to)
                sendEndQueuingEditsAfterDelay()
            }
        }

        super.invalidateLayout(with: context)

        // Handle View Width Changing

        context.viewPropertiesChanged = viewProperties != CollectionViewLayoutProperties(collectionView: view)

        // Update Needed Layout Type

        neededLayoutType.merge(with: context)
    }

    private func sendEndQueuingEditsAfterDelay() {
        ///
        /// Hello! Welcome to the source code. You're probably wondering why this perform after runloop hack is here.
        ///
        /// Well, it is because `UICollectionView` does not play well with removals that occur synchronously
        /// as a result of a reorder being messaged.
        ///
        /// Please, consider the following:
        ///
        /// 1) A user begins dragging an item.
        /// 2) They drop the item at the last point in the list; (2,1). The collection view records this index path (2,1).
        /// 3) Via `collectionView(_:moveItemAt:to:)`, we notify the observer(s) of the change.
        /// 4) Synchronously via that notification, they remove the item at (2,0), moving the item now at (2,1) to (2,0).
        ///
        /// Unfortunately, this causes `super.invalidateLayout(with: context)` to then fail with an invalid
        /// index path; because it seems to take one runloop to let the reorder "settle" through the collection view –
        /// most notably, the `context.targetIndexPathsForInteractivelyMovingItems` contains an
        /// invalid index path – the item which was previously at (2,1) is still there, when it should now be at (2,0).
        ///
        /// So thus, we queue updates a runloop to let the collection view figure its internal state out before we begin
        /// processing any further updates 🥴.
        ///

        OperationQueue.main.addOperation {
            self.delegate.listViewShouldEndQueueingEditsForReorder()
        }
    }

    override func invalidationContext(
        forInteractivelyMovingItems targetIndexPaths: [IndexPath],
        withTargetPosition targetPosition: CGPoint,
        previousIndexPaths: [IndexPath],
        previousPosition: CGPoint
    ) -> UICollectionViewLayoutInvalidationContext {
        isReordering = true

        let context = super.invalidationContext(
            forInteractivelyMovingItems: targetIndexPaths,
            withTargetPosition: targetPosition,
            previousIndexPaths: previousIndexPaths,
            previousPosition: previousPosition
        ) as! InvalidationContext

        context.interactiveMoveAction = .inProgress(
            .init(
                from: previousIndexPaths,
                fromPosition: previousPosition,
                to: targetIndexPaths,
                toPosition: targetPosition
            )
        )

        return context
    }

    override func invalidationContextForEndingInteractiveMovementOfItems(
        toFinalIndexPaths indexPaths: [IndexPath],
        previousIndexPaths: [IndexPath],
        movementCancelled: Bool
    ) -> UICollectionViewLayoutInvalidationContext {
        isReordering = false

        let context = super.invalidationContextForEndingInteractiveMovementOfItems(
            toFinalIndexPaths: indexPaths,
            previousIndexPaths: previousIndexPaths,
            movementCancelled: movementCancelled
        ) as! InvalidationContext

        context.interactiveMoveAction = {
            if movementCancelled {
                return .cancelled(
                    .init(
                        from: previousIndexPaths,
                        to: indexPaths
                    )
                )
            } else {
                return .complete(
                    .init(
                        from: previousIndexPaths,
                        to: indexPaths
                    )
                )
            }
        }()

        return context
    }

    override func shouldInvalidateLayout(forBoundsChange _: CGRect) -> Bool {
        true
    }

    private final class InvalidationContext: UICollectionViewLayoutInvalidationContext {
        var viewPropertiesChanged: Bool = false

        var interactiveMoveAction: InteractiveMoveAction?

        enum InteractiveMoveAction {
            case inProgress(InProgress)
            case complete(Complete)
            case cancelled(Cancelled)

            var shouldRelayout: Bool {
                switch self {
                case let .inProgress(info):
                    return info.from != info.to
                case .complete:
                    return false
                case .cancelled:
                    return true
                }
            }

            struct InProgress {
                var from: [IndexPath]
                var fromPosition: CGPoint

                var to: [IndexPath]
                var toPosition: CGPoint
            }

            struct Complete {
                var from: [IndexPath]
                var to: [IndexPath]
            }

            struct Cancelled {
                var from: [IndexPath]
                var to: [IndexPath]
            }
        }
    }

    //

    // MARK: Preparing For Layouts

    //

    private enum NeededLayoutType {
        case none
        case relayout
        case rebuild

        mutating func merge(with context: UICollectionViewLayoutInvalidationContext) {
            let context = context as! InvalidationContext

            let requeryDataSourceCounts = context.invalidateEverything || context.invalidateDataSourceCounts
            let needsRelayout = context.viewPropertiesChanged || context.interactiveMoveAction?.shouldRelayout ?? false

            if requeryDataSourceCounts {
                merge(with: .rebuild)
            } else if needsRelayout {
                merge(with: .relayout)
            }
        }

        mutating func merge(with new: NeededLayoutType) {
            if new.priority > priority {
                self = new
            }
        }

        private var priority: Int {
            switch self {
            case .none: return 0
            case .relayout: return 1
            case .rebuild: return 2
            }
        }

        mutating func update(with success: Bool) {
            if success {
                self = .none
            }
        }
    }

    private var neededLayoutType: NeededLayoutType = .rebuild

    override func prepare() {
        super.prepare()

        changesDuringCurrentUpdate = UpdateItems(with: [])

        let size = collectionView?.bounds.size ?? .zero

        neededLayoutType.update(with: {
            // Layouts with zero area are undefined,
            // so skip them until the view has a size.
            let shouldLayout = size.isEmpty == false

            switch self.neededLayoutType {
            case .none:
                return true
            case .relayout:
                self.performLayout()
            case .rebuild:
                self.performRebuild(andLayout: shouldLayout)
            }

            return true
        }())

        performLayoutUpdate()

        if isReordering == false {
            delegate.listViewLayoutDidLayoutContents()
        }
    }

    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)

        changesDuringCurrentUpdate = UpdateItems(with: updateItems)
    }

    //

    // MARK: Finishing Layouts

    //

    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()

        changesDuringCurrentUpdate = UpdateItems(with: [])
    }

    //

    // MARK: Performing Layouts

    //

    private func performRebuild(andLayout layout: Bool) {
        previousLayout = self.layout

        self.layout = layoutDescription.configuration.createPopulatedLayout(
            appearance: appearance,
            behavior: behavior,
            content: {
                self.delegate.listLayoutContent(defaults: $0)
            }
        )

        self.layout.scrollViewProperties.apply(
            to: collectionView!,
            behavior: behavior,
            direction: self.layout.direction,
            showsScrollIndicators: appearance.showsScrollIndicators
        )

        if layout {
            performLayout()
        }
    }

    private func performLayout() {
        let view = collectionView!

        let context = ListLayoutLayoutContext(
            collectionView: view,
            environment: delegate.listViewLayoutCurrentEnvironment()
        )

        layout.performLayout(
            with: delegate,
            in: context
        )

        viewProperties = CollectionViewLayoutProperties(collectionView: view)
    }

    private func performLayoutUpdate() {
        let view = collectionView!

        let context = ListLayoutLayoutContext(
            collectionView: view,
            environment: delegate.listViewLayoutCurrentEnvironment()
        )

        layout.positionStickyListHeaderIfNeeded(in: view)
        layout.positionStickySectionHeadersIfNeeded(in: view)

        layout.updateLayout(in: context)
    }

    //

    // MARK: UICollectionViewLayout Methods

    //

    override var collectionViewContentSize: CGSize {
        self.layout.content.contentSize
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        layout.content.layoutAttributes(in: rect, alwaysIncludeOverscroll: true)
    }

    func visibleLayoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        layout.content.layoutAttributes(in: rect, alwaysIncludeOverscroll: false)
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        layout.content.layoutAttributes(at: indexPath)
    }

    override public func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        layout.content.supplementaryLayoutAttributes(of: elementKind, at: indexPath)
    }

    //

    // MARK: UICollectionViewLayout Methods: Insertions & Removals

    //

    private func animations(for item: ListLayoutContent.ItemInfo) -> ItemInsertAndRemoveAnimations {
        if UIAccessibility.isReduceMotionEnabled {
            return .fade
        } else {
            return item.insertAndRemoveAnimations
        }
    }

    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        let wasInserted = changesDuringCurrentUpdate.insertedItems.contains(.init(newIndexPath: itemIndexPath))

        if wasInserted {
            let item = layout.content.item(at: itemIndexPath)
            let attributes = item.layoutAttributes(with: itemIndexPath)
            let animations = animations(for: item)

            var properties = ListContentLayoutAttributes(attributes)
            animations.onInsert(&properties)
            properties.apply(to: attributes)

            return attributes
        } else {
            let wasSectionInserted = changesDuringCurrentUpdate.insertedSections.contains(.init(newIndex: itemIndexPath.section))

            let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)

            if wasSectionInserted == false {
                attributes?.alpha = 1.0
            }

            return attributes
        }
    }

    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        let wasItemDeleted = changesDuringCurrentUpdate.deletedItems.contains(.init(oldIndexPath: itemIndexPath))

        if wasItemDeleted {
            let item = previousLayout.content.item(at: itemIndexPath)
            let attributes = item.layoutAttributes(with: itemIndexPath)
            let animations = animations(for: item)

            var properties = ListContentLayoutAttributes(attributes)
            animations.onRemoval(&properties)
            properties.apply(to: attributes)

            return attributes
        } else {
            let wasSectionDeleted = changesDuringCurrentUpdate.deletedSections.contains(.init(oldIndex: itemIndexPath.section))

            let attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)

            if wasSectionDeleted == false {
                attributes?.alpha = 1.0
            }

            return attributes
        }
    }

    override func initialLayoutAttributesForAppearingSupplementaryElement(ofKind elementKind: String, at elementIndexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        let wasInserted = changesDuringCurrentUpdate.insertedSections.contains(.init(newIndex: elementIndexPath.section))
        let attributes = super.initialLayoutAttributesForAppearingSupplementaryElement(ofKind: elementKind, at: elementIndexPath)

        if wasInserted == false {
            attributes?.alpha = 1.0
        }

        return attributes
    }

    override func finalLayoutAttributesForDisappearingSupplementaryElement(ofKind elementKind: String, at elementIndexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        let wasDeleted = changesDuringCurrentUpdate.deletedSections.contains(.init(oldIndex: elementIndexPath.section))
        let attributes = super.finalLayoutAttributesForDisappearingSupplementaryElement(ofKind: elementKind, at: elementIndexPath)

        if wasDeleted == false {
            attributes?.alpha = 1.0
        }

        return attributes
    }

    //

    // MARK: UICollectionViewLayout Methods: Moving Items

    //

    override func targetIndexPath(
        forInteractivelyMovingItem previousIndexPath: IndexPath,
        withPosition position: CGPoint
    ) -> IndexPath {
        /// TODO: The default implementation provided by `UICollectionView` does not work correctly
        /// when trying to move an item to the end of a section, or when trying to move an item into an
        /// empty section. We should add casing that allows moving into the section in these cases.

        super.targetIndexPath(forInteractivelyMovingItem: previousIndexPath, withPosition: position)
    }

    override func layoutAttributesForInteractivelyMovingItem(
        at indexPath: IndexPath,
        withTargetPosition position: CGPoint
    ) -> UICollectionViewLayoutAttributes {
        let original = layout.content.layoutAttributes(at: indexPath)
        let current = super.layoutAttributesForInteractivelyMovingItem(at: indexPath, withTargetPosition: position)

        var currentAttributes = ListContentLayoutAttributes(current)

        layout.adjust(
            layoutAttributesForReorderingItem: &currentAttributes,
            originalAttributes: ListContentLayoutAttributes(original),
            at: indexPath,
            withTargetPosition: position
        )

        currentAttributes.apply(to: current)

        return current
    }
}

//

// MARK: Invalidation Helpers

//

struct CollectionViewLayoutProperties: Equatable {
    let size: CGSize
    let safeAreaInsets: UIEdgeInsets
    let contentInset: UIEdgeInsets

    init() {
        size = .zero
        safeAreaInsets = .zero
        contentInset = .zero
    }

    init(collectionView: UICollectionView) {
        size = collectionView.bounds.size
        safeAreaInsets = collectionView.safeAreaInsets
        contentInset = collectionView.contentInset
    }
}

//

// MARK: Delegate For Layout Information

//

public protocol CollectionViewLayoutDelegate: AnyObject {
    func listViewLayoutUpdatedItemPositions()

    func listLayoutContent(
        defaults: ListLayoutDefaults
    ) -> ListLayoutContent

    func listViewLayoutCurrentEnvironment() -> ListEnvironment

    func listViewLayoutDidLayoutContents()

    func listViewShouldEndQueueingEditsForReorder()
}

//

// MARK: Update Information From Collection View Layout

//

private struct UpdateItems: Equatable {
    let insertedSections: Set<InsertSection>
    let deletedSections: Set<DeleteSection>

    let insertedItems: Set<InsertItem>
    let deletedItems: Set<DeleteItem>

    init(with updateItems: [UICollectionViewUpdateItem]) {
        var insertedSections = Set<InsertSection>()
        var deletedSections = Set<DeleteSection>()

        var insertedItems = Set<InsertItem>()
        var deletedItems = Set<DeleteItem>()

        for item in updateItems {
            switch item.updateAction {
            case .insert:
                let indexPath = item.indexPathAfterUpdate!

                if indexPath.item == NSNotFound {
                    insertedSections.insert(.init(newIndex: indexPath.section))
                } else {
                    insertedItems.insert(.init(newIndexPath: indexPath))
                }

            case .delete:
                let indexPath = item.indexPathBeforeUpdate!

                if indexPath.item == NSNotFound {
                    deletedSections.insert(.init(oldIndex: indexPath.section))
                } else {
                    deletedItems.insert(.init(oldIndexPath: indexPath))
                }

            case .move: break
            case .reload: break
            case .none: break

            @unknown default: listableInternalFatal()
            }
        }

        self.insertedSections = insertedSections
        self.deletedSections = deletedSections

        self.insertedItems = insertedItems
        self.deletedItems = deletedItems
    }

    struct InsertSection: Hashable {
        var newIndex: Int
    }

    struct DeleteSection: Hashable {
        var oldIndex: Int
    }

    struct InsertItem: Hashable {
        var newIndexPath: IndexPath
    }

    struct DeleteItem: Hashable {
        var oldIndexPath: IndexPath
    }
}
