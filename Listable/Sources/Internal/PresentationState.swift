//
//  PresentationState.swift
//  Listable
//
//  Created by Kyle Van Essen on 7/22/19.
//


protocol AnyPresentationItemState : AnyObject
{
    var isDisplayed : Bool { get }
    func setAndPerform(isDisplayed: Bool)
    
    var anyModel : AnyItem { get }
    
    var cellRegistrationInfo : (class:AnyClass, reuseIdentifier:String) { get }
    
    func dequeueAndPrepareCollectionViewCell(in collectionView : UICollectionView, for indexPath : IndexPath) -> UICollectionViewCell
    
    func applyTo(cell anyCell : UICollectionViewCell, itemState : Listable.ItemState, reason : ApplyReason)
    func applyToVisibleCell()
        
    func setNew(item anyItem : AnyItem, reason : UpdateReason)
    
    func willDisplay(cell : UICollectionViewCell, in collectionView : UICollectionView, for indexPath : IndexPath)
    func updatePosition(with cell : UICollectionViewCell, in collectionView : UICollectionView, for indexPath : IndexPath)
    func didEndDisplay()
    
    func performUserDidSelectItem(isSelected: Bool)
    
    func resetCachedHeights()
    func height(with width : CGFloat, defaultHeight : CGFloat, measurementCache : ReusableViewCache) -> CGFloat
}


protocol AnyPresentationHeaderFooterState : AnyObject
{
    var anyModel : AnyHeaderFooter { get }
    
    var cellRegistrationInfo : (class:AnyClass, reuseIdentifier:String) { get }
    
    func dequeueAndPrepareCollectionReusableView(in collectionView : UICollectionView, of kind : String, for indexPath : IndexPath) -> UICollectionReusableView
    
    func applyTo(view anyView : UICollectionReusableView, reason : ApplyReason)
    func applyToVisibleView()
    
    func setNew(headerFooter anyHeaderFooter : AnyHeaderFooter, reason : UpdateReason)
    
    func willDisplay(view : UICollectionReusableView, in collectionView : UICollectionView, for indexPath : IndexPath)
    func didEndDisplay()
    
    func resetCachedHeights()
    func height(with width : CGFloat, defaultHeight : CGFloat, measurementCache : ReusableViewCache) -> CGFloat
}


enum UpdateReason
{
    case move
    case update
    case noChange
}


/*
 A class used to manage the "live" / mutable state of the visible items in the collection.
 which is persistent across diffs of content (instances are only created or destroyed when an item enters or leaves the table).
 
 This is where bindings or other update-driving objects live,
 which then push the changes to the item and section content back into view models.
 */
final class PresentationState
{
    //
    // MARK: Public Properties
    //
    
    unowned var view : UICollectionView!
    
    var refreshControl : RefreshControl.PresentationState?
    
    var header : AnyPresentationHeaderFooterState?
    var footer : AnyPresentationHeaderFooterState?
    
    var sections : [PresentationState.SectionState]
        
    private(set) var containsAllItems : Bool
    
    //
    // MARK: Initialization
    //
        
    init()
    {
        self.refreshControl = nil
        self.sections = []
        
        self.containsAllItems = true
    }
    
    //
    // MARK: Accessing Data
    //
    
    var sectionModels : [Section] {
        return self.sections.map { section in
            var sectionModel = section.model
            
            sectionModel.items = section.items.map {
                $0.anyModel
            }
            
            return sectionModel
        }
    }
    
    var selectedIndexPaths : [IndexPath] {
        let indexes : [[IndexPath]] = self.sections.flatMapWithIndex { sectionIndex, section in
            return section.items.flatMapWithIndex { itemIndex, item in
                if item.anyModel.selection.isSelected {
                    return IndexPath(item: itemIndex, section: sectionIndex)
                } else {
                    return nil
                }
            }
        }
        
        return indexes.flatMap { $0 }
    }
    
    func item(at indexPath : IndexPath) -> AnyPresentationItemState
    {
        let section = self.sections[indexPath.section]
        let item = section.items[indexPath.item]
        
        return item
    }
    
