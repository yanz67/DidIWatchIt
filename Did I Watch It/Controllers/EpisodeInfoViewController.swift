//
//  EpisodeInfoViewController.swift
//  Did I Watch It
//
//  Created by Yan Zverev on 9/26/16.
//  Copyright © 2016 Yan Zverev. All rights reserved.
//

import UIKit
import CoreData


class EpisodeInfoViewController: UIViewController
{
    var episode: Episode?

    @IBOutlet weak var didIWatchItSwitch: UISwitch!
    @IBOutlet weak var episodeInfoLabel: UILabel!
    @IBOutlet weak var episodeTitleLabel: UILabel!
    @IBOutlet weak var episodeOverViewTextField: UITextView!
    @IBOutlet weak var didIWatchItButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let episode = episode {
            episodeTitleLabel.text = episode.episodeName
            episodeOverViewTextField.text = episode.episodeOverview
            episodeInfoLabel.text = "Season: \(episode.airedSeason!) \nEpisode: \(episode.airedEpisodeNumber!)"
            setSwitchDidIwatchitOrNot()
        }
    }

    
    private func setSwitchDidIwatchitOrNot()
    {
        if let didIWatchIt = episode?.didIWatchIt {
            didIWatchItSwitch.on = didIWatchIt == 0 ? false : true
        }
    }
    
    @IBAction func didIWatchItSwitchChanged(sender: UISwitch)
    {
        if let episode = episode {
            TVDBClientManager.sharedInstance.setEpisodeDidIWatchitOrNot(episode, completionHandlerSetEpisodeDidIwatchItOrNot: { (success) in
                dispatch_async(dispatch_get_main_queue(), {
                    self.setSwitchDidIwatchitOrNot()
                    let title = self.didIWatchItSwitch.on  ? "I Watched It" : "I Didn't Watch It"
                    HUD.flash(.Label(title), delay: 0.3)
                })
            })
        }

    }
    
}
