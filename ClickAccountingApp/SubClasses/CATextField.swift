//
//  CATextField.swift
//  ClickAccountingApp
//
//  Created by Deepak Kumar on 6/30/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit

class CATextField: UITextField {

    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        
    }
    public func placeHolderText(withColor text: String, andColor color: UIColor)
    {
        if (text.characters.count != 0) {
            //for avoiding nil placehoder
            attributedPlaceholder = NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName: color])
        }
    }

    
}
