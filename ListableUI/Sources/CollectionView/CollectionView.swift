//
//  CollectionView.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 11/29/23.
//

import Foundation


final class LSTCollectionView : UIScrollView {
    
    private let queue : ListChangesQueue
    
    private(set) var content : Content
    
    private var reuseCache : ReusableViewCache
    
    private let view : ContentView
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        
        self.queue = .init()
        self.content = .empty
        self.reuseCache = .init()
        self.view = .init(frame: .init(origin: .zero, size: frame.size))
        
        super.init(frame: frame)
        
        self.addSubview(self.view)
    }
    
    // MARK: UIScrollView
    
    override func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        super.setContentOffset(contentOffset, animated: animated)
    }
    
    // MARK: UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.view.frame = bounds
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func set(
        content : Content,
        changes: SectionedDiff<Section,
        AnyIdentifier,
        AnyItem,
        AnyIdentifier>,
        completion : @escaping () -> ()
    ) {
        queue.add {
            
        }
    }
    
}

extension LSTCollectionView {
    final class ContentView : UIScrollView {
        
    }
}

open class LSTCollectionReusableView : UIView {
    
}

open class LSTCollectionSupplementaryView : LSTCollectionReusableView {
    
}

open class LSTCollectionItemView : LSTCollectionReusableView {
    
}


extension LSTCollectionView {
    
    struct Content {
        
        static var empty : Self {
            fatalError()
        }
        
        var supplementaries : Supplementaries
        
        var sections : [Section]
    }
    
    struct Section {
        var supplementaries : Supplementaries
        
        var items : [Item]
    }
    
    struct Item {
        var value : AnyItem
        
        var state : State
        
        final class State {
            
        }
    }
    
    struct Supplementaries {
        
        private var byType : [ObjectIdentifier:Supplementary]
        
    }
    
    struct Supplementary {
        var value : AnyHeaderFooter
        
        var state : State
        
        final class State {
            
        }
    }
}

protocol SupplementaryTypeKey {
    
}
