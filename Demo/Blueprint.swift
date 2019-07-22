//
//  Blueprint.swift
//  Listable-DemoApp
//
//  Created by Kyle Van Essen on 6/26/19.
//

import Foundation

import Blueprint
import BlueprintLayout
import BlueprintCommonControls


func Init<Value:Element>(_ value : Value, _ block : (inout Value) -> ()) -> Value
{
    var value = value
    
    block(&value)
    
    return value
}

public final class ElementView<DisplayedElement:Blueprint.Element> : UIView
{
    public var element : DisplayedElement? {
        didSet {
            self.blueprintView.element = element
        }
    }
    
    private let blueprintView : BlueprintView
    
    public override convenience init(frame: CGRect)
    {
        self.init(frame: frame, element: nil)
    }
    
    public init(frame: CGRect, element : DisplayedElement? = nil)
    {
        self.element = element
        
        self.blueprintView = BlueprintView(element: self.element)
        
        super.init(frame: frame)
        
        self.addSubview(self.blueprintView)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    public override func layoutSubviews()
    {
        super.layoutSubviews()
        
        self.blueprintView.frame = self.bounds
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize
    {
        guard let element = self.element else {
            return .zero
        }
        
        return element.measure(in: .init(size))
    }
}

struct Square : ProxyElement
{
    var box : Box
    var dimension : Dimension
    
    enum Dimension {
        case horizontal
        case vertical
    }
    
    public init(in dimension : Dimension, box : Box)
    {
        self.dimension = dimension
        self.box = box
    }
    
    
    var elementRepresentation: Element {
        return self.box
    }
    
    func measure(in constraint: SizeConstraint) -> CGSize
    {
        switch self.dimension {
        case .horizontal:
            let value = constraint.width.maximum
            return CGSize(width: value, height: value)
        case .vertical:
            let value = constraint.height.maximum
            return CGSize(width: value, height: value)
        }
    }
}


struct UniformDistributionBox<Content:Element> : ProxyElement {
    var content : Content
    
    init (_ content : Content)
    {
        self.content = content
    }
    
    var elementRepresentation: Element {
        return self.content
    }
    
    // Override measurement so we take the amount as provided by the row element.
    func measure(in constraint: SizeConstraint) -> CGSize {
        return CGSize(width: 0.0, height: 0.0)
    }
}

extension Element {
    func uniformSize() -> UniformDistributionBox<Self> {
        return UniformDistributionBox(self)
    }
}

struct Priority {
    var value : CGFloat
    
    init(_ value : CGFloat) {
        self.value = value
    }
    
    static var zeroPriority : Priority {
        return .init(0)
    }
    
    static var defaultPriority : Priority {
        return .init(1.0)
    }
}

extension Row
{
    func scaleContentToFit() -> Row
    {
        var row = self
        
        row.horizontalUnderflow = .growUniformly
        row.verticalAlignment = .fill
        
        return row
    }
}

extension Column
{
    func scaleContentToFit() -> Column
    {
        var column = self
        
        column.verticalUnderflow = .growUniformly
        column.horizontalAlignment = .fill
        
        return column
    }
}

extension StackElement
{
    static func += (lhs : inout Self, rhs : Element)
    {
        lhs.add(child: rhs)
    }
    
    static func += (lhs : inout Self, rhs : (growPriority:Priority, element:Element))
    {
        lhs.add(growPriority: rhs.growPriority.value, key: nil, child: rhs.element)
    }
}
