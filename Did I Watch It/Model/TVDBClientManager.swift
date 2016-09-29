	//
//  TVDBClientManager.swift
//  Did I Watch It
//
//  Created by Yan Zverev on 9/8/16.
//  Copyright © 2016 Yan Zverev. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class TVDBClientManager : NSObject
{
    static let sharedInstance = TVDBClientManager()
    let coreDatastack = CoreDataStack(modelName: "DidIWatchItModel")!
    
    // shared session
    var session = NSURLSession.sharedSession()
    
    
    override init()
    {
        super.init()
        getTVDBToken { (success, error) in
            print("token received")
        }
        
    }
    
    //MARK: - Authentication
    
    func getTVDBToken(completionHandlerForGetTVDBToken:(success: Bool, error: NSError?) -> Void)
    {
        let jsonBody = "{\"\(TVDBParameterKeys.ApiKey)\":\"\(TVDBValueKeys.ApiKey)\"}"
        taskForPOSTMethod(Methods.Login, parameters: [:], jsonBody: jsonBody) { (result, error) in
            guard error == nil else {
                completionHandlerForGetTVDBToken(success: false, error: error)
                return
            }
            if let token = result[TVDBParameterKeys.Token] as? String {
                let userDefaults = NSUserDefaults.standardUserDefaults()
                userDefaults.setValue(token, forKey: TVDBParameterKeys.Token)
                userDefaults.synchronize()
                
                completionHandlerForGetTVDBToken(success: true, error: error)
            } else {
                completionHandlerForGetTVDBToken(success: false, error: NSError(domain: "getTVDBToken", code: 1, userInfo: [NSLocalizedDescriptionKey : "Error Receiving Token"]))
            }
            
        }
    }
    
    func refreshTVDBToken(completionHandlerForRefreshTVDBToken:(success: Bool, error: NSError?) -> Void)
    {
        if let TVDBToken = NSUserDefaults.standardUserDefaults().valueForKey(TVDBParameterKeys.Token) as? String {
            taskForGETMethod(Methods.RefreshToken, parameters: [:], tvDBToken: TVDBToken) { (result, error) in
                guard error == nil else {
                    if error?.localizedDescription == TVDBErrors.NotAuthorized{
                        self.getTVDBToken(completionHandlerForRefreshTVDBToken)
                    } else {
                        completionHandlerForRefreshTVDBToken(success: false, error: NSError(domain: "refreshTVDBToken", code: 1, userInfo: [NSLocalizedDescriptionKey : "Account not found"]))
                    }
                    return
                }
                completionHandlerForRefreshTVDBToken(success: true, error: nil)
            }
        } else {
            getTVDBToken(completionHandlerForRefreshTVDBToken)
        }
        
    }
    
    func getToken() -> String
    {
        if let token = NSUserDefaults.standardUserDefaults().valueForKey(TVDBParameterKeys.Token) as? String {
            return token
        }
        
        return ""
    }
    
    //MARK: - Search For Series
    
    func searchForSeriesByName(name: String, completionHandlerForSearchForSeriesByName: (result: [SeriesInfo]!, error: NSError?) -> Void)
    {
        let parameters: [String : String] = [TVDBParameterKeys.SeriesName : name]
        if let token = NSUserDefaults.standardUserDefaults().valueForKey(TVDBParameterKeys.Token) as? String {
            taskForGETMethod(Methods.SearchSeries, parameters: parameters, tvDBToken: token ) { (result, error) in
                guard error == nil else {
                    completionHandlerForSearchForSeriesByName(result: nil, error: error)
                    return
                }
                
                
                guard let seriesArray = result[TVDBParameterKeys.Data] as? [[String : AnyObject]] else {
                    completionHandlerForSearchForSeriesByName(result: nil, error: NSError(domain: "searchForSeriesByName", code: 1, userInfo: [NSLocalizedDescriptionKey : "No Data Returned"]))
                    return
                }
                
                
                var resultsArray = [SeriesInfo]()
                self.coreDatastack.context.performBlock({
                    for series in seriesArray {
                        guard let seriesID = series["id"] as? Int else {
                            continue
                        }
                        
                        
                        if !self.isSeriesExistInDatabase(seriesID) {
                            
                            if let seriesInfo = SeriesInfo(seriesInfo: series)  {
                                resultsArray.append(seriesInfo)
                            }
                        }
                        
                        
                    }
                
                    completionHandlerForSearchForSeriesByName(result: resultsArray, error: nil)
                })
            }
        }
        
    }
    
    //MARK: Get Series Info
    
    func getFullSeriesInfo(seriesInfo: SeriesInfo, completionHandlerForGetFullSeriesInfo: (result: AnyObject!, error: NSError?) -> Void)
    {
        taskForGETMethod(substituteKeyInMethod(Methods.SeriesInfo, key: "id", value: "\(seriesInfo.id)")! , parameters: [:], tvDBToken: getToken()) { (result, error) in
            guard error == nil else {
                completionHandlerForGetFullSeriesInfo(result: nil, error: error)
                return
            }

            guard let fullSeriesInfo = result[TVDBParameterKeys.Data] as? [String : AnyObject] else {
                completionHandlerForGetFullSeriesInfo(result: nil, error: NSError(domain: "getFullSeriesInfo", code: 1, userInfo: [NSLocalizedDescriptionKey : "No Data Returned"]))
                return
            }
            
            completionHandlerForGetFullSeriesInfo(result: fullSeriesInfo, error: nil)            
        }
    }
    
    //MARK: - Get Episodes Info
    
    
    func addEpisodesInfoToCoreDataForPage(series: Series, pageNum: String, completionHandlerAddEpisodesInfoToCoreDataForPage: (success: Bool, error: NSError?) -> Void)
    {
        taskForGETMethod(substituteKeyInMethod(Methods.AllEpisodesInfo, key: "id", value: "\(series.id!)")!, parameters: [TVDBEpisodesParameterKeys.Page : pageNum], tvDBToken: getToken()) {  (result, error) in
            
            guard error == nil else {
                // if there is an errror download episodes the series will be delete from core data
                self.deleteSeries(series)
                
                completionHandlerAddEpisodesInfoToCoreDataForPage(success: false, error: error)
                return
            }
            
            guard let links = result[TVDBEpisodesParameterKeys.Links] as? [String : AnyObject] else {
                completionHandlerAddEpisodesInfoToCoreDataForPage(success: false, error: NSError(domain: "addEpisodesInfoToCoreDataForPage", code: 1, userInfo: [NSLocalizedDescriptionKey : "links parameter missing from TVDB Reply"]))
                return
            }
            guard let episodesArray = result[TVDBEpisodesParameterKeys.Data] as? [[String : AnyObject]] else {
                completionHandlerAddEpisodesInfoToCoreDataForPage(success: false, error: NSError(domain: "addEpisodesInfoToCoreDataForPage", code: 1, userInfo: [NSLocalizedDescriptionKey : "No Data Returned"]))
                return
            }
            
            for episodeDictionary in episodesArray {
                guard let episodeInfo = EpisodeInfo(episodeInfo: episodeDictionary) else {
                    completionHandlerAddEpisodesInfoToCoreDataForPage(success: false, error: NSError(domain: "addEpisodesInfoToCoreDataForPage", code: 1, userInfo: [NSLocalizedDescriptionKey : "Unable to add episodes to core data"]))
                    return
                }
                    let episode = self.addEpisodeForSeriesToCoreData(episodeInfo, series: series)
                
                    guard episode != nil else {
                        completionHandlerAddEpisodesInfoToCoreDataForPage(success: false, error: NSError(domain: "addEpisodesInfoToCoreDataForPage", code: 1, userInfo: [NSLocalizedDescriptionKey : "Unable to add episodes to core data"]))
                        return
                    }
            
                    self.saveModel()
            }
            
            guard let nextPage = links[TVDBEpisodesParameterKeys.NextPage] as? Int else {
                completionHandlerAddEpisodesInfoToCoreDataForPage(success: true, error: nil)
                return
            }
            
            self.addEpisodesInfoToCoreDataForPage(series, pageNum: "\(nextPage)",completionHandlerAddEpisodesInfoToCoreDataForPage: completionHandlerAddEpisodesInfoToCoreDataForPage)
            

            }
        
    }
    
    //MARK: - Core Data Functions
    
    func isSeriesExistInDatabase(seriesID: Int) -> Bool
    {
        
        let fr = NSFetchRequest(entityName: "Series")
        fr.predicate = NSPredicate(format:"id == %d", seriesID)
        
        let count = coreDatastack.context.countForFetchRequest(fr, error: nil)
        
        return count == 0 ? false : true
    }
    
    func addSeriesToCoreData(seriesInfo: SeriesInfo, completionHandlerAddSeriesToCoreData: (success: Bool, error: NSError?) -> Void)
    {
        coreDatastack.context.performBlock { 
            if let series = Series(seriesInfo: seriesInfo, context: self.coreDatastack.context) {
                self.saveModel()
                self.addAllEpisodesToCoreData(series, completionHandlerAddAllEpisodesToCareData: completionHandlerAddSeriesToCoreData)
            } else {
                completionHandlerAddSeriesToCoreData(success: false, error: NSError(domain: "addSeriesToCoreData", code: 1, userInfo: [NSLocalizedDescriptionKey : "Couldn't add Series to the database"]))
            }
        }
        
        
    }
    
    func addAllEpisodesToCoreData(series: Series, completionHandlerAddAllEpisodesToCareData: (success: Bool, error: NSError?) -> Void)
    {
        
        addEpisodesInfoToCoreDataForPage(series, pageNum: "1", completionHandlerAddEpisodesInfoToCoreDataForPage: completionHandlerAddAllEpisodesToCareData)
        
    }
    
    func addEpisodeForSeriesToCoreData(episodeInfo: EpisodeInfo, series: Series) -> Episode?
    {
        return Episode(episodeInfo: episodeInfo, series: series, context: coreDatastack.context)
    }
    
    func setEpisodeDidIWatchitOrNot(episode: Episode, completionHandlerSetEpisodeDidIwatchItOrNot:(success: Bool) -> Void)
    {
        coreDatastack.context.performBlock { 
            episode.didIWatchIt = episode.didIWatchIt == 0 ? 1 : 0
            self.saveModel()
            completionHandlerSetEpisodeDidIwatchItOrNot(success: true)
        }
        
    }
    
    func deleteSeries(series: Series)
    {
        coreDatastack.context.performBlock { 
            self.coreDatastack.context.deleteObject(series)
            self.saveModel()
        }
        
    }
    
    
    private func saveModel()
    {
        do{
            try self.coreDatastack.saveContext()
        }catch let error as NSError{
            print("couldn't save model \(error.userInfo)")
        }
    }

    // MARK: POST
    
    func taskForPOSTMethod(method: String, parameters: [String:AnyObject], jsonBody: String, completionHandlerForPOST: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var parametersWithApiKey = parameters
        

        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(URL: URLFromParameters(parametersWithApiKey, withPathExtension: method))
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(result: nil, error: NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!.localizedDescription)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                guard let data = data else {
                    sendError("Your request returned a status code other than 2xx!")
                    return
                }
                self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: { (result, error) in
                    guard error != nil else {
                        sendError("Could not parse the error status")
                        return
                    }
                    guard result != nil else {
                        sendError("Could not parse the error status")
                        return
                    }
                    
                    var userInfo = [String : String]()
                    
                    if let resultError = result["Error"] as? String {
                        userInfo[NSLocalizedDescriptionKey] = resultError
                    }
                    
                    completionHandlerForPOST(result: nil, error: NSError(domain: "taskForPostMethod", code: 1, userInfo: [NSLocalizedDescriptionKey : TVDBErrors.NotAuthorized]))
                    
                })
                return
            }

            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPOST)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }

    
    // MARK: GET
    
    func taskForGETMethod(method: String, parameters: [String:AnyObject],tvDBToken: String, completionHandlerForGET: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        
        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(URL: URLFromParameters(parameters, withPathExtension: method))
        
        request.setValue("Bearer \(tvDBToken)", forHTTPHeaderField: "Authorization")
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!.localizedDescription)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                
                guard let data = data else {
                    sendError("Your request returned a status code other than 2xx!")
                    return
                }
                self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: { (result, error) in
                    let httpStatusCode = (response as? NSHTTPURLResponse)?.statusCode
                    guard error == nil else {
                        sendError("Could not parse the error. HTTP Status Code: \(httpStatusCode!)")
                        return
                    }
                    guard result != nil else {
                        sendError("Could not parse the error. HTTP Status Code: \(httpStatusCode!)")
                        return
                    }
                    
                    var userInfo = [String : String]()
                    
                    if let resultError = result["Error"] as? String {
                        userInfo[NSLocalizedDescriptionKey] = resultError
                    }
                    
                    completionHandlerForGET(result: nil, error: NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
                    
                })
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    //MARK: Download Image
    
    func downloadImageFromURL(imageURL: NSURL, completionHandlerForDownloadImage:(data: NSData?, error: NSError?) -> Void)
    {
        NSURLSession.sharedSession().dataTaskWithURL(imageURL) { (data, response, error) in
            
            completionHandlerForDownloadImage(data: data, error: error)
            
            }.resume()
    }
    
    // MARK: Helpers
    
    // substitute the key for the value that is contained within the method name
    func substituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(result: parsedResult, error: nil)
    }
    
    // create a URL from parameters
    private func URLFromParameters(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        components.path = Constants.ApiPath + (withPathExtension ?? "")
        if parameters.count > 0 {
            components.queryItems = [NSURLQueryItem]()
            
            for (key, value) in parameters {
                let queryItem = NSURLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        
        return components.URL!
    }
    
    //MARK: appdelegate functions
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        
        return true;
        
    }
}
