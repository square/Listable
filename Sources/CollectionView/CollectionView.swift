//
//  CollectionView.swift
//  Listable
//
//  Created by Kyle Van Essen on 7/1/19.
//

import UIKit


public protocol CollectionViewCellElement
{
    // MARK: Identifying Content & Changes
    
    var identifier : Identifier<Self> { get }
    
    func wasMoved(comparedTo other : Self) -> Bool
    func wasUpdated(comparedTo other : Self) -> Bool
    
    // MARK: Applying To Displayed Cell
    
    func applyTo(cell : CollectionView.ElementCell<Content, Background, SelectedBackground>)
    
    var updateStrategy : UpdateStrategy { get }
    
    // MARK: Converting To Cell For Display
        
    associatedtype Content:UIView
    associatedtype Background:UIView
    associatedtype SelectedBackground:UIView
    
    static func createReusableViews() -> CollectionView.ElementCellViews<Content, Background, SelectedBackground>
}

public extension CollectionViewCellElement where Self:Equatable
{
    // MARK: Identifying Content & Changes
    
    func wasMoved(comparedTo other : Self) -> Bool
    {
        return self != other
    }
    
    func wasUpdated(comparedTo other : Self) -> Bool
    {
        return self != other
    }
}


public protocol CollectionViewSupplementaryElement
{
    // MARK: Identifying Content & Changes
    
    var identifier : Identifier<Self> { get }
    
    func wasMoved(comparedTo other : Self) -> Bool
    func wasUpdated(comparedTo other : Self) -> Bool
    
    // MARK: Applying To Displayed View
    
    func applyTo(contentView : ContentView)
    
    // MARK: Converting To View For Display
    
    associatedtype ContentView:UIView
    
    static func createReusableView() -> ContentView
}

public extension CollectionViewSupplementaryElement where Self:Equatable
{
    // MARK: Identifying Content & Changes
    
    func wasMoved(comparedTo other : Self) -> Bool
    {
        return self != other
    }
    
    func wasUpdated(comparedTo other : Self) -> Bool
    {
        return self != other
    }
}


public protocol CollectionViewLayoutSizing
{
    func size(with view : UIView, fittingSize : CGSize, default defaultSize : CGSize) -> CGSize
    
    static var defaultSize : Self { get }
}

public protocol CollectionViewLayoutSupplementaryElementKind
{
    var stringValue : String { get }
}

public protocol CollectionViewLayoutDelegate : AnyObject
{
    var collectionView: CollectionView! { get set }
}

public protocol AnyCollectionViewLayout
{
    var anyLayout : UICollectionViewLayout { get }
    var anyLayoutDelegate : CollectionViewLayoutDelegate? { get }
}

public protocol CollectionViewLayout : AnyCollectionViewLayout
{
    associatedtype ItemSizing : CollectionViewLayoutSizing
    associatedtype SupplementaryItemSizing : CollectionViewLayoutSizing
    
    associatedtype SupplementaryElementKind : CollectionViewLayoutSupplementaryElementKind
    
    associatedtype Layout : UICollectionViewLayout
    
    var layout : Layout { get }
    
    associatedtype LayoutDelegate : CollectionViewLayoutDelegate
    
    var layoutDelegate : LayoutDelegate? { get }
}

public extension CollectionViewLayout
{
    var anyLayout : UICollectionViewLayout {
        return self.layout
    }
    
    var anyLayoutDelegate: CollectionViewLayoutDelegate? {
        return self.layoutDelegate
    }
}

public extension CollectionViewLayout
{
    func content(with build : (inout CollectionView.ContentBuilder<Self>) -> ()) -> CollectionView.Content
    {
        var builder = CollectionView.ContentBuilder(layout: self)
        
        build(&builder)
        
        return CollectionView.Content(sections: builder.sections)
    }
}


public protocol CollectionViewItem
{
    var identifier : AnyIdentifier { get }
    
