//
//  CABaseContainerViewController.swift
//  ClickAccountingApp
//
//  Created by Ratneshwar Singh on 6/28/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit

//Enum definition to manage the selection of tabs
enum selectTabType {
    case Tab_none
    case Tab_home
    case Tab_gallery
    case Tab_camera
    case Tab_document
    case Tab_report
    case Tab_settings
    case Tab_contactUs
    case Tab_planSubscription
    case Tab_alertNnotification
    case Tab_makePayment
    case Tab_faq
    case Tab_howItWorks
    case Tab_profile
}


class CABaseContainerViewController: UIViewController,goToReportDelegate {

 
    @IBOutlet var tabBarHeight: NSLayoutConstraint!
    //Outlet connection from xib
    @IBOutlet var homeButton: CAButton!
    @IBOutlet var galleryButton: CAButton!
    @IBOutlet var cameraButton: CAButton!
    @IBOutlet var documentButton: CAButton!
    @IBOutlet var reportButton: CAButton!
    @IBOutlet var containerView: UIView!
    
    //Navigation controller objects
    var homeNavigationController: UINavigationController!
    var galleryNavigationController: UINavigationController!
    var cameraNavigationController: UINavigationController!
    var documentNavigationController: UINavigationController!
    var reportNavigationController: UINavigationController!
    
    //additional navigation controller
    var settingsNavigationController: UINavigationController!
    var contactUsNavigationController: UINavigationController!
    var planSubscriptionNavigationController: UINavigationController!
    var alertNnotificationNavigationController: UINavigationController!
    var makePaymentNavigationController: UINavigationController!
    var faqNavigationController: UINavigationController!
    var howItWorksNavigationController: UINavigationController!
    var profileNavigationController:UINavigationController!
    
    //Initializing navigation controller
    let galleryVC = CAGalleryDocumentViewController(nibName: "CAGalleryDocumentViewController", bundle: nil)
    let documentVC = CAGalleryDocumentViewController(nibName: "CAGalleryDocumentViewController", bundle: nil)
    let howItWorksVC = CAStaticScreenViewController(nibName:"CAStaticScreenViewController", bundle: nil)
    
    //Current View Controller
     var currentVC: UIViewController!
    
    //Enum declation
    var selectedTabBar: selectTabType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpInitialLoadingBase()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        UIApplication.shared.isStatusBarHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        currentVC.view.frame = containerView.bounds
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    //MARK: Helper Methods
    
    /// Load the inital set up for controller
    func setUpInitialLoadingBase() {
        
        currentVC = UIViewController.init()
        instantiateViewController()
        if selectedTabBar == selectTabType.Tab_none {
            selectHomeViewController()
            homeButton.backgroundColor = RGBA(32.0, g: 189.0, b: 231.0, a: 1.0)
            homeButton.isSelected = true
        }
        else {
            loadingControllersOtherThanButtonTap()
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(crossButtonTapped),
            name: NSNotification.Name(rawValue: "crossButtonPressedOnCamera"),
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(changeBottomButtonToGallery),
            name: NSNotification.Name(rawValue: "changeBottomButtonToGallery"),
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(changeBottomButtonToDocument),
            name: NSNotification.Name(rawValue: "changeBottomButtonToDocument"),
            object: nil)
   
        
    }
    
    
    /// Set up initial controller for navigation on navigationController
    func instantiateViewController(){
        
        //Controllers allocation
        let homeVC = CAHomeViewController(nibName: "CAHomeViewController", bundle: nil)
        homeVC.reportDelegate = self

        let customCameraVC = CACustomCameraViewController(nibName: "CACustomCameraViewController", bundle: nil)
        let reportVC = CAReportViewController(nibName: "CAReportViewController", bundle: nil)
        let settingsVC = CASettingViewController(nibName:"CASettingViewController", bundle: nil)
        let contactUsVC = CAContactUsViewController(nibName:"CAContactUsViewController", bundle: nil)
        let planSubscriptionVC = CAPlanSubscriptionViewController(nibName:"CAPlanSubscriptionViewController", bundle: nil)
        let alertNnotificationVC = CAAlertAndNotificationViewController(nibName:"CAAlertAndNotificationViewController", bundle: nil)
        let makePaymentVC = CAMakeAPayementViewController(nibName:"CAMakeAPayementViewController", bundle: nil)
        let faqVC = CAFAQViewController(nibName:"CAFAQViewController", bundle: nil)
        let profileVC = CAProfileViewController(nibName:"CAProfileViewController", bundle: nil)
        
        
        //Initializing navigation controllers
        homeNavigationController = UINavigationController.init(rootViewController: homeVC)
        galleryNavigationController = UINavigationController.init(rootViewController: galleryVC)
        cameraNavigationController = UINavigationController.init(rootViewController: customCameraVC)
        documentNavigationController = UINavigationController.init(rootViewController: documentVC)
        reportNavigationController = UINavigationController.init(rootViewController: reportVC)
        
        settingsNavigationController = UINavigationController.init(rootViewController: settingsVC)
        contactUsNavigationController = UINavigationController.init(rootViewController: contactUsVC)
        planSubscriptionNavigationController = UINavigationController.init(rootViewController: planSubscriptionVC)
        alertNnotificationNavigationController = UINavigationController.init(rootViewController: alertNnotificationVC)
        makePaymentNavigationController = UINavigationController.init(rootViewController: makePaymentVC)
        faqNavigationController = UINavigationController.init(rootViewController: faqVC)
        howItWorksNavigationController = UINavigationController.init(rootViewController: howItWorksVC)
        profileNavigationController = UINavigationController.init(rootViewController: profileVC)
    }
    
