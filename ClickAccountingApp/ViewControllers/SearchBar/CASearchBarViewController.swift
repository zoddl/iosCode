//
//  CASearchBarViewController.swift
//  ClickAccountingApp
//
//  Created by apptology on 3/8/18.
//  Copyright © 2018 Mobiloitte. All rights reserved.
//

import UIKit

//MARK: - Custom Protocol for Filter
protocol SearchDelegate: class {
    func getSearchString(searchString: String , searchType : String)
}


class CASearchBarViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UINavigationControllerDelegate {
    weak var searchDelegate: SearchDelegate?

    @IBOutlet var searchBar: UISearchBar!
    var incomingController : String = ""
    @IBOutlet var searchTableview: UITableView!
    @IBOutlet var heightOfTableview: NSLayoutConstraint!
    var sourceType : String = ""

    var searchArray = NSMutableArray()
    var sourceTypes = NSMutableArray()

    var filteredArray = NSMutableArray()

    var primaryTags = NSMutableArray()
    var secondaryTags = NSMutableArray()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.becomeFirstResponder()
        searchBar.delegate = self
        heightOfTableview.constant  = 0.0
        primaryTags = (kUserDefaults.value(forKey: kAllPrimaryTags) as! NSArray).mutableCopy() as! NSMutableArray
        secondaryTags = (kUserDefaults.value(forKey: kAllSecondaryTags) as! NSArray) .mutableCopy() as! NSMutableArray
        searchArray.addObjects(from:[primaryTags.value(forKey: kPrimaryName)].first as! [Any])
        searchArray.addObjects(from:[secondaryTags.value(forKey: kSecondaryName)].first as! [Any])
        
        sourceTypes.addObjects(from:[primaryTags.value(forKey: "Source_Type")].first as! [Any])
        sourceTypes.addObjects(from:[secondaryTags.value(forKey: "Source_Type")].first as! [Any])


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func cancelSearch(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: Tableview Datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredArray.count
    }
    
    //MARK: Tableview delegates

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: nil)
        cell.textLabel?.text = filteredArray.object(at: indexPath.row) as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sourceType = sourceTypes.object(at: indexPath.row) as! String
        searchDelegate?.getSearchString(searchString: (filteredArray.object(at: indexPath.row) as? String)!, searchType: sourceType)
        self.dismiss(animated: true, completion: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchBar.text!)
        let predicate = NSPredicate(format: "SELF contains[c] %@", searchBar.text!)
        filteredArray = (searchArray.filtered(using: predicate) as NSArray).mutableCopy() as! NSMutableArray
        filteredArray = self.removeDuplicates(array: filteredArray)
        heightOfTableview.constant = CGFloat(filteredArray.count * 44)
        if heightOfTableview.constant > 170 {
             heightOfTableview.constant = 170
        }
        searchTableview.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let tagListVC: CATagListViewController = CATagListViewController(nibName:"CATagListViewController", bundle:nil)
        tagListVC.isFromSearch = true
        if(sourceType == "image gallery"){
            tagListVC.isFromGallery = true
        }else{
            tagListVC.isFromGallery = false
        }
        
        tagListVC.searchString = self.searchBar.text!
        navigationController?.pushViewController(tagListVC, animated: true)
    }
    
    func removeDuplicates(array : NSMutableArray) -> NSMutableArray{
        
        let tempArray = NSMutableArray()
        for(_, element) in array.enumerated(){
            if(tempArray.contains(element)){
                
            }else{
                tempArray.add(element)
            }
        }
        return tempArray
    }
    

    func callSearchAPI(searchString : String) {

        if(!Reachability.isConnectedToNetwork()){

            let actionSheetController: UIAlertController = UIAlertController(title: kZoddl, message: "Seems like you are not connected to internet. Please check your internet connection.", preferredStyle: .alert)

            let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default) { action -> Void in
            }
            actionSheetController.addAction(okAction)
            self.present(actionSheetController, animated: true, completion: nil)
        }
        else{

            let paramDict : Dictionary<String, AnyObject> = [
                kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject) ,
                "Searchdata" :searchString as AnyObject
            ]

            ServiceHelper.sharedInstanceHelper.createPostRequest(method: .post, showHud: false, params: paramDict, apiName: "Customer_Api/globalsearch") { (result, error) in

                if(!(error != nil)){
                    if (result![kResponseCode]! as? String == "200"){
                        let resultDict:Dictionary<String, AnyObject> = result as! Dictionary


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

    
}
