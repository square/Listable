//
//  Assertions.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 1/10/20.
//

import Foundation


func listableInternalFatal(_ message: @autoclosure () -> String = String(), file: StaticString = #file, line: UInt = #line) -> Never
{
    fatalError(
        """
        LISTABLE FATAL ERROR: This is a problem with Listable. Please let the UI Systems team (#ui-systems) know:

        \(message())
        """,
        
        file: file,
        line: line
    )
}

func listableInternalPrecondition(_ condition: @autoclosure () -> Bool, _ message: @autoclosure () -> String = String(), file: StaticString = #file, line: UInt = #line)
{
    precondition(
        condition(),
        
        """
        LISTABLE FATAL ERROR: This is a problem with Listable. Please let the UI Systems team (#ui-systems) know:
        
        \(message())
        """,
        
        file: file,
        line: line
    )
}


/// By default, `precondition` error messages are not included in release builds. We would like that!
/// https://bugs.swift.org/browse/SR-905
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
/// https://bugs.swift.org/browse/SR-905
public func preconditionFailure(
    _ message: @autoclosure () -> String = String(),
    file: StaticString = #file,
    line: UInt = #line
) -> Never {
    fatalError(message(), file: file, line: line)
}
