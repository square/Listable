//
//  ListView.swift
//  Listable
//
//  Created by Kyle Van Essen on 6/16/19.
//

import UIKit


public final class ListView : UIView
{
    //
    // MARK: Initialization
    //
    
    public init(frame: CGRect = .zero, appearance : Appearance = Appearance())
    {
        // Create all default values.
        
        self.appearance = appearance
        
        self.behavior = Behavior()
        self.scrollInsets = ScrollInsets(top: nil, bottom:  nil)
        
        self.storage = Storage()
        self.sourcePresenter = SourcePresenter(initial: StaticSource.State(), source: StaticSource())
        
        self.dataSource = DataSource(presentationState: self.storage.presentationState)
        
        self.delegate = Delegate(presentationState: self.storage.presentationState)
        self.layoutDelegate = LayoutDelegate(presentationState: self.storage.presentationState, appearance: self.appearance)
        
        self.layout = ListViewLayout(
            delegate: self.layoutDelegate,
            appearance: self.appearance
        )
        
        self.collectionView = UICollectionView(frame: CGRect(origin: .zero, size: frame.size), collectionViewLayout: self.layout)
        
        self.keyboardObserver = KeyboardObserver()
        
        if #available(iOS 10.0, *) {
            self.collectionView.isPrefetchingEnabled = false
        }
                
        self.collectionView.dataSource = self.dataSource
        self.collectionView.delegate = self.delegate
        
        // Super init.
        
        super.init(frame: frame)
        
        // ...And now that we're initialized...
        
        // Set up Delegate callbacks.
        
        self.delegate.actions = Delegate.Actions(
            updatePresentationState: { reason in
                self.updatePresentationState(for: reason)
            },
            moveItem: { from, to in
                self.storage.moveItem(from: from, to: to)
            },
            updateVisibleItems: {
                self.updateVisibleItemsAndSections()
            },
            dismissesKeyboardOnScroll: {
                return self.behavior.dismissesKeyboardOnScroll
            }
        )
        
        // Associate ourselves with our child objects.
            
        self.keyboardObserver.delegate = self
        
        // Size and update views.
        
        self.collectionView.frame = self.bounds
        self.addSubview(self.collectionView)
        
        // Apply various appearance requirements.
        
        self.applyAppearance()
        self.applyScrollInsets()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    //
    // MARK: Internal Properties
    //
    
    internal let storage : Storage
    internal let collectionView : UICollectionView
    internal let layout : ListViewLayout
    
    //
    // MARK: Private Properties
    //
    
    private var sourcePresenter : AnySourcePresenter
    
    private let dataSource : DataSource
    private let delegate : Delegate
    private let layoutDelegate : LayoutDelegate
    
    private let keyboardObserver : KeyboardObserver
    
    //
    // MARK: Appearance
    //
    
    public var appearance : Appearance {
        didSet {
            guard oldValue != self.appearance else {
                return
            }
            
            self.applyAppearance()
        }
    }
    
    private func applyAppearance()
    {
        // Appearance
        
        self.backgroundColor = self.appearance.backgroundColor
        
        // Child Objects
        
        self.layoutDelegate.appearance = self.appearance
        self.layout.appearance = self.appearance
        
        // Row Sizing
        
        self.storage.presentationState.resetAllCachedHeights()
        
        // Scroll View Config
        
        self.collectionView.setAlwaysBounce(self.appearance.underflow.alwaysBounce, direction: self.appearance.direction)
    }
    
    public var behavior : Behavior {
        didSet {
            guard oldValue != self.behavior else {
                return
            }
            
            self.applyBehavior()
        }
    }
    
    private func applyBehavior()
    {
        // Nothing right now.
    }
    
    public var scrollInsets : ScrollInsets {
        didSet {
            guard oldValue != self.scrollInsets else {
                return
            }
            
            self.applyScrollInsets()
        }
    }
    
