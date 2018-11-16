//
//  CAHomeCollectionViewCell.swift
//  ClickAccountingApp
//
//  Created by apptology on 3/22/18.
//  Copyright © 2018 Mobiloitte. All rights reserved.
//

import UIKit

class CAHomeCollectionViewCell: UICollectionViewCell {

    @IBOutlet var primaryAmount: UILabel!
    @IBOutlet var primaryName: UILabel!
    @IBOutlet var typeIcon: UIImageView!
    @IBOutlet var detailButtonAction: UIButton!
    @IBOutlet var categoryTypeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
