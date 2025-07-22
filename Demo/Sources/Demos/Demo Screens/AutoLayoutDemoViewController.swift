//
//  AutoLayoutDemoViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 10/28/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//

import ListableUI

import UIKit


final class AutoLayoutDemoViewController : ListViewController {
    
    override func configure(list: inout ListProperties) {
     
        list.add {
            Section("section") {
                AutoLayoutContent(
                    header: "Some header text",
                    detail: "Some detail text"
                )
                
                AutoLayoutContent(
                    header: "Some header text",
                    detail: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas odio urna, volutpat vitae volutpat quis, auctor ut purus. Pellentesque ac varius metus."
                )
            }
        }
    }
}


struct AutoLayoutContent : ItemContent, Equatable {
    
    var header : String
    var detail : String
    
    var identifierValue: String {
        header + detail
    }
    
    var defaultItemProperties: DefaultProperties {
        .init(
            sizing: .autolayout()
        )
    }
    
    func apply(
        to views: ItemContentViews<Self>,
        for reason: ApplyReason,
        with info: ApplyItemContentInfo
    ) {
        views.content.headerLabel.text = self.header
        views.content.detailLabel.text = self.detail
    }
    
    static func createReusableContentView(frame: CGRect) -> View {
        View(frame: frame)
    }
    
    final class View: UIView {
        
        lazy var headerLabel: UILabel = {
            let v = UILabel()
            v.translatesAutoresizingMaskIntoConstraints = false
            v.textColor = .black
            v.font = .systemFont(ofSize: 36.0, weight: .semibold)
            return v
        }()
        
        lazy var detailLabel: UILabel = {
            let v = UILabel()
            v.translatesAutoresizingMaskIntoConstraints = false
            v.textColor = .black
            v.numberOfLines = 0
            v.lineBreakMode = .byWordWrapping
            v.font = .systemFont(ofSize: 24.0, weight: .regular)
            return v
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.backgroundColor = .init(white: 1.0, alpha: 0.05)
            
            self.addSubview(headerLabel)
            self.addSubview(detailLabel)
            
            NSLayoutConstraint.activate([
                headerLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
                headerLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
                headerLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),

                detailLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
                detailLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
                detailLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
                detailLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12)
            ])
        }
        
        required init?(coder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
        }
    }
}
