//
//  SizingCacheKey.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 4/5/25.
//

import Foundation


public protocol SizingSharingKey: Hashable {
    
    
}


public struct DefaultSizingSharingKey : SizingSharingKey {}



final class SizingSharingCache {
    
    typealias SizeKey = PresentationState.SizeKey
    
    private var cache: Cache<AnySizingSharingKey, Cache<SizeKey, CGSize>> = .init()
    
    func size<Key:SizingSharingKey>(
        sharing sharingKey: Key,
        key: SizeKey,
        measure: () -> CGSize
    ) -> CGSize {
        
        if Key.self is DefaultSizingSharingKey.Type {
            return measure()
        }
        
        let anySharingKey = sharingKey.asAny
        
        
    }
}


extension SizingSharingKey {
    
    var asAny : AnySizingSharingKey {
        .init(
            metatype: Metatype(Self.self),
            key: self as AnyHashable
        )
    }
}


struct AnySizingSharingKey : Hashable {
    
    var metatype : Metatype
    var key : AnyHashable
    
    fileprivate init(
        metatype : Metatype,
        key: AnyHashable
    ) {
        self.metatype = metatype
        self.key = key
    }
}
