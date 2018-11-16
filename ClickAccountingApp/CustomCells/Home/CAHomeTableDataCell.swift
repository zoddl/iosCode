//
//  CAHomeTableDataCell.swift
//  ClickAccountingApp
//
//  Created by Ashish Kumar Gupta on 30/06/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit

class CAHomeTableDataCell: UITableViewCell {
    
    @IBOutlet var serialNoLabel: UILabel!
    @IBOutlet var top5CMinusLabel: UILabel!
    @IBOutlet var top5CPlusLabel: UILabel!
    @IBOutlet var top5BPlusLabel: UILabel!
    @IBOutlet var top5BMinusLabel: UILabel!
    @IBOutlet var otherLabel: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
