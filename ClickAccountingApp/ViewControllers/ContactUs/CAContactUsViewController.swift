//
//  CAContactUsViewController.swift
//  ClickAccountingApp
//
//  Created by Sunil Datt Joshi on 29/06/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit

class CAContactUsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate, AddTagDelegate {
    
    @IBOutlet var sectionHeaderView2: UIView!
    @IBOutlet var sectionHeaderView1: UIView!
    @IBOutlet var sectionFooterView: UIView!
    @IBOutlet weak var sendButtonOutlet: UIButton!
    @IBOutlet weak var contactusTableView: UITableView!
    
    var contactUsInfo = CAContactUsInfo()
    
    var dateLabel : String = "17/06/2017"
    var messageLabel: String = "please mail me"
    var emailLabel : String = "jjkk@cx.ccc"
    var emailTitle : String = "email"
    var emailIcon : String = ""
    var mobileLabel : String = "12345454564"
    var mobileTitle : String = "Mobile"
    var MobileIcon : String = ""
    var websiteLabel : String = "djfk@hjf.dff"
    var websiteTitle : String = "Website"
    var websiteIcon : String = ""
    var payementType : String = ""
    var payementArray = [CAContactUsInfo]()
    var contactUsArray = [CAContactUsInfo]()
    
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialMethod()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Helper Methods
    func initialMethod()
    {
        contactUsInfo.nameString = ""
        contactUsInfo.emailString = ""
        contactUsInfo.mobileNumberString = ""
        contactUsInfo.messageString = ""
        self.getContactPageInfo()
        self.navigationController?.isNavigationBarHidden = true
        self.contactusTableView.register(UINib(nibName:"ForgotPasswordTableViewCell",bundle: nil), forCellReuseIdentifier:"ForgotPasswordTableViewCell")
        self.contactusTableView.register(UINib(nibName: "PaymentTableViewCell", bundle: nil),forCellReuseIdentifier:"PaymentTableViewCell")
        self.contactusTableView.register(UINib(nibName: "CAContactUsTableViewCell", bundle: nil),forCellReuseIdentifier:"CAContactUsTableViewCell")
        
        self.sendButtonOutlet.layer.cornerRadius = 3
        let   dataSourceArray =
            [
            ["dateLabel": "12/06/2023:" as AnyObject, "messageLabel": "hello how are you" as AnyObject],
            
            ["dateLabel": "18/06/2015:" as AnyObject, "messageLabel": "hello how are you" as AnyObject],
            
            ["dateLabel": "19/06/2017:" as AnyObject, "messageLabel": "hello how are you" as AnyObject]]
        
        
        
    }
    
    //MARK: - UITableView DataSource Methods
        public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if(section == 0)
        {
            return 4
        }
        if(section == 1)
        {
            return 3
        }
        if section == 2
        {
            return payementArray.count
        }
        return 0
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell1 = tableView.dequeueReusableCell(withIdentifier: "ForgotPasswordTableViewCell") as? ForgotPasswordTableViewCell
        let cell2 = tableView.dequeueReusableCell(withIdentifier: "CAContactUsTableViewCell") as? CAContactUsTableViewCell
        let cell3 = tableView.dequeueReusableCell(withIdentifier: "PaymentTableViewCell") as? PaymentTableViewCell
               cell1?.forgotPasswordTextField.autocorrectionType = .no
        cell1?.forgotPasswordTextField.delegate = self as UITextFieldDelegate
        cell1?.forgotPasswordTextField.returnKeyType = .next
        cell1?.forgotPasswordTextField.tag = indexPath.row + 100
        
        //Change selection style
        cell1?.selectionStyle = UITableViewCellSelectionStyle.none
        cell2?.selectionStyle = UITableViewCellSelectionStyle.none
        cell3?.selectionStyle = UITableViewCellSelectionStyle.none
        
