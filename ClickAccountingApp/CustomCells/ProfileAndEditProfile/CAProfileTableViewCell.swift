//
//  CAProfileTableViewCell.swift
//  ClickAccountingApp
//
//  Created by Deepak Kumar on 6/30/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit

class CAProfileTableViewCell: UITableViewCell {

    @IBOutlet var iconImageView: UIImageView!
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var valueLabel: UILabel!
    
    @IBOutlet var statusButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
