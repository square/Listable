//
//  ListView+iOS16.4Workaround.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 4/6/23.
//

import Foundation
import ObjectiveC
import UIKit


/// ## ⚠️⚠️⚠️ Good Morning! iOS Bug Workaround Ahead ⚠️⚠️⚠️
///
/// iOS 16.4 introduced a regression (which was fixed in 16.5, then again broken in 17.0),
/// where on every `performBatchUpdates` applied to a `UICollectionView`, it would resign
/// the first responder if it was within a supplementary (header, footer) view.
/// This is a common position for search bars. Regular cells are not affected.
///
/// Update 06/04/2025:
/// It appears that the buggy behavior on iOS 17+ is triggered when there are _multiple_
/// `performBatchUpdates` calls within a short interval. The workaround still appears to avoid the issue.
///
/// Square SEV: https://jira.sqprod.co/browse/ALERT-11928
///
/// ## Ok, how do we fix it?
///
/// Some initial thoughts using clever public-only workarounds, that turned out to not work for various reasons:
///
/// ### Override canResignFirstResponder/resignFirstResponder and return false
/// This would've been so easy! Alas, it triggers an assert  within `UICollectionView`:
/// ```
/// *** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'The first responder contained inside of a deleted section or item refused to resign.
/// ```
///
/// ### Immediately re-becomeFirstResponder after collection view resigns it
/// In theory works, but for any screen that reloads the collection view as the result of a text field
/// becoming or resigning first responder, causes an infinite loop of updates. Not good!
///
/// ### Making `_resignOrRebaseFirstResponderViewWithIndexPathMapping` a no-op
/// Too likely to break internal bits. As you can see in [this gist](https://gist.github.com/kyleve/56da14d0dea1849ec12f2ec28ab472c1),
/// there's a lot of state management happening within there. Not a good idea!
///
/// Ok, that leaves us with...
///
/// ## Digging into private bits...
///
/// We can see, examining the stack trace of an affected supplementary view, that a method named
/// `_resignOrRebaseFirstResponderViewWithIndexPathMapping` is performing the first responder resigning:
///
/// ```
/// TextFieldView.resignFirstResponder()
/// @objc TextFieldView.resignFirstResponder() ()
/// -[UICollectionView _resignOrRebaseFirstResponderViewWithIndexPathMapping:] ()
/// -[UICollectionView _updateWithItems:tentativelyForReordering:propertyAnimator:collectionViewAnimator:] ()
/// -[UICollectionView _endItemAnimationsWithInvalidationContext:tentativelyForReordering:animator:collectionViewAnimator:] ()
/// -[UICollectionView _performBatchUpdates:completion:invalidationContext:tentativelyForReordering:animator:animationHandler:] ()
/// -[UICollectionView performBatchUpdates:completion:] ()
/// ```
///
/// Unfortunately, overriding that method to inspect the singular argument does not bear much fruit,
/// as the argument is a block:
///
/// ```
/// (lldb) po arg1
/// 0 elements
///
/// (lldb) po indexPathMapping
/// <__NSMallocBlock__: 0x600003c80e70>
///  signature: "@"NSIndexPath"16@?0@"NSIndexPath"8"
///  invoke   : 0x11d85d138 /// (/Applications/Xcode_14_2.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS/// .simruntime/Contents/Resources/RuntimeRoot/System/Library/PrivateFrameworks/UIKitCore.framework/UIKitCore`__102-[UICollectionView /// _updateWithItems:tentativelyForReordering:propertyAnimator:collectionViewAnimator:]_block_invoke)
/// ```
///
/// Ok, damn. Well we tried. Also of note, the arguments to this method changed between iOS 16.3 and 16.4:
///
/// ```
/// // iOS 16.3
/// func _resignOrRebaseFirstResponderViewWithUpdateItems(_ arg1 : Any, indexPathMapping: Any)
///
/// // iOS 16.4
/// func _resignOrRebaseFirstResponderViewWithIndexPathMapping(_ arg : Any)
/// ```
///
/// It does seem like we've found where to dig in, though. Let's decompile that method with Hopper (https://www.hopperapp.com/),
/// a very useful app to have in your toolbox. It'll give you pseudocode-ish versions of various methods you want to inspect.
///
/// Doing that, we get this (snipped for brevity):
///
/// ```
/// -(void)_resignOrRebaseFirstResponderViewWithIndexPathMapping:(int)arg2 {
///     rdx = arg2;
///     rbx = arg1;
///     r15 = arg0;
///     r12 = [rdx retain];
///     if ([r15 _isFirstResponderInDeletedSectionOrItem] != 0x0) {
///             var_78 = rbx;
///             var_98 = r12;
///             r13 = *ivar_offset(_firstResponderView);
///             var_38 = *ivar_offset(_firstResponderIndexPath);
///             rbx = 0x0;
///             var_48 = r15;
///             var_40 = r13;
///             do {
///     ...
/// ```
///
/// Ok, that `_isFirstResponderInDeletedSectionOrItem` sure looks interesting. And it's a boolean
/// method to boot, too, so in theory it shouldn't have (m)any side effects we need to re-implement if we were
/// to override it and implement it ourselves. Lets try overriding it to see if that does what we want:
///
/// ```
/// class MyTestingCollectionView : UICollectionView {
///     @objc var _isFirstResponderInDeletedSectionOrItem : Bool {
///         false
///     }
/// }
/// ```
///
/// Hey, it works! Upon returning `false` from this method, the first responder remains
/// doing its first responder-y things. This means this is the way to go. Not great, but not awful.
///
/// To accomplish this, we'll re-implement the broken bits of `_isFirstResponderInDeletedSectionOrItem`
/// ourselves, and call back to the original implementation when we can.
///
extension ListView {
    
