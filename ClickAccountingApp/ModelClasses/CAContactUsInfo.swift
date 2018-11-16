//
//  CAContactUsInfo.swift
//  ClickAccountingApp
//
//  Created by Sunil Datt Joshi on 29/06/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit

class CAContactUsInfo: NSObject
{

    var nameString = String()
    var emailString = String()
    var mobileNumberString = String()
    var messageString = String()
    var emailErrorString = String()
    var messageErrorString = String()
    var mobileNumberErrorString = String()
    var nameErrorString = String()
    var email : String = "djkjdfk@jkfd.dfd"
    var mobileNumber : String = "1234567890"
    var website : String = "gdshg@jkd.dsd"
    var messageLabel = String()
    var dateLabel  = String()
    var questionLabel = String()
    var answerLabel = String()

    class func getPayementList(responseArray : Array<Dictionary<String, String>>) -> Array<CAContactUsInfo> {
        var PayementArray = Array<CAContactUsInfo>()
        for payementItem in responseArray {
            let payementObj = CAContactUsInfo()
            payementObj.messageLabel = payementItem["Message"]!
            payementObj.dateLabel = payementItem["Date"]!
       PayementArray.append(payementObj)
}
return PayementArray
    }


  
    class func getFaqList(responseArray : Array<Dictionary<String, String>>) -> Array<CAContactUsInfo> {
        var faqArray = Array<CAContactUsInfo>()
        for faqItem in responseArray {
            let faqObj = CAContactUsInfo()
            faqObj.questionLabel = faqItem["questionLabel"]!
            faqObj.answerLabel = faqItem["answerLabel"]!
            faqArray.append(faqObj)
        }
        return faqArray
    }
    
    
    /* class func getContactUsList(responseArray : Array<Dictionary<String, String>>) -> Array<CAContactUsInfo> {
        var contactUsArray = Array<CAContactUsInfo>()
        for contactItem in responseArray {
            let contactObj = CAContactUsInfo()
            contactObj.email = contactItem["emailLabel"]!
            contactObj.mobileNumber = contactItem["mobileLabel"]!
            contactObj.website = contactItem["websiteLabel"]!

            contactUsArray.append(contactObj)
        }
        return contactUsArray
    }
*/


}
