//
//  HeaderFooterCallbacks.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 4/3/25.
//

import Foundation


extension HeaderFooter {
    
    /// Value passed to the `onDisplay` callback for `HeaderFooter`.
    public struct OnDisplay
    {
        public typealias Callback = (OnDisplay) -> ()

        public var headerFooter : HeaderFooter
        
        public var isFirstDisplay : Bool
    }
    
    /// Value passed to the `onEndDisplay` callback for `HeaderFooter`.
    public struct OnEndDisplay
    {
        public typealias Callback = (OnEndDisplay) -> ()

        public var headerFooter : HeaderFooter
        
        public var isFirstEndDisplay : Bool
    }

}
