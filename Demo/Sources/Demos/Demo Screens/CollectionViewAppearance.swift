//
//  CollectionViewAppearance.swift
//  Demo
//
//  Created by Kyle Van Essen on 10/20/19.
//  Copyright © 2019 Kyle Van Essen. All rights reserved.
//

import BlueprintUI
import BlueprintUICommonControls
import BlueprintUILists
import ListableUI

extension Appearance {
    static var demoAppearance = Appearance {
        $0.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
    }
}

extension LayoutDescription {
    static var demoLayout: Self {
        self.demoLayout()
    }

    static func demoLayout(_ configure: @escaping (inout TableAppearance) -> Void = { _ in }) -> Self {
        .table {
            $0.bounds = .init(
                padding: UIEdgeInsets(top: 30.0, left: 20.0, bottom: 30.0, right: 20.0),
                width: .atMost(600.0)
            )

            $0.layout = .init(
                headerToFirstSectionSpacing: 20.0,
                interSectionSpacingWithNoFooter: 20.0,
                interSectionSpacingWithFooter: 20.0,
                sectionHeaderBottomSpacing: 15.0,
                itemSpacing: 10.0,
                itemToSectionFooterSpacing: 10.0
            )

            $0.listHeaderPosition = .fixed
            $0.stickySectionHeaders = true

            configure(&$0)
        }
    }

    static func retailGridDemo(columns: Int, rows: RetailGridAppearance.Layout.Rows = .infinite(tileAspectRatio: 9.0 / 16.0)) -> Self {
        .retailGrid {
            $0.layout = .init(
                padding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
                itemSpacing: 20,
                columns: columns,
                rows: rows
            )
        }
    }
}

extension UIColor {
    static func white(_ blend: CGFloat) -> UIColor {
        UIColor(white: blend, alpha: 1.0)
    }
}

struct DemoHeader: BlueprintHeaderFooterContent, Equatable {
    var title: String
    var detail: String?

    var useMonospacedTitleFont: Bool

    init(
        title: String,
        detail: String? = nil,
        useMonospacedTitleFont: Bool = false
    ) {
        self.title = title
        self.detail = detail
        self.useMonospacedTitleFont = useMonospacedTitleFont
    }

    var elementRepresentation: Element {
        Column(alignment: .fill, minimumSpacing: 10.0) {
            Label(text: self.title) {
                if #available(iOS 13.0, *), useMonospacedTitleFont {
                    $0.font = .monospacedSystemFont(ofSize: 21.0, weight: .semibold)
                } else {
                    $0.font = .systemFont(ofSize: 21.0, weight: .semibold)
                }
            }

            if let detail = detail {
                Label(text: detail) {
                    $0.font = .systemFont(ofSize: 14.0, weight: .regular)
                    $0.color = .lightGray
                }
                .constrainedTo(width: .atMost(600))
                .aligned(vertically: .fill, horizontally: .leading)
            }
        }
        .inset(horizontal: 15.0, vertical: 15.0)
        .box(
            background: .white,
            corners: .rounded(radius: 10.0)
        )
    }
}

struct DemoHeader2: BlueprintHeaderFooterContent, Equatable {
    var title: String

    var elementRepresentation: Element {
        Label(text: title) {
            $0.font = .systemFont(ofSize: 21.0, weight: .bold)
        }
        .inset(horizontal: 15.0, vertical: 30.0)
        .box(
            background: .white,
            corners: .rounded(radius: 10.0)
        )
    }
}

struct DemoItem: BlueprintItemContent, Equatable, LocalizedCollatableItemContent {
    var text: String
    var requiresLongPress = false

    var identifierValue: String {
        text
    }

    typealias SwipeActionsView = DefaultSwipeActionsView

    func element(with info: ApplyItemContentInfo) -> Element {
        let row = Row { row in
            row.verticalAlignment = .center

            row.add(child: Label(text: self.text) {
                $0.font = .systemFont(ofSize: 17.0, weight: .medium)
                $0.color = info.state.isActive ? .white : .darkGray
            })

            row.addFlexible(child: Spacer(width: 1.0))

            if info.isReorderable {
                row.addFixed(
                    child: Image(
                        image: UIImage(named: "ReorderControl"),
                        contentMode: .center
                    )
                    .listReorderGesture(with: info.reorderingActions, begins: requiresLongPress ? .onLongPress : .onTap)
                )
            }
        }
        .inset(horizontal: 15.0, vertical: 13.0)

        if !info.isReorderable {
            // Only wrap the row in an accessibility element if we arent showing the reorder gesture.
            return AccessibilityElement(label: text, value: nil, traits: [.button], wrapping: row)
        }
        return row
    }

    func backgroundElement(with info: ApplyItemContentInfo) -> Element? {
        Box(
            backgroundColor: info.state.isReordering ? .white(0.8) : .white,
            cornerStyle: .rounded(radius: 8.0)
        )
    }

    func selectedBackgroundElement(with _: ApplyItemContentInfo) -> Element? {
        Box(
            backgroundColor: .white(0.2),
            cornerStyle: .rounded(radius: 8.0),
            shadowStyle: .simple(radius: 2.0, opacity: 0.15, offset: .init(width: 0.0, height: 1.0), color: .black)
        )
    }

    var collationString: String {
        text
    }
}

struct DemoFooter: BlueprintHeaderFooterContent, Equatable {
    var text: String

    var elementRepresentation: Element {
        Centered(Label(text: text))
    }
}

struct Toggle: Element {
    var isOn: Bool

    var onToggle: (Bool) -> Void

    var content: ElementContent {
        ElementContent(layout: Layout())
    }

    func backingViewDescription(with _: ViewDescriptionContext) -> ViewDescription? {
        ViewDescription(ToggleView.self) { config in
            config.builder = {
                ToggleView()
            }

            config.apply { toggle in
                if toggle.isOn != self.isOn {
                    toggle.setOn(self.isOn, animated: UIView.inheritedAnimationDuration > 0.0)
                }
                toggle.onToggle = self.onToggle
            }
        }
    }

    private final class ToggleView: UISwitch {
        var onToggle: (Bool) -> Void = { _ in }

        override init(frame: CGRect) {
            super.init(frame: frame)

            addTarget(self, action: #selector(didToggleValue), for: .valueChanged)
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError()
        }

        @objc func didToggleValue() {
            onToggle(isOn)
        }
    }

    private struct Layout: BlueprintUI.Layout {
        static let measurementSwitch = ToggleView()

        func measure(in _: SizeConstraint, items _: [(traits: (), content: Measurable)]) -> CGSize {
            Layout.measurementSwitch.sizeThatFits(.init(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        }

        func layout(size _: CGSize, items _: [(traits: (), content: Measurable)]) -> [LayoutAttributes]
        {
            []
        }
    }
}
