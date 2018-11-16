//
//  CAForgotPasswordViewController.swift
//  ClickAccountingApp
//
//  Created by Chandan Mishra on 29/06/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit

class CAForgotPasswordViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var tableViewForgotPassword: UITableView!
    @IBOutlet var footerView: UIView!
    @IBOutlet var headerView: UIView!
    
    var forgotPasswordInfo = CAUserInfo()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
        // Do any additional setup after loading the view.
    }

  func initialSetup(){
    
    self.tableViewForgotPassword.tableHeaderView = headerView
    self.tableViewForgotPassword.tableFooterView = footerView
    self.tableViewForgotPassword.allowsSelection=false
    
    // For registereing nib
    self.tableViewForgotPassword.register(UINib(nibName: "ForgotPasswordTableViewCell", bundle: nil), forCellReuseIdentifier: "ForgotPasswordTableViewCell")
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDataSource Methods.
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 1;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForgotPasswordTableViewCell", for: indexPath) as? ForgotPasswordTableViewCell
        
        // cell?.backgroundColor = UIColor.clear
        cell?.forgotPasswordTextField.autocorrectionType = .no
        cell?.forgotPasswordTextField.delegate = self as UITextFieldDelegate
        cell?.forgotPasswordTextField.keyboardType = .default
        cell?.forgotPasswordTextField.returnKeyType = .done
        
        cell?.forgotPasswordTextField.tag = indexPath.row + 100;
        switch indexPath.row
        {
        case 0:
            if forgotPasswordInfo.emailErrorString.length != 0
            {
                cell?.errorLabel.text = forgotPasswordInfo.emailErrorString
                cell?.seperatorLabel.backgroundColor = RGBA(246.0, g: 23.0, b: 0.0, a: 1.0)
            }
            else {
                cell?.errorLabel.text = ""
                cell?.seperatorLabel.backgroundColor = RGBA(104.0, g: 104.0, b: 104.0, a: 1.0)
            }
            cell?.forgotPasswordTextField.placeHolderText(withColor: "Email ID", andColor: RGBA(17.0, g: 43.0, b: 88.0, a: 1.0))
           // cell?.forgotPasswordTextField.placeholder="Email ID";
            cell?.forgotPasswordTextField.keyboardType = .emailAddress
            
            cell?.forgotPasswordTextField.text = forgotPasswordInfo.emailString
        default: break
        }
        return cell!
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.row == 0 {
            if  forgotPasswordInfo.emailErrorString.trimWhiteSpace().length == 0
            {
                return 50
            }
            else {
                return 70
            }
        }
        return 80
    }
    
    //MARK: - UITextFieldDelegates Methods.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.textInputMode?.primaryLanguage == "emoji") || !((textField.textInputMode?.primaryLanguage) != nil) {
            return false
        }
        var str:NSString = textField.text! as NSString
        str = str.replacingCharacters(in: range, with: string) as NSString
        switch textField.tag {
        case 100:
            if str.length > 80 {
                return false
            }
            break
        default:
            break
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case 100:
            forgotPasswordInfo.emailString = textField.text!
        default:
            break;
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .done
        {
//            let tf: UITextField? = (view.viewWithTag(textField.tag + 1) as? UITextField)
//            tf?.becomeFirstResponder()
//        }
//        else {
            view.endEditing(true)
        }
        return true
    }
    
    //MARK: - validation Methods.
    func isallFieldsVerfield() -> Bool {
        
        var isvalid = false
        if forgotPasswordInfo.emailString.trimWhiteSpace().length == 0 {
            forgotPasswordInfo.emailErrorString = "*Please enter your email ID."
            isvalid = false
        }
        else if forgotPasswordInfo.emailString.isEmail() == false {
            forgotPasswordInfo.emailErrorString = "*Please enter your valid email ID."
            isvalid = false
        }
        else {
            isvalid = true
        }
        self.tableViewForgotPassword.reloadData()
        return isvalid;
    }
    
    //MARK: - UI Button Actions 
    
    @IBAction func submitButtonAction(_ sender: UIButton)
    {
        self.view.endEditing(true)
        if  isallFieldsVerfield() {
        
            let paramDict : Dictionary<String, AnyObject> = [
                kEmail : forgotPasswordInfo.emailString as AnyObject
            ]
            
            print(paramDict)
            
            
            ServiceHelper.sharedInstanceHelper.createPostRequest(method: .post, showHud: true, params: paramDict, apiName: "Customer_Api/forget") { (result, error) in
                
                if(!(error != nil)){
                    if (result![kResponseCode]! as? String == "200"){
                        presentAlert(kZoddl, msgStr:"We have sent an email to this registered email id. Please login again." as? String, controller: self)
                    }
                    else {
                        presentAlert(kZoddl, msgStr: result![kResponseMessage]! as? String, controller: self)
                    }
                    
                } else {
                    presentAlert("", msgStr: error?.localizedDescription, controller: self)
                }
                
            }
        }
    }
    
    
    @IBAction func backButtonAction(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
   }
    

}













