//
//  SectionCollectionReusableView.swift
//  ClickAccountingApp
//
//  Created by apptology on 12/20/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit

class SectionCollectionReusableView: UICollectionReusableView {

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func loadCellData(string : String){
        self.sectionTitleLabel.text = string
    }
    
    func loadAmountData(string : String){
        self.amountLabel.text = string
    }
    
    @IBOutlet var sectionTitleLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    
}
