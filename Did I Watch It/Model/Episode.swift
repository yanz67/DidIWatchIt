//
//  Episode.swift
//  Did I Watch It
//
//  Created by Yan Zverev on 9/21/16.
//  Copyright © 2016 Yan Zverev. All rights reserved.
//

import Foundation
import CoreData


class Episode: NSManagedObject {

 
// Insert code here to add functionality to your managed object subclass
    convenience init?(episodeInfo: EpisodeInfo, series: Series, context: NSManagedObjectContext)
    {
        if let ent = NSEntityDescription.entityForName("Episode", inManagedObjectContext: context) {
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.episodeName = episodeInfo.episodeName
            self.id = episodeInfo.id
            self.airedEpisodeNumber = episodeInfo.airedEpisodeNumber
            self.episodeOverview = episodeInfo.episodeOverview
            self.didIWatchIt = episodeInfo.didIWatchIt
            self.airedSeason = episodeInfo.airedSeason
            self.series = series
            
        } else {
            return nil
        }
    }

}
