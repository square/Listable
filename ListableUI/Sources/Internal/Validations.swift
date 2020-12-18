//
//  Validations.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 12/15/20.
//

import Foundation


//
// MARK: Value Type Validation
//

///
/// This protocol exists to enforce at compile time that your `ItemContent` and `HeaderFooterContent`
/// implementations are value types, aka a `struct` or `enum`.
///
/// It is very very unusual and usually an error to make your `Content` a `class` type. Listable's internal
/// implementation relies on the fact that passed in `Content` respects value semantics and is owned by the framework.
///
/// Notes
/// -----
/// You should really not make your `Content` be a `class`. If for some reason you really really want to do this,
/// (you should not do this unless you have a good reason, which you do not), then override the
/// `contents_should_be_value_types_by_overriding_this_method_i_acknowledge_i_am_in_hard_mode()`
/// method in your type to opt out of this validation. But you probably shouldn't.
///
public protocol Listable_Contents_Should_Be_Value_Types {
    func contents_should_be_value_types_by_overriding_this_method_i_acknowledge_i_am_in_hard_mode()
}


public extension Listable_Contents_Should_Be_Value_Types {
    func contents_should_be_value_types_by_overriding_this_method_i_acknowledge_i_am_in_hard_mode() {}
}


public extension Listable_Contents_Should_Be_Value_Types where Self : AnyObject {
    @available(*, unavailable)
    func contents_should_be_value_types_by_overriding_this_method_i_acknowledge_i_am_in_hard_mode() {}
}
