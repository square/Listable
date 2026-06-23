//
//  ApproachingBottomPaginationViewController.swift
//  Demo
//
//  Created by OpenAI Codex on 2026-04-24.
//

import ListableUI
import BlueprintUILists
import BlueprintUI
import BlueprintUICommonControls
import UIKit


final class ApproachingBottomPaginationViewController : ListViewController
{
    private let actions = ListActions()

    private let pageSize = 20
    private let maxPageCount = 5

    private var items : [DemoItem] = []
    private var nextItemNumber = 1
    private var loadedPageCount = 0
    private var approachingBottomCallCount = 0
    private var isLoadingNextPage = false

    private var loadTask : Task<Void, Never>?

    private var hasMorePages : Bool {
        self.loadedPageCount < self.maxPageCount
    }

    deinit {
        self.loadTask?.cancel()
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.title = "Approaching Bottom"

        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetDemo)),
            UIBarButtonItem(title: "Bottom", style: .plain, target: self, action: #selector(scrollToBottom)),
        ]

        self.reset()
    }

    override func configure(list : inout ListProperties)
    {
        list.appearance = .demoAppearance
        list.layout = .demoLayout()
        list.actions = self.actions

        list.content.header = DemoHeader(
            title: "Approaching Bottom Pagination",
            detail: """
            Uses `onApproachingBottom(within: .screens(1.0))` to load the next page as the list nears its rendered end.
            Pages: \(loadedPageCount)/\(maxPageCount)
            Observer Calls: \(approachingBottomCallCount)
            Loading: \(isLoadingNextPage ? "Yes" : "No")
            """
        )

        list.stateObserver = ListStateObserver { observer in
            observer.onApproachingBottom(
                within: .screens(1.0),
                shouldPerform: { [weak self] _ in
                    guard let self = self else { return false }
                    return self.isLoadingNextPage == false && self.hasMorePages
                }
            ) { [weak self] _ in
                self?.approachingBottomCallCount += 1
                self?.loadNextPage()
            }
        }

        list("items") { section in
            for item in self.items {
                section += item
            }

            if self.isLoadingNextPage {
                section += PaginationLoadingItem(identifierValue: "loading-next-page")
            } else if self.hasMorePages == false {
                section.footer = DemoFooter(text: "Reached the end of the demo list.")
            }
        }
    }

    @objc private func resetDemo()
    {
        self.reset()
    }

    @objc private func scrollToBottom()
    {
        self.actions.scrolling.scrollToLastItem(animated: true)
    }

    private func reset()
    {
        self.loadTask?.cancel()
        self.loadTask = nil

        self.items = []
        self.nextItemNumber = 1
        self.loadedPageCount = 0
        self.approachingBottomCallCount = 0
        self.isLoadingNextPage = false

        self.appendPage()
        self.reload(animated: false)
    }

    private func loadNextPage()
    {
        guard self.isLoadingNextPage == false else { return }
        guard self.hasMorePages else { return }

        self.isLoadingNextPage = true
        self.reload(animated: true)

        self.loadTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 1_000_000_000)

            guard let self = self else { return }
            guard Task.isCancelled == false else { return }

            self.isLoadingNextPage = false
            self.appendPage()
            self.reload(animated: true)
            self.loadTask = nil
        }
    }

    private func appendPage()
    {
        let end = self.nextItemNumber + self.pageSize

        for itemNumber in self.nextItemNumber..<end {
            self.items.append(DemoItem(text: "Item #\(itemNumber)"))
        }

        self.nextItemNumber = end
        self.loadedPageCount += 1
    }
}


fileprivate struct PaginationLoadingItem : BlueprintItemContent, Equatable
{
    var identifierValue : String

    func element(with info : ApplyItemContentInfo) -> Element
    {
        Row(alignment: .center, minimumSpacing: 10.0) {
            PaginationActivityIndicatorElement()
            Label(text: "Loading next page…") {
                $0.font = .systemFont(ofSize: 17.0, weight: .medium)
                $0.color = .darkGray
            }
        }
        .inset(horizontal: 15.0, vertical: 13.0)
    }

    func backgroundElement(with info: ApplyItemContentInfo) -> Element?
    {
        Box(
            backgroundColor: .white,
            cornerStyle: .rounded(radius: 8.0)
        )
    }
}

fileprivate struct PaginationActivityIndicatorElement : UIViewElement {
    func makeUIView() -> UIActivityIndicatorView
    {
        UIActivityIndicatorView(style: .medium)
    }

    func updateUIView(_ view: UIActivityIndicatorView, with context: UIViewElementContext)
    {
        if context.isMeasuring == false && view.isAnimating == false {
            view.startAnimating()
        }
    }
}