    func applyScrollInsets()
    {
        self.collectionView.contentInset = self.scrollInsets.insets(
            with: self.collectionView.contentInset,
            layoutDirection: self.appearance.direction
        )
    }
    
    //
    // MARK: Scrolling To Sections & Items
    //
    
    @discardableResult
    public func scrollTo(item : AnyItem, position : ItemScrollPosition, animated : Bool = false) -> Bool
    {
        return self.scrollTo(item: item.identifier, position: position, animated: animated)
    }
    
    @discardableResult
    public func scrollTo<Element:ItemElement>(item : Identifier<Element>, position : ItemScrollPosition, animated : Bool = false) -> Bool
    {
        return self.scrollTo(item: AnyIdentifier(item), position: position, animated: animated)
    }
    
    @discardableResult
    public func scrollTo(item : AnyIdentifier, position : ItemScrollPosition, animated : Bool = false) -> Bool
    {
        // Make sure the item identifier is valid.
        
        guard let toIndexPath = self.storage.allContent.indexPath(for: item) else {
            return false
        }
        
        guard let lastLoadedIndexPath = self.storage.presentationState.lastIndexPath else {
            return false
        }
        
        // If the item is already visible and that's good enough, return.
        
        let isAlreadyVisible = self.collectionView.indexPathsForVisibleItems.contains(toIndexPath)
        
        if  isAlreadyVisible && position.ifAlreadyVisible == .doNothing {
            return true
        }
        
        // Otherwise, perform scrolling.
        
        let scroll = {
            self.collectionView.scrollToItem(
                at: toIndexPath,
                at: position.position.UICollectionViewScrollPosition,
                animated: animated
            )
        }
        
        if lastLoadedIndexPath < toIndexPath {
            self.updatePresentationState(for: .programaticScrollDownTo(toIndexPath)) { _ in
                scroll()
            }
        } else {
            scroll()
        }
    
        return true
    }
    
    //
    // MARK: Setting & Getting Content
    //
    
    public var content : Content {
        get { return self.storage.allContent }
        set { self.setContent(animated: false, newValue) }
    }
    
    public func setContent(with builder : ListDescription.Build)
    {
        let description = ListDescription(
            animatesChanges: true,
            appearance: self.appearance,
            behavior: self.behavior,
            scrollInsets: self.scrollInsets,
            build: builder
        )
        
        self.setProperties(with: description)
    }
    
    public func setContent(animated : Bool = false, _ content : Content)
    {
        self.set(
            source: StaticSource(with: content),
            initial: StaticSource.State(),
            animated: animated
        )
    }
    
    private var sourceChangedTimer : ReloadTimer? = nil
    
    @discardableResult
    public func set<Source:ListViewSource>(source : Source, initial : Source.State, animated : Bool = false) -> StateAccessor<Source.State>
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
        
        self.setContentFromSource(animated: animated)
        
