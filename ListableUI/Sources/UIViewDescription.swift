//
//  UIViewDescription.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 1/25/21.
//

import Foundation


public struct UIViewDescription<ViewType:UIView> {
    
    private let viewType : ViewType.Type
    private let create : () -> UIView
    private let update : (UIView) -> ()
    
    public init(
        _ type : ViewType.Type,
        create : @escaping () -> ViewType,
        update : @escaping (ViewType) -> ()
    ) {
        self.viewType = type
        
        self.create = create
        
        self.update = { existing in
            update(existing as! ViewType)
        }
    }
    
    static func update(
        view : ViewType?,
        with description : UIViewDescription?,
        created : (ViewType) -> () = { _ in },
        removed : (ViewType) -> () = { _ in },
        replaced : (ViewType, ViewType) -> () = { _, _ in },
        updated : (ViewType) -> () = { _ in }
    ) -> ViewType? {
        if let view = view {
            if let description = description {
                if type(of: view) == description.viewType {
                    description.update(view)
                    updated(view)
                    return view
                } else {
                    let newView = description.create() as! ViewType
                    description.update(newView)
                    replaced(view, newView)
                    return newView
                }
            } else {
                removed(view)
                return nil
            }
        } else {
            if let description = description {
                let view = description.create() as! ViewType
                description.update(view)
                created(view)
                return view
            } else {
                // Nil to nil, no change needed.
                return nil
            }
        }
    }
}
