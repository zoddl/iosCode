//
//  CATagCollectionCell.swift
//  ClickAccountingApp
//
//  Created by Ashish Kumar Gupta on 30/06/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit

class CATagCollectionCell: UICollectionViewCell {

 @IBOutlet var tagBtn: UIButton!
 @IBOutlet var tickImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.tagBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        let myString: NSString = (self.tagBtn.titleLabel?.text!)! as String as NSString
        let size: CGSize = myString.size(attributes: [NSFontAttributeName: UIFont.init(name: "Calibri", size: 16.0)!])
        self.tagBtn.frame.size.width = size.width + 7
        print(self.tagBtn.frame.size.width)

        if(self.tagBtn.frame.size.width < 130){
            self.tagBtn.frame.size.width = 140
        }else{
             self.tagBtn.frame.size.width = size.width + 30
        }
       self.tagBtn.layer.cornerRadius =  15.0

    }
    
}

