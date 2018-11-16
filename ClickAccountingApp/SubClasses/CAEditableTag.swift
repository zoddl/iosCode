//
//  CAEditableTag.swift
//  ClickAccountingApp
//
//  Created by apptology on 12/19/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit

class CAEditableTag: UITextField {

    
    func getWidth(text: String) -> CGFloat
    {
        let txtField = UITextField(frame: .zero)
        txtField.text = text
        txtField.sizeToFit()
        return txtField.frame.size.width
    }
    
}
