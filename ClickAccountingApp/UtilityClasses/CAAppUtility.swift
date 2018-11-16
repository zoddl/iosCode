//
//  CAAppUtility.swift
//  ClickAccountingApp
//
//  Created by Deepak Kumar on 6/28/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import Foundation
import UIKit
let showLog = false



func showHud() {
    let attribute = RappleActivityIndicatorView.attribute(style: RappleStyleCircle, tintColor: .white, screenBG: nil, progressBG: .black, progressBarBG: .lightGray, progreeBarFill: .yellow)
    RappleActivityIndicatorView.startAnimating(attributes: attribute)
}

func hideHud() {
    RappleActivityIndicatorView.stopAnimation()
    RappleActivityIndicatorView.stopAnimation(completionIndicator: .none, completionLabel: "", completionTimeout: 1.0)
}


func drawPDFfromURL(url: URL) -> UIImage? {
   
    guard let document = CGPDFDocument(url as CFURL) else { return nil }
    guard let page = document.page(at: 1) else { return nil }
    
    let pageRect = page.getBoxRect(.mediaBox)
    let renderer = UIGraphicsImageRenderer(size: pageRect.size)
    let img = renderer.image { ctx in
        UIColor.white.set()
        ctx.fill(pageRect)
        
        ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
        ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
        
        ctx.cgContext.drawPDFPage(page)
    }
    
    return img
}




func presentAlert(_ titleStr : String?,msgStr : String?,controller : AnyObject?){
    DispatchQueue.main.async(execute: {
        let alert=UIAlertController(title: titleStr, message: msgStr, preferredStyle: UIAlertControllerStyle.alert);
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil));
        
        //event handler with closure
        controller!.present(alert, animated: true, completion: nil);
    })
}

func presentAlertWithOptions(_ title: String, message: String,controller : AnyObject, buttons:[String], tapBlock:((UIAlertAction,Int) -> Void)?) -> UIAlertController {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet, buttons: buttons, tapBlock: tapBlock)
    controller.present(alert, animated: true, completion: nil)
    
    //        instance.topMostController()?.presentViewController(alert, animated: true, completion: nil)
    return alert
}

private extension UIAlertController {
    
    
    convenience init(title: String?, message: String?, preferredStyle: UIAlertControllerStyle, buttons:[String], tapBlock:((UIAlertAction,Int) -> Void)?) {
        self.init(title: title, message: message, preferredStyle:preferredStyle)
        var buttonIndex = 0
        for buttonTitle in buttons {
            let action = UIAlertAction(title: buttonTitle, preferredStyle: .default, buttonIndex: buttonIndex, tapBlock: tapBlock)
            buttonIndex += 1
            self.addAction(action)
        }
    }
}

private extension UIAlertAction {
    convenience init(title: String?, preferredStyle: UIAlertActionStyle, buttonIndex:Int, tapBlock:((UIAlertAction,Int) -> Void)?) {
        
        
        self.init(title: title, style: preferredStyle) {
            (action:UIAlertAction) in
            if let block = tapBlock {
                block(action,buttonIndex)
            }
        }
    }
}

func RGBA(_ r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat) -> UIColor {
    return UIColor(red: (r/255.0), green: (g/255.0), blue: (b/255.0), alpha: a)
}

func addToolBarOnTextfield(textField: UITextField, target: UIViewController) -> UIToolbar {
    
    let numberToolbar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
    numberToolbar.barStyle = UIBarStyle.default
    numberToolbar.items = [
        UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
        UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: target, action: Selector(("doneWithNumberPad")))]
    numberToolbar.sizeToFit()
    return numberToolbar
}

func doneWithNumberPad() {
 
}

// custom log
func logInfo(_ message: String, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
    if (showLog) {
        print("\(function): \(line): \(message)")
    }
}
extension String {
    
    
    func trimWhiteSpace () -> String
    {
        let trimmedString = self.trimmingCharacters(in: CharacterSet.whitespaces)
        return trimmedString
    }
    
    var length: Int
    {
        return self.characters.count
    }
    
    
    func isValidName() -> Bool
    {
        
        let nameRegEx = "^[a-zA-Z\\s]+$"
        let nameTest = NSPredicate(format:"SELF MATCHES %@", nameRegEx)
        return nameTest.evaluate(with: self)
    }
    
    
    func isEmail() -> Bool
    {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        print(emailTest.evaluate(with: self))
        return emailTest.evaluate(with: self)
    }
    
    
    func isValidNumber() -> Bool
    {
        
        let nameRegEx = "^[0-9]+$"
        let nameTest = NSPredicate(format:"SELF MATCHES %@", nameRegEx)
        return nameTest.evaluate(with: self)
    }
    
