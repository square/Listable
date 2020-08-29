//
//  BlurredBackground.swift
//  BalanceFauxMarket
//
//  Created by Ben Cochran on 6/12/20.
//  Copyright © 2020 Square, Inc. All rights reserved.
//

import BlueprintUI


extension Element {

    public func blurredBackground(style: BlurredBackground.Style = .regular) -> BlurredBackground {
        return BlurredBackground(style: style, wrapping: self)
    }

}

public struct BlurredBackground: Element {

    public var style: Style
    public var wrappedElement: Element?

    public init(
        style: Style = .regular,
        wrapping: Element? = nil
    ) {
        self.style = style
        self.wrappedElement = wrapping
    }

    public var content: ElementContent {
        if let wrappedElement = wrappedElement {
            return ElementContent(child: wrappedElement)
        } else {
            return ElementContent(intrinsicSize: .zero)
        }
    }

    public func backingViewDescription(bounds: CGRect, subtreeExtent: CGRect?) -> ViewDescription? {
        return UIVisualEffectView.describe { config in
            config.contentView = { $0.contentView }

            // TODO: Profile to see if reapplying the effect is a performance
            // problem
            config[\.effect] = style.effect
        }
    }

}

extension BlurredBackground {

    public enum Style {
        case extraLight
        case light
        case dark

        case regular
        case prominent

    }

}

extension BlurredBackground.Style {

    var effect: UIBlurEffect {
        return UIBlurEffect(style: effectStyle)
    }

    var effectStyle: UIBlurEffect.Style {
        switch self {
        case .extraLight: return .extraLight
        case .light: return .light
        case .dark: return .dark
        case .regular: return .regular
        case .prominent: return .prominent
        }
    }

}
