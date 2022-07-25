//
//  InvoicesPaymentScheduleDemoViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 11/18/19.
//  Copyright © 2019 Kyle Van Essen. All rights reserved.
//

import BlueprintUI
import BlueprintUICommonControls
import BlueprintUILists
import ListableUI
import UIKit

final class InvoicesPaymentScheduleDemoViewController: UIViewController {
    private let list = ListView()

    private var data = ViewData.mockData {
        didSet {
            guard oldValue != self.data else {
                return
            }

            self.reloadData(animated: true)
        }
    }

    override func loadView() {
        view = list

        setAppearance()
        reloadData(animated: false)
    }

    func setAppearance() {
        list.layout = .table {
            $0.bounds = .init(padding: UIEdgeInsets(top: 20.0, left: 10.0, bottom: 20.0, right: 10.0))

            $0.layout.set {
                $0.interSectionSpacingWithFooter = 30.0
                $0.interSectionSpacingWithNoFooter = 30.0
                $0.sectionHeaderBottomSpacing = 5.0
                $0.itemToSectionFooterSpacing = 20.0
            }
        }
    }

    func reloadData(animated: Bool) {
        list.configure { list in

            list.animatesChanges = animated

            list += Section(SectionIdentifier.toggles) {
                Item(
                    ToggleRow(
                        content: .init(text: "Request initial deposit", isOn: self.data.requestsInitialDeposit),
                        onToggle: { isOn in
                            self.data.requestsInitialDeposit = isOn
                        }
                    )
                )

                Item(
                    ToggleRow(
                        content: .init(text: "Split balance into milestones", isOn: self.data.splitsIntoMilestones),
                        onToggle: { isOn in
                            self.data.splitsIntoMilestones = isOn
                        }
                    )
                )
            }

            if self.data.requestsInitialDeposit {
                list += Section(SectionIdentifier.deposits) {
                    Item(
                        SegmentedControlRow(id: "split-type") { control in
                            control.appendItem(title: "%") {}

                            control.appendItem(title: "%") {}
                        },

                        layouts: .init {
                            $0.table.itemSpacing = 20.0
                        }
                    )

                    Item(
                        AmountRow(
                            content: .init(amount: 100, title: "Deposit", detail: "Due upon receipt"),
                            onAmountChanged: { _ in

                            },
                            onEdit: { _ in
                            }
                        )
                    )
                } header: {
                    SectionHeader(text: "Deposit Request")
                } footer: {
                    SectionFooter(text: "Request $10.00 deposit on $100.00 invoice.")
                }
            }

            if self.data.splitsIntoMilestones {
                list += Section(SectionIdentifier.splits) {
                    Item(
                        SegmentedControlRow(id: "split-type") { control in
                            control.appendItem(title: "%") {}

                            control.appendItem(title: "%") {}
                        },
                        layouts: .init {
                            $0.table.itemSpacing = 20
                        }
                    )

                    Item(
                        AmountRow(
                            content: .init(amount: 100, title: "Payment 1", detail: "Due in 10 days."),
                            onAmountChanged: { _ in

                            },
                            onEdit: { _ in
                            }
                        )
                    )

                    Item(
                        AmountRow(
                            content: .init(amount: 100, title: "Payment 2", detail: "Due in 20 days."),
                            onAmountChanged: { _ in

                            },
                            onEdit: { _ in
                            }
                        )
                    )
                } header: {
                    SectionHeader(text: "Balance Split")
                } footer: {
                    SectionFooter(text: "Request $90.00 of $100.00 invoice balance over 2 payments.")
                }
            }
        }
    }
}

private enum SectionIdentifier: Hashable {
    case toggles
    case deposits
    case splits
}

private struct ViewData: Equatable {
    var requestsInitialDeposit: Bool
    var splitsIntoMilestones: Bool

    var depositRequest: DepositRequest
    var balanceSplit: BalanceSplit

    struct DepositRequest: Equatable {
        var splitType: SplitType

        var deposit: Deposit
        var balance: Balance

        var invoiceTotal: Int

        struct Deposit: Equatable {
            var amount: Int
            var due: Date
        }

        struct Balance: Equatable {
            var amount: Int
        }
    }

    struct BalanceSplit: Equatable {
        var splitType: SplitType

        var payments: [Payment]

        struct Payment: Equatable {
            var amount: Amount
            var due: Date

            enum Amount: Equatable {
                case percent(Int)
                case amount(Int)
            }
        }
    }

