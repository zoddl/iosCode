//
//  CAMakeAPayementViewController.swift
//  ClickAccountingApp
//
//  Created by Sunil Datt Joshi on 30/06/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit

class CAMakeAPayementViewController: UIViewController,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate, AddTagDelegate, UIDocumentPickerDelegate {
    
    @IBOutlet weak var payementTableView: UITableView!
    
    @IBOutlet weak var paytmButton: UIButton!
    @IBOutlet weak var creditButtton: UIButton!
    @IBOutlet weak var debitCardButton: UIButton!
    @IBOutlet weak var netBankingButton: UIButton!
    @IBOutlet var section2HeaderView: UIView!
    @IBOutlet weak var payNowButton: UIButton!
    @IBOutlet var section1HeaderView: UIView!
    
    @IBOutlet var paymentWebView: UIWebView!
    @IBOutlet weak var tickButtonOutlet: UIButton!
    @IBOutlet var section1FooterView: UIView!
    var payementInfo = CAMakePaymentInfo()
    var contactUsInfo = CAContactUsInfo()
    var flag = Bool()
    var dateLabel : String = "17/06/2017"
    var messageLabel: String = "please mail me"
    var payementArray = [CAMakePaymentInfo]()
    // MARK: - View Life Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.initialMethod()
        
