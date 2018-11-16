//
//  CASettingViewController.swift
//  ClickAccountingApp
//
//  Created by Deepak Kumar on 6/29/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit


class CASettingViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, AddTagDelegate {

    @IBOutlet var navBarTitleLabel: UILabel!
    @IBOutlet var navigationBackView: UIView!
    @IBOutlet var tableView: UITableView!
    
    var settingArray : [CASettingInfo] = []
    var toggleValue = NSDictionary()
    var dataFetched: Bool! = false

    var titleArray  = [String]()
    var valueArray  = [String]()

    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialMethod()
    }
    
    // MARK: - Helper methods
    func initialMethod(){
        
//                let titleArray = ["Allow Zoddl to view your Report","Allow Zoddl to view your Gallery","Allow Zoddl to view your Documents","Auto Optimise My Image","Username","Change Password","Self Tagging","Personal Folder","Personal Images Gallery","Show Cloud Disk","Free Cloud Disk","Push Notifications","Auto Sync","App Version","T&C","About Us","Update Profile","Rate Click Accounting App"]
        
         titleArray = ["Allow Zoddl to view your Gallery","Allow Zoddl to view your Documents","Allow Zoddl to view your Report","Free / Paid","About Us"]
         valueArray = ["","","",""]


       // self.tableView.allowsSelection=false;

        // For registereing nib
         self.tableView.isScrollEnabled = false
        self.tableView.register(UINib(nibName: "CASettingTableViewCell", bundle: nil), forCellReuseIdentifier: "CASettingTableViewCell")
        self.tableView.register(UINib(nibName: "CASettingSwitchTableViewCell", bundle: nil), forCellReuseIdentifier: "CASettingSwitchTableViewCell")
        self.getCurrentPermission()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    
    // MARK: - UITableViewDataSource Methods.
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return titleArray.count;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let switchCell = tableView.dequeueReusableCell(withIdentifier: "CASettingSwitchTableViewCell") as! CASettingSwitchTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "CASettingTableViewCell") as! CASettingTableViewCell
        
        cell.arrowImageView.isHidden = true
        switchCell.switchButton.tag = indexPath.row
        
        switchCell.switchButton .addTarget(self, action:#selector(switchButtonAction(_ :)) , for: .valueChanged)
        cell.valueLabel.text = ""
        
        cell.titleLabel.text = titleArray[indexPath.row]
        cell.arrowImageView.isHidden = true
        
        
        switch indexPath.row {

        case 0:
            switchCell.titleLabel.text = titleArray[indexPath.row]
            if(dataFetched){
                if(toggleValue.value(forKey: "g") as! NSString == "1"){
                    switchCell.switchButton.isOn = true
                }
                else{
                    switchCell.switchButton.isOn = false

                }
            }

            return switchCell

        case 1:
            switchCell.titleLabel.text = titleArray[indexPath.row]
            if(dataFetched){
                if(toggleValue.value(forKey: "d") as! NSString == "1"){
                    switchCell.switchButton.isOn = true
                }
                else{
                    switchCell.switchButton.isOn = false
                    
                }
            }
            return switchCell

        case 2:
            switchCell.titleLabel.text = titleArray[indexPath.row]
            if(dataFetched){
                if(toggleValue.value(forKey: "r") as! NSString == "1"){
                    switchCell.switchButton.isOn = true
                }
                else{
                    switchCell.switchButton.isOn = false
                    
                }
            }
            return switchCell
        case 3:
            switchCell.titleLabel.text = titleArray[indexPath.row]
            if(dataFetched){
                if(toggleValue.value(forKey: "Paid_Status") as! NSString == "1"){
                    switchCell.switchButton.isOn = true
                }
                else{
                    switchCell.switchButton.isOn = false
                    
                }
            }
            return switchCell
            

        case 4:
            cell.titleLabel.text = titleArray[indexPath.row]
            cell.arrowImageView.isHidden = false

            return cell

        default:
            return switchCell
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 50
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        //let appDelegateShared : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        switch indexPath.row {
            
        case 4:
            let staticVC : CAStaticScreenViewController = CAStaticScreenViewController(nibName:"CAStaticScreenViewController", bundle: nil)
            staticVC.stringNav = "About Us"
            self.navigationController?.pushViewController(staticVC, animated: true)
            //appDelegateShared.menuViewController?.embed (centerViewController: staticVC)
            break;
            
//        case 5:
//            let changePassVC : CAChangePasswordViewController = CAChangePasswordViewController(nibName:"CAChangePasswordViewController", bundle: nil)
//            self.navigationController?.pushViewController(changePassVC, animated: true)
//            //appDelegateShared.menuViewController?.embed (centerViewController: changePassVC)
//
//            break
//        case 14:
//            let staticVC : CAStaticScreenViewController = CAStaticScreenViewController(nibName:"CAStaticScreenViewController", bundle: nil)
//            staticVC.stringNav = "Terms & Conditions"
//            self.navigationController?.pushViewController(staticVC, animated: true)
//            //appDelegateShared.menuViewController?.embed (centerViewController: staticVC)
//            break
//
//        case 16:
//            let editProfileVC : CAEditProfileViewController = CAEditProfileViewController(nibName:"CAEditProfileViewController", bundle: nil)
//            self.navigationController?.pushViewController(editProfileVC, animated: true)
//            //appDelegateShared.menuViewController?.embed (centerViewController: editProfileVC)
//            break;
        default:
            break
        }
    }
    
    // MARK: - UIButton Action & Selector Method
    func switchButtonAction(_ sender : UISwitch) {
        
        let value : Int
        if(sender.isOn){
            value = 1
        }else{
            value = 0
        }
        switch sender.tag {

        case 0:
            self.changeStatus(type: "g", value: value)
            
        case 1:
            self.changeStatus(type: "d", value: value)
            
        case 2:
            self.changeStatus(type: "r", value: value)
            
        case 3:
            self.changeStatus(type: "Paid_Status", value: value)
            
        default:
            break
        }
    }
    
    @IBAction func plusButtonAction(_ sender: UIButton) {
        let addTagPopUpVC: CAAddTagPopUpViewController = CAAddTagPopUpViewController(nibName:"CAAddTagPopUpViewController", bundle: nil)
        addTagPopUpVC.addTagDelegate = self
        addTagPopUpVC.navigationTitleString = "Add Manual"
        addTagPopUpVC.modalPresentationStyle = .overCurrentContext
        addTagPopUpVC.modalTransitionStyle = .crossDissolve
        self.present(addTagPopUpVC, animated: true, completion: nil)
}
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        let appDelegateShared : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegateShared.menuViewController .toggle()
    }
    
    @IBAction func searchButtonAction(_ sender: UIButton) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Mark Custom Delegate
    func addDelegateWithDetailsAndIsSubmit(details: NSString, isSubmit: Bool) {
        
    }
    
  
    
    //Mark Update on toggle switch

    func changeStatus(type: String, value : Int) {
        
        let paramDict : Dictionary<String, AnyObject> = [
            kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject) ,
            kPermissionType : type as AnyObject ,
            kPermissionValue : value as AnyObject ,
        ]
        

        ServiceHelper.sharedInstanceHelper.createPostRequest(method: .post, showHud: false, params: paramDict, apiName: "Customer_Api/permission") { (result, error) in
            
            if(!(error != nil)){
                if (result![kResponseCode]! as! String == "200"){
                    
                    if(type == "Paid_Status"){
                        UserDefaults.standard.set(value, forKey: kPaidStatus)
                    }
                    
                }
                else {
                    presentAlert(kZoddl, msgStr: result![kResponseMessage]! as? String, controller: self)
                }
                
            } else {
                presentAlert("", msgStr: error?.localizedDescription, controller: self)
            }
        }
        
    }
    
    //Mark Get on toggle switch

    func getCurrentPermission() {
        
        let paramDict : Dictionary<String, AnyObject> = [
            kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject) ,
            ]
        
        ServiceHelper.sharedInstanceHelper.createPostRequest(method: .post, showHud: false, params: paramDict, apiName: "Customer_Api/getpermission") { (result, error) in
            
            if(!(error != nil)){
                if (result![kResponseCode]! as! String == "200"){
                    self.toggleValue = (result![kAPIPayload] as! NSArray).firstObject as! NSDictionary
                    self.dataFetched = true
                    self.tableView.reloadData()
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
