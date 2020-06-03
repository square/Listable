//
//  PresentationState.ItemState.swift
//  Listable
//
//  Created by Kyle Van Essen on 5/22/20.
//

import Foundation


protocol AnyPresentationItemState : AnyObject
{
    var isDisplayed : Bool { get }
    func setAndPerform(isDisplayed: Bool)
    
    var itemPosition : ItemPosition { get set }
    
    var anyModel : AnyItem { get }
    
    var reorderingActions : ReorderingActions { get }
    
    var cellRegistrationInfo : (class:AnyClass, reuseIdentifier:String) { get }
    
    func dequeueAndPrepareCollectionViewCell(in collectionView : UICollectionView, for indexPath : IndexPath) -> UICollectionViewCell
    
    func applyTo(cell anyCell : UICollectionViewCell, itemState : Listable.ItemState, reason : ApplyReason)
    func applyToVisibleCell()
        
    func setNew(item anyItem : AnyItem, reason : PresentationState.ItemUpdateReason)
    
    func willDisplay(cell : UICollectionViewCell, in collectionView : UICollectionView, for indexPath : IndexPath)
    func didEndDisplay()
    
    func wasRemoved()
    
    var isSelected : Bool { get }
    func performUserDidSelectItem(isSelected: Bool)
    
    func resetCachedSizes()
    func size(in sizeConstraint : CGSize, layoutDirection : LayoutDirection, defaultSize : CGSize, measurementCache : ReusableViewCache) -> CGSize
    
    func moved(with result : Reordering.Result)
}


protocol ItemContentCoordinatorDelegate : AnyObject
{
    func coordinatorUpdated(for item : AnyItem, animated : Bool)
}


public struct ItemStateDependencies
{
    internal var reorderingDelegate : ReorderingActionsDelegate
    internal var coordinatorDelegate : ItemContentCoordinatorDelegate
}


extension PresentationState
{
    enum ItemUpdateReason : CaseIterable
    {
        case move
        case updateFromList
        case updateFromItemCoordinator
        case noChange
    }
    
    final class ItemState<Content:ItemContent> : AnyPresentationItemState
    {
        var model : Item<Content> {
            self.storage.model
        }
        
        private(set) var coordination : Coordination
        
        struct Coordination {
            var coordinator : Content.Coordinator
            
            let actions : ItemContentCoordinatorActions<Content>
            let info : ItemContentCoordinatorInfo<Content>
        }
        
        let reorderingActions: ReorderingActions
        
        var itemPosition : ItemPosition
        
        let storage : Storage
                
        init(with model : Item<Content>, dependencies : ItemStateDependencies)
        {
            self.reorderingActions = ReorderingActions()
            self.itemPosition = .single
        
            self.cellRegistrationInfo = (ItemCell<Content>.self, model.reuseIdentifier.stringValue)
                        
            let storage = Storage(model)
            self.storage = storage
                        
            let actions = ItemContentCoordinatorActions(
                current: { storage.model },
                update: { new, _ in
                    
                    /// This is a temporary update callback, in case the initialization of the
                    /// coordinator causes an update to the item itself.
                    
                    storage.model = new
                }
            )

            let info = ItemContentCoordinatorInfo(
                original: storage.model,
                current: { storage.model }
            )
            
            let coordinator = model.content.makeCoordinator(actions: actions, info: info)
            
            self.coordination = Coordination(
                coordinator: coordinator,
                actions: actions,
                info: info
            )
            
            self.reorderingActions.item = self
            self.reorderingActions.delegate = dependencies.reorderingDelegate
            
            /// Now that the presentation state is entirely configured, set up the final
            /// update callback, which triggers a `setNew` call, alongside informing the
            /// `listView` that changes have occurred.
            
            weak var coordinatorDelegate = dependencies.coordinatorDelegate
            
            self.coordination.actions.updateCallback = { [weak self, weak coordinatorDelegate] new, animated in
                guard let self = self, let delegate = coordinatorDelegate else {
                    return
                }
                
                self.setNew(item: new, reason: .updateFromItemCoordinator)
                
                delegate.coordinatorUpdated(for: self.anyModel, animated: animated)
                
                self.applyToVisibleCell()
            }
            
            self.storage.didSetState = { [weak self] old, new in
                self?.updateCoordinatorWithStateChange(old: old, new: new)
            }
            
            self.coordination.coordinator.wasCreated()
        }
        