    func sections(at indexes : [Int]) -> [SectionState]
    {
        var sections : [SectionState] = []
        
        indexes.forEach {
            sections.append(self.sections[$0])
        }
        
        return sections
    }
    
    public var lastIndexPath : IndexPath?
    {
        let nonEmptySections : [(index:Int, section:SectionState)] = self.sections.flatMapWithIndex {
            return $1.items.isEmpty ? nil : ($0, $1)
        }
        
        guard let lastSection = nonEmptySections.last else {
            return nil
        }
        
        return IndexPath(item: (lastSection.section.items.count - 1), section: lastSection.index)
    }
    
    //
    // MARK: Mutating Data
    //
    
    func remove(item itemToRemove : AnyPresentationItemState) -> IndexPath?
    {
        for (sectionIndex, section) in self.sections.enumerated() {
            for (itemIndex, item) in section.items.enumerated() {
                if item === itemToRemove {
                    self.sections[sectionIndex].removeItem(at: itemIndex)
                    return IndexPath(item: itemIndex, section: sectionIndex)
                }
            }
        }
        
        return nil
    }
    
    //
    // MARK: Height Caching
    //
    
    func resetAllCachedHeights()
    {
        self.sections.forEach { section in
            section.items.forEach { item in
                item.resetCachedHeights()
            }
        }
    }
    
    //
    // MARK: Updating Content & State
    //
    
    func update(with diff : SectionedDiff<Section, AnyItem>, slice : Content.Slice)
    {
        self.containsAllItems = slice.containsAllItems
        
        self.header = SectionState.headerFooterState(with: self.header, new: slice.content.header)
        self.footer = SectionState.headerFooterState(with: self.footer, new: slice.content.footer)
        
        self.updateRefreshControl(with: slice.content.refreshControl)
        
        self.sections = diff.changes.transform(
            old: self.sections,
            removed: { _, _ in },
            added: { section in SectionState(model: section) },
            moved: { old, new, changes, section in section.update(with: old, new: new, changes: changes) },
            noChange: { old, new, changes, section in section.update(with: old, new: new, changes: changes) }
        )
    }
    
    private func updateRefreshControl(with refreshControl : RefreshControl?)
    {
        guard #available(iOS 10.0, *) else { return }
        
        // TODO: Remove use of syncOptionals
        
        syncOptionals(
            left: self.refreshControl,
            right: refreshControl,
            created: { model in
                let new = RefreshControl.PresentationState(model)
                self.view.refreshControl = new.view
                self.refreshControl = new
        },
            removed: { _ in
                self.refreshControl = nil
                self.view.refreshControl = nil
        },
            overlapping: { control, model in
                model.apply(to: control.view)
        })
    }
    
    //
    // MARK: Cell & Supplementary View Registration
    //
    
    struct SupplementaryIdentifier : Hashable
    {
        let identifier : ObjectIdentifier
        let kind : String
    }
    
    private var registeredSupplementaryViewsObjectIdentifiers : Set<SupplementaryIdentifier> = Set()
        
    func registerSupplementaryView(of kind : String, for headerFooter : AnyPresentationHeaderFooterState)
    {
        let info = headerFooter.cellRegistrationInfo
        
        let identifier = SupplementaryIdentifier(identifier: ObjectIdentifier(info.class), kind: kind)
        
        guard self.registeredSupplementaryViewsObjectIdentifiers.contains(identifier) == false else {
            return
        }
        
        self.registeredSupplementaryViewsObjectIdentifiers.insert(identifier)
        
        self.view.register(info.class, forSupplementaryViewOfKind: kind, withReuseIdentifier: info.reuseIdentifier)
    }
    
    private var registeredCellObjectIdentifiers : Set<ObjectIdentifier> = Set()
    
