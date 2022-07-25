//
//  UpdateCallbacks.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 8/19/20.
//

import Foundation
import UIKit

public final class UpdateCallbacks {
    let executionType: ExecutionType
    let wantsAnimations: Bool

    init(_ executionType: ExecutionType, wantsAnimations: Bool) {
        self.executionType = executionType
        self.wantsAnimations = wantsAnimations
    }

    deinit {
        precondition(self.calls.isEmpty)
    }

    private(set) var calls: [() -> Void] = []

    func add(if performsCallbacks: Bool, _ call: @escaping () -> Void) {
        guard performsCallbacks else {
            return
        }

        switch executionType {
        case .immediate: call()
        case .queue: calls.append(call)
        }
    }

    func performAnimation(_ animations: @escaping () -> Void) {
        if wantsAnimations {
            UIView.animate(withDuration: 0.2, animations: animations)
        } else {
            animations()
        }
    }

    func perform() {
        calls.forEach { $0() }
        calls = []
    }

    enum ExecutionType {
        case immediate
        case queue
    }
}
