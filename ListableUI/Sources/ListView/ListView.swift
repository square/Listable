//
//  ListView.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 6/16/19.
//

import UIKit

public final class ListView: UIView, KeyboardObserverDelegate {
    //

    // MARK: Initialization

    //

    public init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        // Create all default values.

        self.appearance = appearance

        behavior = Behavior()
        autoScrollAction = .none
        scrollIndicatorInsets = .zero

        storage = Storage()

        environment = .empty

        sourcePresenter = SourcePresenter(initial: StaticSource.State(), source: StaticSource())

        dataSource = DataSource()
        delegate = Delegate()

        let initialLayout = CollectionViewLayout(
            delegate: delegate,
            layoutDescription: .table(),
            appearance: self.appearance,
            behavior: behavior
        )

        collectionView = UICollectionView(
            frame: CGRect(origin: .zero, size: frame.size),
            collectionViewLayout: initialLayout
        )

        layoutManager = LayoutManager(
            layout: initialLayout,
            collectionView: collectionView
        )

        liveCells = LiveCells()

        visibleContent = VisibleContent()

        keyboardObserver = KeyboardObserver.shared
        KeyboardObserver.logKeyboardSetupWarningIfNeeded()

        stateObserver = ListStateObserver()

        collectionView.isPrefetchingEnabled = false

        collectionView.delegate = delegate
        collectionView.dataSource = dataSource

        // Super init.

        super.init(frame: frame)

        // Associate ourselves with our child objects.

        dataSource.view = self
        dataSource.presentationState = storage.presentationState
        dataSource.storage = storage
        dataSource.liveCells = liveCells

        delegate.view = self
        delegate.presentationState = storage.presentationState
        delegate.layoutManager = layoutManager

        keyboardObserver.add(delegate: self)

        // Register supplementary views.

        SupplementaryKind.allCases.forEach {
            SupplementaryContainerView.register(in: self.collectionView, for: $0.rawValue)
        }

        // Size and update views.

        collectionView.frame = bounds
        addSubview(collectionView)