    func registerCell(for item : AnyPresentationItemState)
    {
        let info = item.cellRegistrationInfo
        
        let identifier = ObjectIdentifier(info.class)
        
        guard self.registeredCellObjectIdentifiers.contains(identifier) == false else {
            return
        }
        
        self.registeredCellObjectIdentifiers.insert(identifier)
        
        self.view.register(info.class, forCellWithReuseIdentifier: info.reuseIdentifier)
    }
    
    final class SectionState
    {
        var model : Section
        
        var header : AnyPresentationHeaderFooterState?
        var footer : AnyPresentationHeaderFooterState?
        
        var items : [AnyPresentationItemState]
        
        // TODO: Add header and footer.
        
        init(model : Section)
        {
            self.model = model
            
            self.header = SectionState.headerFooterState(with: self.header, new: model.header)
            self.footer = SectionState.headerFooterState(with: self.footer, new: model.footer)
            
            self.items = self.model.items.map {
                $0.newPresentationItemState() as! AnyPresentationItemState
            }
        }
        
        fileprivate func removeItem(at index : Int)
        {
            self.model.items.remove(at: index)
            self.items.remove(at: index)
        }
        
        fileprivate func update(
            with oldSection : Section,
            new newSection : Section,
            changes : SectionedDiff<Section, AnyItem>.ItemChanges
            )
        {
            self.model = newSection
            
            self.header = SectionState.headerFooterState(with: self.header, new: self.model.header)
            self.footer = SectionState.headerFooterState(with: self.footer, new: self.model.footer)
            
            self.items = changes.transform(
                old: self.items,
                removed: { _, _ in },
                added: { $0.newPresentationItemState() as! AnyPresentationItemState },
                moved: { old, new, item in item.setNew(item: new, reason: .move) },
                updated: { old, new, item in item.setNew(item: new, reason: .update) },
                noChange: { old, new, item in item.setNew(item: new, reason: .noChange) }
            )
        }
        
        fileprivate static func headerFooterState(with current : AnyPresentationHeaderFooterState?, new : AnyHeaderFooter?) -> AnyPresentationHeaderFooterState?
        {
            if let current = current {
                if let new = new {
                    let isSameType = type(of: current.anyModel) == type(of: new)
                    
                    if isSameType {
                        current.setNew(headerFooter: new, reason: .update)
                        return current
                    } else {
                        return (new.newPresentationHeaderFooterState() as! AnyPresentationHeaderFooterState)
                    }
                } else {
                    return nil
                }
            } else {
                if let new = new {
                    return (new.newPresentationHeaderFooterState() as! AnyPresentationHeaderFooterState)
                } else {
                    return nil
                }
            }
        }
    }
    
    final class HeaderFooterState<Element:HeaderFooterElement> : AnyPresentationHeaderFooterState
    {
        var model : HeaderFooter<Element>
        
        private var visibleView : SupplementaryItemView<Element>?
        
        init(_ model : HeaderFooter<Element>)
        {
            self.model = model
            
            self.cellRegistrationInfo = (class: SupplementaryItemView<Element>.self, reuseIdentifier: self.model.reuseIdentifier.stringValue)
        }
        
        // MARK: AnyPresentationHeaderFooterState
        
        var anyModel: AnyHeaderFooter {
            return self.model
        }
        
        public let cellRegistrationInfo : (class:AnyClass, reuseIdentifier:String)
        
        public func dequeueAndPrepareCollectionReusableView(in collectionView : UICollectionView, of kind : String, for indexPath : IndexPath) -> UICollectionReusableView
        {
            let anyView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: self.model.reuseIdentifier.stringValue, for: indexPath)
                        
            self.applyTo(view: anyView, reason: .willDisplay)
            
            return anyView
        }
        
        func applyTo(view anyView : UICollectionReusableView, reason : ApplyReason)
        {
            let view = anyView as! SupplementaryItemView<Element>
            
            self.model.appearance.apply(to: view.content, previous: view.appearance)
            view.appearance = self.model.appearance
            
            self.model.element.apply(to: view.content, reason: reason)
        }
        
