//
//  CAAlertAndNotificationViewController.swift
//  ClickAccountingApp
//
//  Created by Deepak Kumar on 6/29/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit

class CAAlertAndNotificationViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate,AddTagDelegate {
    
    @IBOutlet var navBarTitleLabel: UILabel!
    @IBOutlet var navigationBackView: UIView!
    @IBOutlet var tableView: UITableView!
    
    var notificationTitleArray  = NSMutableArray()
    var notificationMessageArray  = NSMutableArray()
    var notificationKeyArray  = NSMutableArray()
    
    @IBOutlet var noNotificationLabel: UILabel!
    
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialMethod()
    }
    
    // MARK: - Helper methods
    func initialMethod(){
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsSelection=false;
        
        // For registereing nib
        self.tableView.register(UINib(nibName: "CAAlertAndNotificationTableViewCell", bundle: nil), forCellReuseIdentifier: "CAAlertAndNotificationTableViewCell")
        self.tableView.tableFooterView = UIView.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshData), name: Notification.Name("newNotificationReceived"), object: nil)
        
        fetchFromCoreData()
        
    }
    
    func refreshData(){
        notificationTitleArray.removeAllObjects()
        notificationMessageArray.removeAllObjects()
        notificationKeyArray.removeAllObjects()
        fetchFromCoreData()
    }
    
    
    func fetchFromCoreData(){
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NotificationTable")
        self.printCoreDataEntries()
        do {
            let results = try context.fetch(fetchRequest)
            var  notificationData = results as! [NotificationTable]
            notificationData = notificationData.reversed()
            for docData in notificationData {
                notificationTitleArray.add(docData.title!)
                notificationMessageArray.add(docData.message!)
                notificationKeyArray.add(docData.notificationKey!)
            }
            
            if(notificationTitleArray.count == 0){
                noNotificationLabel.isHidden = false
            }else{
                noNotificationLabel.isHidden = true
            }
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.saveContext()

            self.tableView.reloadData()
        }
        catch let err as NSError {
            print(err.debugDescription)
        }
        
    }
    
    func printCoreDataEntries(){
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NotificationTable")
        do {
            let results = try context.fetch(fetchRequest)
            let  notificationData = results as! [NotificationTable]
            for docData in notificationData {
                print(docData.title!)
                print(docData.message!)
                print(docData.notificationKey!)
            }
            self.tableView.reloadData()
        }
        catch let err as NSError {
            print(err.debugDescription)
        }
        
    }
    
    
    
    
    // MARK: - UITableViewDataSource Methods.
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return notificationTitleArray.count;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CAAlertAndNotificationTableViewCell") as! CAAlertAndNotificationTableViewCell
        cell.titleLabel.text   = (notificationTitleArray.object(at: indexPath.row) as? String)?.capitalized
        cell.contentLabel.text = (notificationMessageArray.object(at: indexPath.row) as? String)?.capitalized
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 80
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // delete data and row
            removeEntry(indexpath: indexPath.row)
           // tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    
    
    
    func removeEntry(indexpath : Int){
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NotificationTable")
        let predicate = NSPredicate(format: "notificationKey = %@", notificationKeyArray.object(at: indexpath) as! String)
        fetchRequest.predicate = predicate
        
        do{
            let result = try context.fetch(fetchRequest)
            print(result)
            if result.count > 0{
                for object in result {
                    context.delete(object as! NSManagedObject)
                    notificationTitleArray.removeObject(at: indexpath)
                    notificationMessageArray.removeObject(at: indexpath)
                    notificationKeyArray.removeObject(at: indexpath)
                    self.tableView.reloadData()
                }
                
                if(notificationTitleArray.count == 0){
                    noNotificationLabel.isHidden = false
                }else{
                    noNotificationLabel.isHidden = true
                }
                
                
                
            }
        }catch{
            
        }
    }
    
    
    
    // MARK: - UIButton ACtion
    
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
    
    
}
