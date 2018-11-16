//
//  CAFAQTableViewCell.swift
//  ClickAccountingApp
//
//  Created by Sunil Datt Joshi on 01/07/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit

class CAFAQTableViewCell: UITableViewCell {

    @IBOutlet weak var faqAnswerLabel: UILabel!
    @IBOutlet weak var faqQuestionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
