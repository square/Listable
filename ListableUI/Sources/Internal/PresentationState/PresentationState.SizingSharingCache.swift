//
//  SizingSharingCache.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 4/5/25.
//

import Foundation


extension PresentationState {
 
    final class SizingSharingCache {
        
        typealias SizeKey = PresentationState.SizeKey
        
        private var cache: Cache<ContentTypeKey, Cache<AnySizingSharingKey, Cache<SizeKey, CGSize>>> = .init()
        
        func clear() {
            cache.clear()
        }
        
        func size<ContentType, Key:SizingSharingKey>(
            contentType: ContentType.Type,
            sharingKey: Key,
            sizingKey: SizeKey,
            measure: () -> CGSize
        ) -> CGSize {
            
            /// By default, contents return this as their key, meaning we should not cache.
            if Key.self is NoSizingSharingKey.Type {
                return measure()
            }
            
            let sizeSharingCache = cache.get(.init(contentType)) {
                .init()
            }
            
            let sizeCache = sizeSharingCache.get(sharingKey.asAny) {
                .init()
            }
            
            return sizeCache.get(sizingKey) {
                measure()
            }
        }
        
        private struct ContentTypeKey : Hashable {
            var metatype : Metatype
            
            init<ContentType>(_ type : ContentType.Type) {
                metatype = .init(type)
            }
        }
    }
}


extension SizingSharingKey {
    
    fileprivate var asAny : AnySizingSharingKey {
        .init(
            metatype: Metatype(Self.self),
            key: self as AnyHashable
        )
    }
}


fileprivate struct AnySizingSharingKey : Hashable {
    
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
