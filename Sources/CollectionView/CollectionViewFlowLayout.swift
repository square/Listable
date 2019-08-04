//
//  CollectionViewFlowLayout.swift
//  Listable
//
//  Created by Kyle Van Essen on 7/6/19.
//

import UIKit


public final class CollectionViewFlowLayout : UICollectionViewFlowLayout, CollectionViewLayout
{    
    public typealias Layout = UICollectionViewFlowLayout
    
    public var layout : Layout {
        return self
    }
    
    public var layoutDelegate: LayoutDelegate?
    
    public override init()
    {
        self.layoutDelegate = LayoutDelegate()
        
        super.init()
        
        self.layoutDelegate?.layout = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

public extension CollectionViewFlowLayout
{
    final class LayoutDelegate : NSObject, CollectionViewLayoutDelegate, UICollectionViewDelegateFlowLayout
    {
        public unowned var collectionView: CollectionView!
        
        unowned var layout : CollectionViewFlowLayout!
        
        public func collectionView(
            _ collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout,
            sizeForItemAt indexPath: IndexPath
            ) -> CGSize
        {
            let item = self.collectionView.content.item(at: indexPath)
            
            return item.size(
                fittingSize: self.layout.itemSize,
                default: self.layout.itemSize,
                measurementCache: self.collectionView.cellMeasurementCache
            )
        }
        
        public func collectionView(
            _ collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout,
            insetForSectionAt section: Int
            ) -> UIEdgeInsets
        {
            // TODO
            return .zero
        }
        
        public func collectionView(
            _ collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout,
            minimumLineSpacingForSectionAt section: Int
            ) -> CGFloat
        {
            // TODO
            return 0.0
        }
        
        public func collectionView(
            _ collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout,
            minimumInteritemSpacingForSectionAt section: Int
            ) -> CGFloat
        {
            // TODO
            return 0.0
        }
        
        public func collectionView(
            _ collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout,
            referenceSizeForHeaderInSection section: Int
            ) -> CGSize
        {
            // TODO
            return .zero
        }
        
        public func collectionView(
            _ collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout,
            referenceSizeForFooterInSection section: Int
            ) -> CGSize
        {
            // TODO
            return .zero
        }
    }
    
    enum SupplementaryElementKind : CollectionViewLayoutSupplementaryElementKind
    {
        case header
        case footer
        
        public var stringValue: String {
            switch self {
            case .header: return UICollectionView.elementKindSectionHeader
            case .footer: return UICollectionView.elementKindSectionFooter
            }
        }
    }
    
    typealias SupplementaryItemSizing = Sizing
    typealias ItemSizing = Sizing
    
    enum Sizing : CollectionViewLayoutSizing
    {
        case `default`
        case fixed(CGSize)
        case thatFits(SizeConstraint)
        case autolayout(SizeConstraint)
        
        public struct SizeConstraint : Equatable
        {
            public var width : AxisConstraint
            public var height : AxisConstraint
            
            public static var noConstraint : SizeConstraint {
                return SizeConstraint(width: .noConstraint, height: .noConstraint)
            }
            
            public init(width : AxisConstraint = .noConstraint, height : AxisConstraint = .noConstraint)
            {
                self.width = width
                self.height = height
            }
            
            public func clamp(_ size : CGSize) -> CGSize
            {
                return CGSize(
                    width: self.width.clamp(size.width),
                    height: self.height.clamp(size.height)
                )
            }
        }
        
        public static var defaultSize : Sizing {
            return .default
        }
        
        public func size(with view : UIView, fittingSize : CGSize, default defaultSize : CGSize) -> CGSize
        {
            switch self {
            case .default:
                return defaultSize
                
            case .fixed(let fixedSize):
                return fixedSize
                
            case .thatFits(let constraints):
                let size = view.sizeThatFits(fittingSize)
                return constraints.clamp(size)
                
            case .autolayout(let constraints):
                let size = view.systemLayoutSizeFitting(fittingSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)
                return constraints.clamp(size)
            }
        }
    }
}
