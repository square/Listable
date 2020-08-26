//
//  ApplyReason.swift
//  Listable
//
//  Created by Kyle Van Essen on 8/10/19.
//


/// Why the `Item` or `HeaderFooter` is being asked to apply the given update to its presented views
public enum ApplyReason : Hashable
{
    /// The view is about to be displayed. Update should be performed with no animation.
    case willDisplay
    
    /// A view that is already visible is being updated. If your updates can contain animation,
    /// it should be used here.
    case wasUpdated
    
    /// If you should use animations while applying the update.
    public var shouldAnimate : Bool {
        switch self {
        case .willDisplay: return false
        case .wasUpdated: return true
        }
    }
}