        if(indexPath.section == 0 ) {
            self.contactusTableView.separatorStyle = UITableViewCellSeparatorStyle.none
            switch indexPath.row
            {
            case 0:
                if contactUsInfo.nameErrorString.length != 0
                {
                    cell1?.errorLabel.text = contactUsInfo.nameErrorString
                    cell1?.seperatorLabel.backgroundColor = RGBA(246.0, g: 23.0, b: 0.0, a: 1.0)
                }else{
                    cell1?.errorLabel.text = ""
                    cell1?.seperatorLabel.backgroundColor = RGBA(17, g: 43, b: 88, a: 1)
                }
                cell1?.forgotPasswordTextField.placeHolderText(withColor: "Name", andColor: RGBA(199, g: 199, b: 205, a: 1))
                
                cell1?.forgotPasswordTextField.text = contactUsInfo.nameString
                
            case 1:
                if contactUsInfo.emailErrorString.length != 0 {
                    cell1?.errorLabel.text = contactUsInfo.emailErrorString
                    cell1?.seperatorLabel.backgroundColor = RGBA(246.0, g: 23.0, b: 0.0, a: 1.0)
                }
                else {
                    cell1?.errorLabel.text = ""
                    cell1?.seperatorLabel.backgroundColor = RGBA(17, g: 43, b: 88, a: 1)
                }
                cell1?.forgotPasswordTextField.placeHolderText(withColor: "Email", andColor: RGBA(199, g: 199, b: 205, a: 1))
                cell1?.forgotPasswordTextField.keyboardType = .emailAddress
                cell1?.forgotPasswordTextField.text = contactUsInfo.emailString
                
            case 2:
                if contactUsInfo.mobileNumberErrorString.length != 0 {
                    cell1?.errorLabel.text = contactUsInfo.mobileNumberErrorString
                    cell1?.seperatorLabel.backgroundColor = RGBA(246.0, g: 23.0, b: 0.0, a: 1.0)
                }
                else
                {
                    cell1?.errorLabel.text = ""
                    cell1?.seperatorLabel.backgroundColor = RGBA(17, g: 43, b: 88, a: 1)
                }
                cell1?.forgotPasswordTextField.placeHolderText(withColor: "Mobile Number", andColor: RGBA(199, g: 199, b: 205, a: 1))
                cell1?.forgotPasswordTextField.keyboardType = .numberPad
                cell1?.forgotPasswordTextField.text = contactUsInfo.mobileNumberString
                
            default:
                if contactUsInfo.messageErrorString.length != 0 {
                    cell1?.errorLabel.text = contactUsInfo.messageErrorString
                    cell1?.seperatorLabel.backgroundColor = RGBA(246.0, g: 23.0, b: 0.0, a: 1.0)
                }
                else {
                    cell1?.errorLabel.text = ""
                    cell1?.seperatorLabel.backgroundColor = RGBA(17, g: 43, b: 88, a: 1)
                }
                cell1?.forgotPasswordTextField.placeHolderText(withColor: "Message", andColor: RGBA(199, g: 199, b: 205, a: 1))
                cell1?.forgotPasswordTextField.returnKeyType = .done
                cell1?.forgotPasswordTextField.text = contactUsInfo.messageString
            }
        }
        else  if(indexPath.section == 1 )
        {
            
            //  let contactInfo = contactUsArray[indexPath.row]
            switch indexPath.row {
            case 0:
                cell2?.iconImageView.image = UIImage(named: "icon42.jpg")
                cell2?.titleLabel.text = "Email"
                cell2?.valueLabel.text =  contactUsInfo.email
                print("%@",contactUsInfo.email)
                break
            case 1:
                cell2?.iconImageView.image = UIImage(named: "icon41.jpg")
                cell2?.titleLabel.text = "Mobile"
                cell2?.valueLabel.text =  contactUsInfo.mobileNumber
                break
            case 2:
                cell2?.iconImageView.image = UIImage(named: "icon40.jpg")
                cell2?.titleLabel.text = "Website"
                cell2?.valueLabel.text =  contactUsInfo.website
                cell2?.seperatorLabel3.isHidden = true
                break
                default:
                break
            }
            return cell2!
        }
        else if(indexPath.section == 2) {
            let payementInfo = payementArray[indexPath.row]
            cell3?.dateLabel.text =  payementInfo.dateLabel
            cell3?.messageLabel.text =   payementInfo.messageLabel
            return cell3!
        }
        return cell1!
    }
        public func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    
    
    //MARK: - tableViewDelegateMethods
