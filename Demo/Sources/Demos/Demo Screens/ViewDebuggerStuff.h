//
//  ViewDebuggerStuff.h
//  Demo
//
//  Created by Kyle Van Essen on 5/29/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface ViewDebuggerStuff : NSObject

+ (void)swizzledTestingMethods;

@end

@interface UIView (StuffFromXcode)

- (id)dbgSubviewHierarchy;

@end

NS_ASSUME_NONNULL_END
