//
//  CASettingInfo.swift
//  ClickAccountingApp
//
//  Created by Deepak Kumar on 6/29/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit

class CASettingInfo: NSObject {

    var titleString = String()
    var valueString = String()
    var isSwitchOn = Bool()

    
    class func getSettingInfo(tempDict : Dictionary<String, Any>) -> CASettingInfo {
        
        let settingInfo = CASettingInfo()
        
        settingInfo.titleString = tempDict.validatedValue("title", expected: "" as AnyObject) as! String
        settingInfo.valueString = tempDict.validatedValue("value", expected: "" as AnyObject) as! String
        settingInfo.isSwitchOn = tempDict.validatedValue("switchStatus", expected: false as AnyObject) as! Bool
        
        return settingInfo
    }
    
    
}
