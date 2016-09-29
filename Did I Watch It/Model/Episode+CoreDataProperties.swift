//
//  Episode+CoreDataProperties.swift
//  Did I Watch It
//
//  Created by Yan Zverev on 9/21/16.
//  Copyright © 2016 Yan Zverev. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Episode {

    @NSManaged var airedEpisodeNumber: NSNumber?
    @NSManaged var airedSeason: NSNumber?
    @NSManaged var episodeName: String?
    @NSManaged var episodeOverview: String?
    @NSManaged var didIWatchIt: NSNumber?
    @NSManaged var id: NSNumber?
    @NSManaged var series: Series?

}