        applyAppearance()
        applyBehavior()
        updateScrollViewInsets()
    }

    deinit {
        self.keyboardObserver.remove(delegate: self)

        /**
         Even though these are zeroing weak references in UIKIt as of iOS 9.0,

         We still want to nil these out, because _our_ `delegate` and `dataSource`
         objects have unowned references back to us (`ListView`). We do not want
         any `delegate` or `dataSource` callbacks to trigger referencing
         that unowned reference (eg, in `scrollViewDidScroll:`).
         */

        self.collectionView.delegate = nil
        self.collectionView.dataSource = nil
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { listableInternalFatal() }

    //

    // MARK: Internal Properties

    //

    let storage: Storage
    let collectionView: UICollectionView
    let delegate: Delegate
    let layoutManager: LayoutManager
    let liveCells: LiveCells

    var collectionViewLayout: CollectionViewLayout {
        layoutManager.collectionViewLayout
    }

    var performsContentCallbacks: Bool = true {
        didSet {
            storage.presentationState.performsContentCallbacks = performsContentCallbacks
        }
    }

    private(set) var visibleContent: VisibleContent

    //

    // MARK: Private Properties

    //

    private var sourcePresenter: AnySourcePresenter

    private var autoScrollAction: AutoScrollAction

    private let dataSource: DataSource

    private let keyboardObserver: KeyboardObserver

    //

    // MARK: Debugging

    //

    public var debuggingIdentifier: String?

    //

    // MARK: Appearance

    //

    public var appearance: Appearance {
        didSet {
            guard oldValue != appearance else {
                return
            }

            applyAppearance()
        }
    }

    private func applyAppearance() {
        // Appearance

        collectionViewLayout.appearance = appearance
        backgroundColor = appearance.backgroundColor

        // Scroll View

        updateCollectionViewWithCurrentLayoutProperties()
    }

    //

    // MARK: Layout

    //

    public var scrollPositionInfo: ListScrollPositionInfo {
        let visibleItems = Set(visibleContent.items.map { item in
            item.item.anyModel.anyIdentifier
        })

        return ListScrollPositionInfo(
            scrollView: collectionView,
            visibleItems: visibleItems,
            isFirstItemVisible: content.firstItem.map { visibleItems.contains($0.anyIdentifier) } ?? false,
            isLastItemVisible: content.lastItem.map { visibleItems.contains($0.anyIdentifier) } ?? false
        )
    }

    public var layout: LayoutDescription {
        get { collectionViewLayout.layoutDescription }
        set { set(layout: newValue, animated: false) }
    }

    public func set(layout new: LayoutDescription, animated: Bool = false, completion: @escaping () -> Void = {})
    {
        let needsInsetUpdate = layout.needsCollectionViewInsetUpdate(for: new)

        layoutManager.set(layout: new, animated: animated, completion: completion)

        if needsInsetUpdate {
            updateScrollViewInsets()
        }
    }

    public var contentSize: CGSize {
        collectionViewLayout.layout.content.contentSize
    }

    //

    // MARK: Behavior

    //

    public var behavior: Behavior {
        didSet {
            guard oldValue != behavior else {
                return
            }

            applyBehavior()
        }
    }

    private func applyBehavior() {
        collectionViewLayout.behavior = behavior

        collectionView.keyboardDismissMode = behavior.keyboardDismissMode

        collectionView.canCancelContentTouches = behavior.canCancelContentTouches
        collectionView.delaysContentTouches = behavior.delaysContentTouches

        updateCollectionViewWithCurrentLayoutProperties()
        updateCollectionViewSelectionMode()

        updateScrollViewInsets()
    }

    private func updateCollectionViewWithCurrentLayoutProperties() {
        collectionViewLayout.layout.scrollViewProperties.apply(
            to: collectionView,
            behavior: behavior,
            direction: collectionViewLayout.layout.direction,
            showsScrollIndicators: appearance.showsScrollIndicators
        )
    }

    private func updateCollectionViewSelectionMode() {
        let view = collectionView

        switch behavior.selectionMode {
        case .none:
            view.allowsSelection = false
            view.allowsMultipleSelection = false

        case .single:
            view.allowsSelection = true
            view.allowsMultipleSelection = false

        case .multiple:
            view.allowsSelection = true
            view.allowsMultipleSelection = true
        }
    }

    //

    // MARK: Scroll Insets

    //

    public var scrollIndicatorInsets: UIEdgeInsets {
        didSet {
            guard oldValue != scrollIndicatorInsets else {
                return
            }

            updateScrollViewInsets()
        }
    }

    private func updateScrollViewInsets() {
        let (contentInsets, scrollIndicatorInsets) = calculateScrollViewInsets(
            with: keyboardObserver.currentFrame(in: self)
        )

        if collectionView.contentInset != contentInsets {
            collectionView.contentInset = contentInsets
        }

        if collectionView.scrollIndicatorInsets != scrollIndicatorInsets {
            collectionView.scrollIndicatorInsets = scrollIndicatorInsets
        }
    }

    func calculateScrollViewInsets(with keyboardFrame: KeyboardObserver.KeyboardFrame?) -> (UIEdgeInsets, UIEdgeInsets)
    {
        let keyboardBottomInset: CGFloat = {
            guard let keyboardFrame = keyboardFrame else {
                return 0.0
            }

            guard layout.wantsKeyboardInsetAdjustment else {
                return 0.0
            }

            switch self.behavior.keyboardAdjustmentMode {
            case .none:
                return 0.0

            case .adjustsWhenVisible:
                switch keyboardFrame {
                case .nonOverlapping:
                    return 0.0

                case let .overlapping(frame):
                    return (self.bounds.size.height - frame.origin.y) - self.safeAreaInsets.bottom
                }
            }
        }()

        let scrollIndicatorInsets = modified(scrollIndicatorInsets) {
            $0.bottom = max($0.bottom, keyboardBottomInset)
        }

        let contentInsets = modified(collectionView.contentInset) {
            $0.bottom = keyboardBottomInset
        }

        return (contentInsets, scrollIndicatorInsets)
    }

    //

    // MARK: KeyboardObserverDelegate

    //

    private var lastKeyboardFrame: KeyboardObserver.KeyboardFrame?

    func keyboardFrameWillChange(for _: KeyboardObserver, animationDuration: Double, options: UIView.AnimationOptions) {
        guard let frame = keyboardObserver.currentFrame(in: self) else {
            return
        }

        guard lastKeyboardFrame != frame else {
            return
        }

        lastKeyboardFrame = frame

        UIView.animate(withDuration: animationDuration, delay: 0.0, options: options, animations: {
            self.updateScrollViewInsets()
        })
    }

    //

    // MARK: List State Observation

    //

    /// A state observer allows you to receive callbacks when varying types
    /// of changes occur within the list's state, such as scroll events,
    /// content change events, frame change events, or item visibility changes.
    ///
    /// See the `ListStateObserver` for more info.
    public var stateObserver: ListStateObserver

    /// Allows registering a `ListActions` object associated
    /// with the list view that allows you to perform actions such as scrolling to
    /// items, or controlling view appearance transitions.
    private var actions: ListActions? {
        didSet {
            oldValue?.listView = nil

            actions?.listView = self
        }
    }

    //

    // MARK: Public - Scrolling To Sections & Items

    //

    /// TODO: The below functions do not yet work for horizontal lists.
    /// A pass needs to be done to change math and offsets based on the `LayoutDirection`
    /// of the current layout.

    public typealias ScrollCompletion = (Bool) -> Void

    ///
    /// Scrolls to the provided item, with the provided positioning.
    /// If the item is contained in the list, true is returned. If it is not, false is returned.
    ///
    @discardableResult
    public func scrollTo(
        item: AnyItem,
        position: ScrollPosition,
        animation: ViewAnimation = .none,
        completion: @escaping ScrollCompletion = { _ in }
    ) -> Bool {
        scrollTo(
            item: item.anyIdentifier,
            position: position,
            animation: animation,
            completion: completion
        )
    }

    private var hasLoggedHorizontalScrollToWarning: Bool = false

    private func logHorizontalScrollToWarning() {
        guard collectionViewLayout.layout.direction == .horizontal else { return }

        if hasLoggedHorizontalScrollToWarning { return }

        hasLoggedHorizontalScrollToWarning = true

        print(
            """
            Hello! It looks like you are using one of the `scrollTo...` family of APIs.

            These have not yet been updated to support `.horizontal` layouts, and thus, will
            likely not work as expected.

            Please let us know you're looking for this feature in #listable on Slack.
            """
        )
    }

    ///
    /// Scrolls to the item with the provided identifier, with the provided positioning.
    /// If there is more than one item with the same identifier, the list scrolls to the first.
    /// If the item is contained in the list, true is returned. If it is not, false is returned.
    ///
    @discardableResult
    public func scrollTo(
        item: AnyIdentifier,
        position: ScrollPosition,
        animation: ViewAnimation = .none,
        completion: @escaping ScrollCompletion = { _ in }
    ) -> Bool {
        logHorizontalScrollToWarning()

        // Make sure the item identifier is valid.

        guard let toIndexPath = storage.allContent.firstIndexPathForItem(with: item) else {
            return false
        }

        return preparePresentationStateForScroll(to: toIndexPath) {
            let itemFrame = self.collectionViewLayout.frameForItem(at: toIndexPath)

            let isAlreadyVisible = self.collectionView.visibleContentFrame.contains(itemFrame)

            // If the item is already visible and that's good enough, return.

            if isAlreadyVisible, position.ifAlreadyVisible == .doNothing {
                return
            }

            let scroll: () -> Void = {
                let sectionHeader = self.collectionViewLayout.layout.content.sections[toIndexPath.section].header

                // Prevent the item from appearing underneath a sticky section header.

                if sectionHeader.isPopulated,
                   self.collectionViewLayout.layout.stickySectionHeaders,
                   position.position == .top
                {
                    let itemFrameAdjustedForStickyHeaders = CGRect(
                        x: itemFrame.minX,
                        y: itemFrame.minY - sectionHeader.size.height,
                        width: itemFrame.width,
                        height: itemFrame.height
                    )
                    self.performScroll(to: itemFrameAdjustedForStickyHeaders, scrollPosition: position)

                } else {
                    self.collectionView.scrollToItem(
                        at: toIndexPath,
                        at: position.position.toUICollectionViewScrollPosition(for: self.collectionViewLayout.layout.direction),
                        animated: false
                    )
                }
            }

            animation.perform(
                animations: scroll,
                completion: completion
            )
        }
    }

    ///
    /// Scrolls to the section with the given identifier, with the provided scroll and section positioning.
    ///
    /// If there is more than one section with the same identifier, the list scrolls to the first.
    /// If the section has any content and is contained in the list, true is returned. If not, false is returned.
    ///
    /// The list will first attempt to scroll to the section's supplementary view
    /// (header for `SectionPosition.top`, footer for `SectionPosition.bottom`).
    ///
    /// If not found, the list will scroll to the adjacent item instead
    /// (section's first item for `.top`, last item for `.bottom`).
    ///
    /// If none of the above are present, the list will fallback to the remaining supplementary view
    /// (footer for `.top`, header for `.bottom`).
    ///
    @discardableResult
    public func scrollToSection(
        with identifier: AnyIdentifier,
        sectionPosition: SectionPosition = .top,
        scrollPosition: ScrollPosition,
        animation: ViewAnimation = .none,
        completion: @escaping ScrollCompletion = { _ in }
    ) -> Bool {
        logHorizontalScrollToWarning()

        let storageContent = storage.allContent

        // Make sure the section identifier is valid.

        guard let sectionIndex = storageContent.firstIndexForSection(with: identifier) else {
            return false
        }

        return preparePresentationStateForScrollToSection(index: sectionIndex) {
            let layoutContent = self.collectionViewLayout.layout.content

            // Make sure the section has content.

            guard layoutContent.sections[sectionIndex].all.isEmpty == false else {
                return
            }
            let header = layoutContent.sections[sectionIndex].header
            let footer = layoutContent.sections[sectionIndex].footer
            let items = storageContent.sections[sectionIndex].items

            let targetSupplementaryView = (sectionPosition == .top) ? header : footer
            let fallbackSupplementaryView = (sectionPosition == .top) ? footer : header
            let adjacentItem = (sectionPosition == .top) ? items.first : items.last

            // Prevent the footer from appearing underneath a sticky section header.

            let footerFrameAdjustedForStickyHeaders: CGRect? = {
                guard sectionPosition == .bottom,
                      self.collectionViewLayout.layout.stickySectionHeaders,
                      scrollPosition.position == .top
                else {
                    return nil
                }
                return CGRect(
                    x: footer.x,
                    y: footer.y - header.size.height,
                    width: footer.size.width,
                    height: footer.size.height
                )
            }()

            if targetSupplementaryView.isPopulated {
                self.performScroll(
                    to: footerFrameAdjustedForStickyHeaders ?? targetSupplementaryView.defaultFrame,
                    scrollPosition: scrollPosition,
                    animation: animation,
                    completion: completion
                )
            } else if let adjacentItem = adjacentItem {
                self.scrollTo(
                    item: adjacentItem,
                    position: scrollPosition,
                    animation: animation,
                    completion: completion
                )
            } else {
                self.performScroll(
                    to: fallbackSupplementaryView.defaultFrame,
                    scrollPosition: scrollPosition,
                    animation: animation,
                    completion: completion
                )
            }
        }
    }

    /// Scrolls to the very top of the list, which includes displaying the list header.
    @discardableResult
    public func scrollToTop(
        animation: ViewAnimation = .none,
        completion: @escaping ScrollCompletion = { _ in }
    ) -> Bool {
        logHorizontalScrollToWarning()

        // The rect we scroll to must have an area – an empty rect will result in no scrolling.
        let rect = CGRect(origin: .zero, size: CGSize(width: 1.0, height: 1.0))

        return preparePresentationStateForScroll(to: IndexPath(item: 0, section: 0)) {
            animation.perform(
                animations: {
                    self.collectionView.scrollRectToVisible(rect, animated: false)
                },
                completion: completion
            )
        }
    }

    /// Scrolls to the last item in the list. If the list contains no items, no action is performed.
    @discardableResult
    public func scrollToLastItem(
        animation: ViewAnimation = .none,
        completion: @escaping ScrollCompletion = { _ in }
    ) -> Bool {
        logHorizontalScrollToWarning()

        // Make sure we have a valid last index path.

        guard let toIndexPath = storage.allContent.lastIndexPath() else {
            return false
        }

        // Perform scrolling.

        return preparePresentationStateForScroll(to: toIndexPath) {
            let contentHeight = self.collectionViewLayout.collectionViewContentSize.height
            let contentFrameHeight = self.collectionView.visibleContentFrame.height

            guard contentHeight > contentFrameHeight else {
                return
            }

            let contentOffsetY = contentHeight - contentFrameHeight - self.collectionView.adjustedContentInset.top
            let contentOffset = CGPoint(x: self.collectionView.contentOffset.x, y: contentOffsetY)

            animation.perform(
                animations: {
                    self.collectionView.setContentOffset(contentOffset, animated: false)
                },
                completion: completion
            )
        }
    }

    //

    // MARK: Setting & Getting Content

    //

    /// The environment associated with the list, which is used to pass data through to
    /// the list's layout, or through to items, headers/footers, etc.
    ///
    /// If you have used SwiftUI's environment, Listable's environment is similar.
    ///
    /// ### Note
    /// Setting the environment, or a property on the environment, does **not** force a re-layout
    /// of the list view. The newly provided environment values will be used during the next update.
    public var environment: ListEnvironment

    public var content: Content {
        get { storage.allContent }
        set { setContent(animated: false, newValue) }
    }

    public func setContent(animated: Bool = false, _ content: Content) {
        set(
            source: StaticSource(with: content),
            initial: StaticSource.State(),
            animated: animated
        )
    }

    private var sourceChangedTimer: ReloadTimer?

    @discardableResult
    public func set<Source: ListViewSource>(source: Source, initial: Source.State, animated: Bool = false) -> StateAccessor<Source.State>
    {
        self.sourcePresenter.discard()

        let sourcePresenter = SourcePresenter(initial: initial, source: source, didChange: { [weak self] in
            guard let self = self else { return }
            guard self.sourceChangedTimer == nil else { return }

            self.sourceChangedTimer = ReloadTimer {
                self.sourceChangedTimer = nil
                self.setContentFromSource(animated: true)
            }
        })

        self.sourcePresenter = sourcePresenter

        setContentFromSource(animated: animated)

        return StateAccessor(get: {
            sourcePresenter.state
        }, set: {
            sourcePresenter.state = $0
        })
    }

    public func configure(with configure: ListProperties.Configure) {
        let description = ListProperties(
            animatesChanges: true,
            layout: layout,
            appearance: appearance,
            scrollIndicatorInsets: scrollIndicatorInsets,
            behavior: behavior,
            autoScrollAction: autoScrollAction,
            accessibilityIdentifier: collectionView.accessibilityIdentifier,
            debuggingIdentifier: debuggingIdentifier,
            configure: configure
        )

        self.configure(with: description)
    }

    let updateQueue = ListChangesQueue()

    public func configure(with properties: ListProperties) {
        /// We enqueue these changes into the update queue to ensure they are not applied
        /// before it is safe to do so. Currently, "safe" means "during the application of a reorder".
        ///
        /// See `CollectionViewLayout.sendEndQueuingEditsAfterDelay()` for more.

        updateQueue.add { [weak self] in
            guard let self = self else { return }

            let animated = properties.animatesChanges

            self.appearance = properties.appearance
            self.behavior = properties.behavior
            self.autoScrollAction = properties.autoScrollAction
            self.scrollIndicatorInsets = properties.scrollIndicatorInsets
            self.collectionView.accessibilityIdentifier = properties.accessibilityIdentifier
            self.debuggingIdentifier = properties.debuggingIdentifier
            self.actions = properties.actions

            self.stateObserver = properties.stateObserver

            self.environment = properties.environment

            self.set(layout: properties.layout, animated: animated)

            self.setContent(animated: animated, properties.content)
        }
    }

    private func setContentFromSource(animated: Bool = false) {
        let oldIdentifier = storage.allContent.identifier

        storage.allContent = sourcePresenter.reloadContent()

        let newIdentifier = storage.allContent.identifier
        let identifierChanged = oldIdentifier != newIdentifier

        storage.presentationState.context = storage.allContent.context

        updatePresentationState(for: .contentChanged(animated: animated, identifierChanged: identifierChanged))
    }

    //

    // MARK: UIView

    //

    @available(*, unavailable, message: "sizeThatFits does not re-measure the size of the list. Use ListView.contentSize(in:for:) instead.")
    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        super.sizeThatFits(size)
    }

    @available(*, unavailable, message: "intrinsicContentSize does not re-measure the size of the list. Use ListView.contentSize(in:for:) instead.")
    override public var intrinsicContentSize: CGSize {
        super.intrinsicContentSize
    }

    override public var frame: CGRect {
        didSet {
            self.frameDidChange(from: oldValue, to: self.frame)
        }
    }

    override public var bounds: CGRect {
        get { super.bounds }

        set {
            let oldValue = frame

            super.bounds = newValue

            frameDidChange(from: oldValue, to: frame)
        }
    }

    private func frameDidChange(from old: CGRect, to new: CGRect) {
        /// Set the frame explicitly, so that the layout can occur
        /// within performBatchUpdates. Waiting for layoutSubviews() is too late.
        collectionView.frame = bounds

        /// If nothing has changed, there's no work here – return early.
        guard old != new else {
            return
        }

        /// Once the view actually has a size, we can provide content.
        ///
        /// There's no value in having content with no view size, as we cannot size cells otherwise.
        let fromEmpty = old.size.isEmpty && new.size.isEmpty == false
        let toEmpty = old.size.isEmpty == false && new.size.isEmpty

        if fromEmpty {
            updatePresentationState(for: .transitionedToBounds(isEmpty: false))
        } else if toEmpty {
            updatePresentationState(for: .transitionedToBounds(isEmpty: true))
        }

        /// Our frame changed, update the keyboard inset in case the inset should now be different.
        updateScrollViewInsets()

        ListStateObserver.perform(stateObserver.onFrameChanged, "Frame Changed", with: self) { actions in
            ListStateObserver.FrameChanged(
                actions: actions,
                positionInfo: self.scrollPositionInfo,
                old: old,
                new: new
            )
        }
    }

    override public var backgroundColor: UIColor? {
        didSet {
            self.collectionView.backgroundColor = self.backgroundColor
        }
    }

    override public func didMoveToWindow() {
        super.didMoveToWindow()

        if window != nil {
            updateScrollViewInsets()
        }
    }

    override public func didMoveToSuperview() {
        super.didMoveToSuperview()

        if superview != nil {
            updateScrollViewInsets()
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        collectionView.frame = bounds

        /// Our layout changed, update the keyboard inset in case the inset should now be different.
        updateScrollViewInsets()
    }

    //

    // MARK: Internal - Updating Content

    //

    internal func setPresentationStateItemPositions() {
        storage.presentationState.forEachItem { indexPath, item in
            item.itemPosition = self.collectionViewLayout.positionForItem(at: indexPath)
        }
    }

    private func updateCollectionViewSelections(animated: Bool) {
        let oldSelected: Set<IndexPath> = Set(collectionView.indexPathsForSelectedItems ?? [])
        let newSelected: Set<IndexPath> = Set(storage.presentationState.selectedIndexPaths)

        let removed = oldSelected.subtracting(newSelected)
        let added = newSelected.subtracting(oldSelected)

        let view = collectionView
        let state = storage.presentationState

        removed.forEach {
            let item = state.item(at: $0)
            view.deselectItem(at: $0, animated: animated)
            item.applyToVisibleCell(with: self.environment)
        }

        added.forEach {
            let item = state.item(at: $0)
            view.selectItem(at: $0, animated: animated, scrollPosition: [])
            item.applyToVisibleCell(with: self.environment)
        }
    }

    //

    // MARK: Internal - Updating Presentation State

    //

    internal func updatePresentationState(
        for reason: PresentationState.UpdateReason,
        completion callerCompletion: @escaping (Bool) -> Void = { _ in }
    ) {
        SignpostLogger.log(.begin, log: .updateContent, name: "List Update", for: self)

        let completion = { (completed: Bool) in
            callerCompletion(completed)
            SignpostLogger.log(.end, log: .updateContent, name: "List Update", for: self)
        }

        let indexPaths = collectionView.indexPathsForVisibleItems

        let indexPath = indexPaths.first

        let presentationStateTruncated = storage.presentationState.containsAllItems == false

        switch reason {
        case .scrolledDown:
            let needsUpdate = collectionView.isScrolledNearBottom() && presentationStateTruncated

            if needsUpdate {
                updatePresentationStateWith(firstVisibleIndexPath: indexPath, for: reason, completion: completion)
            } else {
                completion(true)
            }

        case .contentChanged:
            updatePresentationStateWith(firstVisibleIndexPath: indexPath, for: reason, completion: completion)

        case .didEndDecelerating:
            if presentationStateTruncated {
                updatePresentationStateWith(firstVisibleIndexPath: indexPath, for: reason, completion: completion)
            } else {
                completion(true)
            }

        case .scrolledToTop:
            if presentationStateTruncated {
                updatePresentationStateWith(firstVisibleIndexPath: IndexPath(item: 0, section: 0), for: reason, completion: completion)
            } else {
                completion(true)
            }

        case .transitionedToBounds:
            updatePresentationStateWith(firstVisibleIndexPath: indexPath, for: reason, completion: completion)

        case let .programaticScrollDownTo(scrollToIndexPath):
            updatePresentationStateWith(firstVisibleIndexPath: scrollToIndexPath, for: reason, completion: completion)
        }
    }

    private func updatePresentationStateWith(
        firstVisibleIndexPath indexPath: IndexPath?,
        for reason: PresentationState.UpdateReason,
        completion callerCompletion: @escaping (Bool) -> Void
    ) {
        // Figure out visible content.

        let presentationState = storage.presentationState

        let indexPath = indexPath ?? IndexPath(item: 0, section: 0)

        let visibleSlice = newVisibleSlice(to: indexPath)

        let diff = SignpostLogger.log(log: .updateContent, name: "Diff Content", for: self) {
            ListView.diffWith(old: presentationState.sectionModels, new: visibleSlice.content.sections)
        }

        let updateCallbacks = UpdateCallbacks(.queue, wantsAnimations: reason.animated)

        let updateBackingData = {
            let dependencies = ItemStateDependencies(
                reorderingDelegate: self,
                coordinatorDelegate: self,
                environmentProvider: { [weak self] in self?.environment ?? .empty }
            )

            presentationState.update(
                with: diff,
                slice: visibleSlice,
                reason: .wasUpdated,
                animated: reason.animated,
                dependencies: dependencies,
                updateCallbacks: updateCallbacks,
                loggable: self
            )
        }

        // Update Refresh Control

        /**
         Update Refresh Control

         Note: Must be called *OUTSIDE* of CollectionView's `performBatchUpdates:`, otherwise
         we trigger a bug where updated indexes are calculated incorrectly.
         */
        presentationState.updateRefreshControl(with: visibleSlice.content.refreshControl, in: collectionView)

        // Update Collection View

        performBatchUpdates(with: diff, animated: reason.animated, updateBackingData: updateBackingData, completion: callerCompletion)

        // Update the offset of the scroll view to show the refresh control if needed
        presentationState.adjustContentOffsetForRefreshControl(in: collectionView)

        // Perform any needed auto scroll actions.
        performAutoScrollAction(with: diff.changes.addedItemIdentifiers, animated: reason.animated)

        // Update info for new contents.

        updateCollectionViewSelections(animated: reason.animated)

        // Notify updates.

        updateCallbacks.perform()

        // Notify state reader the content updated.

        if case .contentChanged = reason {
            ListStateObserver.perform(self.stateObserver.onContentUpdated, "Content Updated", with: self) { actions in
                ListStateObserver.ContentUpdated(
                    hadChanges: diff.changes.isEmpty == false,
                    insertionsAndRemovals: .init(diff: diff),
                    actions: actions,
                    positionInfo: self.scrollPositionInfo
                )
            }
        }
    }

    private func newVisibleSlice(to indexPath: IndexPath) -> Content.Slice {
        if bounds.isEmpty {
            return Content.Slice()
        } else {
            switch autoScrollAction {
            case let .scrollToItem(insertInfo):
                let itemPath = storage.allContent.firstIndexPathForItem(with: insertInfo.insertedIdentifier)
                guard let autoScrollIndexPath = itemPath else {
                    fallthrough
                }

                let greaterIndexPath = max(autoScrollIndexPath, indexPath)
                return storage.allContent.sliceTo(indexPath: greaterIndexPath)

            case .none, .pin:

                return storage.allContent.sliceTo(indexPath: indexPath)
            }
        }
    }

    private func performAutoScrollAction(with addedItems: Set<AnyIdentifier>, animated: Bool) {
        switch autoScrollAction {
        case .none:
            return

        case let .scrollToItem(info):
            let wasInserted = addedItems.contains(info.insertedIdentifier)

            if wasInserted, info.shouldPerform(scrollPositionInfo) {
                /// Only animate the scroll if both the update **and** the scroll action are animated.
                let animation = info.animation.and(with: animated)

                if let destination = info.destination.destination(with: content) {
                    scrollTo(item: destination, position: info.position, animation: animation) { _ in
                        info.didPerform(self.scrollPositionInfo)
                    }
                }
            }

        case let .pin(pin):
            if pin.shouldPerform(scrollPositionInfo) {
                /// Only animate the scroll if both the update **and** the scroll action are animated.
                let animation = pin.animation.and(with: animated)

                if let destination = pin.destination.destination(with: content) {
                    scrollTo(item: destination, position: pin.position, animation: animation) { _ in
                        pin.didPerform(self.scrollPositionInfo)
                    }
                }
            }
        }
    }

    private func performScroll(
        to targetFrame: CGRect,
        scrollPosition: ScrollPosition,
        animation: ViewAnimation = .none,
        completion: @escaping ScrollCompletion = { _ in }
    ) {
        // If the item is already visible and that's good enough, return.

        let isAlreadyVisible = collectionView.visibleContentFrame.contains(targetFrame)
        if isAlreadyVisible, scrollPosition.ifAlreadyVisible == .doNothing {
            return
        }

        let topInset = collectionView.adjustedContentInset.top
        let contentFrameHeight = collectionView.visibleContentFrame.height
        let adjustedOriginY = targetFrame.origin.y - topInset

        var resultOffset = collectionView.contentOffset

        switch scrollPosition.position {
        case .top:
            resultOffset.y = adjustedOriginY
        case .centered:
            resultOffset.y = adjustedOriginY - (contentFrameHeight / 2 - targetFrame.size.height / 2)
        case .bottom:
            resultOffset.y = adjustedOriginY - (contentFrameHeight - targetFrame.size.height)
        }

        // Don't scroll past the bottom of the list.

        let maxOffsetHeight = collectionViewLayout.collectionViewContentSize.height - contentFrameHeight - topInset
        resultOffset.y = min(resultOffset.y, maxOffsetHeight)

        // Don't scroll beyond the top of the list.

        resultOffset.y = max(resultOffset.y, -topInset)

        animation.perform(
            animations: {
                self.collectionView.setContentOffset(resultOffset, animated: false)
            },
            completion: completion
        )
    }

    private func preparePresentationStateForScroll(to toIndexPath: IndexPath, scroll: @escaping () -> Void) -> Bool {
        // Make sure we have a last loaded index path.

        guard let lastLoadedIndexPath = storage.presentationState.lastIndexPath else {
            return false
        }

        // Update presentation state if needed, then scroll.

        if lastLoadedIndexPath < toIndexPath {
            updatePresentationState(for: .programaticScrollDownTo(toIndexPath)) { _ in
                scroll()
            }
        } else {
            scroll()
        }

        return true
    }

    private func preparePresentationStateForScrollToSection(index: Int, scroll: @escaping () -> Void) -> Bool {
        // Make sure section is contained within all content.

        guard index < storage.allContent.sections.count else {
            return false
        }

        // Update presentation state if needed, then scroll.

        if index >= storage.presentationState.sections.count {
            let toIndexPath = IndexPath(item: 0, section: index)
            updatePresentationState(for: .programaticScrollDownTo(toIndexPath)) { _ in
                scroll()
            }
        } else {
            scroll()
        }

        return true
    }

    private func performBatchUpdates(
        with diff: SectionedDiff<Section, AnyIdentifier, AnyItem, AnyIdentifier>,
        animated: Bool,
        updateBackingData: @escaping () -> Void,
        completion callerCompletion: @escaping (Bool) -> Void
    ) {
        SignpostLogger.log(.begin, log: .updateContent, name: "Update UICollectionView", for: self)

        let completion = { (completed: Bool) in
            callerCompletion(completed)
            SignpostLogger.log(.end, log: .updateContent, name: "Update UICollectionView", for: self)
        }

        let view = collectionView

        let changes = CollectionViewChanges(sectionChanges: diff.changes)

        let batchUpdates = {
            updateBackingData()

            // Sections

            view.deleteSections(IndexSet(changes.deletedSections.map(\.oldIndex)))
            view.insertSections(IndexSet(changes.insertedSections.map(\.newIndex)))

            changes.movedSections.forEach {
                view.moveSection($0.oldIndex, toSection: $0.newIndex)
            }

            // Items

            view.deleteItems(at: changes.deletedItems.map(\.oldIndex))
            view.insertItems(at: changes.insertedItems.map(\.newIndex))

            changes.movedItems.forEach {
                view.moveItem(at: $0.oldIndex, to: $0.newIndex)
            }
        }

        if changes.hasIndexAffectingChanges {
            if hasInProgressReorders {
                print(
                    """
                    LISTABLE WARNING: Reordering while applying an update diff that has changes which affect index \
                    path stability is currently experimental, and will likely crash. A fix is planned, but this \
                    warning is here so you know what to expect.
                    """
                )
            }

            cancelAllInProgressReorders()
        }

        collectionViewLayout.setShouldAskForItemSizesDuringLayoutInvalidation()

        if animated {
            view.performBatchUpdates(batchUpdates, completion: completion)
        } else {
            UIView.performWithoutAnimation {
                view.performBatchUpdates(batchUpdates, completion: completion)
            }
        }
    }

    private static func diffWith(old: [Section], new: [Section]) -> SectionedDiff<Section, AnyIdentifier, AnyItem, AnyIdentifier>
    {
        SectionedDiff(
            old: old,
            new: new,
            configuration: SectionedDiff.Configuration(
                section: .init(
                    identifier: { $0.identifier },
                    items: { $0.items },
                    movedHint: { $0.identifier != $1.identifier }
                ),
                item: .init(
                    identifier: { $0.anyIdentifier },
                    updated: { $0.anyIsEquivalent(to: $1) == false },
                    movedHint: { $0.anyWasMoved(comparedTo: $1) }
                )
            )
        )
    }
}

