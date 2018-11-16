//
//  CAGalleryCollectionViewCell.swift
//  ClickAccountingApp
//
//  Created by Chandan Mishra on 30/06/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit

class CAGalleryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var tagNameLabel: UILabel!
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        tagNameLabel.clipsToBounds = true
        tagNameLabel.layer.cornerRadius = 13
        // Initialization code
    }
}
