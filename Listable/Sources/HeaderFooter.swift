//
//  HeaderFooter.swift
//  Listable
//
//  Created by Kyle Van Essen on 8/10/19.
//


public protocol AnyHeaderFooter : AnyHeaderFooter_Internal
{
}

public protocol AnyHeaderFooter_Internal
{
    func apply(to headerFooterView : UICollectionReusableView, reason: ApplyReason)
    
    func wasUpdated(comparedTo other : AnyHeaderFooter) -> Bool
    
    func newPresentationHeaderFooterState() -> Any
}


public struct HeaderFooter<Element:HeaderFooterElement> : AnyHeaderFooter
{
    public var element : Element
    public var appearance : Element.Appearance
    
    public var height : Height
    
    internal let reuseIdentifier : ReuseIdentifier<Element>
    
    // MARK: Initialization
    
    public init(
        _ element : Element,
        appearance : Element.Appearance,
        height : Height = .default
    )
    {
        self.element = element
        self.appearance = appearance
        
        self.height = height
        
        self.reuseIdentifier = ReuseIdentifier.identifier(for: self.element)
    }
    
    // MARK: AnyHeaderFooter_Internal
    
    public func apply(to anyView : UICollectionReusableView, reason: ApplyReason)
    {
        let view = anyView as! SupplementaryItemView<Element>
        
        self.element.apply(to: view.content, reason: reason)
    }
        
    public func wasUpdated(comparedTo other : AnyHeaderFooter) -> Bool
    {
        guard let other = other as? HeaderFooter<Element> else {
            return true
        }
        
        return self.element.wasUpdated(comparedTo: other.element)
    }
    
    public func newPresentationHeaderFooterState() -> Any
    {
        return PresentationState.HeaderFooterState(self)
    }
}
