//
//  ViewDebuggerStuff.m
//  Demo
//
//  Created by Kyle Van Essen on 5/29/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//

@import UIKit;

#import "ViewDebuggerStuff.h"

#import "objc/runtime.h"

@implementation ViewDebuggerStuff

+ (void)swizzledTestingMethods
{
    SEL originalSel = @selector(fallback_debugHierarchyValueForPropertyWithName:onObject:outOptions:outError:);
    SEL newSel = @selector(swizzle_fallback_debugHierarchyValueForPropertyWithName:onObject:outOptions:outError:);
    
    Method originalMethod = class_getClassMethod([UIView class], originalSel);
    Method newMethod = class_getClassMethod([UIView class], newSel);
    
    method_exchangeImplementations(originalMethod, newMethod);
}

@end


@interface UIView (ViewDebuggerStuff)

+(id)swizzle_fallback_debugHierarchyValueForPropertyWithName:(NSString *)name onObject:(id)obj outOptions:(id *)outOpts outError:(NSError **)outError;

@end


@implementation UIView (ViewDebuggerStuff)

+(id)swizzle_fallback_debugHierarchyValueForPropertyWithName:(NSString *)name onObject:(id)obj outOptions:(id *)outOpts outError:(NSError **)outError;
{
    NSLog(@"%@", name);
    NSLog(@"%@", obj);
    return [self swizzle_fallback_debugHierarchyValueForPropertyWithName:name onObject:obj outOptions:outOpts outError:outError];
}

@end
