//
//  UpdateCallbacks.swift
//  Listable
//
//  Created by Kyle Van Essen on 8/19/20.
//

import Foundation


public final class UpdateCallbacks {
    
    let executionType : ExecutionType
    
    init(_ executionType : ExecutionType) {
        self.executionType = executionType
    }
    
    deinit {
        precondition(self.calls.isEmpty)
    }

    private(set) var calls : [() -> ()] = []
        
    func add(_ call : @escaping () -> ()) {
        switch self.executionType {
        case .immediate: call()
        case .queue: self.calls.append(call)
        }
    }
    
    func perform() {
        self.calls.forEach { $0() }
        self.calls = []
    }
    
    enum ExecutionType {
        case immediate
        case queue
    }
}
