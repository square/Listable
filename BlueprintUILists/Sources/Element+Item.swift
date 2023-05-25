//
//  Element+Item.swift
//  BlueprintUILists
//
//  Created by Kyle Van Essen on 7/24/22.
//

import BlueprintUI
import ListableUI


// MARK: Item / ItemContent Extensions



/// Ensures that the `Equatable` initializer for `WrappedElementContent` is called.
extension Element where Self:Equatable {
    
    public func listItem(
        id : AnyHashable? = nil,
        selection: ItemSelectionStyle = .notSelectable,
        background : @escaping (ApplyItemContentInfo) -> Element? = { _ in nil },
        selectedBackground : @escaping (ApplyItemContentInfo) -> Element? = { _ in nil },
        configure : (inout Item<WrappedElementContent<Self>>) -> () = { _ in }
    ) -> Item<WrappedElementContent<Self>> {
        Item(
            WrappedElementContent(
                identifierValue: id,
                represented: self,
                background: background,
                selectedBackground: selectedBackground
            ),
            configure: {
                $0.selectionStyle = selection
                
                configure(&$0)
            }
        )
    }
}


/// Ensures that the `LayoutEquivalent` initializer for `WrappedElementContent` is called.
extension Element where Self:LayoutEquivalent {
    
    @_disfavoredOverload
    public func listItem(
        id : AnyHashable? = nil,
        selection: ItemSelectionStyle = .notSelectable,
        background : @escaping (ApplyItemContentInfo) -> Element? = { _ in nil },
        selectedBackground : @escaping (ApplyItemContentInfo) -> Element? = { _ in nil },
        configure : (inout Item<WrappedElementContent<Self>>) -> () = { _ in }
    ) -> Item<WrappedElementContent<Self>> {
        Item(
            WrappedElementContent(
                identifierValue: id,
                represented: self,
                background: background,
                selectedBackground: selectedBackground
            ),
            configure: {
                $0.selectionStyle = selection
                
                configure(&$0)
            }
        )
    }
}


public struct WrappedElementContent<ElementType:Element> : BlueprintItemContent
{
    public let identifierValue: AnyHashable?
    
    public let represented : ElementType
    
    private let isEquivalent : (Self, Self) -> Bool
    
    init(
        identifierValue: AnyHashable?,
        represented: ElementType,
        background : @escaping (ApplyItemContentInfo) -> Element?,
        selectedBackground : @escaping (ApplyItemContentInfo) -> Element?
    ) where ElementType:Equatable
    {
        self.represented = represented
        self.identifierValue = identifierValue
        
        self.backgroundProvider = background
        self.selectedBackgroundProvider = selectedBackground
        
        self.isEquivalent = {
            $0.represented == $1.represented
        }
    }
    
    init(
        identifierValue: AnyHashable?,
        represented: ElementType,
        background : @escaping (ApplyItemContentInfo) -> Element?,
        selectedBackground : @escaping (ApplyItemContentInfo) -> Element?
    ) where ElementType:LayoutEquivalent
    {
        self.represented = represented
        self.identifierValue = identifierValue
        
        self.backgroundProvider = background
        self.selectedBackgroundProvider = selectedBackground
        
        self.isEquivalent = {
            $0.represented.isEquivalent(to: $1.represented)
        }
    }
    
    public func isEquivalent(to other: Self) -> Bool {
        isEquivalent(self, other)
    }
    
    public func element(with info: ApplyItemContentInfo) -> Element {
        represented
    }
    
    var backgroundProvider: (ApplyItemContentInfo) -> Element?
    
    public func backgroundElement(with info: ApplyItemContentInfo) -> Element? {
        backgroundProvider(info)
    }
    
    var selectedBackgroundProvider: (ApplyItemContentInfo) -> Element?
    
    public func selectedBackgroundElement(with info: ApplyItemContentInfo) -> Element? {
        selectedBackgroundProvider(info)
    }
    
    public var reappliesToVisibleView: ReappliesToVisibleView {
        .ifNotEquivalent
    }
}
