//
//  RefreshControlOffsetAdjustmentViewController.swift
//  Demo
//
//  Created by Alexis Akers on 3/16/21.
//  Copyright © 2021 Kyle Van Essen. All rights reserved.
//

import UIKit

import UIKit
import ListableUI
import BlueprintUI
import BlueprintUICommonControls
import BlueprintUILists

final class RefreshControlOffsetAdjustmentViewController : UIViewController
{
    private let blueprintView = BlueprintView()
    private var isRefreshing: Bool = false
    private var enableScrollToTop: Bool = false

    // MARK: - Views

    override func loadView()
    {
        self.view = self.blueprintView
        reloadData()
        updateNavigationItems()
    }

    private func updateNavigationItems()
    {
        var items: [UIBarButtonItem] = [
            UIBarButtonItem(
                title: "Scroll to top: \(enableScrollToTop ? "ON" : "OFF")",
                style: .plain,
                target: self, action: #selector(toggleScrollToTop))
        ]

        if isRefreshing {
            items.append(
                UIBarButtonItem(title: "Stop Refreshing", style: .plain, target: self, action: #selector(stopRefreshing))
            )
        } else {
            items.append(
                UIBarButtonItem(title: "Refresh", style: .plain, target: self, action: #selector(refresh))
            )
        }

        navigationItem.rightBarButtonItems = items
    }

    // MARK: - Actions

    @objc func toggleScrollToTop()
    {
        enableScrollToTop.toggle()
        updateNavigationItems()
    }

    @objc func refresh()
    {
        isRefreshing = true
        reloadData()
        updateNavigationItems()
    }

    @objc func stopRefreshing()
    {
        isRefreshing = false
        reloadData()
        updateNavigationItems()
    }

    // MARK: - Content

    func reloadData()
    {
        blueprintView.element = List { list in
            list.layout = .table {
                $0.layout.padding = UIEdgeInsets(top: 24, left: 16, bottom: 24, right: 16)
                $0.layout.itemSpacing = 10.0
            }

            list.content.refreshControl = RefreshControl(
                isRefreshing: isRefreshing,
                offsetAdjustmentBehavior: .displayWhenRefreshing(animate: true, scrollToTop: enableScrollToTop),
                onRefresh: { [weak self] in
                    self?.refresh()
                }
            )

            list += Section("section") { section in
                section.items = (1 ... 100).map {
                    Item(
                        DemoItem(text: "Item \($0)")
                    )
                }
            }
        }
    }
}
