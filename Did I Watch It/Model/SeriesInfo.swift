//
//  SeriesInfo.swift
//  Did I Watch It
//
//  Created by Yan Zverev on 9/11/16.
//  Copyright © 2016 Yan Zverev. All rights reserved.
//

import Foundation
import UIKit


class SeriesInfo: CustomStringConvertible
{
    var id: Int
    var seriesName: String
    var banner: NSURL?
    var firstAired: NSDate?
    var overView: String?
    var status: String?
    var network: String?
    var bannerImage: UIImage?
    
    
    var description: String {
        
        return "ID: \(id) \n \(seriesName)"
    }


    init?(seriesInfo: [String : AnyObject])
    {
        if let id = seriesInfo["id"] as? Int {
            self.id = id
        }else {
            return nil // will not construct the object if Series ID is not available
        }
        
        
        if let seriesName = seriesInfo["seriesName"] as? String {
            self.seriesName = seriesName
        } else {
            return nil // will not construct the object if Series Name is not available
        }
        
        if let banner = seriesInfo["banner"] as? String {
            if banner != "" {
                self.banner = NSURL(string: "https://thetvdb.com/banners/\(banner)")
            } else {
                self.banner = nil
            }
        } else {
            self.banner = nil
        }
        
        if let firstAired = seriesInfo["firstAired"] as? String {
            let df = NSDateFormatter()
            df.setLocalizedDateFormatFromTemplate("yyyy-MM-mm")
            self.firstAired = df.dateFromString(firstAired)
        } else {
            self.firstAired = nil
        }
        
        if let overView = seriesInfo["overview"] as? String {
            self.overView = overView
        } else {
            self.overView = nil
        }
        
        if let status = seriesInfo["status"] as? String {
            self.status = status
        } else {
            self.status = nil
        }
        
        if let network = seriesInfo["network"] as? String {
            self.network = network
        } else {
            self.network = nil
        }

    }
}

