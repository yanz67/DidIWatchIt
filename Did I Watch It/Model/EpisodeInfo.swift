//
//  EpisodeInfo.swift
//  Did I Watch It
//
//  Created by Yan Zverev on 9/21/16.
//  Copyright © 2016 Yan Zverev. All rights reserved.
//

import Foundation

import Foundation
import UIKit


class EpisodeInfo: CustomStringConvertible
{
    var airedEpisodeNumber: Int?
    var airedSeason: Int
    var episodeName: String?
    var episodeOverview: String?
    var didIWatchIt: Bool
    var id: Int
    
    
    var description: String {
        
        return "Season: \(airedSeason) \n \(episodeName)"
    }
    
    
    init?(episodeInfo: [String : AnyObject])
    {
        if let id = episodeInfo["id"] as? Int {
            self.id = id
        }else {
            print("no ID")
            return nil // will not construct the object if Series ID is not available
        }
        
        if let episodeName = episodeInfo["episodeName"] as? String {
            self.episodeName = episodeName
        } else {
            print("no episodeName")
            return nil // will not construct the object if Series Name is not available
        }
        
        self.episodeOverview = episodeInfo["overview"] as? String
        
        self.didIWatchIt = false
        
        if let airedEpisodeNumber = episodeInfo["airedEpisodeNumber"] as? Int {
            self.airedEpisodeNumber = airedEpisodeNumber
        } else {
            print("no airedEpisodeNumber")
            return nil // will not construct the object if Series Name is not available
        }
        
        if let airedSeason = episodeInfo["airedSeason"] as? Int {
            self.airedSeason = airedSeason
        } else {
            print("no airedSeason")
            return nil // will not construct the object if Series Name is not available
        }
    }
}

