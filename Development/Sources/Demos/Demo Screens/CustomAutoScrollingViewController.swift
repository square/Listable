//
//  CustomAutoScrollingViewController.swift
//  Demo
//
//  Created by Square on 5/22/26.
//

import BlueprintUI
import BlueprintUICommonControls
import BlueprintUILists
import ListableUI
import UIKit


final class CustomAutoScrollingViewController : UIViewController
{
    private let list = ListView()
    private let footer = UIView()
    private let footerTitle = UILabel()

    private var selectedRow = 24
    private var expandedRows = Set<Int>()
    private var hasPerformedInitialLayoutUpdate = false

    override func loadView()
    {
        self.view = UIView()
        self.view.backgroundColor = .white

        self.list.translatesAutoresizingMaskIntoConstraints = false
        self.footer.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(self.list)
        self.view.addSubview(self.footer)

        NSLayoutConstraint.activate([
            self.list.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.list.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.list.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.list.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.footer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.footer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.footer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.footer.heightAnchor.constraint(equalToConstant: 112.0),
        ])

        self.configureFooter()
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.title = "Custom Auto Scrolling"
        self.updateList()
    }

    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()

        guard self.hasPerformedInitialLayoutUpdate == false else {
            return
        }

        self.hasPerformedInitialLayoutUpdate = true
        self.updateList()
    }

    override func viewSafeAreaInsetsDidChange()
    {
        super.viewSafeAreaInsetsDidChange()

        self.updateList()
    }

    private func configureFooter()
    {
        self.footer.backgroundColor = .systemBackground
        self.footer.layer.shadowColor = UIColor.black.cgColor
        self.footer.layer.shadowOpacity = 0.18
        self.footer.layer.shadowRadius = 8.0
        self.footer.layer.shadowOffset = CGSize(width: 0.0, height: -2.0)

        let previous = UIButton(type: .system)
        previous.setTitle("Previous", for: .normal)
        previous.addTarget(self, action: #selector(selectPreviousRow), for: .touchUpInside)

        let next = UIButton(type: .system)
        next.setTitle("Next", for: .normal)
        next.addTarget(self, action: #selector(selectNextRow), for: .touchUpInside)

        let toggleHeight = UIButton(type: .system)
        toggleHeight.setTitle("Toggle Height", for: .normal)
        toggleHeight.addTarget(self, action: #selector(toggleSelectedRowHeight), for: .touchUpInside)

        self.footerTitle.font = .systemFont(ofSize: 16.0, weight: .semibold)
        self.footerTitle.textAlignment = .center

        let buttons = UIStackView(arrangedSubviews: [previous, next, toggleHeight])
        buttons.axis = .horizontal
        buttons.alignment = .center
        buttons.distribution = .equalSpacing
        buttons.spacing = 16.0

        let stack = UIStackView(arrangedSubviews: [self.footerTitle, buttons])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 10.0

        self.footer.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: self.footer.topAnchor, constant: 12.0),
            stack.leadingAnchor.constraint(equalTo: self.footer.leadingAnchor, constant: 20.0),
            stack.trailingAnchor.constraint(equalTo: self.footer.trailingAnchor, constant: -20.0),
        ])
    }

    @objc private func selectPreviousRow()
    {
        self.selectedRow = max(0, self.selectedRow - 1)
        self.updateList()
    }

    @objc private func selectNextRow()
    {
        self.selectedRow = min(Self.rowCount - 1, self.selectedRow + 1)
        self.updateList()
    }

    @objc private func toggleSelectedRowHeight()
    {
        if self.expandedRows.contains(self.selectedRow) {
            self.expandedRows.remove(self.selectedRow)
        } else {
            self.expandedRows.insert(self.selectedRow)
        }

        self.updateList()
    }

    private func updateList()
    {
        self.footerTitle.text = "Target row \(self.selectedRow + 1) stays above the fixed footer"

        let selectedRow = self.selectedRow
        let targetIdentifier = FooterAwarePinnedItem.identifier(with: selectedRow)

        self.list.configure { list in
            list.appearance = .demoAppearance
            list.layout = .demoLayout
            list.animation = .fast
            list.scrollIndicatorInsets.bottom = self.scrollIndicatorBottomInset

            list.autoScrollAction = .pin(
                .item(targetIdentifier),
                itemPosition: .verticalContentOffsetAdjustment { [weak self] info in
                    self?.footerAwareScrollDelta(for: info) ?? 0.0
                },
                animated: false,
                scrollInterruptionPolicy: .deferDuringUserScrolling,
                shouldPerform: { _ in true }
            )

            list += Section("rows") {
                for row in 0..<Self.rowCount {
                    FooterAwarePinnedItem(
                        row: row,
                        isSelected: row == selectedRow,
                        isExpanded: self.expandedRows.contains(row)
                    )
                }
            }
        }
    }

    private func footerAwareScrollDelta(for info: ListItemScrollPositionInfo) -> CGFloat
    {
        let topGap : CGFloat = 16.0
        let footerGap : CGFloat = 16.0
        let footerHeight = self.footer.bounds.height

        let idealTop = info.visibleContentFrame.minY + topGap
        let idealBottom = info.visibleContentFrame.maxY - footerHeight - footerGap

        if info.itemFrame.height > idealBottom - idealTop {
            return info.itemFrame.minY - idealTop
        }

        if info.itemFrame.minY < idealTop {
            return info.itemFrame.minY - idealTop
        }

        if info.itemFrame.maxY > idealBottom {
            return info.itemFrame.maxY - idealBottom
        }

        return 0.0
    }

    private var scrollIndicatorBottomInset : CGFloat {
        max(0.0, self.footer.bounds.height - self.view.safeAreaInsets.bottom)
    }

    private static let rowCount = 50
}


private struct FooterAwarePinnedItem : BlueprintItemContent, Equatable
{
    var row : Int
    var isSelected : Bool
    var isExpanded : Bool

    var identifierValue : Int {
        self.row
    }

    func element(with info : ApplyItemContentInfo) -> Element
    {
        let title = Label(text: "Row \(self.row + 1)") {
            $0.font = .systemFont(ofSize: 17.0, weight: self.isSelected ? .semibold : .regular)
            $0.color = self.isSelected ? .systemBlue : .label
        }

        let detail = Label(text: self.detailText) {
            $0.font = .systemFont(ofSize: 14.0, weight: .regular)
            $0.color = .secondaryLabel
        }

        let content = Column(alignment: .fill, minimumSpacing: 6.0) {
            title
            detail
        }

        var box = Box(
            backgroundColor: self.isSelected ? UIColor.systemBlue.withAlphaComponent(0.08) : .white,
            cornerStyle: .rounded(radius: 6.0),
            wrapping: Inset(
                uniformInset: 14.0,
                wrapping: content
            )
        )

        box.borderStyle = .solid(
            color: self.isSelected ? .systemBlue : .white(0.9),
            width: 2.0
        )

        return box
    }

    private var detailText : String {
        if self.isExpanded {
            return "Expanded row content demonstrates a layout update that re-runs declarative custom auto-scroll."
        } else if self.isSelected {
            return "Selected target row"
        } else {
            return "Regular row"
        }
    }
}
