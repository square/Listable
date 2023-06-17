//
//  ListContentItem.swift
//  BlueprintUILists
//
//  Created by Kyle Van Essen on 6/16/23.
//

import Foundation
import ListableUI


//public protocol ListContentItem {
//
//    func asListItem(
//        id : AnyHashable?,
//        selection: ItemSelectionStyle,
//        background : @escaping (ApplyItemContentInfo) -> Element?,
//        selectedBackground : @escaping (ApplyItemContentInfo) -> Element?,
//        configure : (inout Item<WrappedElementContent<Self>>) -> ()
//    ) -> Item<WrappedElementContent<Self>>
//}


public func AsListItem<Model, ID:Hashable>(
    _ model : Model,
    identifierValue : (AsListItemReader<Model>) -> ID,
    content : @escaping (AsListItemReader<Model>, ApplyItemContentInfo) -> Element,
    background : @escaping (Model, ApplyItemContentInfo) -> Element?,
    selectedBackground : @escaping (Model, ApplyItemContentInfo) -> Element?,
    configure : (inout Item<AsListItemContent<Model, ID>>) -> ()
) -> some BlueprintItemContent {
    
    // NOTE: We need to eval all states in here to capture all reads...
    
    let reader = AsListItemReader(value: model)
    
    return AsListItemContent(
        represented: model,
        identifierValue: identifierValue(reader),
        content: content,
        background: background,
        selectedBackground: selectedBackground,
        dependencies: { reader.readKeyPaths }
    )
    
}


@dynamicMemberLookup
public final class AsListItemReader<Model> {
    
    public let value : Model
    
    fileprivate var readKeyPaths : Set<KeyPathComparator> = []
    
    init(value: Model) {
        self.value = value
    }
    
    public subscript<Value>(dynamicMember keyPath: KeyPath<AsListItemReader, Value>) -> Value {
        return self[keyPath: keyPath]
    }
    
    public subscript<Value>(dynamicMember keyPath: KeyPath<Model, Value>) -> Value {
        readKeyPaths.insert(.init(keyPath))
        return value[keyPath: keyPath]
    }
    
    public subscript<Value:Equatable>(dynamicMember keyPath: KeyPath<Model, Value>) -> Value {
        // TODO handle me...
        readKeyPaths.insert(.init(keyPath))
        return value[keyPath: keyPath]
    }
    
    public subscript<Value:LayoutEquivalent>(dynamicMember keyPath: KeyPath<Model, Value>) -> Value {
        // TODO handle me...
        readKeyPaths.insert(.init(keyPath))
        return value[keyPath: keyPath]
    }
    
    fileprivate struct KeyPathComparator : Hashable {
        
        let keyPath : PartialKeyPath<Model>
        let compare : (Model, Model) -> Bool
        
        fileprivate init(_ keyPath : KeyPath<Model, some Any>) {
            self.keyPath = keyPath
            
            compare = { lhs, rhs in
                fatalError("TODO")
            }
        }
        
        fileprivate init(_ keyPath : KeyPath<Model, some Equatable>) {
            self.keyPath = keyPath
            
            compare = { lhs, rhs in
                lhs[keyPath: keyPath] == rhs[keyPath: keyPath]
            }
        }
        
        fileprivate init(_ keyPath : KeyPath<Model, some LayoutEquivalent>) {
            self.keyPath = keyPath
            
            compare = { lhs, rhs in
                lhs[keyPath: keyPath].isEquivalent(to: rhs[keyPath: keyPath])
            }
        }
        
        func hash(into hasher: inout Hasher) {
            keyPath.hash(into: &hasher)
        }
        
        static func == (lhs : Self, rhs: Self) -> Bool {
            lhs.keyPath == rhs.keyPath
        }
    }
}


public struct AsListItemContent<Model, ID:Hashable> : BlueprintItemContent
{
    let represented : Model
    
    public let identifierValue: ID
    
    var content : (AsListItemReader<Model>, ApplyItemContentInfo) -> Element
    var background : (Model, ApplyItemContentInfo) -> Element?
    var selectedBackground : (Model, ApplyItemContentInfo) -> Element?
    
    fileprivate var dependencies : Set<AsListItemReader<Model>.KeyPathComparator>
    
    fileprivate init(
        represented: Model,
        identifierValue: ID,
        content: @escaping (AsListItemReader<Model>, ApplyItemContentInfo) -> Element,
        background: @escaping (Model, ApplyItemContentInfo) -> Element?,
        selectedBackground: @escaping (Model, ApplyItemContentInfo) -> Element?,
        dependencies: () -> Set<AsListItemReader<Model>.KeyPathComparator>
    ) {
        self.represented = represented
        self.identifierValue = identifierValue
        self.content = content
        self.background = background
        self.selectedBackground = selectedBackground
        self.dependencies = dependencies()
    }
    
    public func isEquivalent(to other: Self) -> Bool {
        for comparator in dependencies {
            if comparator.compare(represented, other.represented) == false {
                return false
            }
        }
        
        return true
    }
    
    public func element(with info: ApplyItemContentInfo) -> Element {
        fatalError()
    }
    
    public func backgroundElement(with info: ApplyItemContentInfo) -> Element? {
        fatalError()
    }
    
    public func selectedBackgroundElement(with info: ApplyItemContentInfo) -> Element? {
        fatalError()
    }
}

