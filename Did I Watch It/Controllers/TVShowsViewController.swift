//
//  TVShowsViewController.swift
//  Did I Watch It
//
//  Created by Yan Zverev on 9/10/16.
//  Copyright © 2016 Yan Zverev. All rights reserved.
//

import UIKit
import CoreData

class TVShowsViewController: CoreDataTableViewController, AddSeriesViewControllerDelegate
{

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fr = NSFetchRequest(entityName: "Series")
        fr.sortDescriptors = [NSSortDescriptor(key: "seriesName", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: TVDBClientManager.sharedInstance.coreDatastack.context, sectionNameKeyPath: nil, cacheName: nil)
        
      }
    
    
    //MARK: - Tableview DataSource
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SeriesInfoCell", forIndexPath: indexPath) as! SeriesInfoTableViewCell
        let series = fetchedResultsController!.objectAtIndexPath(indexPath) as! Series
        
        if let imageData = series.bannerImage {
            cell.seriesImageView.image = UIImage(data: imageData)
        } else {
            cell.seriesNameLabel.text = series.seriesName
        }
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "addSeries" {
            if let addSeriesVC = segue.destinationViewController as? AddSeriesViewController {
                addSeriesVC.delegate = self
            }
        } else if segue.identifier == "showSeriesInfo" {
            if segue.destinationViewController is EpisodesInfoCoreDataTableViewController {
                let episodeICDTV = segue.destinationViewController as! EpisodesInfoCoreDataTableViewController
                if let series = fetchedResultsController?.objectAtIndexPath(tableView.indexPathForSelectedRow!) as? Series {
                    episodeICDTV.series = series
                }
            }
        }
        
    }
    

    func addSeriesPicker(addSeriesVC: AddSeriesViewController, didAddSeries seriesAdded: SeriesInfo?)
    {
       
        addSeriesVC.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    


}