public extension ListView {
    ///
    /// Call this method to force an immediate, synchronous re-render of the list
    /// and its content when writing unit or snapshot tests. This avoids needing to
    /// spin the runloop or needing to use test expectations to wait for content
    /// to be rendered asynchronously.
    ///
    /// **WARNING**: You must **not** call this method outside of tests. Doing so will cause a fatal error.
    ///
    func testing_forceLayoutUpdateNow() {
        guard NSClassFromString("XCTestCase") != nil else {
            fatalError("You must not call testing_forceLayoutUpdateNow outside of an XCTest environment.")
        }

        collectionView.reloadData()
    }
}

extension ListView: ItemContentCoordinatorDelegate {
    func coordinatorUpdated(for _: AnyItem) {
        collectionViewLayout.setNeedsRelayout()
        collectionView.layoutIfNeeded()
    }
}

extension ListView: ReorderingActionsDelegate {
    //

    // MARK: Internal - Moving Items

    //

    func beginReorder(for item: AnyPresentationItemState) -> Bool {
        guard let indexPath = storage.presentationState.indexPath(for: item) else {
            return false
        }

        if collectionView.beginInteractiveMovementForItem(at: indexPath) {
            item.beginReorder(from: indexPath, with: environment)

            return true
        } else {
            return false
        }
    }

