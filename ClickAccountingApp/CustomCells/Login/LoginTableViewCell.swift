//
//  LoginTableViewCell.swift
//  ClickAccountingApp
//
//  Created by Deepak Kumar on 6/28/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit

class LoginTableViewCell: UITableViewCell {

    
    @IBOutlet var loginImageView: UIImageView!
    @IBOutlet var sepratorLabel: UILabel!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var loginTextField: CATextField!
    
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
