//
//  MosaicListLayout.swift
//  ListableUI
//
//  Created by Gabriel Hernandez Ontiveros on 2021-07-23.
//

import Foundation

extension LayoutDescription
{
    public static func mosaic(_ configure : @escaping (inout MosaicAppearance) -> () = { _ in }) -> Self
    {
        MosaicListLayout.describe(appearance: configure)
    }
}


public struct MosaicAppearance : ListLayoutAppearance
{
    public var layout : Layout
    
    public var direction: LayoutDirection {
        .vertical
    }
    
    public var stickySectionHeaders : Bool = false
    
    public static var `default`: MosaicAppearance {
        return self.init()
    }
    
    public init(
        layout : Layout = Layout()
    ) {
        self.layout = layout
    }
    
    public struct Layout : Equatable
    {
        public var padding : UIEdgeInsets
        public var itemSpacing: CGFloat

        public var columns: Int
        public var rows: Rows
        
        public enum Rows : Equatable {
            case rows(Int)
            case infinite
        }
        
        public init(
            padding : UIEdgeInsets = .zero,
            itemSpacing : CGFloat = 0.0,
            columns: Int = 1,
            rows: Rows = .infinite
        )
        {
            precondition(columns >= 1, "Columns must be greater than or equal to 1.")
            if case .rows(let rowCount) = rows {
                precondition(rowCount >= 1, "Rows must be greater than or equal to 1.")
            }
            self.padding = padding
            self.itemSpacing = itemSpacing
            self.columns = columns
            self.rows = rows
        }

        public mutating func set(with block : (inout Layout) -> ())
        {
            var edited = self
            block(&edited)
            self = edited
        }
        
        internal static func width(
            with width : CGFloat,
            padding : HorizontalPadding,
            constraint : WidthConstraint
        ) -> CGFloat
        {
            let paddedWidth = width - padding.left - padding.right
            
            return constraint.clamp(paddedWidth)
        }
    }
}


extension MosaicAppearance {
    
    public struct ItemLayout : ItemLayoutsValue {
        
        public let origin: Origin
        public let size: Size
        
        public struct Origin: Equatable {
            public let x: Int
            public let y: Int
            
            public static let zero: Origin = .init(x: 0, y: 0)
            
            public init(x: Int, y: Int) {
                self.x = x
                self.y = y
            }
        }

        public struct Size: Equatable {
            
            public enum TileSize: Equatable {
                case single
                case double
                
                var value: CGFloat {
                    switch self {
                    case .single:
                        return 1.0
                    case .double:
                        return 2.0
                    }
                }
            }
            
            let width: TileSize
            let height: TileSize
            
            public static let single: Size = .init(width: .single, height: .single)
            public static let wide: Size = .init(width: .double, height: .single)
            public static let tall: Size = .init(width: .single, height: .double)
            public static let big: Size = .init(width: .double, height: .double)
            
            
            public init(width: TileSize, height: TileSize) {
                self.width = width
                self.height = height
            }
        }
        
        
        public static var defaultValue: Self {
            .init()
        }
        
        public init(
            origin: Origin = .zero,
            size: Size = .single
        ) {
            self.origin = origin
            self.size = size
        }
        
