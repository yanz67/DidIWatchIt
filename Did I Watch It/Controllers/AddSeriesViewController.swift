//
//  AddSeriesViewController.swift
//  Did I Watch It
//
//  Created by Yan Zverev on 9/13/16.
//  Copyright © 2016 Yan Zverev. All rights reserved.
//

import UIKit
import Foundation


protocol AddSeriesViewControllerDelegate {
    func addSeriesPicker(addSeriesVC: AddSeriesViewController, didAddSeries seriesAdded: SeriesInfo?)
}

class AddSeriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate
{
    
    
    var seriesArray = [SeriesInfo]()
    
    var spinner: UIActivityIndicatorView?
    
    var delegate: AddSeriesViewControllerDelegate?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var seriesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HUD.dimsBackground = false
        HUD.allowsInteraction = false
        
        
        
        searchBar.delegate = self
        seriesTableView.delegate = self
        seriesTableView.dataSource = self
    }
    
    
    private func hideKeyboard()
    {
        searchBar.resignFirstResponder()
    }
    
    @IBAction func cancelAddSeries(sender: UIButton)
    {
        hideKeyboard()
        delegate?.addSeriesPicker(self, didAddSeries: nil)
    }
    
    
    //MARK - TableView Datasource
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return seriesArray.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    private func setSeriesBannerInCell(seriesInfo : SeriesInfo, cell: SearchResultTableViewCell, indexPath: NSIndexPath)
    {
        
        guard seriesInfo.banner != nil else {
            cell.seriesNameLabel.text = seriesInfo.seriesName
            return
        }
        
        guard cell.isLoadingBanner == false else {
            cell.seriesNameLabel.text = seriesInfo.seriesName
            return
        }
        
        cell.tag = indexPath.row
        
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.color = UIColor.blackColor()
        activityIndicator.center = CGPointMake(cell.contentView.frame.size.width / 2.0, cell.contentView.frame.size.height / 2.0)
        cell.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        if let bannerURL = seriesInfo.banner {
            TVDBClientManager.sharedInstance.downloadImageFromURL(bannerURL) { (data, error) in
                cell.isLoadingBanner = false
                dispatch_async(dispatch_get_main_queue(), {
                    activityIndicator.stopAnimating()
                })

                guard error == nil else {
                    //set placeholder image
                
                    dispatch_async(dispatch_get_main_queue(), { 
                        cell.seriesNameLabel.text = seriesInfo.seriesName
                    })
                    print(error)
                    
                    return
                }
                
                guard let imageData = data else {
                    //set placeholder image
                    print("no imagedata for series: \(seriesInfo.seriesName) url: \(seriesInfo.banner)")
                    dispatch_async(dispatch_get_main_queue(), {
                        cell.seriesNameLabel.text = seriesInfo.seriesName
                    })
                    return
                }
                
                if let bannerImage = UIImage(data: imageData) {
                    seriesInfo.bannerImage = bannerImage
                    dispatch_async(dispatch_get_main_queue(), {
                        if cell.tag == indexPath.row {
                            cell.bannerImageView.alpha = 0.0
                            cell.bannerImageView.image = bannerImage
                            UIView.animateWithDuration(0.4, animations: {
                                cell.bannerImageView.alpha = 1.0
                            })
                        }
                    })
                } else {
                    print("image wasn't initialized")
                    dispatch_async(dispatch_get_main_queue(), {
                        cell.seriesNameLabel.text = seriesInfo.seriesName
                    })

                }
                
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchResultTVC") as! SearchResultTableViewCell
       
        let seriesInfo = seriesArray[indexPath.row]
        cell.bannerImageView.image = UIImage(named: "White_square.png")
        cell.seriesNameLabel.text = ""
        if seriesInfo.bannerImage != nil {
            cell.bannerImageView.image = seriesInfo.bannerImage
        } else {
            setSeriesBannerInCell(seriesInfo, cell: cell, indexPath: indexPath)

        }
        
        return cell
    }
    
    //MARK - Tableview Delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let seriesPicked = seriesArray[indexPath.row]
               HUD.show(.Progress)
        
        TVDBClientManager.sharedInstance.addSeriesToCoreData(seriesPicked) { (success, error) in
            guard error == nil else {
                dispatch_async(dispatch_get_main_queue(), {
                    HUD.show(.LabeledError(title: "Unable to add this Series", subtitle: error?.localizedDescription))
                    HUD.hide(afterDelay: 1.0)
                })
                return
            }
            
            if success {
                print("Series successfully added")
            }
            dispatch_async(dispatch_get_main_queue(), {
                HUD.flash(.Success, delay: 1.0) { _ in
                    self.delegate?.addSeriesPicker(self, didAddSeries: seriesPicked)
                }
            })
        }

        
    }
    
    
    //MARK - SearchBar Delegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        hideKeyboard()
        if spinner == nil {
            spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
            
            spinner?.center = CGPointMake(searchBar.bounds.width - 25.0 - (spinner?.frame.size.width)!, searchBar.bounds.height / 2.0)
            spinner?.hidesWhenStopped = true
            searchBar.addSubview(spinner!)
        }

        spinner?.startAnimating()
        
        if let searchTerm = searchBar.text {
            TVDBClientManager.sharedInstance.searchForSeriesByName(searchTerm, completionHandlerForSearchForSeriesByName: { (result, error) in
                guard error == nil else {
                    print("Error search for Series: \(error!.localizedDescription)")
                    dispatch_async(dispatch_get_main_queue(), { 
                        self.spinner?.stopAnimating()
                        let alertController = UIAlertController(title: "Series Not Found", message: error!.localizedDescription, preferredStyle: .Alert)
                        alertController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                        self.presentViewController(alertController, animated: true, completion: nil)
                    })
                    return
                }
                
                if let result = result {
                    self.seriesArray = result
                    dispatch_async(dispatch_get_main_queue(), { 
                        self.seriesTableView.reloadData()
                        self.spinner?.stopAnimating()
                    })
                }
            })
        }
    }
    
}
