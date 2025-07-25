//
//  AnyDecoration.swift
//  ListableUI
//
//  Created by Goose on 7/24/25.
//

import Foundation
import UIKit


public protocol AnyDecoration : AnyDecorationConvertible, AnyDecoration_Internal
{
    var anyContent : Any { get }
    
    var sizing : Sizing { get set }
    var layouts : DecorationLayouts { get set }
    
    var reappliesToVisibleView: ReappliesToVisibleView { get }
}


public protocol AnyDecoration_Internal
{
    var layouts : DecorationLayouts { get }
    
    func apply(
        to decorationView : UIView,
        for reason : ApplyReason,
        with info : ApplyDecorationContentInfo
    )
    
    func anyIsEquivalent(to other : AnyDecoration) -> Bool
    
    func newPresentationDecorationState(
        kind : SupplementaryKind,
        performsContentCallbacks : Bool
    ) -> Any
}
