//
//  SwipeActions.swift
//  ListableTableView
//
//  Created by Kyle Van Essen on 8/10/19.
//

import Foundation


public struct SwipeActions
{
    public var actions : [SwipeAction]
    
    public var performsFirstOnFullSwipe : Bool
    
    public var firstDestructiveAction : SwipeAction? {
        return self.actions.first {
            $0.style == .destructive
        }
    }
    
    public init(_ action : SwipeAction, performsFirstOnFullSwipe : Bool = false)
    {
        self.init([action], performsFirstOnFullSwipe: performsFirstOnFullSwipe)
    }
    
    public init(_ actions : [SwipeAction], performsFirstOnFullSwipe : Bool = false)
    {
        self.actions = actions
        
        self.performsFirstOnFullSwipe = performsFirstOnFullSwipe
    }
    
    @available(iOS 11.0, *)
    internal func toUISwipeActionsConfiguration(onPerform : @escaping SwipeAction.OnPerform) -> UISwipeActionsConfiguration
    {
        let config = UISwipeActionsConfiguration(actions: self.actions.map {
            $0.toUIContextualAction(onPerform: onPerform)
        })
        
        config.performsFirstActionWithFullSwipe = self.performsFirstOnFullSwipe
        
        return config
    }
    
    internal func toUITableViewRowActions(onPerform : @escaping SwipeAction.OnPerform) -> [UITableViewRowAction]?
    {
        return self.actions.map {
            $0.toUITableViewRowAction(onPerform: onPerform)
        }
    }
}

public struct SwipeAction
{
    public typealias OnPerform = (Style) -> ()
    
    public var title: String?
    
    public var style: Style = .normal
    
    public var backgroundColor: UIColor?
    public var image: UIImage?
    
    public typealias OnTap = (SwipeAction) -> Bool
    public var onTap : OnTap
    
    public init(title: String?, style: Style = .normal, backgroundColor: UIColor? = nil, image: UIImage? = nil, onTap : @escaping OnTap)
    {
        self.title = title
        self.style = style
        self.backgroundColor = backgroundColor
        self.image = image
        self.onTap = onTap
    }
    
    @available(iOS 11.0, *)
    internal func toUIContextualAction(onPerform : @escaping OnPerform) -> UIContextualAction
    {
        return UIContextualAction(
            style: self.style.toUIContextualActionStyle(),
            title: self.title,
            handler: { action, view, didComplete in
                let completed = self.onTap(self)
                
                if completed {
                    onPerform(self.style)
                }
                
                didComplete(completed)
        })
    }
    
    internal func toUITableViewRowAction(onPerform : @escaping OnPerform) -> UITableViewRowAction
    {
        return UITableViewRowAction(
            style: self.style.toUITableViewRowActionStyle(),
            title: self.title,
            handler: { _, _ in
                let completed = self.onTap(self)
                
                if completed {
                    onPerform(self.style)
                }
        })
    }
    
    public enum Style
    {
        case normal
        case destructive
        
        public var deletesRow : Bool {
            switch self {
            case .normal: return false
            case .destructive: return true
            }
        }
        
        @available(iOS 11.0, *)
        func toUIContextualActionStyle() -> UIContextualAction.Style
        {
            switch self {
            case .normal: return .normal
            case .destructive: return .destructive
            }
        }
        
        func toUITableViewRowActionStyle() -> UITableViewRowAction.Style
        {
            switch self {
            case .normal: return .normal
            case .destructive: return .destructive
            }
        }
    }
}