        func applyToVisibleView()
        {
            guard let view = self.visibleView else {
                return
            }
            
            self.applyTo(view: view, reason: .wasUpdated)
        }
        
        func setNew(headerFooter anyHeaderFooter: AnyHeaderFooter, reason: UpdateReason)
        {
            let oldModel = self.model
            
            self.model = anyHeaderFooter as! HeaderFooter<Element>
            
            if oldModel.height != self.model.height {
                self.resetCachedHeights()
            }
            
            if reason != .noChange {
                self.resetCachedHeights()
            }
        }
        
        func willDisplay(view : UICollectionReusableView, in collectionView : UICollectionView, for indexPath : IndexPath)
        {
            self.visibleView = (view as! SupplementaryItemView<Element>)
        }
        
        func didEndDisplay()
        {
            self.visibleView = nil
        }
        
        private var cachedHeights : [CGFloat:CGFloat] = [:]
        
        func resetCachedHeights()
        {
            self.cachedHeights.removeAll()
        }
        
        func height(with width : CGFloat, defaultHeight : CGFloat, measurementCache : ReusableViewCache) -> CGFloat
        {
            guard width > 0.0 else {
                return 0.0
            }
            
            if let height = self.cachedHeights[width] {
                return height
            } else {
                let height : CGFloat = measurementCache.use(
                    with: self.model.reuseIdentifier,
                    create: {
                        return SupplementaryItemView<Element>()
                }, { view in
                    self.model.appearance.apply(to: view.content, previous: view.appearance)
                    view.appearance = self.model.appearance
                    
                    self.model.element.apply(to: view.content, reason: .willDisplay)
                    
                    return self.model.height.measure(with: view, fittingWidth: width, default: defaultHeight)
                })
                
                self.cachedHeights[width] = height
                
                return height
            }
        }
    }
    
    final class ItemState<Element:ItemElement> : AnyPresentationItemState
    {
        var model : Item<Element>
        
        let binding : Binding<Element>?
        
        private var visibleCell : ItemElementCell<Element>?
        
        init(_ model : Item<Element>)
        {
            self.model = model
            
            // TODO: Remove anyIdentifier?
            self.anyIdentifier = self.model.identifier
        
            self.cellRegistrationInfo = (ItemElementCell<Element>.self, model.reuseIdentifier.stringValue)
            
            if let binding = self.model.bind?(self.model.element)
            {
                self.binding =  binding
                
                binding.start()
                
                binding.onChange { [weak self] element in
                    guard let self = self else { return }
                    
                    self.model.element = element
                    
                    if let views = self.visibleCell?.content {
                        self.model.element.apply(
                            to: views,
                            with: .init(isSelected: false, isHighlighted: false),
                            reason: .willDisplay
                        )
                    }
                }
                
                // Pull the current element off the binding in case it changed
                // during initialization, from the provider.
                
                self.model.element = binding.element
            } else {
                self.binding = nil
            }
        }
        
        deinit {
            self.binding?.discard()
        }
        
        // MARK: AnyPresentationItemState
        
        private(set) var isDisplayed : Bool = false
        
        func setAndPerform(isDisplayed: Bool) {
            guard self.isDisplayed != isDisplayed else {
                return
            }
            
            self.isDisplayed = isDisplayed
            
            if self.isDisplayed {
                self.model.onDisplay?(self.model.element)
            } else {
                self.model.onEndDisplay?(self.model.element)
            }
        }
        
        let anyIdentifier : AnyIdentifier
        
        var anyModel : AnyItem {
            return self.model
        }
        
        var cellRegistrationInfo : (class:AnyClass, reuseIdentifier:String)
        
        func dequeueAndPrepareCollectionViewCell(in collectionView : UICollectionView, for indexPath : IndexPath) -> UICollectionViewCell
        {
            let anyCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellRegistrationInfo.reuseIdentifier, for: indexPath)
            
            let cell = anyCell as! ItemElementCell<Element>
            
            // Theme cell & apply content.
            
            let itemState = Listable.ItemState(cell: cell)
            
            self.applyTo(
                cell: cell,
                itemState: itemState,
                reason: .willDisplay
            )
            
            // Update appearance for position.
            
            self.updatePosition(
                with: anyCell,
                in: collectionView,
                for: indexPath
            )
            
            return cell
        }
        
        func applyTo(cell anyCell : UICollectionViewCell, itemState : Listable.ItemState, reason : ApplyReason)
        {
            let cell = anyCell as! ItemElementCell<Element>
            
            self.model.appearance.apply(to: cell.content, with: itemState, previous: cell.appearance)
            cell.appearance = self.model.appearance
                        
            self.model.element.apply(
                to: cell.content,
                with: itemState,
                reason: reason
            )
        }
        
        func applyToVisibleCell()
        {
            guard let cell = self.visibleCell else {
                return
            }
            
            self.applyTo(
                cell: cell,
                itemState: .init(cell: cell),
                reason: .wasUpdated
            )
        }
        
        func setNew(item anyItem: AnyItem, reason: UpdateReason)
        {
            let oldModel = self.model
            
            self.model = anyItem as! Item<Element>
            
            if oldModel.height != self.model.height {
                self.resetCachedHeights()
            }
            
            if reason != .noChange {
                self.resetCachedHeights()
            }
        }
        
        func willDisplay(cell anyCell : UICollectionViewCell, in collectionView : UICollectionView, for indexPath : IndexPath)
        {
            let cell = (anyCell as! ItemElementCell<Element>)
            
            self.visibleCell = cell
        }
        
        func updatePosition(with anyCell : UICollectionViewCell, in collectionView : UICollectionView, for indexPath : IndexPath)
        {
            let cell = (anyCell as! ItemElementCell<Element>)

            self.model.appearance.update(view: cell.content, with: collectionView.position(for: indexPath))
        }
        
        func didEndDisplay()
        {
            self.visibleCell = nil
        }
        
        public func performUserDidSelectItem(isSelected: Bool)
        {
            self.model.selection = .isSelectable(isSelected: isSelected)
            
            if isSelected {
                self.model.onSelect?(self.model.element)
            } else {
                self.model.onDeselect?(self.model.element)
            }
        }
        
        private var cachedHeights : [CGFloat:CGFloat] = [:]
        
        func resetCachedHeights()
        {
            self.cachedHeights.removeAll()
        }
        
        func height(with width : CGFloat, defaultHeight : CGFloat, measurementCache : ReusableViewCache) -> CGFloat
        {
            guard width > 0.0 else {
                return 0.0
            }
            
            if let height = self.cachedHeights[width] {
                return height
            } else {
                let height : CGFloat = measurementCache.use(
                    with: self.model.reuseIdentifier,
                    create: {
                        return ItemElementCell<Element>()
                }, { cell in
                    let itemState = Listable.ItemState(isSelected: false, isHighlighted: false)
                    
                    self.applyTo(cell: cell, itemState: itemState, reason: .willDisplay)
                    
                    return self.model.height.measure(with: cell, fittingWidth: width, default: defaultHeight)
                })
                
                self.cachedHeights[width] = height
                
                return height
            }
        }
    }
}

fileprivate extension UICollectionView
{
    func position(for indexPath : IndexPath) -> ItemPosition
    {
        let itemCount = self.numberOfItems(inSection: indexPath.section)
        
        let itemIndex = indexPath.item
        
        if itemCount == 0 {
            return .single
        } else if itemCount == 1 {
            return .single
        } else {
            if itemIndex == 0 {
                return .first
            } else if itemIndex == (itemCount - 1) {
                return .last
            } else {
                return .middle
            }
        }
    }
}

private func syncOptionals<Left,Right>(left : Left?, right : Right?, created : (Right) -> (), removed : (Left) -> (), overlapping: (Left, Right) -> ())
{
    if left == nil, let right = right {
        created(right)
    } else if let left = left, right == nil {
        removed(left)
    } else if let left = left, let right = right {
        overlapping(left, right)
    }
}
