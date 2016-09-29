//
//  SeriesInfoTableViewCell.swift
//  Did I Watch It
//
//  Created by Yan Zverev on 9/19/16.
//  Copyright © 2016 Yan Zverev. All rights reserved.
//

import UIKit

class SeriesInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var seriesImageView: UIImageView!
    @IBOutlet weak var seriesNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
