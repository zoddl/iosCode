//
//  CAChangePasswordViewController.swift
//  ClickAccountingApp
//
//  Created by Chandan Mishra on 29/06/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit

class CAChangePasswordViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate
{
    @IBOutlet var FooterView: UIView!
    @IBOutlet var HeaderView: UIView!
    @IBOutlet weak var tableViewChangePassword: UITableView!
    var changePasswordInfo = CAUserInfo()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialSetup()
        
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func initialSetup() {
        changePasswordInfo.oldPasswordString = ""
        changePasswordInfo.newPasswordString = ""
        changePasswordInfo.confirmPasswordString = ""
        self.tableViewChangePassword.tableHeaderView = HeaderView
        self.tableViewChangePassword.tableFooterView = FooterView
        //   tableViewResetPassword.separatorStyle = UITableViewCellStyle.None
        
        self.tableViewChangePassword.allowsSelection=false
        // For registereing nib
        self.tableViewChangePassword.register(UINib(nibName: "ForgotPasswordTableViewCell", bundle: nil), forCellReuseIdentifier: "ForgotPasswordTableViewCell")
    }
     // MARK: - UITableViewDataSource Methods.
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 3;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
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
            if changePasswordInfo.oldPasswordErrorString.length != 0
            {
                cell?.errorLabel.text = changePasswordInfo.oldPasswordErrorString
                cell?.seperatorLabel.backgroundColor = RGBA(246.0, g: 23.0, b: 0.0, a: 1.0)
            }else{
                cell?.errorLabel.text = ""
                cell?.seperatorLabel.backgroundColor = RGBA(104.0, g: 104.0, b: 104.0, a: 1.0)
            }
            cell?.forgotPasswordTextField.placeHolderText(withColor: "Old Password", andColor: RGBA(17.0, g: 43.0, b: 88.0, a: 1.0))

            //cell?.forgotPasswordTextField.placeholder="Old Password";
            cell?.forgotPasswordTextField.isSecureTextEntry = true
            cell?.forgotPasswordTextField.text = changePasswordInfo.oldPasswordString
            break
        case 1:
            if changePasswordInfo.newPasswordErrorString.length != 0
            {
                cell?.errorLabel.text = changePasswordInfo.newPasswordErrorString
                cell?.seperatorLabel.backgroundColor = RGBA(246.0, g: 23.0, b: 0.0, a: 1.0)
            }else{
                cell?.errorLabel.text = ""
                cell?.seperatorLabel.backgroundColor = RGBA(104.0, g: 104.0, b: 104.0, a: 1.0)
            }
            cell?.forgotPasswordTextField.placeHolderText(withColor: "New Password", andColor: RGBA(17.0, g: 43.0, b: 88.0, a: 1.0))

            //cell?.forgotPasswordTextField.placeholder="New Password";
            cell?.forgotPasswordTextField.isSecureTextEntry = true
            cell?.forgotPasswordTextField.text = changePasswordInfo.newPasswordString
            break
        case 2:
            
            if changePasswordInfo.confirmPasswordErrorString.length != 0
            {
                cell?.errorLabel.text = changePasswordInfo.confirmPasswordErrorString
                cell?.seperatorLabel.backgroundColor = RGBA(246.0, g: 23.0, b: 0.0, a: 1.0)
            }else
            {
                cell?.errorLabel.text = ""
                cell?.seperatorLabel.backgroundColor = RGBA(104.0, g: 104.0, b: 104.0, a: 1.0)
            }
            cell?.forgotPasswordTextField.placeHolderText(withColor: "Confirm New Password", andColor: RGBA(17.0, g: 43.0, b: 88.0, a: 1.0))

           // cell?.forgotPasswordTextField.placeholder="Confirm New Password";
            cell?.forgotPasswordTextField.returnKeyType = .done
            cell?.forgotPasswordTextField.isSecureTextEntry = true
            cell?.forgotPasswordTextField.text = changePasswordInfo.confirmPasswordString
            break
            
        default:
            break
        }
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.row == 0
        {
            if  changePasswordInfo.oldPasswordErrorString.trimWhiteSpace().length == 0
            {
                return 50
            }else{
                return 65
            }
            
        }
        
            if indexPath.row == 1
        {
            if  changePasswordInfo.newPasswordErrorString.trimWhiteSpace().length == 0
            {
                return 50
            }
            else
            {
                return 65
            }
        }
    
            if indexPath.row == 2
            {
                if  changePasswordInfo.confirmPasswordErrorString.trimWhiteSpace().length == 0
                {
                    return 50
                }
                else
                {
                    return 65
                }
        }
    return 60
    }
    
    
    //MARK: - UITextFieldDelegates Methods.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        if (textField.textInputMode?.primaryLanguage == "emoji") || !((textField.textInputMode?.primaryLanguage) != nil) {
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
        case 101:
            if str.length > 16
            {
                return false
            }
            
        case 102:
            
            if str.length > 16
            {
                return false
            }
            break
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
            changePasswordInfo.oldPasswordString = textField.text!
            break
            
        case 101:
            changePasswordInfo.newPasswordString = textField.text!
            
            break
            
        case 102:
            changePasswordInfo.confirmPasswordString=textField.text!
        default:
            break;
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField.returnKeyType == .next {
            let tf: UITextField? = (view.viewWithTag(textField.tag + 1) as? UITextField)
            tf?.becomeFirstResponder()
        }
        else
        {
            view.endEditing(true)
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    //MARK: - validation Methods.
    func isallFieldsVerfield() -> Bool
    {
        var isvalid = false
        changePasswordInfo.newPasswordErrorString = ""
        changePasswordInfo.oldPasswordErrorString = ""
        changePasswordInfo.confirmPasswordErrorString = ""
        
        if changePasswordInfo.oldPasswordString.trimWhiteSpace().length == 0
        {
            changePasswordInfo.oldPasswordErrorString = "*Please enter old password."
            isvalid = false
        }
        else if changePasswordInfo.oldPasswordString.length < 8
        {
            changePasswordInfo.oldPasswordErrorString = "*Password must be of atleast 8 characters."
            isvalid = false
        }
        else if changePasswordInfo.newPasswordString.trimWhiteSpace().length == 0
        {
            changePasswordInfo.newPasswordErrorString = "*Please enter new password."
            isvalid = false
        }
        else if changePasswordInfo.newPasswordString.length < 8
        {
            changePasswordInfo.newPasswordErrorString = "*New password must be of atleast 8 characters."
            isvalid = false
        }
        else if changePasswordInfo.confirmPasswordString.trimWhiteSpace().length == 0
        {
            changePasswordInfo.confirmPasswordErrorString = "*Please enter confirm new password."
            isvalid = false
        }
        else
            if(changePasswordInfo.newPasswordString != changePasswordInfo.confirmPasswordString)
        {
            changePasswordInfo.confirmPasswordErrorString = "*New password and confirm new password must be same."
            isvalid = false
        }
        else
        {
            isvalid = true
        }
        self.tableViewChangePassword.reloadData()
        return isvalid;
    }
    @IBAction func SubmitButtonAction(_ sender: UIButton)
    {
        self.view.endEditing(true)
        if  isallFieldsVerfield()
        {
            print("Hello")
            //self.navigationController?.popViewController(animated: true)
        }
    
        

        
    }
    @IBAction func backButtonAction(_ sender: UIButton)
    {
        
        self.navigationController?.popViewController(animated: true)
        
       
    }

    
    
    
    
    
}