    func resetButtonState() {
        
        homeButton.isSelected = false
        galleryButton.isSelected = false
        cameraButton.isSelected = false
        documentButton.isSelected = false
        reportButton.isSelected = false
        homeButton.backgroundColor = RGBA(243.0, g: 243.0, b: 243.0, a: 1.0)
        galleryButton.backgroundColor = RGBA(243.0, g: 243.0, b: 243.0, a: 1.0)
        cameraButton.backgroundColor = RGBA(243.0, g: 243.0, b: 243.0, a: 1.0)
        documentButton.backgroundColor = RGBA(243.0, g: 243.0, b: 243.0, a: 1.0)
        reportButton.backgroundColor = RGBA(243.0, g: 243.0, b: 243.0, a: 1.0)
    }
    
    
    
    
    
    
    
    
    
    //Replace current controller view with provided
    func replaceCurrentVCWithNewVC(updatedVC: UIViewController) {
        currentVC .willMove(toParentViewController: nil)
        currentVC.view.removeFromSuperview()
        currentVC.removeFromParentViewController()
        currentVC = updatedVC
        addChildViewController(currentVC)
        containerView.addSubview(currentVC.view)
        currentVC.view.frame = containerView.bounds
        currentVC.didMove(toParentViewController: self)
        
    }
    
    //Set home vc as root
    func selectHomeViewController() {
  
        let homeVC = CAHomeViewController(nibName: "CAHomeViewController", bundle: nil)
        homeVC.reportDelegate = self
        homeNavigationController = UINavigationController.init(rootViewController: homeVC)
        selectedTabBar = selectTabType.Tab_home
        homeNavigationController.navigationBar.isHidden = true
        replaceCurrentVCWithNewVC(updatedVC: homeNavigationController)
    }
    
    //Set gallery vc as root
    func selectGalleryViewController() {
        let galleryVC = CAGalleryDocumentViewController(nibName: "CAGalleryDocumentViewController", bundle: nil)
        galleryVC.navigationBarTitleString  = "Gallery"
        galleryNavigationController = UINavigationController.init(rootViewController: galleryVC)
        selectedTabBar = selectTabType.Tab_gallery
        galleryNavigationController.navigationBar.isHidden = true
        replaceCurrentVCWithNewVC(updatedVC: galleryNavigationController)
    }
    
    //Set custom camera vc as root
    func selectCustomCameraViewController() {
        
        tabBarHeight.constant = 0
        let customCameraVC = CACustomCameraViewController(nibName: "CACustomCameraViewController", bundle: nil)
        cameraNavigationController = UINavigationController.init(rootViewController: customCameraVC)
        selectedTabBar = selectTabType.Tab_camera
        cameraNavigationController.navigationBar.isHidden = true
        replaceCurrentVCWithNewVC(updatedVC: cameraNavigationController)
    }
    
    //Set document vc as root
    func selectDocumentViewController() {
   
        let documentVC = CAGalleryDocumentViewController(nibName: "CAGalleryDocumentViewController", bundle: nil)
        documentVC.navigationBarTitleString  = "Document"
        documentNavigationController = UINavigationController.init(rootViewController: documentVC)
        selectedTabBar = selectTabType.Tab_document
        documentNavigationController.navigationBar.isHidden = true
        replaceCurrentVCWithNewVC(updatedVC: documentNavigationController)
    }
    
    //Set report vc as root
    func selectReportViewController() {

        let reportVC = CAReportViewController(nibName: "CAReportViewController", bundle: nil)
        reportNavigationController = UINavigationController.init(rootViewController: reportVC)
        selectedTabBar = selectTabType.Tab_report
        reportVC.isFromHomeCollectionView = false
        reportNavigationController.navigationBar.isHidden = true
        replaceCurrentVCWithNewVC(updatedVC: reportNavigationController)
    }
    
