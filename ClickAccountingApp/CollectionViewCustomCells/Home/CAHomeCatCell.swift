//  CAHomeCatCell.swift
//  ClickAccountingApp
//  Created by Ashish Kumar Gupta on 30/06/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.

import UIKit

class CAHomeCatCell: UICollectionViewCell, UIWebViewDelegate {
   // @IBOutlet var dateLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var tagNameLabel: UILabel!
    @IBOutlet var categoryColorLabel: UILabel!
    @IBOutlet var categoryBtn: UIButton!
    @IBOutlet var categoryTypeLabel: UILabel!
    @IBOutlet var bgView: UIView!
    @IBOutlet var categoryImage: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.categoryColorLabel.clipsToBounds = true
        self.bgView.clipsToBounds = true
        self.categoryColorLabel.layer.cornerRadius = 5
        self.bgView.layer.cornerRadius = 5
    }
    

}
