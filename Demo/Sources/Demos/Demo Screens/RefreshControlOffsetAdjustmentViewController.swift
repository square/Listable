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

    // MARK: - Views

    override func loadView()
    {
        self.view = self.blueprintView
        reloadData()
        updateNavigationItems()
    }

    private func updateNavigationItems()
    {
        if isRefreshing {
            navigationItem.rightBarButtonItems = [
                UIBarButtonItem(title: "Stop Refreshing", style: .plain, target: self, action: #selector(stopRefreshing)),
            ]
        } else {
            navigationItem.rightBarButtonItems = [
                UIBarButtonItem(title: "Refresh", style: .plain, target: self, action: #selector(refresh)),
            ]
        }
    }

    // MARK: - Actions

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
                $0.layout.padding.top = 24.0
                $0.layout.itemSpacing = 10.0
            }

            list.content.refreshControl = RefreshControl(
                isRefreshing: isRefreshing,
                offsetAdjustmentBehavior: .displayWhenRefreshing(animate: true),
                onRefresh: { [weak self] in
                    self?.refresh()
                }
            )

            list += Section("section") { section in
                section += DemoItem(text: "Item 1")
                section += DemoItem(text: "Item 2")
                section += DemoItem(text: "Item 3")
            }
        }
    }
}