        func pageIndex(rows: Layout.Rows) -> Int {
            guard case .rows(let rowCount) = rows else {
                return 0
            }
            return origin.y / Int(rowCount)
        }
        
        
        func frame(pageSize: CGSize, pagePadding: UIEdgeInsets, itemSpacing: CGFloat, columns: Int, rows: Layout.Rows) -> CGRect {
            let pageIndex = self.pageIndex(rows: rows)
            
            let totalHorizontalItemSpacing = itemSpacing * CGFloat(columns - 1) + pagePadding.left + pagePadding.right
            let availableWidth = pageSize.width - totalHorizontalItemSpacing
            let tileWidth = (availableWidth / CGFloat(columns) * size.width.value) + (size.width.value - 1) * itemSpacing

            var tileHeight: CGFloat
            let oneByOneTile : CGSize
            
            let localYOrigin: Int
            switch rows {
            case .rows(let rowCount):
                localYOrigin = origin.y % rowCount
                let totalVerticalItemSpacing = itemSpacing * CGFloat(rowCount - 1) + pagePadding.top + pagePadding.bottom
                let availableHeight = pageSize.height - totalVerticalItemSpacing
                
                if Int(size.height.value) % rowCount == 0 {
                    // page size tile height
                    tileHeight = availableHeight * CGFloat(Int(size.height.value) / rowCount)
                    // if the tile crosses to the next page, add top padding as part of the height
                    let localY = origin.y % Int(rowCount)
                    if Int(size.height.value) + localY > rowCount {
                        tileHeight += pagePadding.top
                    }
                } else {
                    tileHeight = (availableHeight / CGFloat(rowCount) * size.height.value)
                }

                oneByOneTile = CGSize(width: availableWidth / CGFloat(columns), height: availableHeight / CGFloat(rowCount))
            case .infinite:
                localYOrigin = origin.y
                oneByOneTile = CGSize(width: availableWidth / CGFloat(columns), height: availableWidth / CGFloat(columns))
                tileHeight = availableWidth / CGFloat(columns) * size.height.value
            }

            tileHeight += (size.height.value - 1) * itemSpacing
            
            let realX: CGFloat = CGFloat(origin.x) * oneByOneTile.width + itemSpacing * CGFloat(origin.x)
            let pageY = CGFloat(pageIndex) * pageSize.height
            let realY: CGFloat = pageY + CGFloat(localYOrigin) * oneByOneTile.height + itemSpacing * CGFloat(localYOrigin) + pagePadding.top
            
            return CGRect(x: realX + pagePadding.left, y: realY, width: tileWidth, height: tileHeight)
        }
    }
}


extension ItemLayouts {
    public var mosaic : MosaicAppearance.ItemLayout {
        get { self[MosaicAppearance.ItemLayout.self] }
        set { self[MosaicAppearance.ItemLayout.self] = newValue }
    }
}


final class MosaicListLayout : ListLayout
{
    typealias LayoutAppearance = MosaicAppearance
    
    static var defaults: ListLayoutDefaults {
        .init(itemInsertAndRemoveAnimations: .scaleDown)
    }
    
    var layoutAppearance: MosaicAppearance
 
    let appearance : Appearance
    let behavior : Behavior
    
    let content : ListLayoutContent
    
    var scrollViewProperties: ListLayoutScrollViewProperties {
        .init(
            isPagingEnabled: self.layoutAppearance.layout.rows != .infinite,
            contentInsetAdjustmentBehavior: .automatic,
            allowsBounceVertical: true,
            allowsBounceHorizontal: false,
            allowsVerticalScrollIndicator: true,
            allowsHorizontalScrollIndicator: false
        )
    }
    
    //
    // MARK: Initialization
    //
    
    init(
        layoutAppearance: MosaicAppearance,
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
    
    func updateLayout(in collectionView: UICollectionView)
    {
        
    }
    
    func layout(
        delegate : CollectionViewLayoutDelegate?,
        in context : ListLayoutLayoutContext
    ) {
        let layout = self.layoutAppearance.layout
        let viewSize = context.viewBounds.size
        var lastContentMaxY : CGFloat = 0.0
        
        self.content.sections.forEachWithIndex { sectionIndex, isLast, section in
            section.items.forEach { item in

                let frame = item.layouts.mosaic.frame(
                    pageSize: viewSize,
                    pagePadding: layout.padding,
                    itemSpacing: layout.itemSpacing,
                    columns: layout.columns,
                    rows: layout.rows
                )
                 
                item.x = frame.origin.x
                item.y = frame.origin.y
                item.size = frame.size
                
                lastContentMaxY = max(lastContentMaxY, item.y + item.size.height + layout.padding.bottom)
            }
        }
        
        if scrollViewProperties.isPagingEnabled {
            let pages = (lastContentMaxY / viewSize.height).rounded(.up)
            lastContentMaxY = pages * viewSize.height
        }

        self.content.contentSize = CGSize(width: viewSize.width, height: lastContentMaxY)
    }
}
