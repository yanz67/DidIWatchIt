//
//  Series.swift
//  Did I Watch It
//
//  Created by Yan Zverev on 9/19/16.
//  Copyright © 2016 Yan Zverev. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Series: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    convenience init?(seriesInfo: SeriesInfo, context: NSManagedObjectContext)
    {
        if let ent = NSEntityDescription.entityForName("Series", inManagedObjectContext: context) {
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.seriesName = seriesInfo.seriesName
            self.id = seriesInfo.id
            if let bannerTempURL = seriesInfo.banner {
                self.bannerURL = "\(bannerTempURL)"
            }
            self.firstAired = seriesInfo.firstAired
            if let banner =  seriesInfo.bannerImage {
                self.bannerImage = UIImageJPEGRepresentation(banner,0.8);
            }
        } else {
            return nil
        }
    }

}