    // Note: If we need additional overrides, please subclass me, so we can
    // wholesale delete this subclass when we drop iOS 17.0.
    @available(iOS, introduced: 14.0, deprecated: 27.0, message: "This workaround may no longer be necessary. Test the behavior and remove this type if it is no longer necessary.")
    class IOS16_4_First_Responder_Bug_CollectionView : UICollectionView {
        
        override init(
            frame: CGRect,
            collectionViewLayout layout: UICollectionViewLayout
        ) {
            super.init(frame: frame, collectionViewLayout: layout)
        }
        
        required init?(coder: NSCoder) { fatalError() }
        
        func performBatchUpdates(
            _ updates: @escaping () -> Void,
            changes : CollectionViewChanges,
            completion: @escaping (Bool) -> Void
        ) {
            enqueuedUpdatesCount += 1
                        
            super.performBatchUpdates {
                self.changes = changes
                updates()
            } completion: { finished in
                completion(finished)
                
                self.enqueuedUpdatesCount -= 1
                
                /// Because these `performBatchUpdates` calls can end up getting queued up,
                /// we only want to clear out the changes if no other changes have come in
                /// behind us. If they have, we'll let the last one handle clearing the changes.
                if self.enqueuedUpdatesCount == 0 {
                    self.changes = nil
                }
            }
        }
        
        private var enqueuedUpdatesCount : Int = 0
        
        private var changes : CollectionViewChanges?
        
