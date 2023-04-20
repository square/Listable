//
//  ItemCell.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 9/22/19.
//

import UIKit


protocol AnyItemCell : UICollectionViewCell
{
    func closeSwipeActions()
    
    var areSwipeActionsVisible : Bool  { get }
    
    func isTouchWithinSwipeActionView(touch: UITouch) -> Bool
    
    func wasDequeued(with liveCells : LiveCells)
}

///
/// An internal cell type used to render items in the list.
///
/// Information on how cell selection appearance customization works:
/// https://developer.apple.com/documentation/uikit/uicollectionviewdelegate/changing_the_appearance_of_selected_and_highlighted_cells
///
final class ItemCell<Content:ItemContent> : UICollectionViewCell, AnyItemCell
{
    private(set) lazy var overlayDecoration : OverlayDecorationView = {
        let view = OverlayDecorationView(
            content: Content.createReusableOverlayDecorationView(frame:bounds),
            frame: bounds
        )
        
        self.overlayDecorationIfLoaded = view
        
        self.contentView.insertSubview(view, aboveSubview: self.contentContainer)
        
        return view
    }()
    
    let contentContainer : ContentContainerView

    let background : Content.BackgroundView
    let selectedBackground : Content.SelectedBackgroundView
    
    var isReorderable: Bool = false
    
    private(set) var overlayDecorationIfLoaded : OverlayDecorationView? = nil
    
    override init(frame: CGRect)
    {
        let bounds = CGRect(origin: .zero, size: frame.size)
        
        self.contentContainer = ContentContainerView(frame: bounds)
        
        self.background = Content.createReusableBackgroundView(frame: bounds)
        self.selectedBackground = Content.createReusableSelectedBackgroundView(frame: bounds)
        
        super.init(frame: frame)
            
        self.backgroundView = self.background
        self.selectedBackgroundView = self.selectedBackground
        
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        self.layer.masksToBounds = false
    
        self.contentView.layer.masksToBounds = false

        self.contentView.addSubview(self.contentContainer)
        
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { listableInternalFatal() }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes
    {
        /// **Note** – Please keep this comment in sync with the comment in SupplementaryContainerView.
        
        /**
         Listable already properly sizes each cell. We do not use self-sizing cells.
         Thus, just return the existing layout attributes.
         
         This avoids an expensive call to sizeThatFits to "re-size" the cell to the same size
         during each of UICollectionView's layout passes:
         
         #0  ItemElementCell.sizeThatFits(_:)
         #1  @objc ItemElementCell.sizeThatFits(_:) ()
         #2  -[UICollectionViewCell systemLayoutSizeFittingSize:withHorizontalFittingPriority:verticalFittingPriority:] ()
         #3  -[UICollectionReusableView preferredLayoutAttributesFittingAttributes:] ()
         #4  -[UICollectionReusableView _preferredLayoutAttributesFittingAttributes:] ()
         #5  -[UICollectionView _checkForPreferredAttributesInView:originalAttributes:] ()
         #6  -[UICollectionView _updateVisibleCellsNow:] ()
         #7  -[UICollectionView layoutSubviews] ()
         
         Returning the passed in value without calling super is OK, per the docs:
         https://developer.apple.com/documentation/uikit/uicollectionreusableview/1620132-preferredlayoutattributesfitting
         
           | The default implementation of this method adjusts the size values to accommodate changes made by a self-sizing cell.
           | Subclasses can override this method and use it to adjust other layout attributes too.
           | If you override this method and want the cell size adjustments, call super first and make your own modifications to the returned attributes.
         
         Important part being "If you override this method **and want the cell size adjustments**, call super first".
         
         We do not want these. Thus, this is fine.
         */
        
        return layoutAttributes
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        _accessibilityLabel = nil
    }
    
    // MARK: UIView
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        self.contentContainer.contentView.sizeThatFits(size)
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        self.contentContainer.contentView.systemLayoutSizeFitting(targetSize)
    }
    
    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        self.contentContainer.contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: verticalFittingPriority
        )
    }

    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        self.contentContainer.frame = self.contentView.bounds
        
        self.overlayDecorationIfLoaded?.frame = self.contentView.bounds
    }
    
    // MARK: AnyItemCell
    
    func closeSwipeActions() {
        self.contentContainer.performAnimatedClose()
    }
    
    var areSwipeActionsVisible : Bool {
        switch self.contentContainer.swipeState {
        case .open:
            return true
        default:
            return false
        }
    }
    
    func isTouchWithinSwipeActionView(touch: UITouch) -> Bool {
        self.contentContainer.isTouchWithinSwipeActionView(touch: touch)
    }
    
    private var hasBeenDequeued = false
    
    func wasDequeued(with liveCells : LiveCells) {
        guard hasBeenDequeued == false else {
            return
        }
        
        self.hasBeenDequeued = true
        
        liveCells.add(self)
    }
    
    
    // MARK: AccessibilityLabel
    
    // When reordering cells the UICollectionView expects all cells to have a valid accessibility label, even when acting as an accessibility container with `isAccessibilityElement == false`. This is used to announce the destination of the reodering operaton in relation to the other cells, e.g. "Before foo" or "after bar".
    private var _accessibilityLabel: String?
    override var accessibilityLabel: String? {
        set {
            _accessibilityLabel = newValue
        }
        get {
            guard let accessibilityLabel = _accessibilityLabel else {
                return reorderingAccessibilityLabel
            }
            return accessibilityLabel
        }
    }
}


