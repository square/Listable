//
//  TableViewDemosBlueprintViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 8/26/19.
//  Copyright © 2019 Kyle Van Essen. All rights reserved.
//

import UIKit

import BlueprintUI
import BlueprintUICommonControls

import ListableTableView
import ListableBlueprintTableView


final class TableViewDemosBlueprintViewController : UIViewController
{
    override func loadView()
    {
        self.title = "Podcasts!"
        
        let blueprintView = BlueprintView()
        blueprintView.element = PodcastList()

        self.view = blueprintView
    }
}

struct PodcastList : ProxyElement
{
    var elementRepresentation: Element
    {
        return Table(style: .plain) { table in
            
            let sorted = Podcast.podcasts.sorted { $0.episode < $1.episode }
            
            table += Section(header: "Episodes") { section in
                
                section += sorted.map { podcast in
                    Row(
                        BlueprintRow(identifier: podcast.name, PodcastRow(podcast: podcast)),
                        sizing: .thatFits(.noConstraint)
                    )
                }
            }
        }
    }
}



struct PodcastRow : ProxyElement
{
    var podcast : Podcast
    
    var elementRepresentation: Element
    {
        return Inset(wrapping: Row { row in
            row.horizontalUnderflow = .growUniformly
            row.verticalAlignment = .fill
            
            row.add(
                growPriority: 0.0,
                child: ConstrainedSize(
                    wrapping: Box(cornerStyle: .rounded(radius: 8.0), wrapping: Image(image: self.podcast.image)),
                    width: .absolute(100.0),
                    height: .absolute(100.0)
                )
            )
            
            row.add(
                growPriority: 0.0,
                child: Spacer(size: CGSize(width: 10.0, height: 0.0))
            )
            
            row.add(child: Column { column in
                column.verticalUnderflow = .growUniformly
                
                column.add(growPriority: 0.0, child: Label(text: self.podcast.episode) { label in
                    label.font = UIFont.systemFont(ofSize: 18.0, weight: .semibold)
                    label.color = .darkGray
                })
                
                column.add(growPriority: 0.0, child: Spacer(size: .init(width: 0.0, height: 5.0)))
                
                column.add(growPriority: 0.0, child: Label(text: self.podcast.name) { label in
                    label.font = UIFont.systemFont(ofSize: 16.0, weight: .regular)
                    label.color = .gray
                })
                
                column.add(growPriority: 1.0, child: Spacer(size: .init(width: 0.0, height: 1.0)))
                
                column.add(growPriority: 0.0, child: Label(text: self.podcast.length) { label in
                    label.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
                    label.color = .lightGray
                })
            })
        }, uniformInset: 10.0)
    }
}

struct Podcast {
    var name : String
    var episode : String
    var length : String
    var image : UIImage
    
    static var podcasts : [Podcast] {
        return [
            Podcast(
                name: "Nancy",
                episode: "What Do We Have In Common?",
                length: "27:54",
                image: UIImage(named: "nancy.png")!
            ),
            
            Podcast(
                name: "This American Life",
                episode: "409: Held Hostage",
                length: "1:01:10",
                image: UIImage(named: "this-american-life.jpg")!
            ),
            
            Podcast(
                name: "Wait Wait Don't Tell Me",
                episode: "Henry Winkler",
                length: "56:34",
                image: UIImage(named: "wait-wait.png")!
            ),
            
            Podcast(
                name: "The Impact",
                episode: "The incredible shrinking city",
                length: "56:34",
                image: UIImage(named: "the-impact.png")!
            ),
            
            Podcast(
                name: "Planet Money",
                episode: "935: You Asked For A Food Show",
                length: "56:34",
                image: UIImage(named: "planet-money.jpg")!
            ),
            
            Podcast(
                name: "Are We There Yet?",
                episode: "The Mysteries At Asteroid Bennu",
                length: "56:34",
                image: UIImage(named: "are-we-there-yet.png")!
            ),
            
            Podcast(
                name: "Outside Lands San Francisco",
                episode: "159: Twin Peaks Tunnel",
                length: "24:03",
                image: UIImage(named: "outside-lands.jpg")!
            ),
        ]
    }
}
