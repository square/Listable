//
//  CollectionViewAppearance.swift
//  Demo
//
//  Created by Kyle Van Essen on 10/20/19.
//  Copyright © 2019 Kyle Van Essen. All rights reserved.
//

import Listable


let defaultAppearance = Appearance {
    $0.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
                
    $0.contentLayout = ListContentLayout(
        padding: UIEdgeInsets(top: 30.0, left: 15.0, bottom: 30.0, right: 15.0),
        width: .atMost(500.0),
        interSectionSpacingWithNoFooter: 20.0,
        interSectionSpacingWithFooter: 20.0,
        sectionHeaderBottomSpacing: 10.0,
        rowSpacing: 5.0,
        rowToSectionFooterSpacing: 10.0,
        usesStickySectionHeaders: true
    )
}

struct ItemAppearance<ContentView:UIView> : ItemElementAppearance
{
    typealias BackgroundView = UIView
    typealias SelectedBackgroundView = UIView
    
    let apply : (ContentView) -> ()
    
    init(_ apply : @escaping (ContentView) -> ())
    {
        self.apply = apply
    }
    
    static func createReusableItemView() -> ItemElementView<ContentView, UIView, UIView>
    {
        return .init(content: ContentView(), background: UIView(), selectedBackground: UIView())
    }
    
    func update(view: ItemElementView<ContentView, UIView, UIView>, with position: ItemPosition)
    {
        // Nothing For Now.
    }
    
    func apply(to view: ItemElementView<ContentView, UIView, UIView>, with state : ItemState, previous : ItemAppearance<ContentView>?)
    {
        self.apply(view.content)
        
        view.contentInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        
        view.content.backgroundColor = .clear
        
        view.background.backgroundColor = .white
        
        view.background.layer.cornerRadius = 6.0
        
        view.background.layer.borderColor = UIColor(white: 0.80, alpha: 1.0).cgColor
        view.background.layer.borderWidth = 0.5
    }
}


struct HeaderAppearance<ContentView:UIView> : HeaderFooterElementAppearance
{
    typealias BackgroundView = UIView
    
    let apply : (ContentView) -> ()
    
    init(_ apply : @escaping (ContentView) -> ())
    {
        self.apply = apply
    }
    
    static func createReusableHeaderFooterView() -> HeaderFooterElementView<ContentView, UIView>
    {
        return .init(content: ContentView(), background: UIView())
    }
    
    func apply(to view: HeaderFooterElementView<ContentView, UIView>, previous: HeaderAppearance<ContentView>?)
    {
        self.apply(view.content)
        
        view.contentInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        
        view.content.backgroundColor = .clear
        
        view.background.backgroundColor = .white
        
        view.background.layer.cornerRadius = 8.0
        
        view.background.layer.borderColor = UIColor(white: 0.0, alpha: 0.35).cgColor
        view.background.layer.borderWidth = 0.5
        
        view.background.layer.shadowOpacity = 0.15
        view.background.layer.shadowColor = UIColor.black.cgColor
        view.background.layer.shadowRadius = 2.0
        view.background.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
    }
}


struct FooterAppearance<ContentView:UIView> : HeaderFooterElementAppearance
{
    typealias BackgroundView = UIView
    
    let apply : (ContentView) -> ()
    
    init(_ apply : @escaping (ContentView) -> ())
    {
        self.apply = apply
    }
    
    static func createReusableHeaderFooterView() -> HeaderFooterElementView<ContentView, UIView>
    {
        return .init(content: ContentView(), background: UIView())
    }
    
    func apply(to view: HeaderFooterElementView<ContentView, UIView>, previous: FooterAppearance<ContentView>?)
    {
        self.apply(view.content)
    }
}

