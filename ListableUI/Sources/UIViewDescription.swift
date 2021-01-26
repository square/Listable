//
//  UIViewDescription.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 1/25/21.
//

import Foundation


public struct UIViewDescription<RequiredType:UIView> {
    
    private let viewType : UIView.Type
    private let create : () -> UIView
    private let update : (UIView) -> ()
    
    public init<ConcreteType:UIView>(
        _ type : ConcreteType.Type,
        create : @escaping () -> ConcreteType,
        update : @escaping (ConcreteType) -> ()
    ) {
        self.viewType = type
        
        self.create = create
        
        self.update = { existing in
            update(existing as! ConcreteType)
        }
    }
    
    static func update(
        view : RequiredType?,
        with description : UIViewDescription?,
        created : (RequiredType) -> () = { _ in },
        removed : (RequiredType) -> () = { _ in },
        replaced : (RequiredType, RequiredType) -> () = { _, _ in },
        updated : (RequiredType) -> () = { _ in }
    ) -> RequiredType? {
        if let view = view {
            if let description = description {
                if type(of: view) == description.viewType {
                    description.update(view)
                    updated(view)
                    return view
                } else {
                    let newView = description.create() as! RequiredType
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
                let view = description.create() as! RequiredType
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


extension UIViewDescription {
    
    final class Instance : UIView {
        
        var viewDescription : UIViewDescription? {
            didSet {
                self.updateView()
            }
        }
        
        private var view : RequiredType?
        
        init(frame : CGRect = .zero, _ description : UIViewDescription? = nil) {
            self.viewDescription = description
            self.view = nil
            
            super.init(frame: frame)
            
            self.updateView()
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) { fatalError() }
        
        
        private func updateView() {
            self.view = UIViewDescription.update(
                view: self.view,
                with: self.viewDescription,
                created: { self.addSubview($0) },
                removed: { $0.removeFromSuperview() },
                replaced: { $0.removeFromSuperview(); self.addSubview($1) }
            )
        }
    }
}
