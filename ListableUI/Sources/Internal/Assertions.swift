//
//  Assertions.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 1/10/20.
//

import Foundation


@inline(__always)
func listableInternalFatal(
    _ message: @autoclosure () -> String = String(),
    file: StaticString = #file,
    line: UInt = #line
) -> Never
{
    fatalError(
        """
        LISTABLE FATAL ERROR: This is a problem with Listable. Please let the UI Systems team (#listable) know:

        \(message())
        """,
        
        file: file,
        line: line
    )
}

@inline(__always)
func listableInternalPrecondition(
    _ condition: @autoclosure () -> Bool,
    _ message: @autoclosure () -> String = String(),
    file: StaticString = #file,
    line: UInt = #line
) {
    precondition(
        condition(),
        
        """
        LISTABLE FATAL ERROR: This is a problem with Listable. Please let the UI Systems team (#listable) know:
        
        \(message())
        """,
        
        file: file,
        line: line
    )
}


/// By default, `precondition` error messages are not included in release builds. We would like that!
/// https://github.com/apple/swift/issues/43517
@inline(__always)
func precondition(
    _ condition: @autoclosure () -> Bool,
    _ message: @autoclosure () -> String = String(),
    file: StaticString = #file,
    line: UInt = #line
) {
    if condition() == false {
        fatalError(message(), file: file, line: line)
    }
}

/// By default, `preconditionFailure` error messages are not included in release builds. We would like that!
/// https://github.com/apple/swift/issues/43517
@inline(__always)
public func preconditionFailure(
    _ message: @autoclosure () -> String = String(),
    file: StaticString = #file,
    line: UInt = #line
) -> Never {
    fatalError(message(), file: file, line: line)
}