    enum SplitType: Equatable {
        case percent
        case dollar
    }

    static var mockData: ViewData {
        ViewData(
            requestsInitialDeposit: true,
            splitsIntoMilestones: true,
            depositRequest: ViewData.DepositRequest(
                splitType: .dollar,
                deposit: ViewData.DepositRequest.Deposit(amount: 100, due: Date()),
                balance: ViewData.DepositRequest.Balance(amount: 900),
                invoiceTotal: 1000
            ),
            balanceSplit: ViewData.BalanceSplit(
                splitType: .dollar,
                payments: [
                    ViewData.BalanceSplit.Payment(amount: .percent(30), due: Date()),
                    ViewData.BalanceSplit.Payment(amount: .percent(30), due: Date()),
                    ViewData.BalanceSplit.Payment(amount: .percent(40), due: Date()),
                ]
            )
        )
    }
}

private struct ToggleRow: BlueprintItemContent {
    var content: Content
    var onToggle: (Bool) -> Void

    struct Content: Equatable {
        var text: String
        var isOn: Bool
    }

    // MARK: BlueprintItemElement

    func element(with _: ApplyItemContentInfo) -> Element {
        Inset(top: 10.0, bottom: 10.0, left: 0.0, right: 0.0, wrapping: Row { row in

            row.verticalAlignment = .center

            row.add(growPriority: 0.0, child: Label(text: self.content.text))
            row.add(growPriority: 1.0, child: Box())
            row.add(growPriority: 0.0, child: Toggle(isOn: self.content.isOn, onToggle: self.onToggle))
        })
    }

    var identifierValue: String {
        content.text
    }

    func isEquivalent(to other: ToggleRow) -> Bool {
        content == other.content
    }
}

private struct SectionHeader: BlueprintHeaderFooterContent, Equatable {
    var text: String

    // MARK: BlueprintHeaderFooterElement

    var elementRepresentation: Element {
        Label(text: text)
    }
}

private struct SectionFooter: BlueprintHeaderFooterContent, Equatable {
    var text: String

    // MARK: BlueprintHeaderFooterElement

    var elementRepresentation: Element {
        Label(text: text)
    }
}

private struct SegmentedControlRow: BlueprintItemContent {
    var id: String
    var control: SegmentedControl

    init(id: String, configure: (inout SegmentedControl) -> Void) {
        self.id = id

        control = SegmentedControl()
        configure(&control)
    }

    // MARK: BlueprintItemElement

    func element(with _: ApplyItemContentInfo) -> Element {
        control
    }

    var identifierValue: String {
        id
    }

    func isEquivalent(to _: SegmentedControlRow) -> Bool {
        true
    }
}

private struct AmountRow: BlueprintItemContent {
    var content: Content

    typealias OnAmountChanged = (Int) -> Void
    var onAmountChanged: OnAmountChanged?

    typealias OnEdit = (Int) -> Void
    var onEdit: OnEdit?

    struct Content: Equatable {
        var amount: Int
        var title: String
        var detail: String
    }

    // MARK: BlueprintItemElement

    func element(with _: ApplyItemContentInfo) -> Element {
        var box = Box(wrapping: Row { row in

            row.verticalAlignment = .fill
            row.horizontalUnderflow = .growProportionally

            row.add(growPriority: 0.0, child: Inset(
                uniformInset: 20.0,
                wrapping: Centered(Label(text: "$0.00"))
            ))

            row.add(growPriority: 1.0, child: Column { column in

                column.horizontalAlignment = .fill
                column.verticalUnderflow = .growProportionally

                column.add(child: Row { row in
                    row.add(growPriority: 0.0, child: Label(text: self.content.title))

                    row.add(growPriority: 1.0, child: Box())

                    if self.onEdit != nil {
                        row.add(growPriority: 0.0, child: Label(text: "Edit"))
                    }
                })

                column.add(child: Label(text: self.content.detail))
            })
        })

        box.borderStyle = .solid(color: .lightGray, width: 1.0)

        return box
    }

    var identifierValue: String {
        content.title
    }

    func isEquivalent(to other: AmountRow) -> Bool {
        content == other.content
    }
}

private struct ButtonRow: BlueprintItemContent {
    var text: String
    var onTap: () -> Void

    func element(with _: ApplyItemContentInfo) -> Element {
        fatalError()
    }

    var identifierValue: String {
        text
    }

    func isEquivalent(to other: ButtonRow) -> Bool {
        text == other.text
    }
}
