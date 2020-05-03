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
    
    public var underflow : Underflow
    
    public init(
        keyboardDismissMode : UIScrollView.KeyboardDismissMode = .interactive,
        underflow : Underflow = Underflow()
    ) {
        self.keyboardDismissMode = keyboardDismissMode
        self.underflow = underflow
    }
}

public extension Behavior
{
    struct Underflow : Equatable
    {
        public var alwaysBounce : Bool
        public var alignment : Alignment
        
        public init(alwaysBounce : Bool = true, alignment : Alignment = .top)
        {
            self.alwaysBounce = alwaysBounce
            self.alignment = alignment
        }
        
        public enum Alignment : Equatable
        {
            case top
            case center
            case bottom
            
            func offsetFor(contentHeight : CGFloat, viewHeight: CGFloat) -> CGFloat
            {
                guard contentHeight < viewHeight else {
                    return 0.0
                }
                
                switch self {
                case .top: return 0.0
                case .center: return round((viewHeight - contentHeight) / 2.0)
                case .bottom: return viewHeight - contentHeight
                }
            }
        }
    }
}
