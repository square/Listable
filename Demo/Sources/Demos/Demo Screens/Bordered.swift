//
//  Bordered.swift
//  Demo
//
//  Created by Thomas Abend on 12/5/22.
//  Copyright © 2022 Kyle Van Essen. All rights reserved.
//

import ListableUI
import BlueprintUILists
import BlueprintUI
import BlueprintUICommonControls

/// Indicates a Border to be drawn around a view
enum Border: Equatable {
    /// Draw a border around the sides and top of the view
    case top
    /// Draw a border on the sides of the view
    case middle
    /// Draw a border on the sides and bottom of the view
    case bottom
    /// Draw a border entirely around the view
    case all
    /// Draw a border on only the bottom of the view
    case flatBottom
    /// Draw no border on the view
    case none
}

extension Border {
    /// The Corners that correspond with this Border
    var corners: Box.CornerStyle.Corners {
        switch self {
        case .top:
            return .top
        case .middle:
            return []
        case .bottom:
            return .bottom
        case .all:
            return .all
        case .flatBottom:
            return []
        case .none:
            return []
        }
    }
}


extension Element {

    /// Wraps the element in a Border
    func bordered(
        _ border: Border,
        style: BorderStyle
    ) -> Element {
        bordered(
            border,
            color: style.color,
            width: style.width,
            cornerRadius: style.cornerRadius
        )
    }

    /// Wraps the element in a Border
    func bordered(
        _ border: Border = .all,
        color: UIColor = .clear,
        width: CGFloat = 2,
        cornerRadius: CGFloat = 0
    ) -> Element {
        BorderElement(
            border: border,
            color: color,
            width: width,
            cornerRadius: cornerRadius,
            wrapping: self
        )
    }
}

/// A simple element that wraps a child element and adds visual styling to the border of that element.
/// Use `Element.addBorder` rather than using this Element directly
private struct BorderElement: Element {
    var border: Border
    var color: UIColor
    var width: CGFloat
    var cornerRadius: CGFloat = 6
    var wrappedElement: Element

    init(
        border: Border,
        color: UIColor,
        width: CGFloat,
        cornerRadius: CGFloat,
        wrapping element: Element
    ) {
        self.border = border
        self.color = color
        self.width = width
        self.cornerRadius = cornerRadius

        wrappedElement = element
    }

    var content: ElementContent {
        ElementContent(child: wrappedElement)
    }

    func backingViewDescription(with context: ViewDescriptionContext) -> ViewDescription? {
        BorderView.describe { config in

            config.apply { view in
                view.radius = cornerRadius
                view.color = color
                view.border = border
                view.width = width
            }

            config.contentView = { view in
                view.contentView
            }
        }
    }
}

private class BorderView: UIView {
    let contentView = UIView()

    var radius: CGFloat = 0
    var color: UIColor = .clear
    var width: CGFloat = 2
    var border: Border = .none {
        didSet {
            setNeedsLayout()
        }
    }

    private var shape = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.frame = bounds
        addSubview(contentView)
        contentView.layer.addSublayer(shape)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = bounds
        let path = UIBezierPath(
            borderedRect: bounds(for: border),
            border: border,
            cornerRadius: radius
        )
        shape.path = path.cgPath
        shape.strokeColor = color.cgColor
        shape.lineWidth = width
        shape.lineCap = .round
        shape.fillColor = UIColor.clear.cgColor
    }

    func bounds(for border: Border) -> CGRect {
        switch border {
        case .top, .middle, .bottom, .all, .none:
            return bounds
        case .flatBottom:
            return bounds.insetBy(dx: radius, dy: 0)
        }
    }
}


/// Holds a list of `BorderedSection`s that we might want to draw an Outer or Background Border around.
/// Some containers might just have a single section, while others will have several sub-sections.
struct BorderedContainer {
    struct Properties {
        /// Whether the background style will be applied to this container
        var isBackgroundEnabled: Bool = false
        /// Whether the outer border will be applied to this container
        var isOuterBorderEnabled: Bool = true
        /// Whether the selection border will be applied to selected sections in this container
        var isSelectionBorderEnabled: Bool = false

