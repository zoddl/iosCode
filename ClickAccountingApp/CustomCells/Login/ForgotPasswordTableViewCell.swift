//
//  ForgotPasswordTableViewCell.swift
//  ClickAccountingApp
//
//  Created by Chandan Mishra on 29/06/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit

class ForgotPasswordTableViewCell: UITableViewCell {

    @IBOutlet weak var seperatorLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var forgotPasswordTextField: CATextField!
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
