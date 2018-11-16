//
//  CAResetViewController.swift
//  ClickAccountingApp
//
//  Created by Chandan Mishra on 29/06/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit

class CAResetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate
{

    @IBOutlet var footerView: UIView!
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var tableViewResetPassword: UITableView!
    
    
    var resetPasswordInfo = CAUserInfo()

    override func viewDidLoad()
    {
        super.viewDidLoad()
self.initialSetup()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: - Helper Methods
    func initialSetup()
    {
        
       

     resetPasswordInfo.newPasswordString=""
    resetPasswordInfo.confirmPasswordString=""
        
    self.tableViewResetPassword.tableHeaderView = headerView
    self.tableViewResetPassword.tableFooterView = footerView
    //   tableViewResetPassword.separatorStyle = UITableViewCellStyle.None
        
    self.tableViewResetPassword.allowsSelection=false
    // For registereing nib
    self.tableViewResetPassword.register(UINib(nibName: "ForgotPasswordTableViewCell", bundle: nil), forCellReuseIdentifier: "ForgotPasswordTableViewCell")
    }
    // MARK: - UITableViewDataSource Methods.
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 2;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForgotPasswordTableViewCell", for: indexPath) as? ForgotPasswordTableViewCell
        
        cell?.backgroundColor = UIColor.clear
        cell?.forgotPasswordTextField.autocorrectionType = .no
        cell?.forgotPasswordTextField.delegate = self as UITextFieldDelegate
        cell?.forgotPasswordTextField.keyboardType = .default
        cell?.forgotPasswordTextField.returnKeyType = .next
        cell?.forgotPasswordTextField.tag = indexPath.row + 100;
       
        switch indexPath.row
        {
        case 0:
            if resetPasswordInfo.newPasswordErrorString.length != 0
            {
                cell?.errorLabel.text = resetPasswordInfo.newPasswordErrorString
                cell?.seperatorLabel.backgroundColor = RGBA(246.0, g: 23.0, b: 0.0, a: 1.0)
            }else
            {
                cell?.errorLabel.text = ""
                
                cell?.seperatorLabel.backgroundColor = RGBA(104.0, g: 104.0, b: 104.0, a: 1.0)
            }
            cell?.forgotPasswordTextField.placeHolderText(withColor: "New Password", andColor: RGBA(17.0, g: 43.0, b: 88.0, a: 1.0))

           // cell?.forgotPasswordTextField.placeholder="New Password";
            cell?.forgotPasswordTextField.keyboardType = .emailAddress
            cell?.forgotPasswordTextField.text = resetPasswordInfo.newPasswordString
            
        default:
            if resetPasswordInfo.confirmPasswordErrorString.length != 0
            {
                cell?.errorLabel.text = resetPasswordInfo.confirmPasswordErrorString
                cell?.seperatorLabel.backgroundColor = RGBA(246.0, g: 23.0, b: 0.0, a: 1.0)
            }else{
                cell?.errorLabel.text = ""
                cell?.seperatorLabel.backgroundColor = RGBA(104.0, g: 104.0, b: 104.0, a: 1.0)
            }
            cell?.forgotPasswordTextField.placeHolderText(withColor: "Confirm Password", andColor: RGBA(17.0, g: 43.0, b: 88.0, a: 1.0))

            //cell?.forgotPasswordTextField.placeholder="Confirm Password";
            cell?.forgotPasswordTextField.returnKeyType = .done
            cell?.forgotPasswordTextField.isSecureTextEntry = true
            cell?.forgotPasswordTextField.text = resetPasswordInfo.confirmPasswordString
        }
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.row == 0
        {
            if  resetPasswordInfo.newPasswordErrorString.trimWhiteSpace().length == 0
            {
                return 50
            }
            else
            {
                return 70
            }
            
        }
        else
        {
            if  resetPasswordInfo.confirmPasswordErrorString.trimWhiteSpace().length == 0 {
                return 50
            }
            else
            {
                return 70
            }
        }
    }
    //MARK: - UITextFieldDelegates Methods.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.textInputMode?.primaryLanguage == "emoji") || !((textField.textInputMode?.primaryLanguage) != nil)
        {
            return false
        }
        
        var str:NSString = textField.text! as NSString
        str = str.replacingCharacters(in: range, with: string) as NSString
        switch textField.tag
        
        {
        case 100:
            if str.length > 16
            {
                return false
            }
            break
            
        case 101:
            if str.length>16
            {
                return false
            }
        default:
            break
        }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        switch textField.tag
        {
        case 100:
            resetPasswordInfo.newPasswordString = textField.text!
        break
        case 101:
            resetPasswordInfo.confirmPasswordString = textField.text!
        break
                default:
                        break;
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField.returnKeyType == .next
        {
            let tf: UITextField? = (view.viewWithTag(textField.tag + 1) as? UITextField)
            tf?.becomeFirstResponder()
        }
        else {
            view.endEditing(true)
        }
        return true
    }
    //MARK: - validation Methods.
    func isallFieldsVerfield() -> Bool
    {
        var isvalid = false
        
        if resetPasswordInfo.newPasswordString.trimWhiteSpace().length == 0
        {
            resetPasswordInfo.newPasswordErrorString = "*Please enter your new password."
            resetPasswordInfo.confirmPasswordErrorString = ""
            isvalid = false
            
        } else if resetPasswordInfo.newPasswordString.length < 8
        {
            resetPasswordInfo.newPasswordErrorString = ""
            resetPasswordInfo.newPasswordErrorString = "*Password must be of atleast 8 characters."
            isvalid = false
            
        }else if resetPasswordInfo.confirmPasswordString.trimWhiteSpace().length == 0
        {
            resetPasswordInfo.newPasswordErrorString = ""
            resetPasswordInfo.confirmPasswordErrorString = "*Please enter confirm new password."
            isvalid = false
            
        }
       
        else if(resetPasswordInfo.newPasswordString != resetPasswordInfo.confirmPasswordString)
        {
            //resetPasswordInfo.confirmPasswordString = ""
            resetPasswordInfo.confirmPasswordErrorString = "*New password and confirm new password must be same"
            isvalid = false
            
        }
            
        else{
            isvalid = true
        }
        self.tableViewResetPassword.reloadData()
        return isvalid;
    }
    
    
    //-----MARK UI Button Action\\----
    
    
    @IBAction func backButtonAction(_ sender: Any) {
    }
    
    @IBAction func SubmitButtonAction(_ sender: Any)
    
    {
    
        self.view.endEditing(true)
        if  isallFieldsVerfield(){
            print("Hello")
        
    }

    }}
