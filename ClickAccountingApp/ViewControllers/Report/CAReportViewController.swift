//
//  CAReportViewController.swift
//  ClickAccountingApp
//
//  Created by Ratneshwar Singh on 6/29/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit
import Alamofire
import PDFKit

class CAReportViewController: UIViewController , UICollectionViewDelegate, UICollectionViewDataSource , UITableViewDelegate , UITableViewDataSource, AddTagDelegate, UIWebViewDelegate,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var tagTableView: UITableView!
    @IBOutlet var reportWebView: UIWebView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    var primaryTagArray = NSMutableArray()
    var secondaryTagArray = NSMutableArray()
    var htmlString : String = ""
    let searchElement = NSMutableDictionary()
    var selectedPrimaryTags = NSMutableArray()
    var selectedSecondaryTags = NSMutableArray()
    @IBOutlet var noReportLabel: UILabel!
    var selectedTagsArray = NSMutableArray()
    var masterTags = NSMutableArray()
    var dataFromHome = NSDictionary()
    var isFromHomeCollectionView: Bool = false
    var index = -1
    var canSelect: Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        masterTags = ["all","count","year", "month","day", "amount", "cash+", "cash-", "bank+", "bank-", "other"]
        self.getAllPrimaryTags()
        self.getAllSecondaryTags()
        activityIndicatorView.isHidden = true
        self.tagTableView!.register(UINib(nibName: "CAHomeTagCell", bundle: nil), forCellReuseIdentifier: "CAHomeTagCell")
        self.tagTableView.delegate = self
        self.tagTableView.dataSource = self
        reportWebView.scalesPageToFit = true
        if(isFromHomeCollectionView){
            self.generateReport(reportArray: ((dataFromHome.value(forKey: kReportData) as! NSArray).mutableCopy() as! NSMutableArray), saveReport: "0")
            noReportLabel.isHidden = true
      
            selectedTagsArray = (((dataFromHome.value(forKey: kReportData) as! NSArray).firstObject as! NSDictionary).allValues as NSArray).mutableCopy() as! NSMutableArray
            
      
            let masterPrimaryPredicate = NSPredicate(format: "Tag_Type = %@ OR Tag_Type = %@ " , "master" , "primary tag")
            let primaryTagData = selectedTagsArray.filter { masterPrimaryPredicate.evaluate(with: $0)}
            
            for object in primaryTagData {
                selectedPrimaryTags.add((object as! NSDictionary).value(forKey: "Id")!)
            }
            
            let secondaryPredicate = NSPredicate(format: "Tag_Type = %@" , "secondary tag")
            let secondaryTagData = selectedTagsArray.filter { secondaryPredicate.evaluate(with: $0)}
            for object in secondaryTagData {
                selectedSecondaryTags.add((object as! NSDictionary).value(forKey: "Id")!)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableView delegate Methods
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 53
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CAHomeTagCell", for: indexPath) as? CAHomeTagCell
        cell?.tagCollectionView.register(UINib(nibName: "CATagCollectionCell", bundle: nil), forCellWithReuseIdentifier: "CATagCollectionCell")
        cell?.tagCollectionView.showsHorizontalScrollIndicator = false
        cell?.tagCollectionView.tag = indexPath.row + 500
        cell?.tagCollectionView.allowsSelection = true
        cell?.tagCollectionView.delegate = self
        cell?.tagCollectionView.dataSource = self
        cell?.tagCollectionView.reloadData()
        return cell!
    }
    
    // MARK: - UICollectionView delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView.tag == 500) {
            return self.primaryTagArray.count
        }
        else {
            return self.secondaryTagArray.count
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let tagCell: CATagCollectionCell? = (collectionView.dequeueReusableCell(withReuseIdentifier: "CATagCollectionCell", for: indexPath) as? CATagCollectionCell)
        tagCell?.tag = collectionView.tag
        //   tagCell?.tagBtn?.tag = indexPath.item + 10000
        tagCell?.tagBtn?.addTarget(self, action: #selector(CAReportViewController.tagAction(_:)), for: .touchUpInside)
        
        if(collectionView.tag == 500) {
            
            tagCell?.tagBtn?.setTitle(((primaryTagArray[indexPath.row] as AnyObject) .value(forKey: kPrimaryName) as? String)?.capitalized, for: .normal)
            
            if(((primaryTagArray[indexPath.row] as AnyObject) .value(forKey: kSourceType) as? String) == "document gallery"){
                tagCell?.tagBtn?.backgroundColor = UIColor.lightGray
            }
            else{
                tagCell?.tagBtn?.backgroundColor  =  UIColor(red: 27.0/255.0, green: 184.0/255.0, blue: 226.0/255.0, alpha: 1)
                
            }
            tagCell?.tickImage?.isHidden = true
            if(selectedPrimaryTags.contains((primaryTagArray[indexPath.row] as AnyObject) .value(forKey: kTagId) as Any)){
                tagCell?.tickImage?.isHidden = false
            }
            tagCell?.tagBtn?.tag = indexPath.item + 10000
            
        }
        else {
            tagCell?.tickImage?.isHidden = true
            tagCell?.tagBtn?.setTitle(((secondaryTagArray[indexPath.row] as AnyObject) .value(forKey: kSecondaryName) as? String)?.capitalized, for: .normal)
            
            if(((secondaryTagArray[indexPath.row] as AnyObject) .value(forKey: kSourceType) as? String) == "document gallery"){
                tagCell?.tagBtn?.backgroundColor = UIColor.lightGray
            }
            else{
                tagCell?.tagBtn?.backgroundColor  =  UIColor(red: 27.0/255.0, green: 184.0/255.0, blue: 226.0/255.0, alpha: 1)
            }
            
            if(selectedSecondaryTags.contains((secondaryTagArray[indexPath.row] as AnyObject) .value(forKey: kTagId)!)){
                tagCell?.tickImage?.isHidden = false
            }
            
            
            tagCell?.tagBtn?.tag = indexPath.item + 20000
            
        }
        return tagCell!
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var cellSize = CGSize()
        if collectionView.tag == 500{
            
            let myString: NSString = checkNull(inputValue:(primaryTagArray.object(at: indexPath.row ) as AnyObject).value(forKey: kPrimaryName) as! NSString) as! NSString
            let size: CGSize = myString.size(attributes: [NSFontAttributeName: UIFont.init(name: "Calibri", size: 16.0)!])
            cellSize  = CGSize(width:size.width + 30,height: 50)
        }
        else {
            
            let myString: NSString = checkNull(inputValue: (secondaryTagArray.object(at: indexPath.row ) as AnyObject).value(forKey: kSecondaryName) as! NSString) as! NSString
            let size: CGSize = myString.size(attributes: [NSFontAttributeName: UIFont.init(name: "Calibri", size: 16.0)!])
            cellSize  = CGSize(width:size.width + 30,height: 50)
        }
        
        return cellSize
    }
    
    // MARK: - custom Methods
    func tagAction(_ sender: UIButton) {
        
        if(selectedTagsArray.count > 4){
            canSelect = false
        }else{
            canSelect = true
        }
        
        noReportLabel.isHidden = true
        
        if(sender.tag > 20000 || sender.tag == 20000 ){
            print("Selected Secondary tags")
            index = sender.tag - 20000
            
            if(canSelect){
                let selectedSecondary = NSMutableDictionary()
                selectedSecondary .setValue((self.secondaryTagArray.object(at: index) as AnyObject).value(forKey: kTagId), forKey: kTagId)
                selectedSecondary.setValue("secondary tag", forKey: "Tag_Type")
                selectedSecondary.setValue((self.secondaryTagArray.object(at: index) as AnyObject).value(forKey: "Source_Type"), forKey: "Source_Type")
                selectedTagsArray.add(selectedSecondary)
                selectedSecondaryTags.add((self.secondaryTagArray.object(at: index) as AnyObject).value(forKey: kTagId) as Any)
                self.generateReport(reportArray: selectedTagsArray, saveReport: "0")
            }
            else{
                presentAlert(kZoddl, msgStr: "You cannot select more that 5 tags", controller: self)
            }
        }
        else{
            index = sender.tag - 10000
            if(canSelect){
                let selectedPrimary = NSMutableDictionary()
                selectedPrimary .setValue((self.primaryTagArray.object(at: index) as AnyObject).value(forKey: kTagId), forKey: kTagId)
                if(index <= 7){
                    selectedPrimary.setValue("master", forKey: "Tag_Type")
                    selectedPrimary.setValue("universal", forKey: "Source_Type")


                }else{
                    selectedPrimary.setValue("primary tag", forKey: "Tag_Type")
                    selectedPrimary.setValue((self.primaryTagArray.object(at: index) as AnyObject).value(forKey: "Source_Type"), forKey: "Source_Type")

                }
                selectedPrimary.setValue((self.primaryTagArray.object(at: index) as AnyObject).value(forKey: kPrimaryName)
                    , forKey: "Prime_Name")
                
                
                selectedTagsArray.add(selectedPrimary)
                selectedPrimaryTags.add((self.primaryTagArray.object(at: index) as AnyObject).value(forKey: kTagId) as Any as Any)
                self.generateReport(reportArray: selectedTagsArray, saveReport: "0")
            }
            else{
                presentAlert(kZoddl, msgStr: "You cannot select more that 5 tags", controller: self)
            }
        }
        
        self.tagTableView.reloadData()
        
    }
    
    @IBAction func sideMenuAction(_ sender: UIButton){
        let appDelegateShared : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegateShared.menuViewController .toggle()
    }
    
    @IBAction func searchAction(_ sender: UIButton){
        presentAlert("", msgStr: "Work in progress...", controller: self)
    }
    
    @IBAction func addDocumentAction(_ sender: UIButton){
        
        let addTagPopUpVC: CAAddTagPopUpViewController = CAAddTagPopUpViewController(nibName:"CAAddTagPopUpViewController", bundle: nil)
        addTagPopUpVC.addTagDelegate = self
        addTagPopUpVC.navigationTitleString = "Add Manual"
        addTagPopUpVC.modalPresentationStyle = .overCurrentContext
        addTagPopUpVC.modalTransitionStyle = .crossDissolve
        self.present(addTagPopUpVC, animated: true, completion: nil)
    }
    
    
    @IBAction func refreshClicked(_ sender: Any) {
        if(selectedTagsArray.count == 0){
            self.generateReport(reportArray: selectedTagsArray, saveReport: "0")
        }
        else{
            self.generateReport(reportArray: selectedTagsArray, saveReport: "1")
        }
        refreshClicked()
    }
    
    func refreshClicked(){
      
        selectedTagsArray.removeAllObjects()
        selectedPrimaryTags.removeAllObjects()
        selectedSecondaryTags.removeAllObjects()
        searchElement.removeAllObjects()
        self.tagTableView.reloadData()
        self.noReportLabel.isHidden = true
    }
    
    
    @IBAction func shareButtonAction(_ sender: UIButton){
        
        UIGraphicsBeginImageContext(view.frame.size)
        reportWebView.layer.render(in: UIGraphicsGetCurrentContext()!)
   
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
        
        guard let pdfdata = printablePdfData(webView: reportWebView) else{return}
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        let docURL = documentDirectory.appendingPathComponent("share_report.pdf")
        print(docURL)
        let docString = docURL.absoluteString
        var pdfUrl:NSURL
        
        do {
            try  pdfdata.write(to: docURL, options: NSData.WritingOptions.atomic)
                 pdfUrl =  NSURL(fileURLWithPath: docString)
    
            let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [pdfUrl], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView=self.view
            present(activityViewController, animated: true, completion: nil)
        } catch {
            print("error catched")
        }
      
   
    }
    
    private func printablePdfData(webView: UIWebView) -> NSData? {
        let A4Size = CGSize(width:2480,height:3504) // A4 in pixels at 300dpi
        let renderer = PRV300dpiPrintRenderer()
        let formatter = webView.viewPrintFormatter()
        formatter.perPageContentInsets = UIEdgeInsets.zero
        renderer.addPrintFormatter(formatter, startingAtPageAt: 0)
        let topPadding: CGFloat = 115.0
        let bottomPadding: CGFloat = 117.0
        let leftPadding: CGFloat = 100.0
        let rightPadding: CGFloat = 100.0
        let printableRect = CGRect(x:leftPadding,y:topPadding,width:A4Size.width - leftPadding - rightPadding,height: A4Size.height - topPadding - bottomPadding)
        let A4Rect = CGRect(x:0,y: 0,width: A4Size.width,height: A4Size.height)
        renderer.setValue(NSValue(cgRect: A4Rect), forKey: "paperRect")
        renderer.setValue(NSValue(cgRect: printableRect), forKey: "printableRect")
        let data = renderer.pdfData()
        return data
    }
    
    
    //Mark Custom Delegate
    func addDelegateWithDetailsAndIsSubmit(details: NSString, isSubmit: Bool) {
        
    }
    
    // MARK: - UIDocumentPickerDelegate Methods
    func documentPicker(controller: UIDocumentPickerViewController, didPickDocumentAtURL url: NSURL) {
        if controller.documentPickerMode == UIDocumentPickerMode.import {
            // This is what it should be
            do {
                let textFromFile: NSString = try String(contentsOfFile: url.path!) as NSString
                print(textFromFile)
            }
            catch {
            }
        }
    }
    
    //MARK: Web view delegate methods
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        activityIndicatorView.hidesWhenStopped = true
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicatorView.stopAnimating()
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        activityIndicatorView.stopAnimating()
    }
    
    
    
    func getAllPrimaryTags(){
        
        let paramDict : Dictionary<String, AnyObject> = [
            kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject) ,
            ]
        
        self.primaryTagArray.removeAllObjects()
        
        ServiceHelper.sharedInstanceHelper.createPostRequest(method: .post, showHud: true, params: paramDict, apiName: "Customer_Api/reportprimarytag") { (result, error) in
            
            if(!(error != nil)){
                if (result![kResponseCode]! as? String == "200"){
                    let resultDict:Dictionary<String, AnyObject> = result as! Dictionary
                    self.primaryTagArray = (resultDict[kPrimaryTag]! as! NSArray).mutableCopy() as! NSMutableArray
                    
                    for(index, data) in self.masterTags.enumerated(){
                        
                        let element = NSMutableDictionary()
                        element.setValue(data, forKey: "Prime_Name")
                        element.setValue("universal", forKey: "Source_Type")
                        element.setValue("master", forKey: "Tag_Type")
                        element.setValue(data, forKey: "Id")
                        self.primaryTagArray.insert(element, at: index)
                    }
                    let tagCell = self.tagTableView.dequeueReusableCell(withIdentifier: "CAHomeTagCell") as? CAHomeTagCell
                    tagCell?.tagCollectionView.reloadData()
                    self.tagTableView.reloadData()
                    self.primaryTagArray = checkNull(inputValue:self.primaryTagArray) as! NSMutableArray
                    print(self.primaryTagArray)
                }
                else {
                    presentAlert(kZoddl, msgStr: result![kResponseMessage]! as? String, controller: self)
                }
                
            } else {
                presentAlert("", msgStr: error?.localizedDescription, controller: self)
            }
            
        }
    }
    
    func getAllSecondaryTags(){
        
        let paramDict : Dictionary<String, AnyObject> = [
            kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject) ,
            ]
        
        self.secondaryTagArray.removeAllObjects()
        
        ServiceHelper.sharedInstanceHelper.createPostRequest(method: .post, showHud: true, params: paramDict, apiName: "Customer_Api/reportsecondarytag") { (result, error) in
            
            if(!(error != nil)){
                if (result![kResponseCode]! as? String == "200"){
                    let resultDict:Dictionary<String, AnyObject> = result as! Dictionary
                    self.secondaryTagArray = (resultDict[kSecondaryTag]! as! NSArray).mutableCopy() as! NSMutableArray
                    
                    let tagCell = self.tagTableView.dequeueReusableCell(withIdentifier: "CAHomeTagCell") as? CAHomeTagCell
                    tagCell?.tagCollectionView.reloadData()
                    self.tagTableView.reloadData()
                    self.secondaryTagArray = checkNull(inputValue:self.secondaryTagArray) as! NSMutableArray
                }
                else {
                    presentAlert(kZoddl, msgStr: result![kResponseMessage]! as? String, controller: self)
                }
                
            } else {
                presentAlert("", msgStr: error?.localizedDescription, controller: self)
            }
            
        }
    }
    
    
    
    
    func generateReport(reportArray: NSMutableArray, saveReport: String){
        
        let dataArray = NSMutableArray()
        for (index, data) in reportArray.enumerated() {
            searchElement .setValue(data, forKey: ("column\(Int(index) + 1)"))
            
            if(index == 4){
                canSelect = false
            }
        }
        dataArray.add(searchElement)
        var dataString  = NSString()
        
        if(isFromHomeCollectionView){
            do {
                let jsonData = try JSONSerialization.data(withJSONObject:  reportArray as NSArray, options: JSONSerialization.WritingOptions.prettyPrinted)
                
                if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
                    dataString = JSONString as NSString
                }
                
            } catch {
            }
            
        }
        else{
            do {
                let jsonData = try JSONSerialization.data(withJSONObject:  dataArray as NSArray, options: JSONSerialization.WritingOptions.prettyPrinted)
                
                if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
                    dataString = JSONString as NSString
                }
                
            } catch {
            }
            
        }

        let paramDict : Dictionary<String, AnyObject> = [
            kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject),
            "reportjson" : dataString as AnyObject,
            "savereport" : saveReport as AnyObject
        ]
        
        ServiceHelper.sharedInstanceHelper.createPostRequest(method: .post, showHud: true, params: paramDict, apiName: "Report_Api/report") { (result, error) in
            
            if(!(error != nil)){
                if (result![kResponseCode]! as? String == "200"){
                    let resultDict:Dictionary<String, AnyObject> = result as! Dictionary
                    let reportData = resultDict[kAPIPayload]! as! NSArray
                    let htmlfetched = reportData.firstObject as! NSDictionary
                    self.htmlString = htmlfetched.value(forKey: "html") as! String
                    self.reportWebView.loadHTMLString(self.htmlString, baseURL: nil)
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