        // MARK: AnyPresentationItemState
        
        private(set) var isDisplayed : Bool = false
        
        func setAndPerform(isDisplayed: Bool) {
            guard self.isDisplayed != isDisplayed else {
                return
            }
            
            self.isDisplayed = isDisplayed
            
            if self.isDisplayed {
                self.model.onDisplay?(self.model.content)
            } else {
                self.model.onEndDisplay?(self.model.content)
            }
        }
                
        var anyModel : AnyItem {
            return self.model
        }
        
        var cellRegistrationInfo : (class:AnyClass, reuseIdentifier:String)
        
        func dequeueAndPrepareCollectionViewCell(in collectionView : UICollectionView, for indexPath : IndexPath) -> UICollectionViewCell
        {
            let anyCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellRegistrationInfo.reuseIdentifier, for: indexPath)
            
            let cell = anyCell as! ItemCell<Content>
            
            // Theme cell & apply content.
            
            let itemState = Listable.ItemState(cell: cell)
            
            self.applyTo(
                cell: cell,
                itemState: itemState,
                reason: .willDisplay
            )
            
            return cell
        }
        
        func applyTo(cell anyCell : UICollectionViewCell, itemState : Listable.ItemState, reason : ApplyReason)
        {
            let cell = anyCell as! ItemCell<Content>
            
            let applyInfo = ApplyItemContentInfo(
                state: itemState,
                position: self.itemPosition,
                reordering: self.reorderingActions
            )
            
            // Apply Model State
            
            self.model.content.apply(
                to: ItemContentViews(content: cell.contentContainer.contentView, background: cell.background, selectedBackground: cell.selectedBackground),
                for: reason,
                with: applyInfo
            )
            
            // Apply Swipe To Action Appearance
            if let actions = self.model.swipeActions {
                cell.contentContainer.registerSwipeActionsIfNeeded(actions: actions, reason: reason)
            } else {
                cell.contentContainer.deregisterSwipeIfNeeded()
            }
        }
        
        func applyToVisibleCell()
        {
            guard let cell = self.storage.state.visibleCell else {
                return
            }
            
            self.applyTo(
                cell: cell,
                itemState: .init(cell: cell),
                reason: .wasUpdated
            )
        }
        
        func setNew(item anyItem: AnyItem, reason: ItemUpdateReason)
        {
            let old = self.model
            let new = anyItem as! Item<Content>
            
            self.storage.model = new
            
            if old.selectionStyle != new.selectionStyle {
                self.storage.state.isSelected = new.selectionStyle.isSelected
            }
            
            if reason == .updateFromList || reason == .move {
                self.coordination.info.original = new
                self.coordination.coordinator.wasUpdated(old: old, new: new)
            }
            
            if reason != .noChange {
                self.resetCachedSizes()
            }
        }
        
        func willDisplay(cell anyCell : UICollectionViewCell, in collectionView : UICollectionView, for indexPath : IndexPath)
        {
            let cell = (anyCell as! ItemCell<Content>)
            
            self.storage.state.visibleCell = cell
        }
        
        func didEndDisplay()
        {
            self.storage.state.visibleCell = nil
        }
        
        func wasRemoved()
        {
            self.coordination.coordinator.wasRemoved()
        }
        
        var isSelected: Bool {
            self.storage.state.isSelected
        }
                
