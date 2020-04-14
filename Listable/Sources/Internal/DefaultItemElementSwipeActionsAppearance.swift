//
//  DefaultItemElementSwipeActionsAppearance.swift
//  AppHost-BlueprintLists-Unit-Tests
//
//  Created by Matthew Faluotico on 4/14/20.
//

import Foundation

public final class DefaultItemElementSwipeActionsAppearance: ItemElementSwipeActionsAppearance {

    public init() { }

}

// MARK: - ItemElementSwipeActionsAppearance
public extension DefaultItemElementSwipeActionsAppearance {

    static func createView(frame: CGRect) -> SwipeView {
        return .init()
    }

    func apply(swipeActions: SwipeActions, to view: SwipeView) {
        // Currently only supporting first action
        if let action = swipeActions.actions.first {
            view.action = action
        }
    }

    func apply(swipeControllerState: SwipeControllerState, to view: DefaultItemElementSwipeActionsAppearance.SwipeView) {
        view.state = swipeControllerState
    }

    func preferredSize(for view: SwipeView) -> CGSize {
        return view.preferredSize()
    }

}

// MARK: - SwipeView
extension DefaultItemElementSwipeActionsAppearance {

    public final class SwipeView: UIView {

        private static var padding: UIEdgeInsets
        {
            return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        }

        var state: SwipeControllerState
        {
            didSet {
                UIView.animate(withDuration: 0.2) {
                    switch self.state {
                    case .pending, .swiping(passedSwipeThroughThreshold: false), .locked:
                        self.stackView.alignment = .center
                    case .swiping(passedSwipeThroughThreshold: true), .finished:
                        self.stackView.alignment = .leading
                    }
                }
            }
        }

        var action: SwipeAction? {
            didSet {
                self.titleView?.text = action?.title
                self.backgroundColor = action?.backgroundColor ?? .white

                if let image = action?.image {
                    if let imageView = self.imageView {
                        imageView.image = image
                    } else {
                        let imageView = UIImageView(image: image)
                        self.stackView.addArrangedSubview(imageView)
                        self.imageView = imageView
                    }
                }
            }
        }

        private var imageView: UIImageView?
        private var titleView: UILabel?
        private var gestureRecognizer: UITapGestureRecognizer
        private var stackView = UIStackView()

        init()
        {
            self.state = .pending
            self.gestureRecognizer = UITapGestureRecognizer()
            super.init(frame: .zero)

            self.gestureRecognizer.addTarget(self, action: #selector(onTap))
            self.addGestureRecognizer(gestureRecognizer)

            let titleView = UILabel()
            titleView.textColor = .white
            titleView.lineBreakMode = .byClipping
            self.stackView.addArrangedSubview(titleView)
            self.titleView = titleView

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
            guard let titleView = self.titleView else {
                return self.sizeThatFits(UIScreen.main.bounds.size)
            }

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
    }

}
