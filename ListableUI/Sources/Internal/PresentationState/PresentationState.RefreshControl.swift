//
//  RefreshControl.PresentationState.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 12/14/20.
//

import Foundation
import UIKit

extension PresentationState {
    final class RefreshControlState {
        public var model: RefreshControl
        public var view: UIRefreshControl

        public init(_ model: RefreshControl) {
            self.model = model
            view = UIRefreshControl()

            view.addTarget(self, action: #selector(refreshControlChanged), for: .valueChanged)
        }

        func update(with control: RefreshControl) {
            model = control

            if let title = model.title {
                switch title {
                case let .string(string): view.attributedTitle = NSAttributedString(string: string)
                case let .attributed(string): view.attributedTitle = string
                }
            } else {
                view.attributedTitle = nil
            }

            view.tintColor = model.tintColor

            if model.isRefreshing {
                view.beginRefreshing()
            } else {
                view.endRefreshing()
            }
        }

        @objc func refreshControlChanged() {
            model.onRefresh()
        }
    }
}
