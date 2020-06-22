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
    
    public var showsScrollIndicators : Bool = false
    
    public var direction: LayoutDirection {
        .vertical
    }
    
    public var stickySectionHeaders : Bool {
        false
    }
}


final class PagedListLayout : ListLayout
{
    public typealias LayoutAppearance = PagedAppearance
    
    var layoutAppearance: PagedAppearance
    
    let appearance: Appearance
    let behavior: Behavior
    let content: ListLayoutContent
            
    var scrollViewProperties: ListLayoutScrollViewProperties {
        .init(
            isPagingEnabled: true,
            contentInsetAdjustmentBehavior: .never,
            allowsBounceVertical: false,
            allowsBounceHorizontal: false,
            allowsVerticalScrollIndicator: false,
            allowsHorizontalScrollIndicator: false
        )
    }
    
    //
    // MARK: Initialization
    //
    
    init()
    {
        self.layoutAppearance = LayoutAppearance()
        self.appearance = Appearance()
        self.behavior = Behavior()
        
        self.content = ListLayoutContent(with: self.layoutAppearance.direction)
    }
    
    init(
        layoutAppearance: PagedAppearance,
        appearance: Appearance,
        behavior: Behavior,
        delegate: CollectionViewLayoutDelegate,
        in collectionView: UICollectionView
    ) {
        listablePrecondition(layoutAppearance.direction == .vertical, "Only the default layout is currently supported.")
        
        self.layoutAppearance = layoutAppearance
        self.appearance = appearance
        self.behavior = behavior
        
        self.content = ListLayoutContent(
            delegate: delegate,
            direction: layoutAppearance.direction,
            defaults: .init(itemInsertAndRemoveAnimations: .fade),
            in: collectionView
        )
    }
    
    //
    // MARK: Performing Layouts
    //
    
    @discardableResult
    func updateLayout(in collectionView : UICollectionView) -> Bool
    {
        true
    }
    
    func layout(
        delegate : CollectionViewLayoutDelegate,
        in collectionView : UICollectionView
        ) -> Bool
    {
        guard collectionView.frame.size.isEmpty == false else {
            return false
        }
        
        let viewSize = CGSize(
            width: collectionView.bounds.size.width,
            height: collectionView.bounds.size.height
        )
                
        var lastMaxX : CGFloat = 0.0
        var lastSectionMaxX : CGFloat = 0.0
        
        for section in self.content.sections {
            for item in section.items {
                item.x = lastMaxX
                item.y = 0.0
                item.size = viewSize
                
                lastMaxX = item.frame.maxX
            }
            
            section.size = CGSize(width: lastMaxX - lastSectionMaxX, height: viewSize.height)
            
            section.x = lastSectionMaxX
            
            lastSectionMaxX = section.frame.maxX
        }
        
        self.content.contentSize = CGSize(width: lastMaxX, height: viewSize.height)
        
        return true
    }
}
