//
//  ScrollViewEdgesPlaygroundViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 5/4/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//

import UIKit
import ListableUI


final class ScrollViewEdgesPlaygroundViewController : UIViewController, UIScrollViewDelegate
{
    let scrollView = UIScrollView()
    let innerView = UIView()
    
    override func loadView()
    {
        scrollView.backgroundColor = .white
        innerView.backgroundColor = .lightGray

        scrollView.addSubview(innerView)
        scrollView.delegate = self
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        
        self.view = scrollView
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.contentSize = CGSize(
            width: round(self.view.bounds.width / 1.25),
            height: round(self.view.bounds.height / 1.25)
        )
        
        innerView.frame = CGRect(
            x: 0.0,
            y: 0.0,
            width: scrollView.contentSize.width,
            height: scrollView.contentSize.height
        )
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let info = ListScrollPositionInfo(
            scrollView: scrollView,
            visibleItems: Set(),
            isFirstItemVisible: false,
            isLastItemVisible: false
        )
        
        print("edges: \(info.visibleContentEdges())")
        print("---------\n")
    }
}
