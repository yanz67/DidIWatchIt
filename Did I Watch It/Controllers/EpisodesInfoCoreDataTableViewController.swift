//
//  EpisodesInfoCoreDataTableViewController.swift
//  Did I Watch It
//
//  Created by Yan Zverev on 9/26/16.
//  Copyright © 2016 Yan Zverev. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class EpisodesInfoCoreDataTableViewController: CoreDataTableViewController
{
    
    var series: Series?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fr = NSFetchRequest(entityName: "Episode")
        fr.sortDescriptors = [NSSortDescriptor(key: "airedEpisodeNumber", ascending: true)]
        fr.predicate = NSPredicate(format: "series == %@", series!)
        
  
        if let bannerImage = series?.bannerImage {
            let headerView = UIView(frame: CGRectMake(0.0, 0.0, tableView.bounds.width, 80.0))
            let headerImageView = UIImageView(frame: headerView.bounds)
            headerImageView.image = UIImage(data: bannerImage)
            headerView.addSubview(headerImageView)
            tableView.tableHeaderView = headerView
        } else {
            self.title = series?.seriesName
        }
        
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: TVDBClientManager.sharedInstance.coreDatastack.context, sectionNameKeyPath: "airedSeason", cacheName: nil)
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("EpisodeInfo")! as UITableViewCell
        
        let episode = fetchedResultsController?.objectAtIndexPath(indexPath) as! Episode
        
        cell.textLabel?.text = episode.episodeName
        cell.detailTextLabel?.text = episode.episodeOverview
        if (episode.didIWatchIt == true) {
            cell.accessoryType = .Checkmark
        }else {
            cell.accessoryType = .None
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let fc = fetchedResultsController{
            return "Season \(fc.sections![section].name)"
        } else{
            return nil
        }
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EpisodeInfo" {
            if segue.destinationViewController is EpisodeInfoViewController {
                let episodeIVC = segue.destinationViewController as? EpisodeInfoViewController
                episodeIVC?.episode = fetchedResultsController?.objectAtIndexPath(tableView.indexPathForSelectedRow!) as? Episode
            }
        }
    }
    
    
    @IBAction func deleteSeries(sender: UIBarButtonItem)
    {
        TVDBClientManager.sharedInstance.deleteSeries(series!)
        navigationController?.popViewControllerAnimated(true)
        
    }
    
}
