//
//  main.swift
//  Scripts
//
//  Created by Kyle Van Essen on 12/27/19.
//  Copyright © 2019 Kyle Van Essen. All rights reserved.
//

import Foundation


let jsonString = try BashCommand(with: ["xcrun simctl list -j"]).run()
let simList = try SimCtl.List.from(json: jsonString)

print(simList)
