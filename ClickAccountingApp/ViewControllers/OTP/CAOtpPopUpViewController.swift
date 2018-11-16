//
//  CAOtpPopUpViewController.swift
//  ClickAccountingApp
//
//  Created by Sunil Datt Joshi on 03/07/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit

protocol navigateToProfle: NSObjectProtocol {

}


class CAOtpPopUpViewController: UIViewController,UITextFieldDelegate {

    
      //MARK: view life cycle
    @IBOutlet weak var popUpView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
       self.initialMethod()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    //MARK: helper methods
    func initialMethod()
    {
     self.popUpView.layer.cornerRadius = 5
    }
    
    //MARK: UITextFieldDelegate methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if ((textField.text?.length)! < 1) && ((string.characters.count ) > 0) {
            let nextTag: Int = textField.tag + 1
            var nextResponder: UIResponder? = textField.superview?.viewWithTag(nextTag)
            if nextResponder == nil {
                nextResponder = textField.superview?.viewWithTag(1001)
            }
            textField.text = string
            if nextResponder != nil {
                nextResponder?.becomeFirstResponder()
            }
            return false
        }
            
            
        else  if ((textField.text?.length)! >= 1) && (string.length == 0) {
            let prevTag: Int = textField.tag - 1
            // Try to find prev responder
            var prevResponder: UIResponder? = textField.superview?.viewWithTag(prevTag)
            if prevResponder == nil {
                prevResponder = textField.superview?.viewWithTag(1001)
            }
            textField.text = string
            if prevResponder != nil {
                // Found next responder, so set it.
                prevResponder?.becomeFirstResponder()
            }
            return false
        }
        else if textField.tag == 1 || textField.tag == 2 || textField.tag == 3 || textField.tag == 4 {
            return (textField.text!.length > 0 && range.length == 0) ? false : true
        }
        
        // upper limit 1
        return true
        
    }

   
    //MARK : UIButton Action
    @IBAction func cancelButtonAction(_ sender: Any) {
    presentAlert("", msgStr: "work in progress...", controller: self)
    }
    @IBAction func submitButtonAction(_ sender: Any) {
   presentAlert("", msgStr: "work in progress...", controller: self)
    }
}
