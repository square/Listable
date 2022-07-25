//
//  ListPerformanceTesting.swift
//  BlueprintUILists-Unit-Tests
//
//  Created by Kyle Van Essen on 4/5/21.
//

import Foundation

import BlueprintUI
import BlueprintUILists
import XCTest

class ListPerformanceTesting: XCTestCase {
    override func invokeTest() {
        // Uncomment to be able to run perf testing.
        // super.invokeTest()
    }

    func test_applying_same_elements() {
        let list = List { list in
            list("section") { section in
                section += (1 ... 10).map { index in
                    Content(title: "\(index)")
                }
            }
        }

        let view = BlueprintView()
        view.frame.size = CGSize(width: 400, height: 2000)

        determineAverage(for: 10) {
            view.element = list
            view.layoutIfNeeded()
        }
    }
}

private struct Content: BlueprintItemContent, Equatable {
    var title: String

    var identifierValue: String {
        title
    }

    func element(with _: ApplyItemContentInfo) -> Element {
        Column { col in
            col.add(child: Column { col in
                col.add(child: Column { col in
                    col.add(child: Column { col in
                        col.add(child: Column { col in
                            col.add(child: Column { col in
                                col.add(child: Column { col in
                                    col.add(child: Column { col in
                                        col.add(child: Column { col in
                                            col.add(child: Column { col in
                                                col.add(child: Column { col in
                                                    col.add(child: Label(text: "This is some text that is in a thing"))
                                                })
                                            })
                                        })
                                    })
                                })
                            })
                        })
                    })
                })
            })
        }
    }

    var reappliesToVisibleView: ReappliesToVisibleView {
        .ifNotEquivalent
    }
}

private struct Label: UIViewElement {
    var text: String

    func makeUIView() -> UILabel {
        UILabel()
    }

    func updateUIView(_ view: UILabel, with _: UIViewElementContext) {
        view.text = text
    }
}
