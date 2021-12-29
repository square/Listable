//
//  LocalizedCollationViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 12/7/20.
//  Copyright © 2020 Kyle Van Essen. All rights reserved.
//

import BlueprintUILists
import BlueprintUICommonControls


final class LocalizedCollationViewController : ListViewController {
    
    override func configure(list: inout ListProperties) {
        
        list.appearance = .demoAppearance
        list.layout = .demoLayout
        
        let items = names.map { name in
            Item(DemoItem(text: name))
        }
        
        list += LocalizedItemCollator.sections(with: items) { collated, section in
            section.header = DemoHeader(title: collated.title)
        }
    }
}


/// Via http://listofrandomnames.com

fileprivate let names : [String] = [
    "Delisa Leggio",
    "Carlota Loughran",
    "Krystin Schoenberg",
    "Dionna Levering",
    "Larhonda Piatt",
    "Duane Norred",
    "Pearline Spino",
    "Justin Lafrance",
    "Dell Lundell",
    "Marina Opie",
    "Jason Polson",
    "Sunni Latta",
    "Alta Arnott",
    "Kaitlin Spigner",
    "Harriette Cagney",
    "Zoraida Gloria",
    "Daisey Strait",
    "Demetra Wojcik",
    "Lovella Ho",
    "Isabell Navas",
    "Odessa Krogman",
    "Loria Morissette",
    "Ozie Cadle",
    "Ethel Killebrew",
    "Brandon Hynson",
    "Jerlene Vanasse",
    "Clement Gregson",
    "Mika Hubble",
    "Randy Rega",
    "Charla Buzbee",
    "Sherlyn Imler",
    "Renda Rierson",
    "Neomi Kimbler",
    "Ruthanne Ceniceros",
    "Lucretia Fountaine",
    "Elias Rotondo",
    "Illa Jellison",
    "Delmer Luppino",
    "Ma Waring",
    "Jack Villar",
    "Rosann Alloway",
    "Lurlene Rolland",
    "Sol Desalvo",
    "Venice Tincher",
    "Alica Hadsell",
    "Carlee Stankiewicz",
    "Adriana Blackford",
    "Leonida Crank",
    "Burton Renfrow",
    "Micheal Melgar",
]
