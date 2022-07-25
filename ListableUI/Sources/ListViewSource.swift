//
//  TableViewSource.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 8/4/19.
//

import UIKit

// TODO: Rename this all to ContentProvider?

public protocol ListViewSource {
    associatedtype State: Equatable

    func content(with state: SourceState<State>, content: inout Content)

    func content(with state: SourceState<State>) -> Content
}

public extension ListViewSource {
    func content(with state: SourceState<State>) -> Content {
        Content { content in
            self.content(with: state, content: &content)
        }
    }
}

internal protocol AnySourcePresenter {
    func discard()

    func reloadContent() -> Content
}

internal final class SourcePresenter<Source: ListViewSource>: AnySourcePresenter {
    let source: Source

    var state: Source.State {
        get { sourceState.value }
        set { sourceState.value = newValue }
    }

    private var sourceState: SourceState<Source.State>

    init(initial: Source.State, source: Source, didChange: @escaping () -> Void = {}) {
        self.source = source

        sourceState = SourceState(initial: initial, didChange: didChange)
    }

    // MARK: TableViewSourceController

    func discard() {
        sourceState.discard()
    }

    internal func reloadContent() -> Content {
        source.content(with: sourceState)
    }
}

public final class StateAccessor<State: Equatable> {
    public var value: State {
        get { get() }
        set { set(newValue) }
    }

    private let get: () -> State
    private let set: (State) -> Void

    internal init(get: @escaping () -> State, set: @escaping (State) -> Void) {
        self.get = get
        self.set = set
    }
}

public final class SourceState<Value: Equatable> {
    public var value: Value {
        didSet {
            guard value != oldValue else { return }

            didChange?()
        }
    }

    public func set(_ block: (inout Value) -> Void) {
        var new = value

        block(&new)

        value = new
    }

    public init(initial value: Value, didChange: @escaping () -> Void) {
        self.value = value

        self.didChange = didChange
    }

    public func discard() {
        didChange = nil
    }

    private var didChange: (() -> Void)?
}

//

// MARK: Block-Driven Sources

//

public final class DynamicSource<Input: Equatable>: ListViewSource {
    public typealias Builder = (SourceState<Input>, inout Content) -> Void

    let builder: Builder

    public init(with builder: @escaping Builder) {
        self.builder = builder
    }

    public func content(with state: SourceState<Input>, content: inout Content) {
        builder(state, &content)
    }
}

//

// MARK: Immutable Sources

//

public final class StaticSource: ListViewSource {
    public struct State: Equatable {
        public init() {}
    }

    public let content: Content

    public init(with content: Content = Content()) {
        self.content = content
    }

    public convenience init(with builder: Content.Configure) {
        self.init(with: Content(with: builder))
    }

    public func content(with _: SourceState<StaticSource.State>, content _: inout Content) {
        listableInternalFatal()
    }

    public func content(with _: SourceState<StaticSource.State>) -> Content {
        content
    }
}

//

// MARK: Timer For Reloading

//

internal final class ReloadTimer {
    private var timer: Timer?

    typealias OnFire = () -> Void
    private var onFire: OnFire?

    init(onFire: @escaping OnFire) {
        self.onFire = onFire

        timer = Timer.scheduledTimer(timeInterval: 0.0, target: self, selector: #selector(timerFired), userInfo: nil, repeats: false)
    }

    @objc func timerFired() {
        onFire?()
        onFire = nil

        timer = nil
    }
}
