//
//  CAProfileViewController.swift
//  ClickAccountingApp
//
//  Created by Deepak Kumar on 6/30/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit

class CAProfileViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet var headerView: UIView!
    @IBOutlet var userCompanyAndCityLabel: UILabel!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var navBarTitleLabel: UILabel!
    @IBOutlet var navigationBackView: UIView!
    @IBOutlet var tableView: UITableView!
    
    var profileArray : [CAUserInfo] = []
    var userInformationDictionary = NSDictionary()
    var titleArray = NSMutableArray()
    var imageArray = NSMutableArray()

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getProfileData()
    }
    
    // MARK: - Helper methods
    func initialMethod(){
        
        self.navigationController?.navigationBar.isHidden = true
        
        titleArray = ["Skype ID","Email ID","Mobile No.","Alt Mobile No.","My PAN No.","My Aadhar No.","Gender","DOB","GSTN"]
        imageArray = ["icon8","icon7","icon6","icon6","icon5","icon4","icon3","icon2","icon"]

        
        self.userImageView.layer.cornerRadius = 45
        self.userImageView.clipsToBounds = true
     
        self.userImageView.sd_setImage(with: URL(string: checkNull(inputValue: (userInformationDictionary.value(forKey: kProfileImage) as! String as AnyObject)) as! String), placeholderImage: UIImage(named: "userplaceholder"))
             
        self.userNameLabel.text = (userInformationDictionary.value(forKey: kFirstName) as! String).appending(" ").appending((userInformationDictionary.value(forKey: kLastName) as! String))
        
        self.userCompanyAndCityLabel.text = ("      ").appending(userInformationDictionary.value(forKey: kCompanyName) as! String).appending(",  ").appending((userInformationDictionary.value(forKey: kCity) as! String))
        
        self.tableView.tableHeaderView = headerView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsSelection=false;
        
        // For registereing nib
        self.tableView.register(UINib(nibName: "CAProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "CAProfileTableViewCell")
    }
    
    
    // MARK: - UITableViewDataSource Methods.
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 8;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CAProfileTableViewCell") as! CAProfileTableViewCell
        cell.statusButton.isHidden = true
        
        if indexPath.row == 1 || indexPath.row == 2  {
            cell.statusButton.isHidden = false
        }
        cell.titleLabel.text = titleArray.object(at: indexPath.row) as? String
        cell.iconImageView.image = UIImage.init(named:(imageArray.object(at: indexPath.row) as? String)!)
        
        if(indexPath.row == 0){
            cell.valueLabel.text = userInformationDictionary.value(forKey: kSkypeId) as? String
        }
        if(indexPath.row == 1){
            cell.valueLabel.text = userInformationDictionary.value(forKey: kEmail) as? String
        }
        if(indexPath.row == 2){
            cell.valueLabel.text = userInformationDictionary.value(forKey: kMobileNumber) as? String
        }
        if(indexPath.row == 3){
            cell.valueLabel.text = userInformationDictionary.value(forKey: kAltMobileNumber) as? String
        }
        if(indexPath.row == 4){
            cell.valueLabel.text = userInformationDictionary.value(forKey: kPanNumber) as? String
        }
        if(indexPath.row == 5){
            cell.valueLabel.text = userInformationDictionary.value(forKey: kAdharNumber) as? String
        }
        if(indexPath.row == 6){
            cell.valueLabel.text = userInformationDictionary.value(forKey: kGender) as? String
        }
        if(indexPath.row == 7){
            cell.valueLabel.text = userInformationDictionary.value(forKey: kDOB) as? String
        }
        
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 60
    }
    
    
    // MARK: - UIButton Action & Selector Method
    
    @IBAction func editButtonAction(_ sender: UIButton) {
        
        //let appDelegateShared : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let editProfileVC : CAEditProfileViewController = CAEditProfileViewController(nibName:"CAEditProfileViewController", bundle: nil)
        editProfileVC.profileInfoDictionary = userInformationDictionary
        self.navigationController?.pushViewController(editProfileVC, animated: true)
        //appDelegateShared.menuViewController?.embed(centerViewController: editProfileVC)
    }
    
    @IBAction func menuButtonAction(_ sender: UIButton) {
        let appDelegateShared : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegateShared.menuViewController .toggle()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getProfileData (){
        
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
                ]
            
            ServiceHelper.sharedInstanceHelper.createPostRequest(method: .post, showHud: false, params: paramDict, apiName:"Customer_Api/getUserProfile") { (result, error) in

                if(!(error != nil)){
                    if (result![kResponseCode]! as? String == "200"){
                        let resultDict:Dictionary<String, AnyObject> = result as! Dictionary
                        print(resultDict)
                        print(resultDict[kAPIPayload] as Any)
                        self.userInformationDictionary = (resultDict[kAPIPayload] as! NSArray).firstObject as! NSDictionary
                        self.initialMethod()
                        self.tableView.reloadData()

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