        typealias Configure = (inout Properties) -> Void

        /// An instance of `ListProperties` with sensible default values.
        static func `default`(
            with configure: Configure = { _ in }
        ) -> Self {
            Self(
                isBackgroundEnabled: false,
                isOuterBorderEnabled: true,
                isSelectionBorderEnabled: false,
                configure: configure
            )
        }

        /// Create a new instance of `ListProperties` with the provided values.
        init(
            isBackgroundEnabled: Bool,
            isOuterBorderEnabled: Bool,
            isSelectionBorderEnabled: Bool,
            configure: Configure
        ) {
            self.isBackgroundEnabled = isBackgroundEnabled
            self.isOuterBorderEnabled = isOuterBorderEnabled
            self.isSelectionBorderEnabled = isSelectionBorderEnabled

            configure(&self)
        }
    }

    let sections: [BorderedSection]
    let properties: Properties

    init(configure: Properties.Configure = { _ in () }, sections: [BorderedSection]) {
        properties = .default(with: configure)
        self.sections = sections
    }

    init(
        configure: Properties.Configure = { _ in () },
        @ListableBuilder<BorderedSection> sections: () -> [BorderedSection]
    ) {
        properties = .default(with: configure)
        self.sections = sections()
    }
}

/// Holds a list of `BorderedItem`s that it can display. Can render a Selection Border to indicate that the Section is Selected within its Container.
struct BorderedSection {

    let id: String
    let isSelected: Bool
    let drawsBottomBorder: Bool
    let items: [BorderedItem]

    init(
        _ id: String,
        isSelected: Bool = false,
        drawsBottomBorder: Bool = false,
        @ListableBuilder<BorderedItem> items: () -> [BorderedItem]
    ) {
        self.id = id
        self.isSelected = isSelected
        self.drawsBottomBorder = drawsBottomBorder
        self.items = items()
    }

    init(
        _ id: String,
        isSelected: Bool = false,
        drawsBottomBorder: Bool = false,
        items: [BorderedItem]
    ) {
        self.id = id
        self.isSelected = isSelected
        self.drawsBottomBorder = drawsBottomBorder
        self.items = items
    }
}

/// An item that can be displayed in a `BorderedList`
protocol BorderedItem {
    var identifierValue: String { get }
    func element(with info: ApplyItemContentInfo) -> Element
    func isEquivalent(to other: BorderedItem) -> Bool
}

/// Context object that the BorderedList uses to figure out what Borders an Item should draw based on preferences and its position within the list.
struct BorderContext {
    let item: BorderedItem
    let itemIndex: Int
    let section: BorderedSection
    let sectionIndex: Int
    let container: BorderedContainer
    let containerIndex: Int

    /// The selectionBorder to draw for this Item
    var selectionBorder: Border {
        guard container.properties.isSelectionBorderEnabled, section.isSelected else { return .none }
        if section.items.count == 1 { return .all }
        if itemIndex == 0 { return .top }
        if itemIndex == section.items.count - 1 { return .bottom }
        return .middle
    }

    var separatorBorder: Border {
        return drawBottomBorder ? .flatBottom : .none
    }

    /// The outerBorder to draw for this Item
    var outerBorder: Border {
        guard container.properties.isOuterBorderEnabled else {
            return .none
        }
        return _border
    }

    /// The backgroundBorder to draw for this Item
    var backgroundBorder: Border {
        guard container.properties.isBackgroundEnabled else {
            return .none
        }
        return _border
    }

