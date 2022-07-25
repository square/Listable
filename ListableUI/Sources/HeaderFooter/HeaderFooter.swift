//
//  HeaderFooter.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 8/10/19.
//

import UIKit

public typealias Header<Content: HeaderFooterContent> = HeaderFooter<Content>
public typealias Footer<Content: HeaderFooterContent> = HeaderFooter<Content>

public struct HeaderFooter<Content: HeaderFooterContent>: AnyHeaderFooter {
    public var content: Content

    public var sizing: Sizing
    public var layouts: HeaderFooterLayouts

    public typealias OnTap = () -> Void
    public var onTap: OnTap?

    public var debuggingIdentifier: String?

    internal let reuseIdentifier: ReuseIdentifier<Content>

    //

    // MARK: Initialization

    //

    public typealias Configure = (inout HeaderFooter) -> Void

    public init(
        _ content: Content,
        configure: Configure
    ) {
        self.init(content)

        configure(&self)
    }

    public init(
        _ content: Content,
        sizing: Sizing? = nil,
        layouts: HeaderFooterLayouts? = nil,
        onTap: OnTap? = nil
    ) {
        assertIsValueType(Content.self)

        self.content = content

        let defaults = self.content.defaultHeaderFooterProperties

        self.sizing = sizing ?? defaults.sizing ?? .thatFits(.noConstraint)
        self.layouts = layouts ?? defaults.layouts ?? .init()
        self.onTap = onTap ?? defaults.onTap
        debuggingIdentifier = defaults.debuggingIdentifier

        reuseIdentifier = ReuseIdentifier.identifier(for: Content.self)
    }

    // MARK: AnyHeaderFooter

    public var anyContent: Any {
        content
    }

    public var reappliesToVisibleView: ReappliesToVisibleView {
        content.reappliesToVisibleView
    }

    // MARK: AnyHeaderFooterConvertible

    public func asAnyHeaderFooter() -> AnyHeaderFooter {
        self
    }

    // MARK: AnyHeaderFooter_Internal

    public func apply(
        to anyView: UIView,
        for reason: ApplyReason,
        with info: ApplyHeaderFooterContentInfo
    ) {
        let view = anyView as! HeaderFooterContentView<Content>

        let views = HeaderFooterContentViews<Content>(
            content: view.content,
            background: view.background,
            pressed: view.pressedBackground
        )

        content.apply(
            to: views,
            for: reason,
            with: info
        )
    }

    public func anyIsEquivalent(to other: AnyHeaderFooter) -> Bool {
        guard let other = other as? HeaderFooter<Content> else {
            return false
        }

        return content.isEquivalent(to: other.content)
    }

    public func newPresentationHeaderFooterState(performsContentCallbacks: Bool) -> Any {
        PresentationState.HeaderFooterState(self, performsContentCallbacks: performsContentCallbacks)
    }
}

public extension HeaderFooterContent {
    /// Identical to `HeaderFooter.init` which takes in a `HeaderFooterContent`,
    /// except you can call this on the `HeaderFooterContent` itself, instead of wrapping it,
    /// to avoid additional nesting, and to hoist your content up in your code.
    ///
    /// ```
    /// Section("id") { section in
    ///     section.header = MyHeaderContent(
    ///         title: "Hello, World!"
    ///     )
    ///     .with(
    ///         sizing: .thatFits(.noConstraint),
    ///     )
    ///
    /// struct MyHeaderContent : HeaderFooterContent {
    ///    var title : String
    ///    ...
    /// }
    /// ```
    func with(
        sizing: Sizing? = nil,
        layouts: HeaderFooterLayouts? = nil,
        onTap: HeaderFooter<Self>.OnTap? = nil
    ) -> HeaderFooter<Self> {
        HeaderFooter(
            self,
            sizing: sizing,
            layouts: layouts,
            onTap: onTap
        )
    }
}

extension HeaderFooter: SignpostLoggable {
    var signpostInfo: SignpostLoggingInfo {
        SignpostLoggingInfo(
            identifier: debuggingIdentifier,
            instanceIdentifier: nil
        )
    }
}
