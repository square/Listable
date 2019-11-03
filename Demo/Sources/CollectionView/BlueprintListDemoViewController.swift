//
//  BlueprintListViewController.swift
//  Demo
//
//  Created by Kyle Van Essen on 10/22/19.
//  Copyright © 2019 Kyle Van Essen. All rights reserved.
//

import Listable
import BlueprintLists
import BlueprintUI
import BlueprintUICommonControls


final class BlueprintListDemoViewController : UIViewController
{
    let blueprintView = BlueprintView()
    
    override func loadView()
    {
        self.title = "Podcasts"
        
        self.view = self.blueprintView
        
        self.blueprintView.element = self.content
    }
    
    var content : Element {
        return List(appearance: Appearance()) { list in

            let podcasts = Podcast.podcasts.sorted { $0.episode < $1.episode }

            list += Section(identifier: "podcasts") { section in

                section += podcasts.map { podcast in
                    Item(
                        PodcastRow(podcast: podcast),
                        height: .thatFits(.noConstraint)
                    )
                }
            }
        }
    }
}

struct PodcastRow : BlueprintItemElement, Equatable
{
    var podcast : Podcast
    
    var identifier: Identifier<PodcastRow> {
        return .init(self.podcast.name)
    }

    func element(with state: ItemState) -> Element
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
    
    func backgroundElement(with state: ItemState) -> Element?
    {
        return Box(backgroundColor: .white, cornerStyle: .square)
    }
    
    func selectedBackgroundElement(with state: ItemState) -> Element?
    {
        return Box(backgroundColor: .lightGray, cornerStyle: .square)
    }

}

struct Podcast : Equatable
{
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
