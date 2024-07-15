//
//  ListAnimation.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 7/15/24.
//

import Foundation


public struct ListAnimation {
    
    public typealias Animations = () -> ()
    
    public var perform : (@escaping Animations) -> ()
    
    public init(_ perform : @escaping (@escaping Animations) -> ()) {
        self.perform = perform
    }
    
    public static let `default` : Self = .init { animations in
        animations()
    }
    
    public static let fast : Self = .init { animations in
        UIView.animate(withDuration: 0.1, animations: animations)
    }
}
