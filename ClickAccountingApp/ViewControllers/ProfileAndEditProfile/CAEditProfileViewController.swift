//
//  CAEditProfileViewController.swift
//  ClickAccountingApp
//
//  Created by Deepak Kumar on 6/29/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit

class CAEditProfileViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIGestureRecognizerDelegate,HADropDownDelegate {
    
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var headerView: UIView!
    @IBOutlet var footerView: UIView!
    @IBOutlet var navBarTitleLabel: UILabel!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var tableView: UITableView!
    
    
    var picker = UIImagePickerController()
    var dropDown = HADropDown()
    var profileTitleArray : [String] = []
    var profileInfo = CAUserInfo()
    var profileInfoDictionary = NSDictionary()

    // MARK: - UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        profileInfo.firstNameString = profileInfoDictionary.value(forKey: kFirstName) as! String
        profileInfo.lastNameString = profileInfoDictionary.value(forKey: kLastName) as! String
        profileInfo.emailString = profileInfoDictionary.value(forKey: kEmail) as! String
        profileInfo.mobileNumberString = profileInfoDictionary.value(forKey: kMobileNumber) as! String
        profileInfo.altMobileNumberString = profileInfoDictionary.value(forKey: kAltMobileNumber) as! String
        profileInfo.genderSting = profileInfoDictionary.value(forKey: kGender) as! String
        profileInfo.dobString = profileInfoDictionary.value(forKey: kDOB) as! String
        profileInfo.panNumberString = profileInfoDictionary.value(forKey: kPanNumber) as! String
        profileInfo.adharNumberString = profileInfoDictionary.value(forKey: kAdharNumber) as! String
        profileInfo.cityString = profileInfoDictionary.value(forKey: kCity) as! String
        profileInfo.companyNameString = profileInfoDictionary.value(forKey: kCompanyName) as! String
        profileInfo.skypeIDString = profileInfoDictionary.value(forKey: kSkypeId) as! String
        profileInfo.gstnString = profileInfoDictionary.value(forKey: kGSTN) as! String
        profileInfo.imageString = profileInfoDictionary.value(forKey: kProfileImage) as! String
        
        
        userImageView.layer.cornerRadius = 45
        userImageView.clipsToBounds = true
        userImageView.image = UIImage(named: "profile")
        userImageView.sd_setImage(with: URL(string: checkNull(inputValue: (profileInfoDictionary.value(forKey: kProfileImage) as! String as AnyObject)) as! String), placeholderImage: UIImage(named: "userplaceholder"))
        initialMethod()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - Helper methods
    func initialMethod(){
        
        let titleArray = ["First Name","Last Name","Email ID","Mobile No.","Alt Mobile No.","Gender","DOB","My PAN No.","My Aadhar No.","City","Company Name","Skype ID","GSTN"]
        
        profileTitleArray.append(contentsOf: titleArray)
  
        
        let tap = UITapGestureRecognizer(target: self, action:#selector(editProfileImage(sender:)))
        tap.delegate = self
        userImageView.addGestureRecognizer(tap)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsSelection=false;
        
        self.tableView.tableHeaderView = headerView
        self.tableView.tableFooterView = footerView
        
        // For registereing nib
        self.tableView.register(UINib(nibName: "CAEditProfileButtonTableViewCell", bundle: nil), forCellReuseIdentifier: "CAEditProfileButtonTableViewCell")
        self.tableView.register(UINib(nibName: "CAEditProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "CAEditProfileTableViewCell")
    }
    

    
    // MARK: - UITableViewDataSource Methods.
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return profileTitleArray.count;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let buttonCell = tableView.dequeueReusableCell(withIdentifier: "CAEditProfileButtonTableViewCell") as! CAEditProfileButtonTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "CAEditProfileTableViewCell") as! CAEditProfileTableViewCell
        
        buttonCell.dropDownButton.tag = indexPath.row + 2000
        
        buttonCell.dropDownButton .addTarget(self, action:#selector(dropDownButtonAction(_ :)) , for: .touchUpInside)
        cell.valueTextField.tag = indexPath.row + 100
        cell.valueTextField.delegate = self
        cell.valueTextField.autocorrectionType = .no
        cell.valueTextField.keyboardType = .default
        cell.valueTextField.returnKeyType = .next
        buttonCell.titleLabel.text = profileTitleArray[indexPath.row]
        cell.titleLabel.text       = profileTitleArray[indexPath.row]
        cell.valueTextField.isUserInteractionEnabled = true
        buttonCell.dropDownView.isUserInteractionEnabled = false
        switch indexPath.row {
            
        case 5:
            buttonCell.dropDownImageView.image = UIImage(named: "icon10")
            //     buttonCell.dropDownView.isUserInteractionEnabled = true
            //            buttonCell.dropDownView.delegate = self
            //            buttonCell.dropDownView.items = ["Male", "Female"]
            buttonCell.dropDownView.isHidden = true
            buttonCell.dropDownButton.isHidden = false
            buttonCell.valueLabel.text = profileInfo.genderSting
            return buttonCell
        case 6:
            buttonCell.dropDownImageView.image = UIImage(named: "icon11")
            buttonCell.dropDownButton.isHidden = false
            buttonCell.valueLabel.text = profileInfo.dobString
            return buttonCell
            
        case 0:
            cell.valueTextField.text = profileInfo.firstNameString
            break
        case 1:
            cell.valueTextField.text = profileInfo.lastNameString
            break
        case 2:
            cell.valueTextField.isUserInteractionEnabled = false
            cell.valueTextField.text = profileInfo.emailString
            break
        case 3:
            cell.valueTextField.keyboardType = .numberPad
            cell.valueTextField.text = profileInfo.mobileNumberString
            cell.valueTextField.inputAccessoryView = addToolBarOnTextfield(textField: cell.valueTextField, target: self)
            break
        case 4:
            cell.valueTextField.keyboardType = .numberPad
            cell.valueTextField.text = profileInfo.altMobileNumberString
            cell.valueTextField.inputAccessoryView = addToolBarOnTextfield(textField: cell.valueTextField, target: self)
            break
        case 7:
            cell.valueTextField.text = profileInfo.panNumberString
            break
        case 8:
            cell.valueTextField.keyboardType = .numberPad
            cell.valueTextField.text = profileInfo.adharNumberString
            cell.valueTextField.inputAccessoryView = addToolBarOnTextfield(textField: cell.valueTextField, target: self)
            break
        case 9:
            cell.valueTextField.text = profileInfo.cityString
            break
        case 10:
            cell.valueTextField.text = profileInfo.companyNameString
            break
        case 11:
            cell.valueTextField.text = profileInfo.skypeIDString
            break
        case 12:
            cell.valueTextField.returnKeyType = .done
            cell.valueTextField.text = profileInfo.gstnString
            break
        default:
            break
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 50
    }
    
    //    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    //
    //        let indexPathForCell: IndexPath = IndexPath.init(row: 5, section: 0)
    //        let buttonCell = tableView.cellForRow(at: indexPathForCell) as! CAEditProfileButtonTableViewCell
    //        logInfo("TableViewScroll Content offset \(scrollView.contentOffset) andTableCellFrame\(buttonCell.frame)")
    //
    //       if scrollView.contentOffset.y > 0 && scrollView.contentOffset.y < 130.0{
    //            buttonCell.dropDownView.frame = CGRect.init(x: buttonCell.dropDownView.frame.origin.x, y: (scrollView.contentOffset.y - buttonCell.dropDownView.frame.height), width: buttonCell.dropDownView.frame.width, height:buttonCell.dropDownView.frame.height)
    //            buttonCell.dropDownView.backgroundColor = UIColor.red
    //       }
    //}
    
    //MARK: - UITextFieldDelegates Methods.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        if (textField.textInputMode?.primaryLanguage == "emoji") || !((textField.textInputMode?.primaryLanguage) != nil) {
            return false
        }
        var str:NSString = textField.text! as NSString
        str = str.replacingCharacters(in: range, with: string) as NSString
        
        switch textField.tag {
        case 100:
            if str.length > 50 {
                return false
            }
        case 101:
            if str.length > 50 {
                return false
            }
            break
        case 102:
            if str.length > 80 {
                return false
            }
        case 103:
            if str.length > 10 {
                return false
            }
            break
        case 104:
            if str.length > 10 {
                return false
            }
        case 107:
            if str.length > 10 {
                return false
            }
            break
        case 108:
            if str.length > 12 {
                return false
            }
        case 109:
            if str.length > 30 {
                return false
            }
            break
        case 110:
            if str.length > 100 {
                return false
            }
        case 111:
            if str.length > 50 {
                return false
            }
            break
        case 112:
            if str.length > 50 {
                return false
            }
            
        default:
            break
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        textField.text = textField.text?.trimWhiteSpace()
        
        switch textField.tag {
        case 100:
            profileInfo.firstNameString = textField.text!
            break
        case 101:
            profileInfo.lastNameString = textField.text!
            break
        case 102:
            profileInfo.emailString = textField.text!
            break
        case 103:
            profileInfo.mobileNumberString = textField.text!
            break
        case 104:
            profileInfo.altMobileNumberString = textField.text!
            break
        case 107:
            profileInfo.panNumberString = textField.text!
            break
        case 108:
            profileInfo.adharNumberString = textField.text!
            break
        case 109:
            profileInfo.cityString = textField.text!
            break
        case 110:
            profileInfo.companyNameString = textField.text!
            break
        case 111:
            profileInfo.skypeIDString = textField.text!
            break
        case 112:
            profileInfo.gstnString = textField.text!
            break
            
        default:
            break
        }
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if  textField.tag == 104{
            let tf: UITextField? = (view.viewWithTag(textField.tag + 3) as? UITextField)
            tf?.becomeFirstResponder()
        }
        else if textField.tag == 101{
            let tf: UITextField? = (view.viewWithTag(textField.tag + 2) as? UITextField)
            tf?.becomeFirstResponder()
        }
        else if textField.returnKeyType == .next {
            let tf: UITextField? = (view.viewWithTag(textField.tag + 1) as? UITextField)
            tf?.becomeFirstResponder()
        }
        else {
            view.endEditing(true)
        }
        return true
    }
    
    //MARK: - validation Methods.
    func isallFieldsVerfield() -> Bool {
        var isvalid = false
        
        if profileInfo.firstNameString.trimWhiteSpace().length == 0{
            presentAlert("", msgStr: "*Please enter first name.", controller: self)
            isvalid = false
            
        }else if profileInfo.firstNameString.trimWhiteSpace().length < 2 {
            presentAlert("", msgStr: "*Please enter at least 2 character for first name.", controller: self)
            isvalid = false
            
        }else if profileInfo.firstNameString.isValidName() == false {
            presentAlert("", msgStr: "*Please enter valid first name.", controller: self)
            isvalid = false
            
        }else if profileInfo.lastNameString.trimWhiteSpace().length == 0 {
            presentAlert("", msgStr: "*Please enter last name.", controller: self)
            isvalid = false
            
        }else if profileInfo.lastNameString.trimWhiteSpace().length < 2 {
            presentAlert("", msgStr: "*Please enter at least 2 character for last name.", controller: self)
            isvalid = false
            
        }else if profileInfo.lastNameString.isValidName() == false  {
            presentAlert("", msgStr: "*Please enter valid last name.", controller: self)
            isvalid = false
            
        }else if profileInfo.mobileNumberString.trimWhiteSpace().length == 0{
            presentAlert("", msgStr: "*Please enter mobile number.", controller: self)
            isvalid = false
            
        }else if profileInfo.mobileNumberString.isValidNumber() == false {
            presentAlert("", msgStr: "*Please enter valid mobile number.", controller: self)
            isvalid = false
            
        }else if profileInfo.mobileNumberString.trimWhiteSpace().length < 10 {
            presentAlert("", msgStr: "*Please enter 10 digit mobile number.", controller: self)
            isvalid = false
            
        }
//           else if profileInfo.genderSting.trimWhiteSpace().length == 0 {
//            presentAlert("", msgStr: "*Please select gender.", controller: self)
//            isvalid = false
//
//        }else if profileInfo.cityString.trimWhiteSpace().length == 0  {
//            presentAlert("", msgStr: "*Please enter city.", controller: self)
//            isvalid = false
//
//        }else if profileInfo.cityString.trimWhiteSpace().length < 2 {
//            presentAlert("", msgStr: "*Please enter at least 2 characters for city.", controller: self)
//            isvalid = false
//
//        }else if profileInfo.companyNameString.trimWhiteSpace().length == 0  {
//            presentAlert("", msgStr: "*Please enter company name.", controller: self)
//            isvalid = false
//
//        }else if profileInfo.companyNameString.trimWhiteSpace().length < 2 {
//            presentAlert("", msgStr: "*Please enter at least 2 characters for company name.", controller: self)
//            isvalid = false
//
//        }
    else{
            isvalid = true
        }
        return isvalid;
    }
    
    
    // MARK: - UIButton Actions and Selector Methods
    func editProfileImage(sender: UITapGestureRecognizer? = nil) {
        
        self.view.endEditing(true)
        
        let alert = UIAlertController(title: "", message: "Please select", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default , handler:{ (UIAlertAction)in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
                
                
                
                self.picker.delegate = self
                
                self.picker.sourceType = UIImagePickerControllerSourceType.camera;
                
                self.picker.allowsEditing = false
                
                
                
                self.present(self.picker, animated: true, completion: nil)
                
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Choose from gallery", style: .default , handler:{ (UIAlertAction)in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                
                let imagePicker = UIImagePickerController()
                
                imagePicker.delegate = self
                
                imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
                
                imagePicker.allowsEditing = true
                
                
                self.present(imagePicker, animated: true, completion: {
                    
                })
                
            }     }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler:{ (UIAlertAction)in
            
        }))
        self.present(alert, animated: true, completion: {
            
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.userImageView.image = image
            ServiceHelper.sharedInstanceHelper.showHud()
            ServiceHelper.sharedInstanceHelper.uploadThumbImageToS3(image: image, fileName: "", completion: { (result, error) in
                self.profileInfo.imageString = kImageBaseURL  + (result?.key)! as String
                ServiceHelper.sharedInstanceHelper.hideHud()
            })
        }
            
        else {
            
            print("Something went wrong")
        }
        
        self.dismiss(animated: true, completion: nil)
        tableView.reloadData()
    }
    
    func dropDownButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if  sender.tag == 2005 {
            
            let alert = UIAlertController(title: "", message: "Please select", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Male", style: .default , handler:{ (UIAlertAction)in
                self.profileInfo.genderSting = "Male"
                self.dismiss(animated: true, completion: nil)
                self.tableView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "Female", style: .default , handler:{ (UIAlertAction)in
                
                self.profileInfo.genderSting = "Female"
                self.dismiss(animated: true, completion: nil)
                self.tableView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler:{ (UIAlertAction)in
                self.dismiss(animated: true, completion: nil)
                self.tableView.reloadData()
            }))
            self.present(alert, animated: true, completion: {
            })
        }
        else{
            let currentDate = Date()
            var dateComponents = DateComponents()
            dateComponents.year = -100
            let minDate = Calendar.current.date(byAdding: dateComponents, to: currentDate)
            
            DatePickerDialog().show("", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", minimumDate: minDate, maximumDate: currentDate, datePickerMode: .date) { (date) in
                if let dt = date {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    self.profileInfo.dobString = dateFormatter.string( from: (dt))
                    self.tableView.reloadData()
                }
            }
            
        }
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func saveButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if isallFieldsVerfield() {
            
            self.view.endEditing(true)
            if(!Reachability.isConnectedToNetwork()){
                
                let actionSheetController: UIAlertController = UIAlertController(title: kZoddl, message: "Seems like you are not connected to internet. Please check your internet connection.", preferredStyle: .alert)
                
                let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default) { action -> Void in
                    
                }
                actionSheetController.addAction(okAction)
                self.present(actionSheetController, animated: true, completion: nil)
            }
            else
            {
                let paramDict : Dictionary<String, AnyObject> = [
                    kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject) ,
                    kFirstName : profileInfo.firstNameString as AnyObject,
                    kLastName :  profileInfo.lastNameString as AnyObject,
                    kGender : profileInfo.genderSting as AnyObject,
                    kDOB : profileInfo.dobString as AnyObject,
                    kPanNumber : profileInfo.panNumberString as AnyObject,
                    kCompanyName : profileInfo.companyNameString as AnyObject,
                    kGSTN : profileInfo.gstnString as AnyObject,
                    kCity : profileInfo.cityString as AnyObject,
                    kAdharNumber : profileInfo.adharNumberString as AnyObject,
                    kMobileNumber : profileInfo.mobileNumberString as AnyObject,
                    kAltMobileNumber : profileInfo.altMobileNumberString as AnyObject,
                    kSkypeId  : profileInfo.skypeIDString as AnyObject,
                    kProfileImage  : profileInfo.imageString as AnyObject,
                    ]
                
                    ServiceHelper.sharedInstanceHelper.createPostRequest(method: .post, showHud: true, params: paramDict, apiName:"Customer_Api/updateUserProfile") { (result, error) in
                        
                        if(!(error != nil)){
                            if (result![kResponseCode]! as? String == "200"){
                                let resultDict:Dictionary<String, AnyObject> = result as! Dictionary
                                print(resultDict)
                                self.navigationController?.popViewController(animated: true)
                            }
                            else {
                                presentAlert(kZoddl, msgStr: result![kResponseMessage]! as? String, controller: self)
                            }
                            
                        }
                        else {
                            presentAlert(kZoddl, msgStr: error?.localizedDescription, controller: self)
                        }
                    }
           
    
            }
        }
        
    }
    
    
    
    
    
    
    func doneWithNumberPad() {
        view.endEditing(true)
    }
    
    //MARK:- DropDown Delegate Methods
    func didSelectItem(dropDown: HADropDown, at index: Int, value selectedText: String) {
        self.profileInfo.genderSting = selectedText
        self.tableView.reloadData()
    }
    // MARK: - Memory Warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
