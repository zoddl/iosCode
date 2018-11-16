//
//  CAEditProfileButtonTableViewCell.swift
//  ClickAccountingApp
//
//  Created by Deepak Kumar on 6/29/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit

class CAEditProfileButtonTableViewCell: UITableViewCell {

    @IBOutlet var dropDownImageView: UIImageView!
    @IBOutlet var dropDownView: HADropDown!
    @IBOutlet var valueLabel: UILabel!
    @IBOutlet var dropDownButton: UIButton!
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
