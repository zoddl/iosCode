//
//  CASettingTableViewCell.swift
//  ClickAccountingApp
//
//  Created by Deepak Kumar on 6/29/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit

class CASettingTableViewCell: UITableViewCell {

    @IBOutlet var valueLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var arrowImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
