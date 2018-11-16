//
//  CAContactUsTableViewCell.swift
//  ClickAccountingApp
//
//  Created by Ratneshwar Singh on 7/1/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit

class CAContactUsTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var seperatorLabel3: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
