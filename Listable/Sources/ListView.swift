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
        self.appearance = appearance
        
        self.storage = Storage()
        self.sourcePresenter = SourcePresenter(initial: StaticSource.State(), source: StaticSource())
        
        self.dataSource = DataSource()
        self.delegate = Delegate()
        
        self.layout = ListViewLayout(
            delegate: self.delegate,
            appearance: self.appearance
        )
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.layout)
        
        if #available(iOS 10.0, *) {
            self.collectionView.isPrefetchingEnabled = false
        }
                
        self.collectionView.dataSource = self.dataSource
        self.collectionView.delegate = self.delegate
        
        super.init(frame: frame)
        
        self.storage.presentationState.view = self.collectionView
        self.dataSource.view = self
        self.delegate.view = self
        
        self.collectionView.frame = self.bounds
        self.addSubview(self.collectionView)
        
        self.applyAppearance()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    //
    // MARK: Private Properties
    //
    
    private let storage : Storage
    private var sourcePresenter : AnySourcePresenter
    
    private let dataSource : DataSource
    private let delegate : Delegate
    
    private let collectionView : UICollectionView
    private let layout : ListViewLayout
    
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
        self.layout.appearance = self.appearance
        self.backgroundColor = self.appearance.backgroundColor
        
        self.storage.presentationState.resetCachedHeights()
    }
    
    //
    // MARK: Setting & Getting Content
    //
    
    public var content : Content {
        get { return self.storage.allContent }
        set { self.setContent(animated: false, newValue) }
    }
    
    public func setContent(animated : Bool = false, _ block : ContentBuilder.Build)
    {
        self.setContent(animated: animated, ContentBuilder.build(with: block))
    }
    
    public func setContent(animated : Bool = false, _ content : Content)
    {
        self.set(
            source: StaticSource(with: content),
            initial: StaticSource.State(),
            animated: animated
        )
    }
    
    @discardableResult
    public func set<Source:ListViewSource>(source : Source, initial : Source.State, animated : Bool = false) -> StateAccessor<Source.State>
    {
        self.sourcePresenter.discard()
        
        let sourcePresenter = SourcePresenter(initial: initial, source: source, didChange: { [weak self] in
            self?.setContentFromSource(animated: true)
        })
        
        self.sourcePresenter = sourcePresenter
        
        self.setContentFromSource(animated: animated)
        
        return StateAccessor(get: {
            sourcePresenter.state
        }, set: {
            sourcePresenter.state = $0
        })
    }
    
    private func setContentFromSource(animated : Bool = false)
    {
        self.storage.allContent = self.sourcePresenter.reloadContent()
        
        self.updatePresentationState(for: .contentChanged(animated: animated))        
    }
    
    // MARK: UIView
    
    public override var frame: CGRect {
        didSet {
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
    
    override public func layoutSubviews()
    {
        super.layoutSubviews()
        
        self.collectionView.frame = self.bounds
    }
    
    //
    // MARK: Updating Content
    //
    
    fileprivate func updateVisibleCellPositions()
    {
        let indexPaths = self.collectionView.indexPathsForVisibleItems
        
        let items : [(IndexPath, AnyPresentationItemState)] = indexPaths.map {
            return ($0, self.storage.presentationState.item(at: $0))
        }
        
        for (indexPath, item) in items {
            let cell = self.collectionView.cellForItem(at: indexPath)!
            item.updatePosition(with: cell, in: collectionView, for: indexPath)
        }
    }
    
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
    
    private struct VisibleItem : Hashable
    {
        let value : AnyPresentationItemState
        
        func hash(into hasher: inout Hasher)
        {
            hasher.combine(ObjectIdentifier(self.value))
        }
        
        static func == (lhs : VisibleItem, rhs : VisibleItem) -> Bool
        {
            return lhs.value === rhs.value
        }
    }
    
    private var visibleItems : Set<VisibleItem> = Set()
    
    private func updateVisibleItems()
    {
        let newVisibleIndexes = self.collectionView.indexPathsForVisibleItems
        
        let newVisibleItems = Set(newVisibleIndexes.map {
            VisibleItem(value: self.storage.presentationState.item(at: $0))
        })
        
        let removed = self.visibleItems.subtracting(newVisibleItems)
        let added = newVisibleItems.subtracting(self.visibleItems)
        
        removed.forEach {
            $0.value.setAndPerform(isDisplayed: false)
        }
        
        added.forEach {
            $0.value.setAndPerform(isDisplayed: true)
        }
        
        self.visibleItems = newVisibleItems
    }
    
    //
    // MARK: Updating Presentation State
    //
    
    private func updatePresentationState(for reason : Content.Slice.UpdateReason)
    {
        let indexPaths = self.collectionView.indexPathsForVisibleItems
        
        let indexPath = indexPaths.first
        
        switch reason {
        case .scrolledDown:
            let needsUpdate = self.collectionView.isScrolledNearBottom() && self.storage.presentationState.containsAllItems == false
            
            if needsUpdate {
                self.updatePresentationStateWith(firstVisibleIndexPath: indexPath, for: reason)
            }
            
        case .contentChanged:
            self.updateCollectionViewConfiguration()
            self.updatePresentationStateWith(firstVisibleIndexPath: indexPath, for: reason)
            
        case .didEndDecelerating:
            self.updatePresentationStateWith(firstVisibleIndexPath: indexPath, for: reason)
            
        case .scrolledToTop:
            self.updatePresentationStateWith(firstVisibleIndexPath: IndexPath(item: 0, section: 0), for: reason)
            
        case .transitionedToBounds(_):
            self.updatePresentationStateWith(firstVisibleIndexPath: indexPath, for: reason)
        }
    }
    
    private func updatePresentationStateWith(firstVisibleIndexPath indexPath: IndexPath?, for reason : Content.Slice.UpdateReason)
    {
        let indexPath = indexPath ?? IndexPath(item: 0, section: 0)
        
        let visibleSlice = self.bounds.isEmpty ? Content.Slice() : self.storage.allContent.sliceTo(indexPath: indexPath, plus: Content.Slice.defaultSize)
        
        let diff = ListView.diffWith(old: self.storage.presentationState.sectionModels, new: visibleSlice.content.sections)
        
        let updateData = {
            self.storage.presentationState.update(with: diff, slice: visibleSlice)
        }
        
        let completion = { (finished : Bool) in
            self.updateVisibleItems()
        }
        
        if reason.diffsChanges {
            self.performBatchUpdates(
                with: diff,
                animated: reason.animated,
                onBeginUpdates: updateData,
                completion:completion
            )
        } else {
            updateData()
            self.collectionView.reloadData()
            completion(true)
        }
        
        self.updateCollectionViewSelections(animated: reason.animated)
    }
        
    private func performBatchUpdates(
        with diff : SectionedDiff<Section,AnyItem>,
        animated: Bool,
        onBeginUpdates : @escaping () -> (),
        completion : @escaping (Bool) -> ()
    )
    {
        let view = self.collectionView
        
        let changes = diff.aggregatedChanges
                
        let batchUpdates = {
            onBeginUpdates()
                                    
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
            
            // Perform Updates Of Section Headers & Footers
            
            diff.changes.moved.forEach { move in
                let section = self.storage.presentationState.sections[move.newIndex]
                
                section.header?.applyToVisibleView()
                section.footer?.applyToVisibleView()
            }
            
            diff.changes.noChange.forEach { change in
                let section = self.storage.presentationState.sections[change.newIndex]
                
                section.header?.applyToVisibleView()
                section.footer?.applyToVisibleView()
            }
            
            // Perform Updates Of Visible Items
            
            // TODO: Always refresh the cells that are on-screen.
            
            changes.updatedItems.forEach {
                let item = self.storage.presentationState.item(at: $0.oldIndex)
                
                item.applyToVisibleCell()
            }
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
    
    private static func diffWith(old : [Section], new : [Section]) -> SectionedDiff<Section, AnyItem>
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


fileprivate extension ListView
{
    final class Storage
    {
        var allContent : Content = Content()

        let presentationState : PresentationState = PresentationState()
        
        func remove(item itemToRemove : AnyPresentationItemState) -> IndexPath?
        {
            if let indexPath = self.presentationState.remove(item: itemToRemove) {
                self.allContent.remove(at: indexPath)
                return indexPath
            } else {
                return nil
            }
        }
    }
    
    final class DataSource : NSObject, UICollectionViewDataSource
    {
        unowned var view : ListView!
        
        var presentationState : PresentationState {
            return self.view.storage.presentationState
        }
        
        func numberOfSections(in collectionView: UICollectionView) -> Int
        {
            return self.presentationState.sections.count
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
        {
            let section = self.presentationState.sections[section]
            
            return section.items.count
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
        {
            let item = self.presentationState.item(at: indexPath)
            
            self.presentationState.registerCell(for: item)
            
            return item.dequeueAndPrepareCollectionViewCell(in: collectionView, for: indexPath)
        }

        func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
        {
            switch ListViewLayout.SupplementaryKind(rawValue: kind)! {
            case .listHeader:
                if let header = self.presentationState.header {
                    self.presentationState.registerSupplementaryView(of: kind, for: header)
                    return header.dequeueAndPrepareCollectionReusableView(in: collectionView, of: kind, for: indexPath)
                }
                
            case .listFooter:
                if let footer = self.presentationState.footer {
                    self.presentationState.registerSupplementaryView(of: kind, for: footer)
                    return footer.dequeueAndPrepareCollectionReusableView(in: collectionView, of: kind, for: indexPath)
                }
                
            case .sectionHeader:
                let section = self.presentationState.sections[indexPath.section]

                if let header = section.header {
                    self.presentationState.registerSupplementaryView(of: kind, for: header)
                    return header.dequeueAndPrepareCollectionReusableView(in: collectionView, of: kind, for: indexPath)
                }
                
            case .sectionFooter:
                let section = self.presentationState.sections[indexPath.section]

                if let footer = section.footer {
                    self.presentationState.registerSupplementaryView(of: kind, for: footer)
                    return footer.dequeueAndPrepareCollectionReusableView(in: collectionView, of: kind, for: indexPath)
                }
            }
            
            fatalError()
        }

        func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool
        {
            return false
        }
        
        func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
        {
            self.view.updateVisibleCellPositions()
        }
    }
    
    final class Delegate : NSObject, UICollectionViewDelegate, ListViewLayoutDelegate
    {
        unowned var view : ListView!
        
        var presentationState : PresentationState {
            return self.view.storage.presentationState
        }
        
        // MARK: UICollectionViewDelegate
        
        func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool
        {
            return true
        }

        func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath)
        {
            let item = self.presentationState.item(at: indexPath)
            
            item.applyToVisibleCell()
        }
        
        func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath)
        {
            let item = self.presentationState.item(at: indexPath)

            item.applyToVisibleCell()
        }

        func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool
        {
            let item = self.presentationState.item(at: indexPath)
            
            return item.anyModel.selection.isSelectable
        }
        
        func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool
        {
            return true
        }

        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
        {
            let item = self.presentationState.item(at: indexPath)
            
            item.performUserDidSelectItem(isSelected: true)
            item.applyToVisibleCell()
        }

        func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
        {
            let item = self.presentationState.item(at: indexPath)
            
            item.performUserDidSelectItem(isSelected: false)
            item.applyToVisibleCell()
        }
        
        private var displayedItems : [ObjectIdentifier:AnyPresentationItemState] = [:]
        
        func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
        {
            let item = self.presentationState.item(at: indexPath)
            
            item.willDisplay(cell: cell, in: collectionView, for: indexPath)
            
            self.displayedItems[ObjectIdentifier(cell)] = item
        }
        
        func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
        {
            guard let item = self.displayedItems.removeValue(forKey: ObjectIdentifier(cell)) else {
                return
            }
                        
            item.didEndDisplay()
        }
        
        private var displayedSupplementaryItems : [ObjectIdentifier:AnyPresentationHeaderFooterState] = [:]
        
        func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath)
        {
            let item : AnyPresentationHeaderFooterState = {
                switch ListViewLayout.SupplementaryKind(rawValue: elementKind)! {
                case .listHeader:
                    return self.presentationState.header!
                    
                case .listFooter:
                    return self.presentationState.footer!
                    
                case .sectionHeader:
                    let section = self.presentationState.sections[indexPath.section]
                    return section.header!
                    
                case .sectionFooter:
                    let section = self.presentationState.sections[indexPath.section]
                    return section.footer!
                }
            }()
            
            item.willDisplay(view: view, in: collectionView, for: indexPath)
            
            self.displayedSupplementaryItems[ObjectIdentifier(view)] = item
        }
        
        func collectionView(
            _ collectionView: UICollectionView,
            didEndDisplayingSupplementaryView view: UICollectionReusableView,
            forElementOfKind elementKind: String,
            at indexPath: IndexPath
        )
        {
            guard let item = self.displayedSupplementaryItems.removeValue(forKey: ObjectIdentifier(view)) else {
                return
            }
            
            item.didEndDisplay()
        }
        
        // MARK: ListViewLayoutDelegate
        
        private let cellMeasurementCache = ReusableViewCache()
        
        func heightForItem(at indexPath : IndexPath, in collectionView : UICollectionView, width : CGFloat) -> CGFloat
        {
            let item = self.presentationState.item(at: indexPath)
            
            return item.height(
                with: width,
                defaultHeight: self.view.layout.appearance.sizing.rowHeight,
                measurementCache: self.cellMeasurementCache
            )
        }
        
        func hasListHeader(in collectionView : UICollectionView) -> Bool
        {
            return self.presentationState.header != nil
        }
        
        func heightForListHeader(in collectionView : UICollectionView, width : CGFloat) -> CGFloat
        {
            let header = self.presentationState.header!
            
            return header.height(with: width, defaultHeight: self.view.layout.appearance.sizing.listHeaderHeight, measurementCache: self.headerMeasurementCache)
        }
        
        func hasListFooter(in collectionView : UICollectionView) -> Bool
        {
            return self.presentationState.footer != nil
        }
        
        func heightForListFooter(in collectionView : UICollectionView, width : CGFloat) -> CGFloat
        {
            let footer = self.presentationState.footer!
            
            return footer.height(with: width, defaultHeight: self.view.layout.appearance.sizing.listFooterHeight, measurementCache: self.headerMeasurementCache)
        }
        
        func hasHeader(in sectionIndex : Int, in collectionView : UICollectionView) -> Bool
        {
            let section = self.presentationState.sections[sectionIndex]
            
            return section.header != nil
        }
        
        private let headerMeasurementCache = ReusableViewCache()
        
        func heightForHeader(in sectionIndex : Int, in collectionView : UICollectionView, width : CGFloat) -> CGFloat
        {
            let section = self.presentationState.sections[sectionIndex]
            let header = section.header!
            
            return header.height(with: width, defaultHeight: self.view.layout.appearance.sizing.sectionHeaderHeight, measurementCache: self.headerMeasurementCache)
        }
        
        func hasFooter(in sectionIndex : Int, in collectionView : UICollectionView) -> Bool
        {
            let section = self.presentationState.sections[sectionIndex]
            
            return section.footer != nil
        }
        
        private let footerMeasurementCache = ReusableViewCache()
        
        func heightForFooter(in sectionIndex : Int, in collectionView : UICollectionView, width : CGFloat) -> CGFloat
        {
            let section = self.presentationState.sections[sectionIndex]
            let footer = section.footer!
                        
            return footer.height(with: width, defaultHeight: self.view.layout.appearance.sizing.sectionFooterHeight, measurementCache: self.headerMeasurementCache)
        }
        
        func columnLayout(for sectionIndex : Int, in collectionView : UICollectionView) -> ListViewLayout.ColumnLayout
        {
            let section = self.presentationState.sections[sectionIndex]
            
            return ListViewLayout.ColumnLayout(
                columns: section.model.layout.columns,
                spacing: section.model.layout.spacing
            )
        }
        
        // MARK: UIScrollViewDelegate
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
        {
            self.view.updatePresentationState(for: .didEndDecelerating)
        }
        
        func scrollViewDidScrollToTop(_ scrollView: UIScrollView)
        {
            self.view.updatePresentationState(for: .scrolledToTop)
        }
        
        private var lastPosition : CGFloat = 0.0
        
        func scrollViewDidScroll(_ scrollView: UIScrollView)
        {
            guard scrollView.bounds.size.height > 0 else { return }
            
            let scrollingDown = self.lastPosition < scrollView.contentOffset.y
            
            self.lastPosition = scrollView.contentOffset.y
            
            if scrollingDown {
                self.view.updatePresentationState(for: .scrolledDown)
            }
            
            self.view.updateVisibleItems()
        }
    }
}


fileprivate extension UICollectionView
{    
    func isScrolledNearBottom() -> Bool
    {
        let viewHeight = self.bounds.size.height
        
        // We are within one half view height from the bottom of the content.
        return self.contentOffset.y + (viewHeight * 1.5) > self.contentSize.height
    }
}
