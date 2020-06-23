//
//  PagedListLayout.swift
//  Listable
//
//  Created by Kyle Van Essen on 6/4/20.
//


public extension LayoutDescription
{
    static func paged(_ configure : @escaping (inout PagedAppearance) -> () = { _ in }) -> Self
    {
        PagedListLayout.describe(appearance: configure)
    }
}

public struct PagedAppearance : ListLayoutAppearance
{
    public static var `default`: PagedAppearance {
        Self.init()
    }
    
    public var direction: LayoutDirection
    
    public var showsScrollIndicators : Bool
    
    public var itemInsets : UIEdgeInsets
    
    public var pagingSize : PagingSize
    
    public init(
        direction: LayoutDirection = .vertical,
        showsScrollIndicators : Bool = false,
        itemInsets : UIEdgeInsets = .zero
    ) {
        self.pagingSize = .view
        
        self.direction = direction
        self.showsScrollIndicators = showsScrollIndicators
        self.itemInsets = itemInsets
    }
    
    public enum PagingSize : Equatable {
        case view
        case fixed(CGFloat)
        
        func size(for view : UIView, direction : LayoutDirection) -> CGSize {
            switch self {
            case .view: return view.bounds.size
            case .fixed(let fixed):
                switch direction {
                case .vertical: return CGSize(width: view.bounds.width, height: fixed)
                case .horizontal: return CGSize(width: fixed, height: view.bounds.height)
                }
            }
        }
    }
}


final class PagedListLayout : ListLayout
{
    public typealias LayoutAppearance = PagedAppearance
    
    static var defaults: ListLayoutDefaults {
        .init(itemInsertAndRemoveAnimations: .scaleDown)
    }
    
    var layoutAppearance: PagedAppearance
    
    let appearance: Appearance
    let behavior: Behavior
    let content: ListLayoutContent
            
    var scrollViewProperties: ListLayoutScrollViewProperties {
        .init(
            isPagingEnabled: self.layoutAppearance.pagingSize == .view,
            contentInsetAdjustmentBehavior: .never,
            allowsBounceVertical: false,
            allowsBounceHorizontal: false,
            allowsVerticalScrollIndicator: self.layoutAppearance.showsScrollIndicators,
            allowsHorizontalScrollIndicator: self.layoutAppearance.showsScrollIndicators
        )
    }
    
    //
    // MARK: Initialization
    //
    
    init(
        layoutAppearance: PagedAppearance,
        appearance: Appearance,
        behavior: Behavior,
        content: ListLayoutContent
    ) {        
        self.layoutAppearance = layoutAppearance
        self.appearance = appearance
        self.behavior = behavior
        
        self.content = content
    }
    
    //
    // MARK: Performing Layouts
    //
    
    func updateLayout(in collectionView : UICollectionView)
    {
        // Nothing needed.
    }
    
    func layout(
        delegate : CollectionViewLayoutDelegate,
        in collectionView : UICollectionView  
    ) {
        let viewSize = self.layoutAppearance.pagingSize.size(for: collectionView, direction: self.direction)
        
        var lastMaxY : CGFloat = 0.0
        
        for item in content.all {
            
            let containerFrame : CGRect
                            
            switch direction {
            case .vertical: containerFrame = CGRect(x: 0.0, y: lastMaxY, width: viewSize.width, height: viewSize.height)
            case .horizontal: containerFrame = CGRect(x: lastMaxY, y: 0.0, width: viewSize.width, height: viewSize.height)
            }
            
            let viewFrame = containerFrame.inset(by: self.layoutAppearance.itemInsets)
            
            item.x = viewFrame.origin.x
            item.y = viewFrame.origin.y
            item.size = viewFrame.size
            
            lastMaxY = direction.maxY(for: containerFrame)
        }
        
        self.content.contentSize = direction.switch(
            vertical: CGSize(width: viewSize.width, height: lastMaxY),
            horizontal: CGSize(width: lastMaxY, height: viewSize.height)
        )
    }
}
