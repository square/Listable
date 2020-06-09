//
//  PagedListLayout.swift
//  Listable
//
//  Created by Kyle Van Essen on 6/4/20.
//

public extension Appearance
{
    var paged : PagedAppearance {
        get {
            self[PagedAppearance.self, default: PagedAppearance()]
        }
        
        set {
            self[PagedAppearance.self] = newValue
        }
    }
}


public struct PagedAppearance : Equatable
{
    var showsScrollIndicators : Bool = false
}


final class PagedListLayout : ListLayout
{
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
        self.appearance = Appearance()
        self.behavior = Behavior()
        
        self.content = ListLayoutContent()
    }
    
    init(
        delegate : CollectionViewLayoutDelegate,
        appearance : Appearance,
        behavior : Behavior,
        in collectionView : UICollectionView
        )
    {
        self.appearance = appearance
        self.behavior = behavior
        
        self.content = ListLayoutContent(
            delegate: delegate,
            direction: .vertical,
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
