//
//  Assertions.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 1/10/20.
//

import Foundation


public func listableFatal(_ message: @autoclosure () -> String = String(), file: StaticString = #file, line: UInt = #line) -> Never
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

public func listablePrecondition(_ condition: @autoclosure () -> Bool, _ message: @autoclosure () -> String = String(), file: StaticString = #file, line: UInt = #line)
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
