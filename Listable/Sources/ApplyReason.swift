//
//  ApplyReason.swift
//  Listable
//
//  Created by Kyle Van Essen on 8/10/19.
//


public enum ApplyReason : Hashable
{
    case willDisplay
    case wasUpdated(WasUpdated)
    case selectionStateChanged(SelectionStateChanged)
    case highlightStateChanged(HighlightStateChanged)
    
    public var animated : Bool {
        switch self {
        case .willDisplay: return false
        case .wasUpdated(let state): return state.animated
        case .selectionStateChanged(let state): return state.animated
        case .highlightStateChanged(let state): return state.animated
        }
    }
    
    public struct WasUpdated : Hashable {
        public var animated : Bool
    }
    
    public struct SelectionStateChanged : Hashable {
        public var animated : Bool
        public var fromUserInteraction : Bool
    }

    public struct HighlightStateChanged : Hashable {
        public var animated : Bool
        public var fromUserInteraction : Bool
    }
}