    func dequeueCell(in collectionView: UICollectionView, for indexPath : IndexPath) -> UICollectionViewCell
    
    func willDisplay(with cell : UICollectionViewCell)
    func didEndDisplay()
    
    func size(fittingSize : CGSize, default defaultSize : CGSize, measurementCache : ReusableViewCache) -> CGSize
}

public protocol CollectionViewSupplementaryItem
{
    var identifier : AnyIdentifier { get }
    
    var anyKind : CollectionViewLayoutSupplementaryElementKind { get }
    
    func dequeueReusableView(in collectionView: UICollectionView, for indexPath : IndexPath) -> UICollectionReusableView
    
    func willDisplay(with view : UICollectionReusableView)
    func didEndDisplay()
}

public extension CollectionView
{
    struct ElementCellViews<Content:UIView, Background:UIView, SelectedBackground:UIView>
    {
        public let content : Content
        public let background : Background?
        public let selectedBackground : SelectedBackground?
    }
    
    final class ElementCell<Content:UIView, Background:UIView, SelectedBackground:UIView> : UICollectionViewCell
    {
        internal var views : ElementCellViews<Content, Background, SelectedBackground>? {
            didSet {
                if let old = oldValue {
                    old.content.removeFromSuperview()
                    self.backgroundView = nil
                    self.selectedBackgroundView = nil
                }
                
                if let new = views {
                    self.contentView.addSubview(new.content)
                    self.backgroundView = new.background
                    self.selectedBackgroundView = new.selectedBackground
                }
            }
        }
        
        public override func layoutSubviews()
        {
            super.layoutSubviews()
            
            self.views?.content.frame = self.contentView.bounds
        }
    }
    
    final class ElementReusableView<Element:CollectionViewSupplementaryElement> : UICollectionReusableView
    {
        public var contentView : Element.ContentView? {
            didSet {
                if let old = oldValue {
                    old.removeFromSuperview()
                }
                
                if let new = self.contentView {
                    self.addSubview(new)
                }
            }
        }
        
        public override func layoutSubviews()
        {
            super.layoutSubviews()
            
            self.contentView?.frame = self.bounds
        }
    }
    
    struct Section
    {
        public let identifier : AnyIdentifier
        
        public var items : [CollectionViewItem]
        
        public var header : CollectionViewSupplementaryItem?
        public var footer : CollectionViewSupplementaryItem?
        
        public func supplementaryItem(at index: Int, of kind : String) -> CollectionViewSupplementaryItem?
        {
            if let header = self.header, index == 0 && kind == header.anyKind.stringValue {
                return header
            }
            
            // TODO is this index right?
            if let footer = self.footer, index == self.items.count && kind == footer.anyKind.stringValue {
                return footer
            }
            
            return nil
        }
    }
    
    struct SupplementaryItem<Element:CollectionViewSupplementaryElement, Kind:CollectionViewLayoutSupplementaryElementKind, Sizing:CollectionViewLayoutSizing> : CollectionViewSupplementaryItem
    {
        public let identifier : AnyIdentifier
        
        public let element : Element
        
        public let kind : Kind
        
        public var anyKind : CollectionViewLayoutSupplementaryElementKind {
            return self.kind
        }
        
        private let reuseIdentifier : ReuseIdentifier<Element>
        
        public let sizing : Sizing
        
        public init(_ element : Element, kind: Kind, sizing : Sizing = .defaultSize)
        {
            self.element = element
            self.sizing = sizing
            self.kind = kind
            
            self.identifier = AnyIdentifier(element.identifier)
            
            self.reuseIdentifier = ReuseIdentifier.identifier(for: element)
        }
        
        // MARK: CollectionViewSupplementaryItem
        
        public func dequeueReusableView(in collectionView: UICollectionView, for indexPath : IndexPath) -> UICollectionReusableView
        {
            let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: self.kind.stringValue,
                withReuseIdentifier: self.reuseIdentifier.stringValue,
                for: indexPath
                ) as! ElementReusableView<Element>
            