func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        if section == 0
        {
            return self.sectionFooterView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 1)
        {
            return self.sectionHeaderView1
        }
        else if (section == 2)
        {
            return self.sectionHeaderView2
        }
        return nil
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if(indexPath.section == 0)
        {
            if indexPath.row == 0
            {
                if  contactUsInfo.nameErrorString.trimWhiteSpace().length == 0
                {
                    return 50
                }
                else {
                    return 70
                }
            }
                
            else if indexPath.row == 1
            {
                if  contactUsInfo.emailErrorString.trimWhiteSpace().length == 0
                {
                    return 50
                }
                else
                {
                    return 70
                }
            }
                
            else if indexPath.row == 2
            {
                if  contactUsInfo.mobileNumberErrorString.trimWhiteSpace().length == 0 {
                    return 50
                }
                else
                {
                    return 70
                }
            }
            else  {
                if  contactUsInfo.messageErrorString.trimWhiteSpace().length == 0 {
                    return 50
                }
                else {
                    return 70
                }
            }
        }
            
        else if (indexPath.section == 1)
        {
            return 40;
        }
            
            
        else if (indexPath.section == 2)
        {
            return 60;
        }
        
        return 0;
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        if section == 0 {
            return 50
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        if section == 1 {
            return 40
        }
        else if section == 2{
            return 40
        }
        
        return 0
    }
    /* public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
     {
     
     var label = "You Can also reach us at"
     
     //label.
     if section == 1
     {
     return label
     }
     
     if section == 2
     {
     return " My Past Messages"
     }
     return ""
     }*/
    
    
    
    //MARK: - UITextFieldDelegates Methods.
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        
        
        if (textField.textInputMode?.primaryLanguage == "emoji") || !((textField.textInputMode?.primaryLanguage) != nil)
        {
            return false
        }
        var str:NSString = textField.text! as NSString
        str = str.replacingCharacters(in: range, with: string) as NSString
        switch textField.tag
        {
        case 100:
            if str.length > 80
            {
                return false
            }
        case 101:
            if str.length > 80 {
                return false
            }
            break
        case 102:
            if str.length > 10 {
                return false
            }
            break
            
        default:
            break
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 102 {
            textField.inputAccessoryView = addToolBarOnTextfield(textField: textField, target: self)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case 100:
            contactUsInfo.nameString = textField.text!
            break
            
        case 101:
            contactUsInfo.emailString = textField.text!
            
            break
        case 102:
            contactUsInfo.mobileNumberString = textField.text!
            break
        case 103:
            contactUsInfo.messageString = textField.text!
            
            
        default:
            break
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.returnKeyType == .next {
            let tf: UITextField? = (view.viewWithTag(textField.tag + 1) as? UITextField)
            tf?.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func doneWithNumberPad() {
        view.endEditing(true)
    }
    
    //MARK: - validation Methods.
    func isallFieldsVerfield() -> Bool
    {
        var isvalid = false
        
        contactUsInfo.nameErrorString = ""
        contactUsInfo.emailErrorString = ""
        contactUsInfo.mobileNumberErrorString = ""
        contactUsInfo.messageErrorString = ""
        if contactUsInfo.nameString.trimWhiteSpace().length == 0
        {
            contactUsInfo.nameErrorString = "*Please enter your Name."
            
            isvalid = false
            
        }else if contactUsInfo.nameString.length < 2 {
            contactUsInfo.nameErrorString = "*Please enter at least 2 character for name."
            isvalid = false
            
            
        }else if contactUsInfo.nameString.isValidName() == false {
            contactUsInfo.nameErrorString = "*Please enter valid Name."
            isvalid = false
            
            
        }else if contactUsInfo.emailString.trimWhiteSpace().length == 0
        {
            contactUsInfo.emailErrorString = "*Please enter your email ID."
            isvalid = false
        }
            
        else if contactUsInfo.emailString.isEmail() == false {
            contactUsInfo.emailErrorString = "*Please enter valid email ID."
            isvalid = false
            
        }else if contactUsInfo.mobileNumberString.trimWhiteSpace().length == 0 {
            contactUsInfo.mobileNumberErrorString = "*Please enter Mobile Number."
            isvalid = false
            
        } else if contactUsInfo.mobileNumberString.isValidNumber() == false {
            contactUsInfo.mobileNumberErrorString = "*Please enter valid mobile number."
            isvalid = false
        }else if contactUsInfo.mobileNumberString.length < 10  {
            contactUsInfo.mobileNumberErrorString = "*mobile number should be atleast 10 digit long."
            isvalid = false
          }else if  contactUsInfo.messageString.trimWhiteSpace().length == 0 {
            contactUsInfo.messageErrorString = "*Please enter message."
            isvalid = false
           }else{
            isvalid = true
        }
        self.contactusTableView.reloadData()
        return isvalid;
    }
    
    //MARK: - backButtonAction
    @IBAction func backButtonAction(_ sender: Any) {
        let appDelegateShared : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegateShared.menuViewController .toggle()
    }
    
    //MARK: - searchButtonAction
    @IBAction func searchButtonAction(_ sender: Any) {
        presentAlert("", msgStr: "Work In Progress..", controller: self)
    }
    
    //MARK: - addButtonAction
    @IBAction func addButtonAction(_ sender: Any) {
        
        let addTagPopUpVC: CAAddTagPopUpViewController = CAAddTagPopUpViewController(nibName:"CAAddTagPopUpViewController", bundle: nil)
        addTagPopUpVC.addTagDelegate = self
        addTagPopUpVC.navigationTitleString = "Add Manual"
        addTagPopUpVC.modalPresentationStyle = .overCurrentContext
        addTagPopUpVC.modalTransitionStyle = .crossDissolve
        self.present(addTagPopUpVC, animated: true, completion: nil)
    }
    
    //MARK: - sendButtonAction
    @IBAction func sendButtonAction(_ sender: Any) {
        self.view.endEditing(true)
        if isallFieldsVerfield(){

            let paramDict : Dictionary<String, AnyObject> = [
                kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject) ,
                kCustomerName : contactUsInfo.nameString as AnyObject ,
                kMobileNumber : contactUsInfo.mobileNumberString as AnyObject ,
                kEmail : contactUsInfo.emailString as AnyObject ,
                kMessage :contactUsInfo.messageString as AnyObject
                ]
            
            
            ServiceHelper.sharedInstanceHelper.createPostRequest(method: .post, showHud: true, params: paramDict, apiName: "Customer_Api/sendmessage") { (result, error) in
                
                if(!(error != nil)){
                    if (result![kResponseCode]! as! String == "200"){
                        presentAlert(kZoddl, msgStr: "Thank you for your feedback. Our support team will contact you soon.", controller: self)
                        self.contactUsInfo.nameString = ""
                        self.contactUsInfo.mobileNumberString = ""
                        self.contactUsInfo.emailString = ""
                        self.contactUsInfo.messageString = ""
                        self.contactusTableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.none)
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
    
    
    
    
    func getContactPageInfo() {
        
        let paramDict : Dictionary<String, AnyObject> = [
            kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject) ,
            ]
        
        ServiceHelper.sharedInstanceHelper.createPostRequest(method: .post, showHud: false, params: paramDict, apiName: "Customer_Api/getcontactdetails") { (result, error) in
            
            if(!(error != nil)){
                if (result![kResponseCode]! as! String == "200"){
                    
                    let messgaeData  = (((result![kAPIPayload] as! NSArray).firstObject) as! NSDictionary).value(forKey: "contacts")
                    self.payementArray = CAContactUsInfo.getPayementList(responseArray: messgaeData as! Array<Dictionary<String, String>>)
                   // self.contactusTableView.reloadSections(IndexSet(integer: 2), with: UITableViewRowAnimation.none)
                    self.contactUsInfo.email = (((result![kAPIPayload] as! NSArray).firstObject) as! NSDictionary).value(forKey: kEmail) as! String
                    self.contactUsInfo.mobileNumber = (((result![kAPIPayload] as! NSArray).firstObject) as! NSDictionary).value(forKey: kMobileNumber) as! String
                    self.contactUsInfo.website = (((result![kAPIPayload] as! NSArray).firstObject) as! NSDictionary).value(forKey: kWebsite) as! String
                    self.contactusTableView.reloadData()
                }
                else {
                    presentAlert(kZoddl, msgStr: result![kResponseMessage]! as? String, controller: self)
                }
                
            } else {
                presentAlert("", msgStr: error?.localizedDescription, controller: self)
            }
        }
        
    }
    
    
    
    
    
    //Mark Custom Delegate Selector
    func addDelegateWithDetailsAndIsSubmit(details: NSString, isSubmit: Bool) {
        
    }
}
