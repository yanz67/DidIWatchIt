//
//  SearchResultTableViewCell.swift
//  Did I Watch It
//
//  Created by Yan Zverev on 9/13/16.
//  Copyright © 2016 Yan Zverev. All rights reserved.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell
{
    @IBOutlet weak var seriesNameLabel: UILabel!

    @IBOutlet weak var bannerImageView: UIImageView!

    var isLoadingBanner: Bool = false

}