        let paymentURL = URL(string: "https://www.payumoney.com/paybypayumoney/#/1CDDF7AD3FAEEF86C50C9693C6D87FB4")
        let request = URLRequest(url: paymentURL!,
                                 cachePolicy:NSURLRequest.CachePolicy.returnCacheDataElseLoad,
                                 timeoutInterval: 10.0)
        paymentWebView.loadRequest(request)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
       
    }

    //MARK: Helper Methods
    func initialMethod() {
        self.payementTableView.isHidden = true

        payementInfo.nameString = ""
        payementInfo.referalString = ""
        payementInfo.amountString = ""
        payementInfo.commentString = ""
        self.navigationController?.isNavigationBarHidden = true
        self.payementTableView.allowsSelection = false
        self.creditButtton.tag = 1000
        self.netBankingButton.tag = 1001
        self.debitCardButton.tag = 1002
        self.paytmButton.tag = 1003
        self.creditButtton.isSelected = true
        self.creditButtton.addTarget(self, action: #selector(radioButtonTouch), for: .touchUpInside)
        self.netBankingButton.addTarget(self, action: #selector(radioButtonTouch), for: .touchUpInside)
        
        self.debitCardButton.addTarget(self, action: #selector(radioButtonTouch), for: .touchUpInside)
        
        self.paytmButton.addTarget(self, action: #selector(radioButtonTouch), for: .touchUpInside)
        self.payementTableView.register(UINib(nibName:"ForgotPasswordTableViewCell",bundle: nil), forCellReuseIdentifier:"ForgotPasswordTableViewCell")
        
        self.payementTableView.register(UINib(nibName: "PaymentTableViewCell", bundle: nil),forCellReuseIdentifier:"PaymentTableViewCell")
        
        let   dataSourceArray = [
            ["dateLabel": "15/06/16 - 2500:" as AnyObject, "messageLabel": "Manual Payment,ITR payment" as AnyObject],
            ["dateLabel": "12/06/23 - 5000:" as AnyObject, "messageLabel": "Manual Payment,ITR payment" as AnyObject],
            ["dateLabel": "12/06/23 - 2000:" as AnyObject, "messageLabel": "Manual Payment,ITR payment" as AnyObject ],
            ["dateLabel": "12/06/23 - 3000:" as AnyObject, "messageLabel": "Manual Payment,ITR payment" as AnyObject],
            ["dateLabel": "12/06/23 - 4000:"  as AnyObject, "messageLabel": "Manual Payment,ITR payment" as AnyObject]]
        
        self.payementArray = CAMakePaymentInfo.getPayementList(responseArray: dataSourceArray as! Array<Dictionary<String, String>>)
        
        self.payNowButton.layer.cornerRadius = 3
    }
    
    
    
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0) {
            return 4
        }
        
        if(section == 1)
        {
            return payementArray.count
        }
        return 0
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell1 = tableView.dequeueReusableCell(withIdentifier: "ForgotPasswordTableViewCell") as? ForgotPasswordTableViewCell
        let cell3 = tableView.dequeueReusableCell(withIdentifier: "PaymentTableViewCell") as? PaymentTableViewCell
        cell1?.forgotPasswordTextField.autocorrectionType = .no
        cell1?.forgotPasswordTextField.delegate = self as UITextFieldDelegate
        cell1?.forgotPasswordTextField.returnKeyType = .next
        cell1?.forgotPasswordTextField.tag = indexPath.row + 100
      
       if payementInfo.payementType == "creditCard"
        {
            self.creditButtton.isSelected = true
            self.netBankingButton.isSelected = false
            self.debitCardButton.isSelected = false
            self.paytmButton.isSelected = false
        }
        else if payementInfo.payementType == "netBanking"
        {
            self.creditButtton.isSelected = false
            self.netBankingButton.isSelected = true
            self.debitCardButton.isSelected = false
            self.paytmButton.isSelected = false
            
        }
        else if payementInfo.payementType == "debitCard"
        {
            self.creditButtton.isSelected = false
            self.netBankingButton.isSelected = false
            self.debitCardButton.isSelected = true
            self.paytmButton.isSelected = false
        }
        else if payementInfo.payementType == "paytm"
        {
            self.creditButtton.isSelected = false
            self.netBankingButton.isSelected = false
            self.debitCardButton.isSelected = false
            self.paytmButton.isSelected = true
        }
        
              if(indexPath.section == 0)
            
        {
            self.payementTableView.separatorStyle = UITableViewCellSeparatorStyle.none
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
                cell1?.forgotPasswordTextField.placeHolderText(withColor: "Name", andColor: RGBA(17, g: 43, b: 88, a: 1))
                cell1?.forgotPasswordTextField.text = payementInfo.nameString
                break
                
            case 1:
                if contactUsInfo.emailErrorString.length != 0
                {
                    cell1?.errorLabel.text = contactUsInfo.emailErrorString
                    cell1?.seperatorLabel.backgroundColor = RGBA(246.0, g: 23.0, b: 0.0, a: 1.0)
                }else{
                    cell1?.errorLabel.text = ""
                    cell1?.seperatorLabel.backgroundColor = RGBA(17, g: 43, b: 88, a: 1)
                }
                
                cell1?.forgotPasswordTextField.placeHolderText(withColor: "Ref if any", andColor: RGBA(17, g: 43, b: 88, a: 1))
                cell1?.forgotPasswordTextField.keyboardType = .emailAddress
                cell1?.forgotPasswordTextField.text = payementInfo.referalString
                break
                
            case 2:
                if contactUsInfo.mobileNumberErrorString.length != 0
                {
                    cell1?.errorLabel.text = contactUsInfo.mobileNumberErrorString
                    cell1?.seperatorLabel.backgroundColor = RGBA(246.0, g: 23.0, b: 0.0, a: 1.0)
                }else{
                    cell1?.errorLabel.text = ""
                    cell1?.seperatorLabel.backgroundColor = RGBA(17, g: 43, b: 88, a: 1)
                }
                cell1?.forgotPasswordTextField.placeHolderText(withColor: "Amount", andColor: RGBA(17, g: 43, b: 88, a: 1))
                cell1?.forgotPasswordTextField.keyboardType = .numberPad
                cell1?.forgotPasswordTextField.text = payementInfo.amountString
                cell1?.forgotPasswordTextField.inputAccessoryView = addToolBarOnTextfield(textField: (cell1?.forgotPasswordTextField)!, target: self)

                
            default:
                if contactUsInfo.messageErrorString.length != 0 {
                    cell1?.errorLabel.text = contactUsInfo.messageErrorString
                    cell1?.seperatorLabel.backgroundColor = RGBA(246.0, g: 23.0, b: 0.0, a: 1.0)
                }else{
                    cell1?.errorLabel.text = ""
                    cell1?.seperatorLabel.backgroundColor = RGBA(17, g: 43, b: 88, a: 1)
                }
                cell1?.forgotPasswordTextField.placeHolderText(withColor: "Comment", andColor: RGBA(17, g: 43, b: 88, a: 1))
                cell1?.forgotPasswordTextField.returnKeyType = .done
                cell1?.forgotPasswordTextField.text = payementInfo.commentString
            }
            
        }
        else if (indexPath.section == 1)
        {
            let payementInfo = payementArray[indexPath.row]
            cell3?.dateLabel.text =  payementInfo.dateLabel
            cell3?.messageLabel.text =   payementInfo.messageLabel
            return cell3!
        }
        return cell1!
        
    }
    
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    //MARK: - UITableViewDelegateMethods
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?{
        if section == 0
        {
            return self.section1FooterView
        }
        return nil
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if (section == 0)
        {
            return self.section1HeaderView
        }
            
        else if(section == 1)
        {
            return self.section2HeaderView
        }
        
        
        return nil
    }
    
    
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if(indexPath.section == 0)
        {
            if indexPath.row == 0 {
                if  contactUsInfo.nameErrorString.trimWhiteSpace().length == 0 {
                    return 50
                }else{
                    return 70
                }
            }
            else if indexPath.row == 1
            {
                if  contactUsInfo.emailErrorString.trimWhiteSpace().length == 0 {
                    return 50
                }else
                {
                    return 70
                }
            }
                
            else if indexPath.row == 2
            {
                if  contactUsInfo.mobileNumberErrorString.trimWhiteSpace().length == 0 {
                    return 50
                }else
                {
                    return 70
                }
            }
                
            else
            {
                if  contactUsInfo.messageErrorString.trimWhiteSpace().length == 0 {
                    return 50
                }else
                {
                    return 70
                }
            }
            
        }
            
            
        else if(indexPath.section == 1)
        {
            return 60
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        if section == 0 {
            return 175
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        if section == 0 || section == 1{
            return 40
        }
        
        return 0
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
        case 101:
            if str.length > 80 {
                return false
            }
            break
        case 102:
            if str.length > 6 {
                return false
            }
            break
        case 103:
            if str.length > 100 {
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
            payementInfo.nameString = textField.text!
            break
            
        case 101:
            payementInfo.referalString = textField.text!
            
            break
        case 102:
            payementInfo.amountString = textField.text!
            break
        case 103:
            payementInfo.commentString = textField.text!
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
    
    //MARK: - validation Methods.
    func isallFieldsVerfield() -> Bool {
        var isvalid = false
        
        contactUsInfo.nameErrorString = ""
        contactUsInfo.emailErrorString = ""
        contactUsInfo.mobileNumberErrorString = ""
        contactUsInfo.messageErrorString = ""
        if payementInfo.nameString.trimWhiteSpace().length == 0
        {
            contactUsInfo.nameErrorString = "*Please enter your Name."
            
            isvalid = false
            
        }else if payementInfo.nameString.length < 2 {
            contactUsInfo.nameErrorString = "*Please enter at least 2 character for name."
            isvalid = false
            
            
        }else if payementInfo.nameString.isValidName() == false {
            contactUsInfo.nameErrorString = "*Please enter valid Name."
            isvalid = false
              }
        else if payementInfo.amountString.trimWhiteSpace().length == 0 {
            contactUsInfo.mobileNumberErrorString = "*Please enter amount."
            isvalid = false
            
                    }  else if flag == false {
            presentAlert("", msgStr: "Please accept terms and conditions.", controller: self)
        }else{
            isvalid = true
        }
        self.payementTableView.reloadData()
        return isvalid;
    }
    //MARK: UIButton methods
    @IBAction func saveButtonAction(_ sender: Any) {
        let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["public.text"], in: UIDocumentPickerMode.import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.present(documentPicker, animated: true, completion: nil)
        
    }
    
    @IBAction func addButtonAction(_ sender: Any) {
        let addTagPopUpVC: CAAddTagPopUpViewController = CAAddTagPopUpViewController(nibName:"CAAddTagPopUpViewController", bundle: nil)
        addTagPopUpVC.addTagDelegate = self
        addTagPopUpVC.navigationTitleString = "Add Manual"
        addTagPopUpVC.modalPresentationStyle = .overCurrentContext
        addTagPopUpVC.modalTransitionStyle = .crossDissolve
        self.present(addTagPopUpVC, animated: true, completion: nil)
    }
    
    @IBAction func searchButtonAction(_ sender: Any) {
        presentAlert("", msgStr: "Work In Progress..", controller:self )
    }
    
    
    @IBAction func radioButtonTouch(sender: UIButton)  {
        self.view .endEditing(true)
        switch (sender.tag) {
        case 1000:
            self.creditButtton.isSelected = true
            self.netBankingButton.isSelected = false
            self.debitCardButton.isSelected = false
            self.paytmButton.isSelected = false
            
            payementInfo.payementType = "creditCard"
            payementTableView.reloadData()
            break
        case 1001:
            self.creditButtton.isSelected = false
            self.netBankingButton.isSelected = true
            self.debitCardButton.isSelected = false
            self.paytmButton.isSelected = false
            
            payementInfo.payementType = "netBanking"
            payementTableView.reloadData()
            break
            
        case 1002:
            self.creditButtton.isSelected = false
            self.netBankingButton.isSelected = false
            self.debitCardButton.isSelected = true
            self.paytmButton.isSelected = false
            
            payementInfo.payementType = "debitCard"
            payementTableView.reloadData()
            break
        case 1003:
            self.creditButtton.isSelected = false
            self.netBankingButton.isSelected = false
            self.debitCardButton.isSelected = false
            self.paytmButton.isSelected = true
            
            payementInfo.payementType = "paytm"
            payementTableView.reloadData()
            break
        default:
            break
        }
    }
    
    
    
    @IBAction func payNowButtonAction(_ sender: Any) {
        self.view.endEditing(true)
        if isallFieldsVerfield(){
            print("correct")
        }
    }
    
    func doneWithNumberPad() {
        view.endEditing(true)
    }
    
    @IBAction func tickButtonAction(_ sender: UIButton) {
        self.view .endEditing(true)
        sender.isSelected = !sender.isSelected
        if sender.isSelected == true
        {
            flag = true
        }
        else
        {
            flag = false
        }
    }
    
    
    @IBAction func backButtonAction(_ sender: Any) {
        let appDelegateShared : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegateShared.menuViewController .toggle()
    }
    
    //Mark Custom Delegate Selector
    func addDelegateWithDetailsAndIsSubmit(details: NSString, isSubmit: Bool) {
        
    }
    
    // MARK: - UIDocumentPickerDelegate Methods
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        if controller.documentPickerMode == UIDocumentPickerMode.import {
            // This is what it should be
            do {
                let textFromFile: NSString = try String(contentsOfFile: url.path) as NSString
                print(textFromFile)
            }
            catch {
            }
        }
    }

}
