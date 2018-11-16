//
//  CAMenuNoSubClassViewController.swift
//  ClickAccountingApp
//
//  Created by Ratneshwar Singh on 6/30/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleToolboxForMac
import FBSDKLoginKit


class CAMenuNoSubClassViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, logOutDelegate {
    
    @IBOutlet var menuTableView : UITableView!
    
    //array allocation
    var menuTitleArray: [String] = []
    var logoutVC : CALogOutPopUpViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
//        menuTitleArray = ["Contact Us","My Settings","My Profile","Alert & Notification","Plan Subscription","Make A Payment","How Its Work","FAQ's","Logout"]
        
        menuTitleArray = ["Contact Us","My Settings","My Profile","Alert & Notification","Make A Payment","How Its Work","FAQ's","Logout"]

        menuTableView.register(UINib.init(nibName: "CAMenuTableCell", bundle: nil), forCellReuseIdentifier: "CAMenuTableCell")
        menuTableView.tableFooterView = UIView.init()
        navigationController?.navigationBar.isHidden = true
        logoutVC = CALogOutPopUpViewController(nibName:"CALogOutPopUpViewController", bundle: nil)
        logoutVC.delegate = self
        logoutVC.modalPresentationStyle = .overCurrentContext
        logoutVC.modalTransitionStyle = .crossDissolve

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Custom Delegate Methods
    func callLogOut(){
        
        self.view.endEditing(true)

        let paramDict : Dictionary<String, AnyObject> = [
                kID :(UserDefaults.standard .value(forKey: kID) as AnyObject) ,
                kDeviceToken : kUserDefaults.value(forKey: kDeviceToken) as AnyObject
            ]
            
        ServiceHelper.sharedInstanceHelper.createPostRequest(method: .post, showHud: false, params: paramDict, apiName: "Customer_Api/logout") { (result, error) in
                
                if(!(error != nil)){
                    if (result![kResponseCode]! as? String == "200"){
                        UserDefaults.standard.removeObject(forKey: kID)
                        self.clearDataFormCoreData()
                    //    GIDSignIn.sharedInstance() . signOut()
                    //    FBSDKLoginManager().logOut()
                        FBSDKAccessToken.setCurrent(nil)
                        FBSDKProfile.setCurrent(nil)
                        if let bundleID = Bundle.main.bundleIdentifier {
                            UserDefaults.standard.removePersistentDomain(forName: bundleID)
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
    
    
    //MARK: - Clear core data values

    func clearDataFormCoreData(){
      
        let context = ( UIApplication.shared.delegate as! AppDelegate ).persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Document")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do
        {
            try context.execute(deleteRequest)
            try context.save()
        }
        catch
        {
            print ("There was an error")
        }
        
    }
    

    
    //MARK: - UITableViewDataSouce Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuTitleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let menuCell: CAMenuTableCell =  tableView.dequeueReusableCell(withIdentifier: "CAMenuTableCell") as! CAMenuTableCell
        menuCell.menuTitleLabel.text = menuTitleArray[indexPath.row]
        menuCell.selectionStyle = UITableViewCellSelectionStyle.none
        return menuCell;
    }
    
    //MARK: UITableViewDelegate Functions
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let appDelegateShared : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        switch indexPath.row {
        case 0:
            //Contact Us
            let baseContainerController: CABaseContainerViewController = CABaseContainerViewController(nibName:"CABaseContainerViewController", bundle: nil)
            baseContainerController.selectedTabBar = selectTabType.Tab_contactUs
            let baseNavigationController: UINavigationController = UINavigationController.init(rootViewController: baseContainerController)
            baseNavigationController.navigationBar.isHidden = true
            appDelegateShared.menuViewController?.embed(centerViewController: baseNavigationController)
            break
            
        case 1:
            //Settings
            let baseContainerController: CABaseContainerViewController = CABaseContainerViewController(nibName:"CABaseContainerViewController", bundle: nil)
            baseContainerController.selectedTabBar = selectTabType.Tab_settings
            let baseNavigationController: UINavigationController = UINavigationController.init(rootViewController: baseContainerController)
            baseNavigationController.navigationBar.isHidden = true
            appDelegateShared.menuViewController?.embed(centerViewController: baseNavigationController)
            break
            
        case 2:
            //Profile
            let baseContainerController:CABaseContainerViewController = CABaseContainerViewController(nibName:"CABaseContainerViewController",bundle:nil)
            baseContainerController.selectedTabBar = selectTabType.Tab_profile
            let baseNavigationController:UINavigationController = UINavigationController.init(rootViewController: baseContainerController)
            baseNavigationController.navigationBar.isHidden = true
            appDelegateShared.menuViewController.embed(centerViewController: baseNavigationController)
//            let profileVC: CAProfileViewController = CAProfileViewController(nibName:"CAProfileViewController", bundle: nil)
//            let baseNavigationController: UINavigationController = UINavigationController.init(rootViewController: profileVC)
//            baseNavigationController.navigationBar.isHidden = true
//            appDelegateShared.menuViewController?.embed (centerViewController: baseNavigationController)
            break
            
        case 3:
            //Alert Notification
            let baseContainerController: CABaseContainerViewController = CABaseContainerViewController(nibName:"CABaseContainerViewController", bundle: nil)
            baseContainerController.selectedTabBar = selectTabType.Tab_alertNnotification
            let baseNavigationController: UINavigationController = UINavigationController.init(rootViewController: baseContainerController)
            baseNavigationController.navigationBar.isHidden = true
            appDelegateShared.menuViewController?.embed(centerViewController: baseNavigationController)
            break
            
//        case 4:
//            //Plan Subscription
//            let baseContainerController: CABaseContainerViewController = CABaseContainerViewController(nibName:"CABaseContainerViewController", bundle: nil)
//            baseContainerController.selectedTabBar = selectTabType.Tab_planSubscription
//            let baseNavigationController: UINavigationController = UINavigationController.init(rootViewController: baseContainerController)
//            baseNavigationController.navigationBar.isHidden = true
//            appDelegateShared.menuViewController?.embed(centerViewController: baseNavigationController)
//            break;
            
        case 4:
            let baseContainerController: CABaseContainerViewController = CABaseContainerViewController(nibName:"CABaseContainerViewController", bundle: nil)
            baseContainerController.selectedTabBar = selectTabType.Tab_makePayment
            let baseNavigationController: UINavigationController = UINavigationController.init(rootViewController: baseContainerController)
            baseNavigationController.navigationBar.isHidden = true
            appDelegateShared.menuViewController?.embed(centerViewController: baseNavigationController)
            break
            
        case 5:
            
            let baseContainerController: CABaseContainerViewController = CABaseContainerViewController(nibName:"CABaseContainerViewController", bundle: nil)
            baseContainerController.selectedTabBar = selectTabType.Tab_howItWorks
            let baseNavigationController: UINavigationController = UINavigationController.init(rootViewController: baseContainerController)
            baseNavigationController.navigationBar.isHidden = true
            appDelegateShared.menuViewController?.embed(centerViewController: baseNavigationController)
            break
            
        case 6:
            let baseContainerController: CABaseContainerViewController = CABaseContainerViewController(nibName:"CABaseContainerViewController", bundle: nil)
            baseContainerController.selectedTabBar = selectTabType.Tab_faq
            let baseNavigationController: UINavigationController = UINavigationController.init(rootViewController: baseContainerController)
            baseNavigationController.navigationBar.isHidden = true
            appDelegateShared.menuViewController?.embed(centerViewController: baseNavigationController)
            break
        case 7:
            //Logout
            appDelegateShared.navController?.present(self.logoutVC, animated: true, completion: nil)
            DispatchQueue.main.async {
            }
            break;
        default:
            break
        }
    }
    
}
