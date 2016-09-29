//
//  Series+CoreDataProperties.swift
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

extension Series {

    @NSManaged var bannerImage: NSData?
    @NSManaged var bannerURL: String?
    @NSManaged var firstAired: NSDate?
    @NSManaged var id: NSNumber?
    @NSManaged var network: String?
    @NSManaged var overView: String?
    @NSManaged var seriesName: String?
    @NSManaged var status: String?
    @NSManaged var episodes: NSSet?

}
