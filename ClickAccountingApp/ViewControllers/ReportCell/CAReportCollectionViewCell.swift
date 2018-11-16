//
//  CAReportCollectionViewCell.swift
//  ClickAccountingApp
//
//  Created by apptology on 3/14/18.
//  Copyright © 2018 Mobiloitte. All rights reserved.
//

import UIKit

class CAReportCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var title1: UILabel!
    @IBOutlet var title2: UILabel!
    @IBOutlet var title3: UILabel!
    @IBOutlet var title4: UILabel!
    @IBOutlet var title5: UILabel!
    @IBOutlet var reportBackgroundView: UIView!
    @IBOutlet var downButton: UIButton!
    @IBOutlet var reportDetailButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
