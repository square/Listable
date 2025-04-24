//
//  SizingCacheKey.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 4/5/25.
//

import Foundation


public protocol SizingSharingKey: Hashable {
    
    
}


public struct SizingSharing<Key:SizingSharingKey, Content> {

    public var sizingSharingKey: Key
    
    public var source : Source
    
    public init(
        sizingSharingKey: Key,
        content: () -> Content
    ) {
        self.sizingSharingKey = sizingSharingKey
        self.source = .provided(content())
    }
    
    public init(
        sizingSharingKey: Key
    ) {
        self.sizingSharingKey = sizingSharingKey
        self.source = .content
    }
    
    public enum Source {
        case content
        case provided(Content)
    }
}


public struct NoSizingSharingKey : SizingSharingKey {}