    private var drawBottomBorder: Bool {
        guard section.drawsBottomBorder else { return false }
        // don't draw the flatBottom selection border on the bottom of the container
        if sectionIndex == container.sections.count - 1 { return false }
        // don't draw the flatBottom if the next section is selected
        if sectionIndex + 1 < container.sections.count && container.sections[sectionIndex + 1].isSelected { return false }
        return itemIndex == section.items.count - 1
    }

    private var _border: Border {
        if container.sections.count == 1 && section.items.count == 1 {
            return .all
        }
        if itemIndex == 0 && sectionIndex == 0 {
            return .top
        }
        if sectionIndex == container.sections.count - 1 && itemIndex == section.items.count - 1 {
            return .bottom
        }
        return .middle
    }

    /// Returns if the two context's draw the same Borders
    func drawsSameBorders(as other: BorderContext) -> Bool {
        selectionBorder == other.selectionBorder &&
            outerBorder == other.outerBorder &&
            backgroundBorder == other.backgroundBorder
    }
}



struct BorderedList: ProxyElement {
    typealias Style = BorderedListStyle

    let style: Style
    let scrollToID: String?
    let containers: [BorderedContainer]

    typealias SectionPath = (container: Int, section: Int)

    init(
        style: Style,
        scrollToID: String? = nil,
        containers: [BorderedContainer]
    ) {
        self.style = style
        self.scrollToID = scrollToID
        self.containers = containers
    }

    init(
        style: Style,
        scrollToID: String? = nil,
        @ListableBuilder<BorderedContainer> containers: () -> [BorderedContainer]
    ) {
        self.style = style
        self.scrollToID = scrollToID
        self.containers = containers()
    }

    var elementRepresentation: Element {
        List { props in
            props.appearance.showsScrollIndicators = false
            props.animatesChanges = true
            props.appearance.backgroundColor = style.backgroundColor
            if let scrollToID = scrollToID {
                props.autoScrollAction = .scrollTo(
                    .item(BorderedItemView.identifier(with: scrollToID)),
                    onInsertOf: BorderedItemView.identifier(with: scrollToID),
                    position: .init(position: .centered),
                    animation: .default
                )
            }
        } sections: {
            for (containerIndex, container) in containers.enumerated() {
                renderContainer(container: container, at: containerIndex)
            }
        }
    }

    func renderContainer(
        container: BorderedContainer,
        at containerIndex: Int
    ) -> [Section] {
        container.sections.enumerated().map { index, section in
            renderSection(section: section, at: index, in: container, at: containerIndex)
        }
    }

    func renderSection(
        section: BorderedSection,
        at sectionIndex: Int,
        in container: BorderedContainer,
        at containerIndex: Int
    ) -> Section {
        let layouts = SectionLayouts.table { table in
            if sectionIndex == container.sections.count - 1 {
                table.customInterSectionSpacing = style.interContainerSpacing
            }
        }
        return Section(section.id, layouts: layouts) {
            section.items.enumerated().map { itemIndex, item in
                BorderedItemView(
                    content: item,
                    context: BorderContext(
                        item: item,
                        itemIndex: itemIndex,
                        section: section,
                        sectionIndex: sectionIndex,
                        container: container,
                        containerIndex: containerIndex
                    ),
                    style: style
                )
                .with(swipeActions: .init(action: SwipeAction.init(title: "done", backgroundColor: .red, handler: { done in
                    print("<TA> wha-bam")
                })))
            }
        }
    }
}

struct BorderStyle: Equatable {
    let color: UIColor
    let width: CGFloat
    let cornerRadius: CGFloat
}

struct ContainerBackgroundStyle: Equatable {
    let color: UIColor
    let cornerRadius: CGFloat
}

struct BorderedListStyle: Equatable {
    let backgroundColor: UIColor
    let outerBorder: BorderStyle
    let selectionBorder: BorderStyle
    let flatBottomSelectionBorder: BorderStyle
    let containerBackground: ContainerBackgroundStyle
    let interContainerSpacing: CGFloat
}

import Foundation

