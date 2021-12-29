//
//  ViewHeaderFooterContent.swift
//  SwiftUILists
//
//  Created by Kyle Van Essen on 10/22/19.
//

import ListableUI
import SwiftUI


@available(iOS 13.0, *)
public protocol ViewHeaderFooterContent : HeaderFooterContent
where
ContentView == SwiftUIContentView,
BackgroundView == SwiftUIContentView,
PressedBackgroundView == SwiftUIContentView
{
    //
    // MARK: Creating SwiftUI View Representations
    //
    
    associatedtype ContentType : SwiftUI.View
    associatedtype BackgroundType : SwiftUI.View
    associatedtype PressedBackgroundType : SwiftUI.View
    
    var body : ContentType { get }
    var background : BackgroundType { get }
    var pressedBackground : PressedBackgroundType { get }
}


@available(iOS 13.0, *)
public extension ViewHeaderFooterContent
{
    //
    // MARK: HeaderFooterContent
    //
    
    func apply(
        to views: HeaderFooterContentViews<Self>,
        for reason: ApplyReason,
        with info: ApplyHeaderFooterContentInfo
    ) {
        views.content.rootView = AnyView(self.body)
        views.background.rootView = AnyView(self.background)
        views.pressed.rootView = AnyView(self.pressedBackground)
    }
    
    static func createReusableHeaderFooterView(frame: CGRect) -> ContentView {
        SwiftUIContentView(frame: frame)
    }
    
    static func createReusableBackgroundView(frame: CGRect) -> BackgroundView {
        SwiftUIContentView(frame: frame)
    }
    
    static func createReusablePressedBackgroundView(frame: CGRect) -> PressedBackgroundView {
        SwiftUIContentView(frame: frame)
    }
}