            if view.contentView == nil {
                view.contentView = Element.createReusableView()
            }
            
            return view
        }
        
        public func willDisplay(with view : UICollectionReusableView)
        {
            
        }
        
        public func didEndDisplay()
        {
            
        }
    }
    
    struct Item<Element:CollectionViewCellElement, Sizing:CollectionViewLayoutSizing> : CollectionViewItem
    {
        public let identifier : AnyIdentifier
        
        public let element : Element
        
        private let reuseIdentifier : ReuseIdentifier<Element>
        
        public let sizing : Sizing
        
        public init(_ element : Element, sizing : Sizing = .defaultSize)
        {
            self.element = element
            self.sizing = sizing
            
            self.identifier = AnyIdentifier(element.identifier)
            self.reuseIdentifier = ReuseIdentifier.identifier(for: self.element)
        }
        
        // MARK: CollectionViewItem
        
        typealias DisplayCell = ElementCell<Element.Content, Element.Background, Element.SelectedBackground>
        
        public func dequeueCell(in collectionView: UICollectionView, for indexPath : IndexPath) -> UICollectionViewCell
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseIdentifier.stringValue, for: indexPath) as! DisplayCell
            
            if cell.views == nil {
                cell.views = Element.createReusableViews()
            }
            
            return cell
        }
        
        public func willDisplay(with cell : UICollectionViewCell)
        {
            
        }
        
        public func didEndDisplay()
        {
            
        }
        
        public func size(fittingSize : CGSize, default defaultSize : CGSize, measurementCache : ReusableViewCache) -> CGSize
        {
            return measurementCache.use(with: self.reuseIdentifier, create: { () -> DisplayCell in
                let cell = DisplayCell()
                cell.views = Element.createReusableViews()
                
                return cell
            }, { cell in
                return self.sizing.size(with: cell.views!.content, fittingSize: fittingSize, default: defaultSize)
            })
        }
    }
}


public class CollectionView : UIView
{
    // MARK: Public Properties
    
    public var content : Content {
        get { return _content }
        set { self.set(content: newValue, animated: false) }
    }
    
    private var _content : Content
    
    public func setContent<Layout:CollectionViewLayout>(animated : Bool, layout : Layout, _ build : (inout ContentBuilder<Layout>) -> ())
    {
        let content = layout.content(with: build)
        
        self.set(content: content, animated: animated)
    }
    
    public func set(content : CollectionView.Content, animated : Bool)
    {
        // TODO: Need to move this AFTER the beginUpdates call at some point.
        _content = content
    }
    
    // TOOD: need to support changing layout...
    public let layout : AnyCollectionViewLayout
    
    public var backgroundView : UIView? {
        didSet {
            self.collectionView.backgroundView = self.backgroundView
        }
    }
    
    // MARK: Private Properties
    
    private let collectionView : UICollectionView

    private let dataSource : DataSource
    private let delegate : Delegate
    
    public let cellMeasurementCache : ReusableViewCache
    public let headerMeasurementCache : ReusableViewCache
    public let footerMeasurementCache : ReusableViewCache
    
    // MARK: Initialization
    
    public init(frame : CGRect = .zero, layout : AnyCollectionViewLayout)
    {
        _content = Content(sections: [])
        
        self.dataSource = DataSource()
        self.delegate = Delegate()
        
        self.cellMeasurementCache = ReusableViewCache()
        self.headerMeasurementCache = ReusableViewCache()
        self.footerMeasurementCache = ReusableViewCache()
        
        self.layout = layout
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.layout.anyLayout)

        super.init(frame: frame)
        
        self.dataSource.collectionView = self
        self.delegate.collectionView = self
        self.layout.anyLayoutDelegate?.collectionView = self
        
        self.collectionView.frame = self.bounds
        self.addSubview(self.collectionView)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: UIView
    
    public override func layoutSubviews()
    {
        super.layoutSubviews()
        
        self.collectionView.frame = self.bounds
    }
}