        func performUserDidSelectItem(isSelected: Bool)
        {
            self.storage.state.isSelected = isSelected
            
            /// Schedule the caller-provided callbacks to happen after one runloop. Why?
            ///
            /// Because this method is called from within `UICollectionViewDelegate` callbacks,
            /// This delay gives the `UICollectionView` time to schedule any necessary animations
            /// for changes to the highlight and selection state – otherwise, these animations get
            /// stuck behind the call to the `onSelect` or `onDeselect` blocks, which creates the appearance
            /// of a laggy UI if these callbacks are slow.
            DispatchQueue.main.async {
                if isSelected {
                    if let onSelect = self.model.onSelect {
                        SignpostLogger.log(log: .listInteraction, name: "Item onSelect", for: self.model) {
                            ListDebugging.debugging.measure(
                                if: \.logsSlowUserCallbacks,
                                max: 0.5,
                                action: {
                                    onSelect(self.model.content)
                                },
                                log: { info in
                                    "Selecting Item (\(self.model.identifier.debugDescription)) took a long time. Max: \(info.max), actual: \(info.duration). Taking too long to perform actions in `onSelect` will have implications on application responsiveness."
                                }
                            )
                        }
                    }
                } else {
                    if let onDeselect = self.model.onDeselect {
                        SignpostLogger.log(log: .listInteraction, name: "Item onDeselect", for: self.model) {
                            ListDebugging.debugging.measure(
                                if: \.logsSlowUserCallbacks,
                                max: 0.5,
                                action: {
                                    onDeselect(self.model.content)
                                },
                                log: { info in
                                    "Deselecting Item (\(self.model.identifier.debugDescription)) took a long time. Max: \(info.max), actual: \(info.duration). Taking too long to perform actions in `onDeselect` will have implications on application responsiveness."
                                }
                            )
                        }
                    }
                }
            }
        }
        
        func updateCoordinatorWithStateChange(old : State, new : State)
        {
            let coordinator = self.coordination.coordinator
            
            if old.isSelected != new.isSelected {
                if new.isSelected {
                    coordinator.wasSelected()
                } else {
                    coordinator.wasDeselected()
                }
            }
            
            if old.visibleCell != new.visibleCell {
                if let cell = new.visibleCell {
                    let contentView = cell.contentContainer.contentView
                    
                    coordinator.view = contentView
                    coordinator.willDisplay(with: contentView)
                } else {
                    if let view = old.visibleCell?.contentContainer.contentView {
                        coordinator.didEndDisplay(with: view)
                    }
                }
            }
        }
        
        private var cachedSizes : [SizeKey:CGSize] = [:]
        
        func resetCachedSizes()
        {
            self.cachedSizes.removeAll()
        }
        
        func size(in sizeConstraint : CGSize, layoutDirection : LayoutDirection, defaultSize : CGSize, measurementCache : ReusableViewCache) -> CGSize
        {
            guard sizeConstraint.isEmpty == false else {
                return .zero
            }
            
            let key = SizeKey(
                width: sizeConstraint.width,
                height: sizeConstraint.height,
                layoutDirection: layoutDirection,
                sizing: self.model.sizing
            )
            
            if let size = self.cachedSizes[key] {
                return size
            } else {
                SignpostLogger.log(.begin, log: .updateContent, name: "Measure ItemContent", for: self.model)
                
                let size : CGSize = measurementCache.use(
                    with: self.model.reuseIdentifier,
                    create: {
                        return ItemCell<Content>()
                }, { cell in
                    let itemState = Listable.ItemState(isSelected: false, isHighlighted: false)
                    
                    self.applyTo(cell: cell, itemState: itemState, reason: .willDisplay)
                    
                    return self.model.sizing.measure(with: cell, in: sizeConstraint, layoutDirection: layoutDirection, defaultSize: defaultSize)
                })
                
                self.cachedSizes[key] = size
                
                SignpostLogger.log(.end, log: .updateContent, name: "Measure ItemContent", for: self.model)
                
                return size
            }
        }
        
        func moved(with result : Reordering.Result)
        {
            self.model.reordering?.didReorder(result)
        }
    }
}


extension PresentationState.ItemState
{
    final class Storage {
        
        var didSetState : (State, State) -> () = { _, _ in }
        
        var model : Item<Content> {
            willSet {
                guard self.model.identifier == newValue.identifier else {
                    fatalError("Cannot change the identifier of an item while updating it. Changed from '\(self.model.identifier)' to '\(newValue.identifier)'.")
                }
            }
        }
        
        var state : State {
            didSet {
                guard oldValue != self.state else {
                    return
                }
                
                self.didSetState(oldValue, self.state)
            }
        }
        
        init(_ model : Item<Content>)
        {
            self.model = model
            
            self.state = State(isSelected: self.model.selectionStyle.isSelected, visibleCell: nil)
        }
    }
    
    internal struct State : Equatable
    {
        var isSelected : Bool
        var visibleCell : ItemCell<Content>?
    }
}
