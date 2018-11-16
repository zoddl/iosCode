//
//  CAMakePaymentInfo.swift
//  ClickAccountingApp
//
//  Created by Sunil Datt Joshi on 30/06/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit

class CAMakePaymentInfo: NSObject {

  var nameString = String()
  var referalString = String()
    var amountString = String()
    var commentString = String()
    var dateLabel = String()
    var messageLabel = String()
    var hifonLabel = String()
    var amountLabel = String()
    var payementType = String()
    var isSelected = Bool()

    

    class func getPayementList(responseArray : Array<Dictionary<String, String>>) -> Array<CAMakePaymentInfo> {
        var PayementArray = Array<CAMakePaymentInfo>()
        for payementItem in responseArray {
            let payementObj = CAMakePaymentInfo()
            payementObj.messageLabel = payementItem["messageLabel"]!
            payementObj.dateLabel = payementItem["dateLabel"]!
          

            PayementArray.append(payementObj)
        }
        return PayementArray
    }


}
