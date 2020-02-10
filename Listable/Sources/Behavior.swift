//
//  Behavior.swift
//  Listable
//
//  Created by Kyle Van Essen on 11/13/19.
//

import Foundation


public struct Behavior : Equatable
{
    public var keyboardDismissMode : UIScrollView.KeyboardDismissMode
    
    public init(keyboardDismissMode : UIScrollView.KeyboardDismissMode = .interactive)
    {
        self.keyboardDismissMode = keyboardDismissMode
    }
}
