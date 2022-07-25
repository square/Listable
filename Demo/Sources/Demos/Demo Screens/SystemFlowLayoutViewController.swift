//
//  SystemFlowLayoutViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 1/13/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//

import UIKit

/**
 Implements  a very basic UICollectionViewFlowLayout, so we can use the debugger and view inspector
 to determine how it implements various things like supplementary views, etc.
 */
final class SystemFlowLayoutViewController: UIViewController {
    let layout: UICollectionViewFlowLayout
    let collectionView: UICollectionView

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        title = "Flow Layout Demo"
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError() }

    override func loadView() {
        view = collectionView

        collectionView.backgroundColor = .white

        collectionView.register(FlowCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.register(FlowHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        collectionView.register(FlowFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer")

        layout.headerReferenceSize = CGSize(width: 300.0, height: 50.0)
        layout.footerReferenceSize = CGSize(width: 300.0, height: 50.0)
        layout.itemSize = CGSize(width: 300.0, height: 100.0)

        layout.minimumLineSpacing = 20.0
        layout.minimumInteritemSpacing = 20.0

        collectionView.delegate = self
        collectionView.dataSource = self
    }

    fileprivate let items: [[FlowItem]] = [
        [
            // Empty section.
        ],
        [
            // Section with one item.

            FlowItem(title: "Item 0, Section 1"),
        ],
        [
            // Section with two items.

            FlowItem(title: "Item 0, Section 2"),
            FlowItem(title: "Item 1, Section 2"),
        ],
        [
            // Section with three items.

            FlowItem(title: "Item 0, Section 3"),
            FlowItem(title: "Item 1, Section 3"),
            FlowItem(title: "Item 2, Section 3"),
        ],
    ]
}

extension SystemFlowLayoutViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    // MARK: UICollectionViewDataSource

    func numberOfSections(in _: UICollectionView) -> Int {
        items.count
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items[section].count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
        case UICollectionView.elementKindSectionFooter:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
        default: fatalError()
        }
    }

    // MARK: UICollectionViewDelegate

    // MARK: UICollectionViewDelegateFlowLayout
}

private struct FlowItem: Equatable {
    var title: String
}

private final class FlowCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .init(white: 0.9, alpha: 1.0)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError() }
}

private final class FlowHeader: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .init(white: 0.95, alpha: 1.0)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError() }
}

private final class FlowFooter: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .init(white: 0.8, alpha: 1.0)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError() }
}
