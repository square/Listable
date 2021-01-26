//
//  UIViewDescription.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 1/25/21.
//

import BlueprintUI
import ListableUI


extension UIViewDescription where RequiredType == UIView {
    
    public static func element(_ provider : @escaping () -> Element) -> Self {
        Self<UIView>(BlueprintView.self) {
            BlueprintView()
        } update: { view in
            view.element = provider()
        }
    }
}
