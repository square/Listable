//
//  AutoScrollingViewController2.swift
//  Demo
//
//  Created by Blake McAnally on 3/26/24.
//  Copyright © 2022 Kyle Van Essen. All rights reserved.//

import UIKit

import ListableUI
import BlueprintUILists
import BlueprintUI
import BlueprintUICommonControls

final class ListBackgroundViewController: UIViewController {
    let list = ListView()
    
    let background: UIImageView = {
        let image = UIImageView(
            image: UIImage(named: "kyle")
        )
        image.contentMode = .scaleAspectFit
        return image
    }()

    override func loadView()
    {
        self.view = self.list
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.list.configure { properties in
            
            properties.backgroundView = background
            
            properties.add {
                Section("items") {
                    AutoLayoutContent(
                        header: "Foo",
                        detail: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas odio urna, volutpat vitae volutpat quis, auctor ut purus. Pellentesque ac varius metus."
                    )
                    AutoLayoutContent(
                        header: "Bar",
                        detail: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas odio urna, volutpat vitae volutpat quis, auctor ut purus. Pellentesque ac varius metus."
                    )
                    AutoLayoutContent(
                        header: "Baz",
                        detail: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas odio urna, volutpat vitae volutpat quis, auctor ut purus. Pellentesque ac varius metus."
                    )
                }
            }
        }
    }
}
