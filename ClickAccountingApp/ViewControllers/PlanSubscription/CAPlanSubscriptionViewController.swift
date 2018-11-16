//  CAPlanSubscriptionViewController.swift
//  ClickAccountingApp
//  Created by Chandan Mishra on 30/06/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
import UIKit

class CAPlanSubscriptionViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,AddTagDelegate, UIDocumentPickerDelegate  {

    @IBOutlet var sectionTwoHeaderView: UIView!
    @IBOutlet var sectionOneHeaderView: UIView!
    @IBOutlet var sectionFirstFooterView: UIView!
    
    @IBOutlet var checkBoxButton: UIButton!
    @IBOutlet weak var tableViewPlanSubscription: UITableView!
    var currentPlan: Int!
    var currentCard: Int!
    
    let array = ["Plan A :","Plan B :","Plan C :"]
    let arrayRs = ["Rs. 1000 Per Month","Rs. 2000 Per Month","Rs. 3000 Per Month"]
    let arrayText = ["Hi my self yoyo honey, honey means honey no metter what just subscribe and shareHi my self yoyo honey, honey means honey no metter what just subscribe and share","Hi my self yoyo honey, honey means honey no metter what just subscribe and share","Hi my self yoyo honey, honey means honey no metter what just subscribe and share"]
    
    let arrayCard = ["Credit Card","Debit Card","Net Banking","Paytm"]
    
    
    let arrayDate = ["21/07/1995-Rs 2500","21/07/1995-Rs 2500","21/07/1995-Rs 2500","21/07/1995-Rs 2500","21/07/1995-Rs 2500"]
    
    let arrayPayment = ["Manual Payment, ITR Payment","Manual Payment, ITR Payment","Manual Payment, ITR Payment","Manual Payment, ITR Payment","Manual Payment, ITR Payment"]
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.initialMethod()
        
        // Do any additional setup after loading the view.
    }
        override func didReceiveMemoryWarning()
    {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func initialMethod()
    {
        currentPlan = 0
        currentCard = 3
        
        self.tableViewPlanSubscription.delegate =  self
        
        self.navigationController?.isNavigationBarHidden = true
        
        self.tableViewPlanSubscription.rowHeight = UITableViewAutomaticDimension
        self.tableViewPlanSubscription.estimatedRowHeight = 140
        
        self.tableViewPlanSubscription.register(UINib(nibName:"CAPlanSubscriptionTableViewCell",bundle: nil), forCellReuseIdentifier:"CAPlanSubscriptionTableViewCell")
        self.tableViewPlanSubscription.register(UINib(nibName:"CAPlanSubscriptionSecondTableViewCell",bundle: nil), forCellReuseIdentifier:"CAPlanSubscriptionSecondTableViewCell")        
        self.tableViewPlanSubscription.register(UINib(nibName:"PaymentTableViewCell",bundle: nil), forCellReuseIdentifier:"PaymentTableViewCell")
        
        if responds(to: #selector(getter: self.edgesForExtendedLayout)) {
            edgesForExtendedLayout = []
        }
    }
    
    //MARK: - UITableView DataSource Methods
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if(section == 0)
        {
            return 7
        }
        if(section == 1)
        {
            return 5
        }
        return 0
    }
     public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch indexPath.section
        {
        case 0:
            if indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CAPlanSubscriptionTableViewCell", for: indexPath) as! CAPlanSubscriptionTableViewCell

                cell.planLabel.text = array[indexPath.row]
                cell.planRsLabel.text = arrayRs[indexPath.row]
cell.labelText.text=arrayText[indexPath.row]
                if indexPath.row == currentPlan
                {
                    cell.radioButton.setImage(UIImage(named:"icon38"), for: .normal)
                }
                    
                else
                {
 cell.radioButton.setImage(UIImage(named:"icon39"), for: .normal)
                }
            
                return cell
            }
            else
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CAPlanSubscriptionSecondTableViewCell", for: indexPath) as! CAPlanSubscriptionSecondTableViewCell
                if indexPath.row == currentCard
                {
                    cell.radioButtonProperty.setImage(UIImage(named:"icon38"), for: .normal)
                }
                else
                {
                    cell.radioButtonProperty.setImage(UIImage(named:"icon39"), for: .normal)
                }
                cell.labelCard.text = arrayCard[indexPath.row-3]

                return cell
            }
        case 1:
            let  cell =  tableView.dequeueReusableCell(withIdentifier: "PaymentTableViewCell", for: indexPath) as! PaymentTableViewCell
            cell.dateLabel.text = arrayDate[indexPath.row]
            cell.messageLabel.text = arrayPayment[indexPath.row]
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CAPlanSubscriptionTableViewCell") as! CAPlanSubscriptionTableViewCell
            return cell
        }
    }
    public func numberOfSections(in tableView: UITableView) -> Int
    {
        return 2
    }
    
    //MARK: - TableViewDelegateMethods
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        if section == 0
        {
            return self.sectionFirstFooterView
        }
        return nil
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if (section == 0)
        {
            return self.sectionOneHeaderView
        }
        else if (section == 1)
        {
            return self.sectionTwoHeaderView
        }
        return nil
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if(indexPath.section == 0)
        {
            if indexPath.row == 3 || indexPath.row == 4 || indexPath.row == 5 || indexPath.row == 6
            {
                return 50
                
            }
//            else
//                
//            {
//                return 50
//            }
            
        }
         if (indexPath.section == 1)
        {
            return 66;
        }
        return UITableViewAutomaticDimension
    }
    
     func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        if section == 0
        {
            return 110
        }
        return 0
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if section == 0
        {
            return 35
        }
        else if section == 1
        {
            return 40
        }
        
        return 0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if indexPath.section == 0
        {
            if indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2
            {
                currentPlan =  indexPath.row
            }
            else
            
            {
                currentCard = indexPath.row
            }
            
            self.tableViewPlanSubscription.reloadData()
        }
    }
    
    
    
    //MARK: - UIButton Actions
    
    
   @IBAction func checkBoxAction(_ sender: UIButton)
 
   {
     sender.isSelected = !sender.isSelected
 
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        let appDelegateShared : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegateShared.menuViewController .toggle()
    }
    
    @IBAction func pageButtonAction(_ sender: UIButton) {
        let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["public.text"], in: UIDocumentPickerMode.import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    @IBAction func plusButtonAction(_ sender: UIButton) {
        
        let addTagPopUpVC: CAAddTagPopUpViewController = CAAddTagPopUpViewController(nibName:"CAAddTagPopUpViewController", bundle: nil)
        addTagPopUpVC.addTagDelegate = self
        addTagPopUpVC.navigationTitleString = "Add Manual"
        addTagPopUpVC.modalPresentationStyle = .overCurrentContext
        addTagPopUpVC.modalTransitionStyle = .crossDissolve
        self.present(addTagPopUpVC, animated: true, completion: nil)
    }

    @IBAction func searchButtonAction(_ sender: UIButton) {
        
    }

    @IBAction func buyNowActionButton(_ sender: Any) {
        if !self.checkBoxButton.isSelected {
            presentAlert("", msgStr: "Please accept Terms and Conditions.", controller: self)
        }else{
            presentAlert("", msgStr: "Work in progress...", controller: self)
        }
    }
    
    //Mark Custom Delegate
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

