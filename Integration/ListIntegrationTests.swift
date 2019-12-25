//
//  ListIntegrationTests.swift
//  Listable-Unit-Tests
//
//  Created by Kyle Van Essen on 12/23/19.
//

import XCTest
import Snapshot

@testable import Listable


class ListIntegrationTests : XCTestCase
{
    func test_empty()
    {
        self.testEach { view in
            
        }
    }
    
    func test_underflow()
    {
        let content = Content { list in
            list += Section(identifier: 1) { section in
                
                section.header = HeaderFooter(with: SimpleHeader(content: "First Header"), sizing: .thatFits)
                
                section += Item(with: SimpleRow(content: "First Row"), sizing: .thatFits)
                section += Item(with: SimpleRow(content: "Second Row"), sizing: .thatFits)
                
                section.footer = HeaderFooter(
                    with: SimpleFooter(content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur sit amet lacus velit."),
                    sizing: .thatFits
                )
            }
            
            list += Section(identifier: 2) { section in
                
                section.header = HeaderFooter(with: SimpleHeader(content: "Second Header"), sizing: .thatFits)
                
                section += Item(with: SimpleRow(content: "First Row"), sizing: .thatFits)
                section += Item(with: SimpleRow(content: "Second Row"), sizing: .thatFits)
                section += Item(with: SimpleRow(content: "Third Row"), sizing: .thatFits)
                
                section.footer = HeaderFooter(
                    with: SimpleFooter(content: "Aliquam volutpat lorem vitae accumsan luctus. Nam scelerisque ante id diam sollicitudin sodales."),
                    sizing: .thatFits
                )
            }
        }
        
        self.testEach(testCase: "top") { view in
            view.setContent(content)
            view.appearance.underflow.alignment = .top
        }
        
        self.testEach(testCase: "center") { view in
            view.setContent(content)
            view.appearance.underflow.alignment = .center
        }
        
        self.testEach(testCase: "bottom") { view in
            view.setContent(content)
            view.appearance.underflow.alignment = .bottom
        }
    }
    
    func test_overflow()
    {
        self.testEach { view in
            
            
            
        }
    }
    
    func test_overscroll()
    {
        self.testEach { view in
            
            
            
        }
    }
    
    private var baseAppearance : Appearance
    {
        return Appearance()
    }
    
    private var plainAppearance : Appearance
    {
        return self.baseAppearance
    }
    
    private var groupedAppearance : Appearance
    {
        var appearance = self.baseAppearance
        
        appearance.layout.set {
            $0.padding = UIEdgeInsets(top: 30.0, left: 30.0, bottom: 30.0, right: 30.0)
            $0.itemSpacing = 10.0
            $0.interSectionSpacingWithFooter = 30.0
            $0.interSectionSpacingWithNoFooter = 30.0
            $0.sectionHeaderBottomSpacing = 5.0
            $0.itemToSectionFooterSpacing = 5.0
        }
        
        appearance.set { _ in
            
        }
        
        return appearance
    }
    
    private func testEach(
        testCase : String? = nil,
        testFilePath : StaticString = #file,
        functionName : StaticString = #function,
        line : UInt = #line,
        test : (ListView) -> ()
    )
    {
        let views : [(String, ListView)] = [
            ("Plain", ListView(frame: .zero, appearance: self.plainAppearance)),
            ("Grouped", ListView(frame: .zero, appearance: self.groupedAppearance)),
        ]
        
        for view in views {
            UIView.performWithoutAnimation {
                test(view.1)
                
                self.snapshot(
                    view: view.1,
                    listType: view.0,
                    testCase: testCase,
                    testFilePath: testFilePath,
                    functionName: functionName,
                    line: line
                )
            }
        }
    }
    
    private func snapshot(
        view : UIView,
        listType : String,
        testCase: String?,
        testFilePath : StaticString,
        functionName : StaticString,
        line : UInt
    )
    {
        let devices = [
            iOSDevice.iPhoneXsMax,
            //iOSDevice.iPhone8Plus
        ].availableOnCurrentSystemVersion()
        
        let hostingView = UIApplication.shared.delegate!.window!!.rootViewController!.view!
        
        let snapshot = Snapshot(
            iterations: devices.map { iOSDeviceIteration(with: hostingView, device: $0) },
            test: { _ in view }
        )
        
        let fullCase = [listType, testCase].compactMap { $0 }.joined(separator: ".")
        
        snapshot.test(output: ViewImageSnapshot.self, testCase: fullCase, testFilePath: testFilePath, functionName: functionName, line:line)
        snapshot.test(output: ViewHierarchySnapshot.self, testCase: fullCase, testFilePath: testFilePath, functionName: functionName, line:line)
    }
    
    func test_dummy()
    {
        
    }
}

fileprivate struct SimpleRow : ItemElement, ItemElementAppearance, Equatable
{
    var content : String
    
    // MARK: ItemElement
    
    typealias Appearance = Self
    
    var identifier: Identifier<SimpleRow> {
        return .init(self.content)
    }
    
    func apply(to view: ContentView, for reason: ApplyReason, with info: ApplyItemElementInfo)
    {
        view.label.text = self.content
    }
    
    // MARK: ItemElementAppearance

    typealias ContentView = LabelView
    
    func apply(to view: ContentView, with info: ApplyItemElementInfo)
    {
        // Nothing required.
    }
    
    static func createReusableItemView(frame: CGRect) -> ContentView
    {
        return LabelView {
            $0.font = .systemFont(ofSize: 16.0, weight: .semibold)
        }
    }
}

fileprivate struct SimpleHeader : HeaderFooterElement, HeaderFooterElementAppearance, Equatable
{
    var content : String
    
    // MARK: HeaderFooterElement
    
    typealias Appearance = Self
    
    func apply(to view: LabelView, reason: ApplyReason)
    {
        view.label.text = self.content
    }
    
    // MARK: HeaderFooterElementAppearance

    typealias ContentView = LabelView
    
    static func createReusableHeaderFooterView(frame: CGRect) -> LabelView
    {
        return LabelView {
            $0.font = .systemFont(ofSize: 18.0, weight: .bold)
        }
    }
    
    func apply(to view: LabelView)
    {
        // Nothing required.
    }
}

fileprivate struct SimpleFooter : HeaderFooterElement, HeaderFooterElementAppearance, Equatable
{
    var content : String
    
    // MARK: HeaderFooterElement
    
    typealias Appearance = Self
    
    func apply(to view: LabelView, reason: ApplyReason)
    {
        view.label.text = self.content
    }
    
    // MARK: HeaderFooterElementAppearance

    typealias ContentView = LabelView
    
    static func createReusableHeaderFooterView(frame: CGRect) -> LabelView
    {
        return LabelView {
            $0.font = .systemFont(ofSize: 12.0, weight: .regular)
            $0.textAlignment = .center
            $0.textColor = .darkGray
        }
    }
    
    func apply(to view: LabelView)
    {
        // Nothing required.
    }
}

final class LabelView : UIView
{
    let label : UILabel
    
    private let padding = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    
    init(_ block : (UILabel) -> ())
    {
        self.label = UILabel()
        self.label.numberOfLines = 0
        
        super.init(frame: .zero)
        
        self.addSubview(self.label)
        
        self.backgroundColor = .init(white: 0.95, alpha: 1.0)
        self.label.backgroundColor = .init(white: 0.85, alpha: 1.0)
        
        block(self.label)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize
    {
        let fittingSize = CGSize(
            width: size.width - self.padding.left - self.padding.right,
            height: .greatestFiniteMagnitude
        )
        
        let labelSize = self.label.sizeThatFits(fittingSize)
        
        return CGSize(
            width: size.width,
            height: labelSize.height + self.padding.top + self.padding.bottom
        )
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        self.label.frame = self.bounds.inset(by: self.padding)
    }
}
