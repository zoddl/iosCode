//
//  CASettingSwitchTableViewCell.swift
//  ClickAccountingApp
//
//  Created by Deepak Kumar on 6/29/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit

class CASettingSwitchTableViewCell: UITableViewCell {

    
    @IBOutlet var switchButton: UISwitch!
    @IBOutlet var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
