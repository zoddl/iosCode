//
//  PaymentTableViewCell.swift
//  ClickAccountingApp
//
//  Created by Sunil Datt Joshi on 30/06/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit

class PaymentTableViewCell: UITableViewCell {

   
    @IBOutlet weak var sepratorLabel2: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
