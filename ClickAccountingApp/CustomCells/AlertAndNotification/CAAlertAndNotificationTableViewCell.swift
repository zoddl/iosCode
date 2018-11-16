//
//  CAAlertAndNotificationTableViewCell.swift
//  ClickAccountingApp
//
//  Created by Deepak Kumar on 6/29/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit

class CAAlertAndNotificationTableViewCell: UITableViewCell {

    @IBOutlet var notificationImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var contentLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
