//
//  TVDBConstants.swift
//  Did I Watch It
//
//  Created by Yan Zverev on 9/8/16.
//  Copyright © 2016 Yan Zverev. All rights reserved.
//

extension TVDBClientManager
{
    struct Constants
    {
        static let ApiScheme = "https"
        static let ApiHost = "api.thetvdb.com"
        static let ApiPath = ""
    }
    
    struct Methods
    {
        static let Login = "/login"
        static let RefreshToken = "/refresh_token"
        static let SearchSeries = "/search/series"
        static let SeriesInfo = "/series/{id}"
        static let EpisodesInfo = "/series/{id}/episodes"
        static let EpisodesQuery = "/series/{id}/episodes/query"
        static let EpisodesSummary = "/series/{id}/episodes/summary"
        static let EpisodeInfo = "/episodes/{id}"
        static let AllEpisodesInfo = "/series/{id}/episodes"
        static let ImagesInfo = "/series/{id}/images"
        static let ImagesQuery = "/series/{id}/images/query"
    }
    
    struct TVDBParameterKeys
    {
        static let ApiKey = "apikey"
        static let Token = "token"
        static let SeriesName = "name"
        static let Data = "data"
        
    }
    
    struct TVDBSeriesParameterKeys
    {
        static let ID = "id"
        static let Name = "name"
        static let Banner = "banner"
        static let FirstAired = "firstaired"
        static let OverView = "overview"
        static let Status = "status"
        static let Network = "network"
    }
    
    struct TVDBEpisodesParameterKeys
    {
        static let Page = "page"
        static let Links = "links"
        static let Data = "data"
        static let NextPage = "next"
    }
    
    struct TVDBValueKeys
    {
        static let ApiKey = "4EA8F8B63A13CF2F"
    }
    
    
    struct TVDBErrors
    {
        static let NotAuthorized = "Not Authorized"
        static let NotFound = "Not Found"
    }
    
    
}