//
//  DefaultItemElementSwipeActionsAppearance.swift
//  AppHost-BlueprintLists-Unit-Tests
//
//  Created by Matthew Faluotico on 4/14/20.
//

import Foundation

public final class DefaultItemElementSwipeActionsAppearance: ItemElementSwipeActionsAppearance {

    public init() { }

    public static func createView(frame: CGRect) -> SwipeView {
        return .init()
    }

    public func apply(swipeActions: SwipeActions, to view: SwipeView) {
        guard swipeActions.actions.count <= 1 else {
            fatalError("More than one action is not currently supported")
        }
        if let action = swipeActions.actions.first {
            view.action = action
        }
    }

    public func apply(swipeControllerState: SwipeControllerState, to view: DefaultItemElementSwipeActionsAppearance.SwipeView) {
        view.setState(swipeControllerState, animated: true)
    }

    public func preferredSize(for view: SwipeView) -> CGSize {
        return view.preferredSize()
    }

}

// MARK: - SwipeView
extension DefaultItemElementSwipeActionsAppearance {

    public final class SwipeView: UIView {

        private static var padding: UIEdgeInsets
        {
            return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }

        private (set) var state: SwipeControllerState

        var action: SwipeAction? {
            didSet {
                self.titleView.text = action?.title
                self.backgroundColor = action?.backgroundColor ?? .white

                if let image = action?.image {
                    self.imageView.image = image

                    if !stackView.arrangedSubviews.contains(imageView) {
                        stackView.addArrangedSubview(imageView)
                    }
                }
            }
        }

        lazy private var imageView = UIImageView()
        private let titleView: UILabel
        private let gestureRecognizer: UITapGestureRecognizer
        private let stackView = UIStackView()

        init()
        {
            self.state = .closed
            self.gestureRecognizer = UITapGestureRecognizer()
            self.titleView = UILabel()
            super.init(frame: .zero)

            self.gestureRecognizer.addTarget(self, action: #selector(onTap))
            self.addGestureRecognizer(gestureRecognizer)

            titleView.textColor = .white
            titleView.lineBreakMode = .byClipping
            self.stackView.addArrangedSubview(titleView)

            stackView.spacing = 2
            stackView.alignment = .center
            stackView.axis = .vertical
            stackView.distribution = .fill
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.layoutMargins = SwipeView.padding

            self.addSubview(self.stackView)
        }

        required init?(coder: NSCoder)
        {
            fatalError("init(coder:) has not been implemented")
        }

        public override func layoutSubviews()
        {
            super.layoutSubviews()
            self.stackView.frame = self.bounds
        }

        func preferredSize() -> CGSize
        {
            var size = titleView.sizeThatFits(self.bounds.size)
            size.width += SwipeView.padding.left + SwipeView.padding.right
            return size
        }

        @objc func onTap()
        {
            if let action = self.action {
                let _ = action.onTap(action)
            }
        }

        public func setState(_ state: SwipeControllerState, animated: Bool)
        {
            self.state = state
            if animated {
                UIView.animate(withDuration: 0.2) {
                    switch self.state {
                    case .closed, .swiping(passedSwipeThroughThreshold: false), .open:
                        self.stackView.alignment = .center
                    case .swiping(passedSwipeThroughThreshold: true), .finished:
                        self.stackView.alignment = .leading
                    }
                }
            }
        }
    }

}
