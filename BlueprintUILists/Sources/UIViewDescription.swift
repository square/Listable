//
//  UIViewDescription.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 1/25/21.
//

import BlueprintUI
import ListableUI


extension UIViewDescription where ViewType == BlueprintView {
    
    static func element(_ provider : @escaping () -> Element) -> Self {
        Self(BlueprintView.self) {
            BlueprintView()
        } update: { view in
            view.element = provider()
        }
    }
}