    func changeToReportTab(reportData: AnyObject) {
        let reportVC = CAReportViewController(nibName: "CAReportViewController", bundle: nil)
        reportVC.isFromHomeCollectionView = true
        reportVC.dataFromHome = reportData as! NSDictionary
        reportNavigationController = UINavigationController.init(rootViewController: reportVC)
        reportButton.backgroundColor = RGBA(32.0, g: 189.0, b: 231.0, a: 1.0)
        reportButton.isSelected = true
        homeButton.isSelected = false
        homeButton.backgroundColor = UIColor.clear
        selectedTabBar = selectTabType.Tab_report
        reportNavigationController.navigationBar.isHidden = true
        replaceCurrentVCWithNewVC(updatedVC: reportNavigationController)
    }
    

    func loadingControllersOtherThanButtonTap() {
        
        var tempTabType: selectTabType = selectTabType.Tab_none
        tempTabType = selectedTabBar
        tabBarHeight.constant = 60
        switch tempTabType {
        case selectTabType.Tab_settings:
          
            selectedTabBar = selectTabType.Tab_settings
            settingsNavigationController.navigationBar.isHidden = true
            replaceCurrentVCWithNewVC(updatedVC: settingsNavigationController)
            break
        case selectTabType.Tab_contactUs:
           
            selectedTabBar = selectTabType.Tab_contactUs
            contactUsNavigationController.navigationBar.isHidden = true
            replaceCurrentVCWithNewVC(updatedVC: contactUsNavigationController)
            break
            
        case selectTabType.Tab_planSubscription:
            
            selectedTabBar = selectTabType.Tab_planSubscription
            planSubscriptionNavigationController.navigationBar.isHidden = true
            replaceCurrentVCWithNewVC(updatedVC: planSubscriptionNavigationController)
            break
        case selectTabType.Tab_alertNnotification:
            
           selectedTabBar = selectTabType.Tab_alertNnotification
            alertNnotificationNavigationController.navigationBar.isHidden = true
            replaceCurrentVCWithNewVC(updatedVC: alertNnotificationNavigationController)
            break
            
        case selectTabType.Tab_makePayment:
            
            selectedTabBar = selectTabType.Tab_makePayment
            makePaymentNavigationController.navigationBar.isHidden = true
            replaceCurrentVCWithNewVC(updatedVC: makePaymentNavigationController)
            break
            
        case selectTabType.Tab_faq:

            howItWorksVC.stringNav = "FAQ's"
            selectedTabBar = selectTabType.Tab_howItWorks
            howItWorksNavigationController.navigationBar.isHidden = true
            replaceCurrentVCWithNewVC(updatedVC: howItWorksNavigationController)
            
//            selectedTabBar = selectTabType.Tab_faq
//            faqNavigationController.navigationBar.isHidden = true
//            replaceCurrentVCWithNewVC(updatedVC: faqNavigationController)
            break
        case selectTabType.Tab_howItWorks:
            howItWorksVC.stringNav = "How It Works"
            selectedTabBar = selectTabType.Tab_howItWorks
            howItWorksNavigationController.navigationBar.isHidden = true
            replaceCurrentVCWithNewVC(updatedVC: howItWorksNavigationController)
            break
            
        case selectTabType.Tab_profile:
            selectedTabBar = selectTabType.Tab_profile
            profileNavigationController.navigationBar.isHidden = true
            replaceCurrentVCWithNewVC(updatedVC: profileNavigationController)
            
        default:
            break
        }
    }
    
    
    //MARK: Button Action & Selector Methods
    @IBAction func commonButtonAction(_ sender: CAButton) {
        
        resetButtonState()
        sender.backgroundColor = RGBA(32.0, g: 189.0, b: 231.0, a: 1.0)
        sender.isSelected = true
        tabBarHeight.constant = 60
        switch sender.tag
        {
        case 91:
            selectHomeViewController()
            break
        case 92:
            selectGalleryViewController()
            break
        case 93:
            selectCustomCameraViewController()
            break
        case 94:
            selectReportViewController()
            break
        case 95:
            selectDocumentViewController()
            break
        default: break
            
        }
    }
    
    //Cross button notification selector
    func crossButtonTapped() {
        resetButtonState()
        tabBarHeight.constant = 60
        selectHomeViewController()
        homeButton.backgroundColor = RGBA(32.0, g: 189.0, b: 231.0, a: 1.0)
        homeButton.isSelected = true
    }
    
    func changeBottomButtonToGallery() {
        selectGalleryViewController()
        resetButtonState()
        galleryButton.isSelected = true
        galleryButton.backgroundColor = RGBA(32.0, g: 189.0, b: 231.0, a: 1.0)
    }
    
    func changeBottomButtonToDocument() {
        resetButtonState()
        selectDocumentViewController()
        documentButton.isSelected = true
        documentButton.backgroundColor = RGBA(32.0, g: 189.0, b: 231.0, a: 1.0)
    }

    
    
}