public extension CollectionView
{
    struct Content
    {
        public var sections : [CollectionView.Section]
        
        public func section(at index : Int) -> CollectionView.Section
        {
            return self.sections[index]
        }
        
        public func item(at indexPath: IndexPath) -> CollectionViewItem
        {
            return self.sections[indexPath.section].items[indexPath.item]
        }
        
        public func supplementaryItem(at indexPath: IndexPath, of kind : String) -> CollectionViewSupplementaryItem?
        {
            return self.section(at: indexPath.section).supplementaryItem(at: indexPath.row, of: kind)
        }
    }
}


fileprivate extension CollectionView
{
    final class DataSource : NSObject, UICollectionViewDataSource
    {
        unowned var collectionView : CollectionView!
        
        func numberOfSections(in collectionView: UICollectionView) -> Int
        {
            return self.collectionView.content.sections.count
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
        {
            let section = self.collectionView.content.section(at: section)
            
            return section.items.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
        {
            let item = self.collectionView.content.item(at: indexPath)
            
            return item.dequeueCell(in: collectionView, for: indexPath)
        }
        
        func collectionView(
            _ collectionView: UICollectionView,
            viewForSupplementaryElementOfKind kind: String,
            at indexPath: IndexPath
            ) -> UICollectionReusableView
        {
            guard let item = self.collectionView.content.supplementaryItem(at: indexPath, of: kind) else {
                fatalError()
            }
            
            return item.dequeueReusableView(in: collectionView, for: indexPath)
        }
        
        func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool
        {
            return false
        }
        
        func collectionView(
            _ collectionView: UICollectionView,
            moveItemAt sourceIndexPath: IndexPath,
            to destinationIndexPath: IndexPath
            )
        {
            fatalError()
        }
    }
    
    final class Delegate : NSObject, UICollectionViewDelegate
    {
        unowned var collectionView : CollectionView!
        
        override func forwardingTarget(for aSelector: Selector!) -> Any? {
            return self.collectionView.layout.anyLayoutDelegate
        }
        
        func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool
        {
            return true
        }
        
        func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath)
        {
            // TODO
        }
        
        func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath)
        {
            // TODO
        }
        
        func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool
        {
            return true
        }
        
        func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool
        {
            return true
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
        {
            // TODO
        }
        
        func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
        {
            // TODO
        }
        
        var visibleItems : [IndexPath:CollectionViewItem] = [:]
        
        struct VisibleSupplementaryItem : Hashable
        {
            let indexPath : IndexPath
            let kind : String
        }
        
        var visibleSupplementaryItems : [VisibleSupplementaryItem:CollectionViewItem] = [:]
        
        func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
        {
            let item = self.collectionView.content.item(at: indexPath)
            
            self.visibleItems[indexPath] = item
            
            item.willDisplay(with: cell)
        }
        
        func collectionView(
            _ collectionView: UICollectionView,
            willDisplaySupplementaryView view: UICollectionReusableView,
            forElementKind elementKind: String,
            at indexPath: IndexPath
            )
        {
            let key = VisibleSupplementaryItem(indexPath: indexPath, kind: elementKind)
            
            // TODO where do supplementary items come from?
            self.visibleSupplementaryItems[key] = nil
            
            
        }
        
        func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
        {
            guard let item = self.visibleItems.removeValue(forKey: indexPath) else {
                return
            }
            
            item.didEndDisplay()
        }
        
        func collectionView(
            _ collectionView: UICollectionView,
            didEndDisplayingSupplementaryView view: UICollectionReusableView,
            forElementOfKind elementKind: String,
            at indexPath: IndexPath
            )
        {
            let key = VisibleSupplementaryItem(indexPath: indexPath, kind: elementKind)
            
            guard let supplementary = self.visibleSupplementaryItems.removeValue(forKey: key) else {
                return
            }
            
            supplementary.didEndDisplay()
        }
    }
}