    func isPostalCode() -> Bool {
        
        let postalCodeRegex = "^[0-9]+$"
        let postalCodeTest = NSPredicate(format:"SELF MATCHES %@", postalCodeRegex)
        return postalCodeTest.evaluate(with: self)
    }
    
}


func checkNull(inputValue : AnyObject) -> AnyObject{

    if let object = inputValue as? AnyObject{
        
     if object is String {
            if ((object as! String == "null") || (object as! String == "<null>") || (object as! String == "(null)")) {
                //logInfo("null string")
                return "" as AnyObject
            }
        }
        
//        if object is Array<Any> {
//            
//            for json in object as! Array<Any>{
//                let arr = json as! NSDictionary
//                for (_, value) in arr {
//                    if(value is Array<Any>){
//                        
//                    }
//                    else if(value is NSNull ){
//                        return "" as AnyObject
//                    }
//                    else if ((value as! String == "null") || (value as! String == "<null>") || (value as! String == "(null)") || value is NSNull ) {
//                        return "" as AnyObject
//                    }
//                   
//                }
//                
//            }          
//        }
        
        return object
    }
}


extension Date {
    func isInSameWeek(date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .weekOfYear)
    }
    func isInSameMonth(date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .month)
    }
    func isInSameYear(date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .year)
    }
    func isInSameDay(date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .day)
    }
    var isInThisWeek: Bool {
        return isInSameWeek(date: Date())
    }
    var isInToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    var isInTheFuture: Bool {
        return Date() < self
    }
    var isInThePast: Bool {
        return self < Date()
    }
}

extension NSMutableArray{
    
    func removeUploaded() -> NSMutableArray {
      
        let tempTag = NSMutableArray()
        for (index,element) in self.enumerated()
        {
            let localTag = element as! Dictionary<String, AnyObject>
            
            if localTag[kIsUploaded] as! String != "1"
            {
                tempTag.add(localTag)
            }
        }
        return tempTag
    }
    
    
    func noDuplicates(byKey: String) -> NSMutableArray {
      
        var noDuplicates = NSMutableArray()
        var usedNames = [String]()
        for dict in self {
            let tag = dict as! Dictionary<String, AnyObject>
            if let name = tag[byKey] as? String, !usedNames.contains(name) {
                noDuplicates.add(dict)
                usedNames.append(name)
            }
        }
        return noDuplicates
    }
    
    func removeDuplicates(byKey: String) ->NSMutableArray{
        
       // let filtered = NSMutableArray()
        
        for outerIndex in 0..<self.count
        {
            
            let temp1 = self[outerIndex] as! Dictionary<String, AnyObject>
            var found = -1
            for indextAt in 1..<self.count
            {
                
                let temp2 = self[indextAt] as! Dictionary<String, AnyObject>

                if temp1[byKey] as! NSNumber == temp2[byKey] as! NSNumber{

                    found = indextAt
                    break
                }
            }

            if found > -1
            {
                self.removeObject(at: found)
            }
        }

        print(self)
        return self
    }

    
}


// MARK:- Dictionary Extensions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

extension Dictionary {
    mutating func unionInPlace(
        _ dictionary: Dictionary<Key, Value>) {
        for (key, value) in dictionary {
            self[key] = value
        }
    }
    
    mutating func unionInPlace<S: Sequence>(_ sequence: S) where S.Iterator.Element == (Key,Value) {
        for (key, value) in sequence {
            self[key] = value
        }
    }
    
    func validatedValue(_ key: Key, expected: AnyObject) -> AnyObject {
        
        // checking if in case object is nil
        
        if let object = self[key] as? AnyObject{
            
            // added helper to check if in case we are getting number from server but we want a string from it
            if object is NSNumber && expected is String {
                
                //logInfo("case we are getting number from server but we want a string from it")
                
                return "\(object)" as AnyObject
            }
                
                // checking if object is of desired class
            else if (object.isKind(of: expected.classForCoder) == false) {
                //logInfo("case // checking if object is of desired class....not")
                
                return expected
            }
                
                // checking if in case object if of string type and we are getting nil inside quotes
            else if object is String {
                if ((object as! String == "null") || (object as! String == "<null>") || (object as! String == "(null)")) {
                    //logInfo("null string")
                    return "" as AnyObject
                }
            }
            
            return object
        }
        else {
            
            if expected is String || expected as! String == "" {
                return "" as AnyObject
            }
            
            return expected
        }
    }
 
}