extension ItemCell {
    
    final class OverlayDecorationView : UIView {
        
        let content : Content.OverlayDecorationView
        
        init(content : Content.OverlayDecorationView, frame: CGRect) {
            
            self.content = content
            
            super.init(frame: frame)
            
            self.content.frame = bounds
            self.addSubview(self.content)
            
            self.isUserInteractionEnabled = false
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) { fatalError() }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            self.content.frame = self.bounds
        }
        
        override var isAccessibilityElement: Bool {
            get { false }
            set { fatalError("Cannot set isAccessibilityElement.") }
        }
        
        override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
            false
        }
        
        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            nil
        }
    }
}


final class LiveCells {
    
    func add(_ cell : AnyItemCell) {
        self.cells.append(.init(cell: cell))
        
        self.cells = self.cells.filter { $0.cell != nil }
    }
    
    func perform(_ block : (AnyItemCell) -> ()) {
        self.cells.forEach {
            if let cell = $0.cell {
                block(cell)
            }
        }
    }
    
    func first(where check : (AnyItemCell) -> Bool) -> AnyItemCell? {
        let cell = cells.first {
            if let cell = $0.cell {
                return check(cell)
            } else {
                return false
            }
        }
        
        return cell?.cell
    }
    
    var activeSwipeCell : AnyItemCell? {
        first(where: \.areSwipeActionsVisible)
    }
    
    private(set) var cells : [LiveCell] = []
    
    struct LiveCell {
        weak var cell : AnyItemCell?
    }
}

extension ItemCell {
    
    var reorderingAccessibilityLabel: String? {
        if isReorderable && UIAccessibility.isVoiceOverRunning {
            return contentView.firstAccessibleChild()?.accessibilityLabel
        }
        return nil
    }
}


extension UIView {
    
   fileprivate func firstAccessibleChild() -> NSObject? {
        guard !isAccessibilityElement else {
            return self
        }
        return recursiveAccessibleSubviews().first as? NSObject
    }
    
    fileprivate func recursiveAccessibleSubviews() -> [Any] {
        subviews.flatMap { subview -> [Any] in
            if subview.accessibilityElementsHidden || subview.isHidden {
                return []
            } else if let accessibilityElements = subview.accessibilityElements {
                return accessibilityElements
            } else if subview.isAccessibilityElement {
                return [subview]
            } else {
                return subview.recursiveAccessibleSubviews()
            }
        }
    }
}