extension UIBezierPath {

    convenience init(borderedRect: CGRect, border: Border, cornerRadius radius: CGFloat) {
        self.init()
        switch border {
        case .top:
            move(to: borderedRect.corner(.bottomLeft))
            addLine(to: borderedRect.corner(.topLeft).translate(dy: radius))
            addClockwiseCorner(.topLeft, radius: radius)
            addLine(to: borderedRect.corner(.topRight).translate(dx: -radius))
            addClockwiseCorner(.topRight, radius: radius)
            addLine(to: borderedRect.corner(.bottomRight))
        case .bottom:
            move(to: borderedRect.corner(.topRight))
            addLine(to: borderedRect.corner(.bottomRight).translate(dy: -radius))
            addClockwiseCorner(.bottomRight, radius: radius)
            addLine(to: borderedRect.corner(.bottomLeft).translate(dx: radius))
            addClockwiseCorner(.bottomLeft, radius: radius)
            addLine(to: borderedRect.corner(.topLeft))
        case .middle:
            move(to: borderedRect.corner(.topLeft))
            addLine(to: borderedRect.corner(.bottomLeft))

            move(to: borderedRect.corner(.topRight))
            addLine(to: borderedRect.corner(.bottomRight))
        case .all:
            move(to: borderedRect.corner(.bottomLeft).translate(dy: -radius))
            addLine(to: borderedRect.corner(.topLeft).translate(dy: radius))
            addClockwiseCorner(.topLeft, radius: radius)
            addLine(to: borderedRect.corner(.topRight).translate(dx: -radius))
            addClockwiseCorner(.topRight, radius: radius)
            addLine(to: borderedRect.corner(.bottomRight).translate(dx: 0, dy: -radius))
            addClockwiseCorner(.bottomRight, radius: radius)
            addLine(to: borderedRect.corner(.bottomLeft).translate(dx: radius, dy: 0))
            addClockwiseCorner(.bottomLeft, radius: radius)
        case .flatBottom:
            move(to: borderedRect.corner(.bottomLeft))
            addLine(to: borderedRect.corner(.bottomRight))
        case .none:
            break
        }
    }

    private func addClockwiseCorner(_ corner: Corner, radius: CGFloat) {
        switch corner {
        case .topLeft:
            addArc(
                withCenter: currentPoint.translate(dx: radius, dy: 0),
                radius: radius,
                startAngle: .pi,
                endAngle: 3 * .pi / 2,
                clockwise: true
            )
        case .topRight:
            addArc(
                withCenter: currentPoint.translate(dx: 0, dy: radius),
                radius: radius,
                startAngle: 3 * .pi / 2,
                endAngle: 0,
                clockwise: true
            )
        case .bottomRight:
            addArc(
                withCenter: currentPoint.translate(dx: -radius, dy: 0),
                radius: radius,
                startAngle: 0,
                endAngle: .pi / 2,
                clockwise: true
            )
        case .bottomLeft:
            addArc(
                withCenter: currentPoint.translate(dx: 0, dy: -radius),
                radius: radius,
                startAngle: .pi / 2,
                endAngle: .pi,
                clockwise: true
            )
        }
    }

}

fileprivate extension CGRect {
    /// Return the point for a corner of a rectangle
    func corner(_ corner: Corner) -> CGPoint {
        switch corner {
        case .topLeft:
            return CGPoint(x: minX, y: minY)
        case .topRight:
            return CGPoint(x: maxX, y: minY)
        case .bottomRight:
            return CGPoint(x: maxX, y: maxY)
        case .bottomLeft:
            return CGPoint(x: minX, y: maxY)
        }
    }
}

/// A corner of a rectangle
private enum Corner {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}

fileprivate extension CGPoint {
    func translate(dx: CGFloat = 0, dy: CGFloat = 0) -> CGPoint {
        .init(x: x + dx, y: y + dy)
    }
}
