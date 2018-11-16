//
//  CAPlanSubscriptionSecondTableViewCell.swift
//  ClickAccountingApp
//
//  Created by Chandan Mishra on 30/06/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit

class CAPlanSubscriptionSecondTableViewCell: UITableViewCell {

    @IBOutlet var radioButtonProperty: UIButton!
   
    @IBOutlet var labelCard: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
 }
