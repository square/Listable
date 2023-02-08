//
//  SupplementaryContainerView.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 9/30/19.
//

import UIKit


/**
 The supplementary view provided to the UICollectionView, which is used
 to contain every actual header and footer view within the list.
 
 Regardless of if a section has a header or footer provided by the developer,
 we always return a supplementary view – if there's no header or footer, it has
 zero height.
 
 Why this extra layer of indirection?
 --------------------------------------
 Within collection views, supplementary views (how you model headers, footers)
 are attached to individual index paths. So, Listable models headers and footers
 as attached to (0,0) for list headers and footers, and (sectionIndex, 0)
 for section headers and footers. All good so far.

 The problem arises when you want to swap out a header or footer without
 changing the row at the (x, 0) index path. The collection view does not
 know to re-query for those associated headers, because we didn't actually
 reload or change that (x, 0) item.
 
 Thus, we always provide this container supplementary view – and swap the content
 of the header or footer in or out as needed as it changes. As mentioned above,
 if there is no actual header or footer to show, the view has zero height.
 */
final class SupplementaryContainerView : UICollectionReusableView
{
    //
    // MARK: Registering & Dequeuing Cells
    //
    
    static let reuseIdentifier = "Listable.SupplementaryContainerView"
    
    static func register(in collectionView: UICollectionView, for kind : String)
    {
        collectionView.register(
            SupplementaryContainerView.self,
            forSupplementaryViewOfKind: kind,
            withReuseIdentifier: SupplementaryContainerView.reuseIdentifier
        )
    }
    
    static func dequeue(
        in collectionView: UICollectionView,
        for kind : String,
        at indexPath : IndexPath,
        reuseCache : ReusableViewCache,
        environment : ListEnvironment
    ) -> SupplementaryContainerView
    {
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SupplementaryContainerView.reuseIdentifier,
            for: indexPath
        ) as! SupplementaryContainerView
        
        view.reuseCache = reuseCache
        
        view.environment = environment
        
        return view
    }
    
    //
    // MARK: Content
    //
    
    var containedTextFieldStateDidChange : (UITextField?) -> () = { _ in }
    
    func setHeaderFooter(_ new : AnyPresentationHeaderFooterState?, animated : Bool) {
        guard headerFooter !== new else {
            return
        }
        
        let old = headerFooter
        
        headerFooter = new
        
        let cache = self.reuseCache!
        
        if let old = old, let content = self.content {
            old.enqueueReusableHeaderFooterView(content, in: cache)
        }
        
        if let headerFooter = self.headerFooter {
            let newContent = headerFooter.dequeueAndPrepareReusableHeaderFooterView(
                in: cache,
                frame: self.bounds,
                environment: self.environment
            )
            
            setContent(newContent, animated: animated)
        } else {
            setContent(nil, animated: animated)
        }
    }
    
    private(set) var headerFooter : AnyPresentationHeaderFooterState?
    
    /// Note: Using implicitly unwrapped optionals because we cannot do
    /// initializer injection in this type – `UICollectionView` calls `init(frame:)`,
    /// we must use property injection instead.
    ///
    /// We use IUOs to avoid having to unwrap the values at each call site.
    
    var environment : ListEnvironment!
    var reuseCache : ReusableViewCache!
    
    func setContent(_ new : UIView?, animated: Bool) {
        
        guard content !== new else { return }
        
        let old = content
        
        content = new
        
        if let old = old {
            if animated {
                UIView.animate(withDuration: 0.2) {
                    old.alpha = 0.0
                } completion: { _ in
                    old.removeFromSuperview()
                    
                    // Reset to an expected alpha in case the view is reused.
                    old.alpha = 1.0
                }

            } else {
                old.removeFromSuperview()
            }
        }
        
        if let new = self.content {
            if animated {
                UIView.performWithoutAnimation {
                    self.addSubview(new)
                    new.alpha = 0.0
                }
                
                UIView.animate(withDuration: 0.2) {
                    new.alpha = 1.0
                }
            } else {
                new.alpha = 1.0
                self.addSubview(new)
            }
        }
        
        self.setNeedsLayout()
    }
    
    private(set) var content : UIView?
    
    //
    // MARK: Initialization
    //
        
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        self.layer.masksToBounds = false
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(lst_textDidEndEditingNotification(_:)),
            name: UITextField.textDidBeginEditingNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(lst_textDidEndEditingNotification(_:)),
            name: UITextField.textDidEndEditingNotification,
            object: nil
        )
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { listableInternalFatal() }
    
    // MARK: UICollectionReusableView
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes
    {
        /// **Note** – Please keep this comment in sync with the comment in ItemCell.
        
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
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        
        setHeaderFooter(nil, animated: false)
    }
    
    //
    // MARK: UIView
    //
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        
        guard let content = self.content else {
            return .zero
        }
        
        return content.sizeThatFits(size)
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        
        guard let content = self.content else {
            return .zero
        }
        
        return content.systemLayoutSizeFitting(targetSize)
    }
    
    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        
        guard let content = self.content else {
            return .zero
        }
        
        return content.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: verticalFittingPriority
        )
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        if let content = self.content {
            content.frame = self.bounds
        }
        
        containedTextField = findContainedTextField()
    }
    
    //
    // MARK: Private
    //
    
    private weak var containedTextField : UITextField? = nil {
        didSet {
            guard oldValue !== containedTextField else { return }
            
            containedTextFieldStateDidChange(containedTextField)
        }
    }
    
    @objc private func lst_textDidBeginEditingNotification(_ notification : Notification) {
        
        guard window != nil else { return }
        guard isHidden == false else { return }
        
        guard let field = notification.object as? UITextField else { return }
        
        guard field.isInHierarchy(of: self) else { return }
     
        containedTextField = field
    }
    
    @objc private func lst_textDidEndEditingNotification(_ notification : Notification) {
        
        guard let field = notification.object as? UITextField else { return }
        
        if field == containedTextField {
            containedTextField = nil
        }
    }
}


fileprivate extension UIView {
    
    func findContainedTextField() -> UITextField? {
        
        for view in subviews {
            if let field = view as? UITextField {
                return field
            } else if let field = view.findContainedTextField() {
                return field
            }
        }
        
        return nil
    }
    
    func isInHierarchy(of container : UIView) -> Bool {
        
        for view in sequence(first: self, next: \.superview) {
            if view == container {
                return true
            }
        }
        
        return false
    }
}