    func updateReorderTargetPosition(
        with recognizer: ItemReordering.GestureRecognizer,
        for _: AnyPresentationItemState
    ) {
        guard let position = recognizer.reorderPosition(in: collectionView) else {
            return
        }

        collectionView.updateInteractiveMovementTargetPosition(position)
    }

    func endReorder(for item: AnyPresentationItemState, with result: ReorderingActions.Result) {
        item.endReorder(with: environment, result: result)

        switch result {
        case .finished:
            collectionView.endInteractiveMovement()
        case .cancelled:
            collectionView.cancelInteractiveMovement()
        }
    }

    func accessibilityMove(item: AnyPresentationItemState, direction: ReorderingActions.AccessibilityMoveDirection) -> Bool {
        guard let indexPath = storage.presentationState.indexPath(for: item),
              dataSource.collectionView(self.collectionView, canMoveItemAt: indexPath)
        else {
            return false
        }

        let destinationPath: IndexPath
        switch direction {
        case .up:
            // Moving an item up means decrementing the index.
            if indexPath.row == 0 {
                // First item in section, we should go to the previous section
                if indexPath.section > 0 {
                    let newSection = indexPath.section - 1
                    let rowInNewSection = storage.allContent.sections[indexPath.section - 1].count
                    destinationPath = IndexPath(row: rowInNewSection, section: newSection)
                } else {
                    // Unable to move up, we are item 0,0.
                    return false
                }
            } else {
                destinationPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
            }

        case .down:
            // Moving an item down means incrementing the index.
            if indexPath.row == storage.allContent.sections[indexPath.section].count - 1 {
                // we are the last item our section, lets see if there's another section we can move down to
                if storage.allContent.sections.count - 1 > indexPath.section {
                    destinationPath = IndexPath(row: 0, section: indexPath.section + 1)
                } else {
                    // Unable to move down, we are the last item in the last section.
                    return false
                }
            } else {
                destinationPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
            }
        }

        let targetPath = delegate.collectionView(collectionView, targetIndexPathForMoveFromItemAt: indexPath, toProposedIndexPath: destinationPath)

        /*  We are responding to a user event, but won't be using the `InteractiveMovement` API the collection view provides as we are being called from an accessibility action rather than a gesture regognizer. This means we'll have to call out to the dataSource directly.

             NOTE: It's Important that we call `dataSource.collectionView(_ :, moveItemAt:, to:)` to perform the move in the data source before calling `collectionView.moveItem(at:, to:)` to update the collection view itself.
         */

        item.beginReorder(from: indexPath, with: environment)
        dataSource.collectionView(collectionView, moveItemAt: indexPath, to: targetPath)
        collectionView.moveItem(at: indexPath, to: targetPath)
        item.endReorder(with: environment, result: .finished)

        return true
    }

    func cancelAllInProgressReorders() {
        storage.presentationState.forEachItem { _, item in
            item.endReorder(with: self.environment, result: .cancelled)
        }

        collectionView.cancelInteractiveMovement()
    }

    private var hasInProgressReorders: Bool {
        for section in storage.presentationState.sections {
            for item in section.items {
                if item.isReordering {
                    return true
                }
            }
        }

        return false
    }
}

extension ListView: SignpostLoggable {
    var signpostInfo: SignpostLoggingInfo {
        SignpostLoggingInfo(
            identifier: debuggingIdentifier,
            instanceIdentifier: String(format: "%p", unsafeBitCast(self, to: Int.self))
        )
    }
}

private extension UIScrollView {
    func isScrolledNearBottom() -> Bool {
        let viewHeight = bounds.size.height

        // We are within one half view height from the bottom of the content.
        return contentOffset.y + (viewHeight * 1.5) > contentSize.height
    }
}