        /// ### 🚨 This Overrides A Private Method
        ///
        /// This method wholesale re-implements a private method from `UICollectionView`,
        /// which broke in iOS 16.4 and again in iOS 17-18. We have the diff, so we can figure this out ourselves.
        ///
        /// For reference, here's the decompiled original impl:
        ///
        /// ```
        /// int -[UICollectionView _isFirstResponderInDeletedSectionOrItem](int arg0) {
        ///     rdi = arg0;
        ///     if (rdi->_firstResponderView == 0x0) goto loc_36d628;
        ///
        /// loc_36d5dd:
        ///     rbx = rdi;
        ///     r15 = *ivar_offset(_firstResponderIndexPath);
        ///     rdx = *(rdi + r15);
        ///     if (rdx == 0x0) goto loc_36d628;
        ///
        /// loc_36d5f0:
        ///     r14 = *ivar_offset(_currentUpdate);
        ///     rdi = *(rbx + r14);
        ///     if (rdi == 0x0) goto loc_36d628;
        ///
        /// loc_36d600:
        ///     if (rbx->_firstResponderViewType != 0x1) goto loc_36d62f;
        ///
        /// loc_36d60e:
        ///     rax = [rdi finalIndexPathForInitialIndexPath:rdx];
        ///     rax = [rax retain];
        ///     goto loc_36d6bf;
        ///
        /// loc_36d6bf:
        ///     r14 = rax;
        ///     rbx = rax == 0x0 ? 0x1 : 0x0;
        ///     goto loc_36d6c8;
        ///
        /// loc_36d6c8:
        ///     [r14 release];
        ///     goto loc_36d6d1;
        ///
        /// loc_36d6d1:
        ///     rax = rbx;
        ///     return rax;
        ///
        /// loc_36d62f:
        ///     rax = [rdx length];
        ///     rdi = *(rbx + r14);
        ///     if (rax != 0x1) goto loc_36d69b;
        ///
        /// loc_36d649:
        ///     r14 = [[*(rdi + 0x80) objectForKeyedSubscript:rbx->_firstResponderViewKind] retain];
        ///     rbx = [r14 containsIndex:[*(rbx + r15) indexAtPosition:0x0]];
        ///     goto loc_36d6c8;
        ///
        /// loc_36d69b:
        ///     rax = [rdi validatedNewIndexPathForSupplementaryElementOfKind:rbx->_firstResponderViewKind oldIndexPath:*(rbx + r15)];
        ///     rax = [rax retain];
        ///     goto loc_36d6bf;
        ///
        /// loc_36d628:
        ///     rbx = 0x0;
        ///     goto loc_36d6d1;
        /// }
        ///
        /// ```
        @objc var _isFirstResponderInDeletedSectionOrItem : Bool {
            
            //
            // Setup
            //
            
            let selector = #selector(getter: self._isFirstResponderInDeletedSectionOrItem)
            
            /// This gets the (private) implementation from `UICollectionView`.
            let super_impl = class_getMethodImplementation(UICollectionView.self, selector)
            
            /// If we can't find the implementation from super, we can assume the name
            /// of this method has changed, so we'll just bail from this method entirely. It shouldn't be
            /// called anyway.
            guard let super_impl else {
                assertionFailure("Could not find super's implementation of _isFirstResponderInDeletedSectionOrItem.")
                return false
            }
            
            /// This is the Swift prototype of the function. There's no arguments, but ObjC
            /// methods (when converted to their final C representation) have two implicit arguments,
            /// `self`, the object, and `SEL`, the selector.
            typealias SuperFunction = @convention(c) (AnyObject, Selector) -> Bool
            
            /// Make the pointer we got back into a Swift-callable function.
            let super_function = unsafeBitCast(super_impl, to: SuperFunction.self)
            
            /// Only perform the workaround on affected versions.
            guard Self.isAffectedIOSVersion else {
                return super_function(self, selector)
            }
            
            guard Self.hasFirstResponderViewProperty else {
                assertionFailure("UICollectionView no longer has an ivar named `_firstResponderView`.")
                return super_function(self, selector)
            }
            
            //
            // Implementation
            //
                        
            /// This is the `UICollectionReusableView` that owns the first responder. Eg,
            /// either the supplementary view, or the cell. It is **not** the first responder itself.
            guard let owningReusableView = self.value(forKey: "_firstResponderView") else {
                /// We don't have a first responder, so just defer to whatever `super` will return. Likely
                /// it will be `nil`, but, better be safe.
                return super_function(self, selector)
            }
            
            /// This bug only affects supplementary views, which for our purposes, are only
            /// `UICollectionReusableView`. If the first responder view is a `UICollectionViewCell`,
            /// then its a regular cell (not affected by bug), defer to super.
            if owningReusableView is UICollectionViewCell {
                return super_function(self, selector)
            }
            
            /// This is a belt-n-suspenders thing, but if we're _not_ a cell, we should be a
            /// `SupplementaryContainerView`, that's the only kind of supplementary view Listable has.
            /// If for some other weird reason its not that, bail out.
            guard let supplementaryView = owningReusableView as? SupplementaryContainerView else {
                return super_function(self, selector)
            }
            
            /// Ok so beyond this, we need to get it right; otherwise we'll hit this internal assert:
            /// ```
            /// 'The first responder contained inside of a deleted section or item refused to resign.
            /// ```
            
            guard let state = supplementaryView.headerFooter else {
                assertionFailure("Visible state should have an associated header / footer.")
                return super_function(self, selector)
            }
            
            guard let oldIndexPath = state.oldIndexPath else {
                assertionFailure("Should have an old index path at this point.")
                return super_function(self, selector)
            }
            
            guard let changes else {
                assertionFailure("Should have collection view changes at this point.")
                return super_function(self, selector)
            }
            
            let isRemoving = changes.deletedSections.contains {
                $0.oldIndex == oldIndexPath.section
            }
            
            return isRemoving
        }
        
        private static let isAffectedIOSVersion : Bool = {
            
            /// First regressed in 16.4.
            
            let isIOS16_4 = ProcessInfo
                .processInfo
                .isOperatingSystemAtLeast(
                    .init(majorVersion: 16, minorVersion: 4, patchVersion: 0)
                )
            
            /// Fixed in 16.5.
            
            let isIOS16_5 = ProcessInfo
                .processInfo
                .isOperatingSystemAtLeast(
                    .init(majorVersion: 16, minorVersion: 5, patchVersion: 0)
                )
            
            /// ...But is broken again iOS 17.0 - 18.4 (at least)
            
            let isIOS17_0 = ProcessInfo
                .processInfo
                .isOperatingSystemAtLeast(
                    .init(majorVersion: 17, minorVersion: 0, patchVersion: 0)
                )

            return (isIOS16_4 && !isIOS16_5) || isIOS17_0
        }()
        
        private static let hasFirstResponderViewProperty : Bool = {
            
            var ivarCount : UInt32 = 0
            
            let ivars = class_copyIvarList(UICollectionView.self, &ivarCount)
            
            guard let ivars else {
                return false
            }
            
            defer {
                free(ivars)
            }
            
            return (0..<ivarCount).contains { index in
                let ivar = ivars[Int(index)]
                
                let name = ivar_getName(ivar)
                
                return strcmp(name, "_firstResponderView") == 0
            }
        }()
    }
}