        return StateAccessor(get: {
            sourcePresenter.state
        }, set: {
            sourcePresenter.state = $0
        })
    }
    
    public func setProperties(with description : ListDescription)
    {
        self.appearance = description.appearance
        self.behavior = description.behavior
        self.scrollInsets = description.scrollInsets
        
        self.setContent(animated: description.animatesChanges, description.content)
    }
    
    private func setContentFromSource(animated : Bool = false)
    {
        let oldIdentifier = self.storage.allContent.identifier
        self.storage.allContent = self.sourcePresenter.reloadContent()
        let newIdentifier = self.storage.allContent.identifier
        
        let identifierChanged = oldIdentifier != newIdentifier
        
        self.updatePresentationState(for: .contentChanged(animated: animated, identifierChanged: identifierChanged))
    }
    
    // MARK: UIView
    
    public override var frame: CGRect {
        didSet {
            /**
             Set the frame explicitly, so that the layout can occur
             within performBatchUpdates. Waiting for layoutSubviews() is too late.
             */
            self.collectionView.frame = self.bounds
            
            /**
             Once the view actually has a size, we can provide content.
            
             There's no value in having content with no view size, as we cannot
             size cells otherwise.
             */
            
            let fromEmpty = oldValue.isEmpty && self.bounds.isEmpty == false
            let toEmpty = oldValue.isEmpty == false && self.bounds.isEmpty
            
            if fromEmpty {
                self.updatePresentationState(for: .transitionedToBounds(isEmpty: false))
            } else if toEmpty {
                self.updatePresentationState(for: .transitionedToBounds(isEmpty: true))
            }
        }
    }
    
    public override var backgroundColor: UIColor? {
        didSet {
            self.collectionView.backgroundColor = self.backgroundColor
        }
    }
    
    public override func didMoveToWindow()
    {
        super.didMoveToWindow()
        
        if self.window != nil {
            self.setContentInsetWithKeyboardFrame()
        }
    }
    
    public override func didMoveToSuperview()
    {
        super.didMoveToSuperview()
        
        if self.superview != nil {
            self.setContentInsetWithKeyboardFrame()
        }
    }
    
    override public func layoutSubviews()
    {
        super.layoutSubviews()
        
        self.collectionView.frame = self.bounds
    }
    
    //
    // MARK: Updating Content
    //
    
    private func updateCollectionViewConfiguration()
    {
        let view = self.collectionView
        
        switch self.content.selectionMode {
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
    
    private func updateCollectionViewSelections(animated : Bool)
    {
        let oldSelected : Set<IndexPath> = Set(self.collectionView.indexPathsForSelectedItems ?? [])
        let newSelected : Set<IndexPath> = Set(self.storage.presentationState.selectedIndexPaths)
        
        let removed = oldSelected.subtracting(newSelected)
        let added = newSelected.subtracting(oldSelected)
        
        let view = self.collectionView
        let state = self.storage.presentationState
        
        removed.forEach {
            let item = state.item(at: $0)
            view.deselectItem(at: $0, animated: animated)
            item.applyToVisibleCell()
        }
        
        added.forEach {
            let item = state.item(at: $0)
            view.selectItem(at: $0, animated: animated, scrollPosition: [])
            item.applyToVisibleCell()
        }
    }
    
    //
    // MARK: Updating Displayed Items
    //
    
    private struct VisibleSection : Hashable
    {
        let section : PresentationState.SectionState
        
        func hash(into hasher: inout Hasher)
        {
            hasher.combine(ObjectIdentifier(self.section))
        }
        
        static func == (lhs : VisibleSection, rhs : VisibleSection) -> Bool
        {
            return lhs.section === rhs.section
        }
    }
    
    
    private struct VisibleItem : Hashable
    {
        let item : AnyPresentationItemState
        
        func hash(into hasher: inout Hasher)
        {
            hasher.combine(ObjectIdentifier(self.item))
        }
        
        static func == (lhs : VisibleItem, rhs : VisibleItem) -> Bool
        {
            return lhs.item === rhs.item
        }
    }
    
    private var visibleSections : Set<VisibleSection> = Set()
    private var visibleItems : Set<VisibleItem> = Set()
    
    internal func updateVisibleItemsAndSections()
    {
        // Visible Items & Sections
        
        let visibleIndexPaths = self.collectionView.indexPathsForVisibleItems
        
        let newVisibleItems = Set(visibleIndexPaths.map {
            VisibleItem(item: self.storage.presentationState.item(at: $0))
        })
        
        let visibleSectionIndexes : Set<Int> = visibleIndexPaths.reduce(into: Set(), { $0.insert($1.section) })
        let visibleSections = self.storage.presentationState.sections(at: Array(visibleSectionIndexes))
        
        // Message Changes
        
        let removed = self.visibleItems.subtracting(newVisibleItems)
        let added = newVisibleItems.subtracting(self.visibleItems)
        
        removed.forEach {
            $0.item.setAndPerform(isDisplayed: false)
        }
        
        added.forEach {
            $0.item.setAndPerform(isDisplayed: true)
        }
        
        self.visibleItems = newVisibleItems
        self.visibleSections = Set(visibleSections.map { VisibleSection(section: $0)} )
    }
    
    //
    // MARK: Updating Presentation State
    //
    
    internal func updatePresentationState(for reason : Content.UpdateReason, completion : @escaping (Bool) -> () = { _ in })
    {
        let indexPaths = self.collectionView.indexPathsForVisibleItems
        
        let indexPath = indexPaths.first
        
        let presentationStateTruncated = self.storage.presentationState.containsAllItems == false
        
        switch reason {
        case .scrolledDown:
            let needsUpdate = self.collectionView.isScrolledNearBottom() && presentationStateTruncated
            
            if needsUpdate {
                self.updatePresentationStateWith(firstVisibleIndexPath: indexPath, for: reason, completion: completion)
            } else {
                completion(true)
            }
            
        case .contentChanged:
            self.updateCollectionViewConfiguration()
            self.updatePresentationStateWith(firstVisibleIndexPath: indexPath, for: reason, completion: completion)
            
        case .didEndDecelerating:
            if presentationStateTruncated {
                self.updatePresentationStateWith(firstVisibleIndexPath: indexPath, for: reason, completion: completion)
            } else {
                completion(true)
            }
            
        case .scrolledToTop:
            if presentationStateTruncated {
                self.updatePresentationStateWith(firstVisibleIndexPath: IndexPath(item: 0, section: 0), for: reason, completion: completion)
            } else {
                completion(true)
            }
            
        case .transitionedToBounds(_):
            self.updatePresentationStateWith(firstVisibleIndexPath: indexPath, for: reason, completion: completion)
            
        case .programaticScrollDownTo(let scrollToIndexPath):
            self.updatePresentationStateWith(firstVisibleIndexPath: scrollToIndexPath, for: reason, completion: completion)
        }
    }
    
    private func updatePresentationStateWith(
        firstVisibleIndexPath indexPath: IndexPath?,
        for reason : Content.UpdateReason,
        completion callerCompletion : @escaping (Bool) -> ()
        )
    {
        // Figure out visible content.
        
        let indexPath = indexPath ?? IndexPath(item: 0, section: 0)
        
        let visibleSlice = self.bounds.isEmpty ? Content.Slice() : self.storage.allContent.sliceTo(indexPath: indexPath, plus: Content.Slice.defaultSize)
        
        let diff = ListView.diffWith(old: self.storage.presentationState.sectionModels, new: visibleSlice.content.sections)
                
        let updateBackingData = {
            self.storage.presentationState.update(with: diff, slice: visibleSlice, reorderingDelegate: self)
        }
        
        /**
         Update Refresh Control
         
         Note: Must be called *OUTSIDE* of CollectionView's `performBatchUpdates:`, otherwise
         we trigger a bug where updated indexes are calculated incorrectly.
         */
 
        self.storage.presentationState.updateRefreshControl(with: visibleSlice.content.refreshControl, in: self.collectionView)
        
        // Update Collection View
        
        self.performBatchUpdates(with: diff, animated: reason.animated, updateBackingData: updateBackingData) { finished in
            self.updateVisibleItemsAndSections()
            callerCompletion(finished)
        }
        
        // Update info for new contents.
        
        self.updateCollectionViewSelections(animated: reason.animated)
    }
        
    private func performBatchUpdates(
        with diff : SectionedDiff<Section,AnyItem>,
        animated: Bool,
        updateBackingData : @escaping () -> (),
        completion : @escaping (Bool) -> ()
    )
    {
        let view = self.collectionView
        
        let changes = diff.aggregatedChanges
                
        let batchUpdates = {
            updateBackingData()
            // Sections

            view.deleteSections(IndexSet(changes.deletedSections.map { $0.oldIndex }))
            view.insertSections(IndexSet(changes.insertedSections.map { $0.newIndex }))
            
            changes.movedSections.forEach {
                view.moveSection($0.oldIndex, toSection: $0.newIndex)
            }

            // Items
            
            view.deleteItems(at: changes.deletedItems.map { $0.oldIndex })
            view.insertItems(at: changes.insertedItems.map { $0.newIndex })
            
            changes.movedItems.forEach {
                view.moveItem(at: $0.oldIndex, to: $0.newIndex)
            }
            
            // Perform Updates Of Visible Section Headers & Footers
            
            self.visibleSections.forEach {
                $0.section.header?.applyToVisibleView()
                $0.section.footer?.applyToVisibleView()
            }
            
            // Perform Updates Of Visible Items
            
            self.visibleItems.forEach {
                $0.item.applyToVisibleCell()
            }
        }
        
        if changes.hasIndexAffectingChanges {
            self.cancelInteractiveMovement()
        }
        
        self.layout.setShouldAskForItemSizesDuringLayoutInvalidation()
        
        if animated {
            view.performBatchUpdates(batchUpdates, completion: completion)
        } else {
            UIView.performWithoutAnimation {
                view.performBatchUpdates(batchUpdates, completion: completion)
            }
        }
    }
    
    internal static func diffWith(old : [Section], new : [Section]) -> SectionedDiff<Section, AnyItem>
    {
        return SectionedDiff(
            old: old,
            new: new,
            configuration: SectionedDiff.Configuration(
                section: .init(
                    identifier: { $0.info.anyIdentifier },
                    items: { $0.items },
                    movedHint: { $0.info.anyWasMoved(comparedTo: $1.info) }
                ),
                item: .init(
                    identifier: { $0.identifier },
                    updated: { $0.anyWasUpdated(comparedTo: $1) },
                    movedHint: { $0.anyWasMoved(comparedTo: $1) }
                )
            )
        )
    }
}


extension ListView : ReorderingActionsDelegate
{
    //
    // MARK: ReorderingActionsDelegate (Moving Items)
    //
    
    internal func beginInteractiveMovementFor(item : AnyPresentationItemState) -> Bool
    {
        guard let indexPath = self.storage.presentationState.indexPath(for: item) else {
            return false
        }
        
        return self.collectionView.beginInteractiveMovementForItem(at: indexPath)
    }
    
    internal func updateInteractiveMovementTargetPosition(with recognizer : UIPanGestureRecognizer)
    {
        let position = recognizer.location(in: self.collectionView)
        
        self.collectionView.updateInteractiveMovementTargetPosition(position)
    }
    
    internal func endInteractiveMovement()
    {
        self.collectionView.endInteractiveMovement()
    }
    
    internal func cancelInteractiveMovement()
    {
        self.collectionView.cancelInteractiveMovement()
    }
}


extension ListView : KeyboardObserverDelegate
{
    private func setContentInsetWithKeyboardFrame()
    {
        guard let frame = self.keyboardObserver.currentFrame(in: self) else {
            return
        }
        
        var inset : CGFloat
        
        switch frame {
        case .notVisible: inset = 0.0
        case .visible(let frame): inset = (self.bounds.size.height - frame.origin.y)
        }
        
        self.collectionView.contentInset.bottom = inset
    }
    
    //
    // MARK: KeyboardObserverDelegate
    //
    
    func keyboardFrameWillChange(observer : KeyboardObserver)
    {
        self.setContentInsetWithKeyboardFrame()
    }
}



fileprivate extension UIScrollView
{    
    func isScrolledNearBottom() -> Bool
    {
        let viewHeight = self.bounds.size.height
        
        // We are within one half view height from the bottom of the content.
        return self.contentOffset.y + (viewHeight * 1.5) > self.contentSize.height
    }
    
    func setAlwaysBounce(_ bounce : Bool, direction : LayoutDirection)
    {
        switch direction {
        case .vertical:
            self.alwaysBounceVertical = bounce
            self.alwaysBounceHorizontal = false
        case .horizontal:
            self.alwaysBounceVertical = false
            self.alwaysBounceHorizontal = bounce
        }
    }
}
