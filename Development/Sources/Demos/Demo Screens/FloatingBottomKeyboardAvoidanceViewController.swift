//
//  FloatingBottomKeyboardAvoidanceViewController.swift
//  Demo
//
//  Created by Rob MacEachern on 5/15/26.
//  Copyright © 2026 Kyle Van Essen. All rights reserved.
//

import BlueprintUI
import BlueprintUICommonControls
import BlueprintUILists
import ListableUI
import UIKit

final class FloatingBottomKeyboardAvoidanceViewController: UIViewController {
    private let listView = ListView()
    private let bottomBarView = UIView()
    private let bottomBarBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
    private let resignButton = UIButton(type: .system)
    private let keyboardDismissModeControl = UISegmentedControl(items: ["None", "Drag", "Interactive"])

    private let floatingBarHeight: CGFloat = 76.0
    private let bottomContentSpacing: CGFloat = 24.0
    private var keyboardDismissMode: UIScrollView.KeyboardDismissMode = .interactive

    override func loadView() {
        view = UIView()
        view.backgroundColor = .white

        listView.translatesAutoresizingMaskIntoConstraints = false
        bottomBarView.translatesAutoresizingMaskIntoConstraints = false
        bottomBarBlurView.translatesAutoresizingMaskIntoConstraints = false
        resignButton.translatesAutoresizingMaskIntoConstraints = false

        bottomBarView.backgroundColor = .clear
        bottomBarView.isOpaque = false
        bottomBarBlurView.alpha = 0.72
        bottomBarBlurView.isUserInteractionEnabled = false

        resignButton.configuration = .filled()
        resignButton.setTitle("Resign", for: .normal)
        resignButton.addTarget(self, action: #selector(resignEditing), for: .touchUpInside)

        view.addSubview(listView)
        view.addSubview(bottomBarView)
        bottomBarView.addSubview(bottomBarBlurView)
        bottomBarView.addSubview(resignButton)

        NSLayoutConstraint.activate([
            listView.topAnchor.constraint(equalTo: view.topAnchor),
            listView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            listView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            listView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            bottomBarView.topAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -floatingBarHeight),
            bottomBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            bottomBarBlurView.topAnchor.constraint(equalTo: bottomBarView.topAnchor),
            bottomBarBlurView.leadingAnchor.constraint(equalTo: bottomBarView.leadingAnchor),
            bottomBarBlurView.trailingAnchor.constraint(equalTo: bottomBarView.trailingAnchor),
            bottomBarBlurView.bottomAnchor.constraint(equalTo: bottomBarView.bottomAnchor),

            resignButton.topAnchor.constraint(equalTo: bottomBarView.topAnchor, constant: 16.0),
            resignButton.centerXAnchor.constraint(equalTo: bottomBarView.safeAreaLayoutGuide.centerXAnchor),
            resignButton.leadingAnchor.constraint(greaterThanOrEqualTo: bottomBarView.safeAreaLayoutGuide.leadingAnchor, constant: 20.0),
            resignButton.trailingAnchor.constraint(lessThanOrEqualTo: bottomBarView.safeAreaLayoutGuide.trailingAnchor, constant: -20.0),
            resignButton.widthAnchor.constraint(equalToConstant: 180.0),
            resignButton.heightAnchor.constraint(equalToConstant: 44.0),
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Floating Bottom Keyboard"
        keyboardDismissModeControl.selectedSegmentIndex = 2
        keyboardDismissModeControl.addTarget(self, action: #selector(keyboardDismissModeChanged), for: .valueChanged)
        navigationItem.titleView = keyboardDismissModeControl

        configureList()
    }

    @objc private func keyboardDismissModeChanged() {
        switch keyboardDismissModeControl.selectedSegmentIndex {
        case 0:
            keyboardDismissMode = .none
        case 1:
            keyboardDismissMode = .onDrag
        default:
            keyboardDismissMode = .interactive
        }

        listView.behavior.keyboardDismissMode = keyboardDismissMode
    }

    @objc private func resignEditing() {
        view.endEditing(true)
    }

    private func configureList() {
        listView.configure { list in
            list.layout = .table { layout in
                layout.stickySectionHeaders = false
                layout.bounds = .init(
                    padding: UIEdgeInsets(top: 16.0, left: 20.0, bottom: self.bottomContentSpacing, right: 20.0),
                    width: .atMost(600.0)
                )
                layout.layout.itemSpacing = 8.0
            }

            list.behavior.keyboardDismissMode = self.keyboardDismissMode
            list.behavior.keyboardAdjustmentMode = .adjustsWhenVisible
            list.behavior.keyboardAdjustmentAdditionalInsets = UIEdgeInsets(
                top: 0.0,
                left: 0.0,
                bottom: self.floatingBarHeight,
                right: 0.0
            )

            list.add {
                Section("inputs") {
                    Item(
                        TextFieldContent(
                            identifierValue: "first-field",
                            placeholder: "First field"
                        ),
                        sizing: .fixed(height: 56.0)
                    )

                    for index in 1 ... 11 {
                        Item(TextRowContent(text: "Filler row \(index)"), sizing: .fixed(height: 44.0))
                    }

                    Item(
                        TextFieldContent(
                            identifierValue: "middle-field",
                            placeholder: "Middle field"
                        ),
                        sizing: .fixed(height: 56.0)
                    )
                } header: {
                    SectionTitleContent(title: "Inputs")
                }

                Section("more-content") {
                    for index in 12 ... 21 {
                        Item(TextRowContent(text: "Filler row \(index)"), sizing: .fixed(height: 44.0))
                    }

                    Item(
                        TextFieldContent(
                            identifierValue: "last-field",
                            placeholder: "Last field"
                        ),
                        sizing: .fixed(height: 56.0)
                    )
                } header: {
                    SectionTitleContent(title: "More Content")
                }
            }
        }
    }
}

private struct SectionTitleContent: BlueprintHeaderFooterContent, Equatable {
    var title: String

    var elementRepresentation: Element {
        Label(text: title) {
            $0.font = .systemFont(ofSize: 20.0, weight: .semibold)
            $0.color = .black
        }
        .inset(by: UIEdgeInsets(top: 16.0, left: 0.0, bottom: 4.0, right: 0.0))
    }
}

private struct TextRowContent: BlueprintItemContent, Equatable {
    var text: String

    var identifierValue: String {
        text
    }

    func element(with _: ApplyItemContentInfo) -> Element {
        Label(text: text) {
            $0.font = .systemFont(ofSize: 17.0)
            $0.color = .darkGray
        }
    }
}

private struct TextFieldContent: BlueprintItemContent, Equatable {
    var identifierValue: String
    var placeholder: String

    func element(with _: ApplyItemContentInfo) -> Element {
        TextField(text: "") {
            $0.placeholder = placeholder
        }
        .inset(vertical: 8.0)
    }
}
