import UIKit

public struct SwipeActionsViewStyle: Equatable {
    public enum Shape: Equatable {
        case rectangle(cornerRadius: CGFloat)
    }
    
    /// The button sizing algorithm used when laying out swipe actions.
    public enum ButtonSizing {
        /// Each button button will lay out with an equal width based on the widest button.
        /// - Note: If the total width of all buttons exceeds the available width, each button
        /// will be scaled down equally to fit.
        case equalWidth
        
        /// Each button receives the amount of space required to fit its contents.
        /// - Note: If the total width exceeds the available width, the buttons _will not_
        // be scaled down to fit.
        case sizeThatFits
    }

    public static let `default` = SwipeActionsViewStyle()

    public var actionShape: Shape
    public var interActionSpacing: CGFloat
    
    /// The insets to apply to the leading swipe actions container.
    public var leadingContainerInsets: NSDirectionalEdgeInsets
    
    /// The insets to apply to the trailing swipe actions container.
    public var trailingContainerInsets: NSDirectionalEdgeInsets
    
    public var containerCornerRadius: CGFloat
    public var buttonSizing: ButtonSizing
    public var minWidth: CGFloat
    
    /// The percentage of the row content width that is available for laying out swipe action buttons.
    ///
    /// For example, a value of `0.8` represents that the swipe action buttons should occupy no more than
    /// 80% of the row content width when the swipe actions are opened.
    /// - Note: Currently only applicable to `ButtonSizing.equalWidth` mode.
    public var maxWidthRatio: CGFloat

    public init(
        actionShape: Shape = .rectangle(cornerRadius: 0),
        interActionSpacing: CGFloat = 0,
        leadingContainerInsets: NSDirectionalEdgeInsets = .zero,
        trailingContainerInsets: NSDirectionalEdgeInsets = .zero,
        containerCornerRadius: CGFloat = 0,
        buttonSizing: ButtonSizing = .sizeThatFits,
        minWidth: CGFloat = 0,
        maxWidthRatio: CGFloat = 0.8
    ) {
        self.actionShape = actionShape
        self.interActionSpacing = interActionSpacing
        self.leadingContainerInsets = leadingContainerInsets
        self.trailingContainerInsets = trailingContainerInsets
        self.containerCornerRadius = containerCornerRadius
        self.buttonSizing = buttonSizing
        self.minWidth = minWidth
        self.maxWidthRatio = maxWidthRatio
    }

    var cornerRadius: CGFloat {
        switch actionShape {
        case .rectangle(let cornerRadius):
            return cornerRadius
        }
    }
}

extension ListEnvironment {
    
    public var swipeActionsViewStyle : SwipeActionsViewStyle {
        get { self[SwipeActionsViewStyleKey.self] }
        set { self[SwipeActionsViewStyleKey.self] = newValue }
    }
}

public enum SwipeActionsViewStyleKey: ListEnvironmentKey {
    
    public static var defaultValue: SwipeActionsViewStyle {
        .default
    }
}
