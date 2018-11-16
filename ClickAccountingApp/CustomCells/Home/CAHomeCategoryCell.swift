//
//  CAHomeCategoryCell.swift
//  ClickAccountingApp
//
//  Created by Ashish Kumar Gupta on 30/06/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit

class CAHomeCategoryCell: UITableViewCell {
    
    @IBOutlet var categoryCollectionView: UICollectionView!
    @IBOutlet var categoryNameLabel: UILabel!
    @IBOutlet var categoryPriceLabel: UILabel!
    @IBOutlet var seeAllBtn: UIButton!



    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
