//
//  AccordionViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 8/10/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//

import BlueprintUICommonControls
import BlueprintUILists

final class AccordionViewController: ListViewController {
    var expandedSectionIndex: Int = 1

    override func configure(list: inout ListProperties) {
        list.add {
            for sectionIndex in 1 ... 10 {
                Section(sectionIndex) {
                    if expandedSectionIndex == sectionIndex {
                        for itemIndex in 1 ... sectionIndex {
                            Item(AccordionRow(text: "Row #\(sectionIndex), \(itemIndex)")) {
                                $0.insertAndRemoveAnimations = .fade
                            }
                        }
                    }
                } header: {
                    HeaderFooter(
                        AccordionHeader(text: "Section Header #\(sectionIndex)"),
                        onTap: {
                            self.expandedSectionIndex = sectionIndex
                            self.reload(animated: true)
                        }
                    )
                }
            }
        }
    }
}

private struct AccordionHeader: BlueprintHeaderFooterContent, Equatable {
    var text: String

    var elementRepresentation: Element {
        Label(text: text) {
            $0.alignment = .left
            $0.font = .systemFont(ofSize: 18.0, weight: .semibold)
        }
        .inset(horizontal: 20.0, vertical: 10.0)
        .constrainedTo(height: .atLeast(80.0))
    }

    var background: Element? {
        self.background(with: .white)
    }

    var pressedBackground: Element? {
        background(with: .white(0.9))
    }

    private func background(with color: UIColor) -> Element {
        Overlay(
            elements: [
                Box(backgroundColor: color),

                Box(backgroundColor: .init(white: 0.85, alpha: 1.0))
                    .constrainedTo(height: .absolute(1.0))
                    .aligned(vertically: .bottom, horizontally: .fill),
            ]
        )
    }
}

private struct AccordionRow: BlueprintItemContent, Equatable {
    var text: String

    var identifierValue: String {
        text
    }

    func element(with _: ApplyItemContentInfo) -> Element {
        Label(text: text) {
            $0.alignment = .left
            $0.font = .systemFont(ofSize: 16.0, weight: .regular)
        }
        .inset(horizontal: 20.0, vertical: 10.0)
        .constrainedTo(height: .atLeast(60.0))
    }

    func backgroundElement(with _: ApplyItemContentInfo) -> Element? {
        Overlay(
            elements: [
                Box(backgroundColor: .white),
                Box(backgroundColor: .init(white: 0.90, alpha: 1.0))
                    .constrainedTo(height: .absolute(1.0))
                    .aligned(vertically: .bottom, horizontally: .fill),
            ]
        )
    }
}
