//
//  PresentationState+Fixtures.swift
//  ListableUI-Unit-Tests
//
//  Created by Kyle Van Essen on 6/10/21.
//

@testable import ListableUI


extension PresentationState {
    
    convenience init(_ content : (inout Content) -> () = { _ in }) {
        self.init(
            forMeasuringOrTestsWith: Content(with: content),
            environment: .empty,
            itemMeasurementCache: .init(),
            headerFooterMeasurementCache: .init()
        )
    }
    
    func toListLayoutContent() -> ListLayoutContent {
        self.toListLayoutContent(defaults: .testing, environment: .empty)
    }
}


extension PresentationState.SectionState {
    
    convenience init(_ section : Section) {
        self.init(
            with: section,
            dependencies: ItemStateDependencies(
                reorderingDelegate: ReorderingActionsDelegateMock(),
                coordinatorDelegate: ItemContentCoordinatorDelegateMock(),
                environmentProvider: { .empty }
            ),
            updateCallbacks: UpdateCallbacks(.immediate, wantsAnimations: false),
            performsContentCallbacks: true
        )
    }
}


extension PresentationState.HeaderFooterState {
    
    convenience init(_ headerFooter : HeaderFooter<Content>) {
        self.init(headerFooter, kind: .sectionHeader, performsContentCallbacks: true)
    }
}


extension PresentationState.ItemState {
    
    convenience init(_ item : Item<Content>) {
        self.init(
            with: item,
            dependencies: ItemStateDependencies(
                reorderingDelegate: ReorderingActionsDelegateMock(),
                coordinatorDelegate: ItemContentCoordinatorDelegateMock(),
                environmentProvider: { .empty }
            ),
            updateCallbacks: UpdateCallbacks(.immediate, wantsAnimations: false),
            performsContentCallbacks: true
        )
    }
}


final class ItemContentCoordinatorDelegateMock : ItemContentCoordinatorDelegate
{
    var coordinatorUpdated_calls = [AnyItem]()
    
    func coordinatorUpdated(for item: AnyItem)
    {
        self.coordinatorUpdated_calls.append(item)
    }
}


final class ReorderingActionsDelegateMock : ReorderingActionsDelegate
{
    func beginReorder(for item: AnyPresentationItemState) -> Bool { true }
    
    func updateReorderTargetPosition(
        with recognizer: ItemReordering.GestureRecognizer,
        for item: AnyPresentationItemState
    ) {}
    
    func endReorder(for item: AnyPresentationItemState, with result: ReorderingActions.Result) {}
    
    func accessibilityMove(item: AnyPresentationItemState, direction: ReorderingActions.AccessibilityMoveDirection) -> Bool { true }
}
