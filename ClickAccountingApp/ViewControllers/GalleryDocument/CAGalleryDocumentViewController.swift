//
//  CAGalleryDocumentViewController.swift
//  ClickAccountingApp
//
//  Created by Sunil Datt Joshi on 04/07/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit
import SDWebImage
import CoreFoundation
import MobileCoreServices

class CAGalleryDocumentViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource, AddTagDelegate, UIDocumentPickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,FilterDelegate, UICollectionViewDelegateFlowLayout, UIWebViewDelegate,docScreenshotDelegate,SearchDelegate,UIGestureRecognizerDelegate {
 
    
    @IBOutlet weak var galleryDocumentTableView: UITableView!
    @IBOutlet  var navigationBarTitle: UILabel!
    @IBOutlet  var pickGalleryButton: UIButton!
    var cv:UICollectionView!
    var cvIndexPath:IndexPath!
    var navigationBarTitleString : String = ""
    var tableViewIndex : NSInteger = 0
    var fetchData  = Bool()
    var imageAddedFromCamera  = Bool()
    var showHUDOnLoad  = Bool()
    var documentExtension : String = ""
    var documentPath : String = ""
    
    // let kUTExportedTypeDeclarationsKey: CFString!
    
    
    var primaryTagArray = NSMutableArray()
    var primaryTagArrayCopy = NSMutableArray()
    var refreshControl: UIRefreshControl!
    
    var secondaryTagArray = NSMutableArray()
    var categoryArray: [String] = ["Untagged(20)","Petrol(20)","Telephone(20)","Telephone(20)"]
    
    var docScreenshotView = CADocScreenshotViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData = true
        showHUDOnLoad = true
        self.initialMethod()
        
        if navigationBarTitleString == "Gallery" {
            pickGalleryButton.setImage(UIImage(named: "icon23"), for: .normal)
            if(fetchData){
                self.getAllTags()
            }
            if(!Reachability.isConnectedToNetwork()){
                self.fetchLocalData()
            }
        }
        else {
            self.getAllTags()
            self.getDocumentsData()
            pickGalleryButton.setImage(UIImage(named: "icon24"), for: .normal)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshView(notification:)), name: Notification.Name("newTagAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshView(notification:)), name: Notification.Name("tagDeleted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshGalleryData(notification:)), name: Notification.Name("imageAddedFromCamera"), object: nil)
        
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing data")
        refreshControl.addTarget(self, action: #selector(CAGalleryDocumentViewController.refresh(sender:)), for: .valueChanged)
        galleryDocumentTableView.addSubview(refreshControl)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    //MARK: - Refresh table
    func refresh(sender:AnyObject) {
        if navigationBarTitleString == "Gallery" {
            self.getAllTags()
        }else{
            self.getDocumentsData()
        }
    }
    
    
    //MARK: - HELPER Metods
    func initialMethod() {
        
        navigationBarTitle.text = navigationBarTitleString
        self.galleryDocumentTableView.delegate = self
        self.galleryDocumentTableView.dataSource = self
        self.navigationController?.isNavigationBarHidden = true
        self.galleryDocumentTableView!.register(UINib(nibName: "CAHomeCategoryCell", bundle: nil), forCellReuseIdentifier: "CAHomeCategoryCell")
        self.galleryDocumentTableView!.register(UINib(nibName: "CAHomeTagCell", bundle: nil), forCellReuseIdentifier: "CAHomeTagCell")
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5.0
        
    }
    // MARK: - UITableView delegate Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.primaryTagArray.count + 2//2 cell for tag cell others are for grid view
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 || indexPath.row == 1{
            return 53
        }
        return 140
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CAHomeCategoryCell") as? CAHomeCategoryCell
        cell?.categoryCollectionView.register(UINib(nibName: "CAHomeCatCell", bundle: nil), forCellWithReuseIdentifier: "CAHomeCatCell")
        let tagCell = tableView.dequeueReusableCell(withIdentifier: "CAHomeTagCell") as? CAHomeTagCell
        tagCell?.tagCollectionView.register(UINib(nibName: "CATagCollectionCell", bundle: nil), forCellWithReuseIdentifier: "CATagCollectionCell")
        tagCell?.tagCollectionView.showsHorizontalScrollIndicator = false
        
        if  indexPath.row == 0 {
            DispatchQueue.main.async {
                tagCell?.tagCollectionView.tag = 5000
                tagCell?.tagCollectionView.delegate = self
                tagCell?.tagCollectionView.dataSource = self
                tagCell?.tagCollectionView.reloadData()
            }
            return tagCell!
        }else if indexPath.row == 1{
            DispatchQueue.main.async {
                tagCell?.tagCollectionView.tag = 6000
                tagCell?.tagCollectionView.delegate = self
                tagCell?.tagCollectionView.dataSource = self
                tagCell?.tagCollectionView.reloadData()
                
            }
            return tagCell!
        }
        else {
            cell?.seeAllBtn.tag = indexPath.row+15000
            cell?.seeAllBtn?.addTarget(self, action: #selector(CAGalleryDocumentViewController.catAction(_:)), for: .touchUpInside)
            cell?.categoryCollectionView.showsHorizontalScrollIndicator = false
            cell?.categoryCollectionView.tag = indexPath.row + 3000
            cell?.categoryCollectionView.allowsSelection = true
            cell?.categoryCollectionView.delegate = self
            cell?.categoryCollectionView.dataSource = self
            cell?.categoryCollectionView.reloadData()
            
            if(primaryTagArray.count>0){
                
                let secondaryItemAttay = ((primaryTagArray[indexPath.row - 2] as AnyObject) .value(forKey: kPrimaryImages) as? NSArray)?.count
                
                cell?.categoryNameLabel.text = (((primaryTagArray[indexPath.row - 2] as AnyObject) .value(forKey: kPrimaryName) as? String)?.capitalized)?.appending (" (").appending((secondaryItemAttay! as NSNumber).stringValue ).appending (")")
                
            }
            cell?.categoryPriceLabel.isHidden = false
            
            if(primaryTagArray.count>0){
                let amount = checkNull(inputValue:((primaryTagArray[indexPath.row - 2] as AnyObject) .value(forKey: kTotal) as AnyObject))
                if(amount.isKind(of: NSNumber.self)){
                    cell?.categoryPriceLabel.text = ("Rs.").appending(amount.stringValue)
                }else{
                    cell?.categoryPriceLabel.text = ("Rs.").appending(amount as! String)
                }
            }
            cell?.seeAllBtn.isHidden = false
            return cell!
        }
    }
    
    // MARK: - UICollectionView delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView.tag == 5000 {
            return primaryTagArray.count
        }else if collectionView.tag == 6000{
            return secondaryTagArray.count
        }else{
            var currentIndex  = Int()
            currentIndex =  collectionView.tag - 3002
            var count  = Int()
            if(self.primaryTagArray.count > 0){
                count = ((self.primaryTagArray.object(at:currentIndex ) as AnyObject).value(forKey: kPrimaryImages) as! NSArray).count
            }
            return count
        }
    }
    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesEnded(touches, with: event)
//        let touches.first?.location(in: view) {
//            
//        }
//    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 5000{
            //user define tags name collection
            let tagCell: CATagCollectionCell? = (collectionView.dequeueReusableCell(withReuseIdentifier: "CATagCollectionCell", for: indexPath) as? CATagCollectionCell)
            tagCell?.tagBtn?.tag = indexPath.item + 7000
            tagCell?.tagBtn?.setTitle((primaryTagArray[indexPath.row] as AnyObject) .value(forKey: kPrimaryName) as? String, for: .normal)
            tagCell?.tagBtn?.addTarget(self, action: #selector(CAGalleryDocumentViewController.tagAction(_:)), for: .touchUpInside)
            return tagCell!
            
        }else if collectionView.tag == 6000{
            //pre define tags name collection
            let tagCell: CATagCollectionCell? = (collectionView.dequeueReusableCell(withReuseIdentifier: "CATagCollectionCell", for: indexPath) as? CATagCollectionCell)
            tagCell?.tagBtn?.tag = indexPath.item + 8000
            tagCell?.tagBtn?.setTitle((secondaryTagArray[indexPath.row] as AnyObject) .value(forKey: kSecondaryName) as? String, for: .normal)
            tagCell?.tagBtn?.addTarget(self, action: #selector(CAGalleryDocumentViewController.tagAction(_:)), for: .touchUpInside)
            return tagCell!
            
        }
        else{
            var currentIndex  = Int()
            currentIndex =  collectionView.tag - 3002
            
            let categoryCell: CAHomeCatCell? = (collectionView.dequeueReusableCell(withReuseIdentifier: "CAHomeCatCell", for: indexPath) as? CAHomeCatCell)
            categoryCell?.categoryBtn?.tag = collectionView.tag + 20000
            //     categoryCell?.categoryBtn?.addTarget(self, action: #selector(CAGalleryDocumentViewController.catAction(_:)), for: .touchUpInside)
            categoryCell?.categoryImage.sd_setShowActivityIndicatorView(true)
            categoryCell?.categoryImage.sd_setIndicatorStyle(.gray)
            categoryCell?.categoryImage.contentMode = UIViewContentMode.scaleAspectFit
            categoryCell?.categoryImage.clipsToBounds = true
            
            if let webView  = categoryCell?.viewWithTag(3250) as? UIWebView{
                webView.removeFromSuperview()
            }
            
            var dateString = NSString()
            
            if(self.primaryTagArray.count > 0){
                
                if((((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: kTagDate) as! NSArray).object(at: indexPath.row) as? String) != nil){
                    
                    let date = (((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: kTagDate) as! NSArray).object(at: indexPath.row) as? String)
                    
                    if((date) != nil){
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        let newdate = dateFormatter.date(from:date!)
                        let dateformatterToString = DateFormatter()
                        dateformatterToString.dateFormat = "dd MMM yyyy"
                        dateString = dateformatterToString.string(from: newdate!) as NSString
                    }
                }
                
            }
            
            if(self.primaryTagArray.count > 0){
                
                let secondaryArr = checkNull(inputValue:(((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: kSecondaryTag) as! NSArray).object(at: indexPath.row)) as! NSArray)
                
                categoryCell?.tagNameLabel.text  =  dateString.appending(", ").appending(checkNull(inputValue: (((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: kPrimaryName) as! NSArray).object(at: indexPath.row) as? String)  as AnyObject) as! String).appending(",").appending((secondaryArr.value(forKey: kSecondaryName) as AnyObject).componentsJoined(by: ",")).appending(",").appending(checkNull(inputValue: (((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: kPrimaryDescription) as! NSArray).object(at: indexPath.row) as? String)  as AnyObject) as! String)
                
                let price = (((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: kAmount) as! NSArray).object(at: indexPath.row) as? String)
                
                categoryCell?.priceLabel.text = ("Rs.").appending(price!)
                
                categoryCell?.categoryTypeLabel.text =  checkNull(inputValue: (((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Tag_Type") as! NSArray).object(at: indexPath.row) as? String)  as AnyObject).capitalized
                
                
                 //**************** comment out this to remove shortform feature **************************
                
                categoryCell?.categoryTypeLabel.font = UIFont.boldSystemFont(ofSize: 12)
                
                let catergoryType = checkNull(inputValue: (((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Tag_Type") as! NSArray).object(at: indexPath.row) as? String)  as AnyObject).capitalized
                
                var catergoryText = ""
                switch catergoryType{
                case "Bank+":
                    catergoryText = "B+"
                case "Bank-":
                    catergoryText = "B-"
                case "Cash+":
                    catergoryText = "C+"
                case "Cash-":
                    catergoryText = "C-"
                case "Other":
                    catergoryText = "O"
                default :
                    catergoryText = ""
                }
                
                categoryCell?.categoryTypeLabel.text = catergoryText
                // ****************** feature ends here ***************************************************
               
                
                if((((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Image_Url") as! NSArray).object(at: indexPath.row) as? String == "")){
                    categoryCell?.categoryImage.image =  UIImage(named: "icon18")
                }
                else{
                    
                    if navigationBarTitleString == "Gallery"{
                        
                        if(((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: kIsUploaded) as! NSArray).object(at: indexPath.row) as? String == "1"){
                            
                            categoryCell?.categoryImage.sd_setImage(with: URL(string: checkNull(inputValue: (((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Image_Url_Thumb") as! NSArray).object(at: indexPath.row) as? String)  as AnyObject) as! String), placeholderImage: UIImage(named: "icon18"))
                            
                        }
                        else{
                            let dirPath = ((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Image_Url") as! NSArray).object(at: indexPath.row) as? String
                            let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(dirPath!)
                            categoryCell?.categoryImage.image = UIImage(contentsOfFile: paths)
                            
                        }
                    }
                    else{
                        
                        categoryCell?.categoryImage.isHidden = false
                       // categoryCell?.categoryImage.image = nil
                        categoryCell?.categoryImage.contentMode = UIViewContentMode.scaleAspectFit
                        
                        let webViewDisplayed = UIWebView()
                        webViewDisplayed.isUserInteractionEnabled = false
                        webViewDisplayed.tag = 3250
                        webViewDisplayed.frame = (categoryCell?.categoryImage.frame)!
                        webViewDisplayed.backgroundColor = UIColor.clear
                        webViewDisplayed.scrollView.isScrollEnabled = false
                        webViewDisplayed.isOpaque = false
                        webViewDisplayed.delegate = self
                        webViewDisplayed.scrollView.bounces = false
                        
//                        self.cv = collectionView
//                        self.cvIndexPath = indexPath
                        
//                        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
//                        tapGesture.numberOfTapsRequired = 1
//                        tapGesture.delegate = self
                        
//                        webViewDisplayed.tag = 70 + indexPath.row
//                        webViewDisplayed.addGestureRecognizer(tapGesture)
                        
                        categoryCell?.bgView.addSubview(webViewDisplayed)
                        
                        if(((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: kIsUploaded) as! NSArray).object(at: indexPath.row) as? String == "1"){
                            
                            let tagImageURL = (((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Image_Url_Thumb") as! NSArray).object(at: indexPath.row) as? String)
                            
                            let docURL = URL(string: tagImageURL!)
                            
                            if(docURL?.pathExtension == "jpg"){
                                
                                webViewDisplayed.isHidden  = true
                                categoryCell?.categoryImage.isHidden = false
                                categoryCell?.categoryImage.sd_setImage(with: URL(string: checkNull(inputValue: (((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Image_Url_Thumb") as! NSArray).object(at: indexPath.row) as? String)  as AnyObject) as! String), placeholderImage: UIImage(named: "icon18"))
                                categoryCell?.categoryImage.contentMode = UIViewContentMode.scaleAspectFill
                                categoryCell?.categoryImage.clipsToBounds = true
                            }
                            else if(docURL?.pathExtension == "pdf"){
                                webViewDisplayed.isHidden  = false
                                categoryCell?.categoryImage.image =  UIImage(named: "icon18")
                                if((docURL) != nil){
                                    self.loadPDFWebViewData(url: docURL!, webView: webViewDisplayed, placeHolderImageView:(categoryCell?.categoryImage)! )
                                }
                            }
                            else if(docURL?.pathExtension == "xls"){
                                categoryCell?.categoryImage.image =  UIImage(named: "icon18")
                                if((docURL) != nil){
                                    self.loadWebViewData(url: docURL!, webView: webViewDisplayed, placeHolderImageView:  (categoryCell?.categoryImage)!)
                                    webViewDisplayed.backgroundColor  = UIColor.white
                                    
                                }
                                
                            }else  if(docURL?.pathExtension == "docx"||docURL?.pathExtension == "doc"){
                                webViewDisplayed.isHidden  = false
                                categoryCell?.categoryImage.image =  UIImage(named: "icon18")
                                if((docURL) != nil){
                                    self.loadWebViewData(url: docURL!, webView: webViewDisplayed, placeHolderImageView:  (categoryCell?.categoryImage)!)
                                    webViewDisplayed.backgroundColor  = UIColor.white
                                }
                            }
                                
                            else
                            {
                                webViewDisplayed.isHidden  = false
                                categoryCell?.categoryImage.image = UIImage(named: "icon18")
                                if((docURL) != nil){
                                    self.loadWebViewData(url: docURL!, webView: webViewDisplayed, placeHolderImageView:  (categoryCell?.categoryImage)!)
                                }
                            }
                            
                        }
                        else
                        {
                            let dirPath = ((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Image_Url") as! NSArray).object(at: indexPath.row) as? String
                            
                            let urlString  = URL.init(fileURLWithPath: dirPath!)
                            //      let data = try! Data(contentsOf: urlString as URL)
                            
                            if(urlString.pathExtension == "jpg"){
                                let dirPath = ((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Image_Url") as! NSArray).object(at: indexPath.row) as? String
                                let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(dirPath!)
                                categoryCell?.categoryImage.contentMode = UIViewContentMode.scaleAspectFill
                                categoryCell?.categoryImage.clipsToBounds = true
                                categoryCell?.categoryImage.isHidden = false
                                categoryCell?.categoryImage.image = UIImage(contentsOfFile: paths)
                            }
                            
                            if(urlString.pathExtension == "pdf"){
                                
                                self.loadPDFWebViewData(url: urlString as URL, webView: webViewDisplayed, placeHolderImageView:  (categoryCell?.categoryImage)!)
                            }
                            else{
                                self.loadWebViewData(url: urlString as URL, webView: webViewDisplayed, placeHolderImageView:  (categoryCell?.categoryImage)!)
                            }
                        }
                    }
                }
                
                
                if categoryCell?.categoryImage.image == nil{
                    categoryCell?.categoryImage.image =  UIImage(named: "icon18")
                }
                
                 categoryCell?.categoryTypeLabel.textColor = UIColor.black
                let primaryTag = (((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Tag_Type") as! NSArray).object(at: indexPath.row) as? String)?.lowercased()
            
                if( primaryTag == kBankPlus){
                    categoryCell?.categoryTypeLabel.backgroundColor = RGBA(33, g: 144, b: 202, a: 1)
                }
                else if(primaryTag == kBankMinus){
                    categoryCell?.categoryTypeLabel.backgroundColor = RGBA(204, g: 232, b: 244, a: 1)
                    
                }
                else if(primaryTag == kCashPlus){
                    categoryCell?.categoryTypeLabel.backgroundColor = RGBA(52, g: 211, b: 202, a: 1)
                    
                }
                else if(primaryTag == kCashMinus){
                    categoryCell?.categoryTypeLabel.backgroundColor = RGBA(191, g: 240, b: 238, a: 1)
                    
                }
                else if(primaryTag == kOther){
                    categoryCell?.categoryTypeLabel.backgroundColor = RGBA(240, g: 244, b: 245, a: 1)
                    categoryCell?.categoryTypeLabel.text = "0"
                    
                }
                else{
                    categoryCell?.categoryTypeLabel.backgroundColor = UIColor.clear
                }
                
                categoryCell?.categoryColorLabel.backgroundColor = RGBA(204, g: 232, b: 244, a: 1)
                
                categoryCell?.layer.cornerRadius = 10.0
                
                //Approved
                if((((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Tag_Status") as! NSArray).object(at: indexPath.row) as? String) == "1" ){
                    categoryCell?.categoryColorLabel.backgroundColor = RGBA(56, g: 152, b: 52, a: 1)
                }
                    
                    //Pending
                else if((((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Tag_Status") as! NSArray).object(at: indexPath.row) as? String) == "2"  ){
                    categoryCell?.categoryColorLabel.backgroundColor = RGBA(56, g: 152, b: 52, a: 1)
                }
                    
                    //Declined
                else if((((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Tag_Status") as! NSArray).object(at: indexPath.row) as? String) == "3" ){
                    categoryCell?.categoryColorLabel.backgroundColor = RGBA(56, g: 152, b: 52, a: 1)
                }
                    //Declined Blur
                else if((((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Tag_Status") as! NSArray).object(at: indexPath.row) as? String) == "4" ){
                    categoryCell?.categoryColorLabel.backgroundColor = RGBA(255, g: 38, b: 0, a: 1)
                }
                    
                    //Uploading
                else if((((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Tag_Status") as! NSArray).object(at: indexPath.row) as? String) == "6"  ){
                    categoryCell?.categoryColorLabel.backgroundColor = RGBA(204, g: 232, b: 244, a: 1)
                }
            }
            return categoryCell!
            
        }
    }
    
    
    func loadWebViewData(url : URL, webView : UIWebView, placeHolderImageView : UIImageView){
        
        DispatchQueue.global(qos: .background).async {
            print("This is run on the background queue")
            
            let request = URLRequest(url: url,
                                     cachePolicy:NSURLRequest.CachePolicy.returnCacheDataElseLoad,
                                     timeoutInterval: 10.0)
            
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            
            let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
                if((data) != nil){
                    
                    
                }
            })
            task.resume()
            
            DispatchQueue.main.async {
                webView.loadRequest(request as URLRequest)
                webView.scrollView.bounces = false
                webView.scrollView.isScrollEnabled = false
                // placeHolderImageView.isHidden = true
                
            }
        }
        
        
    }
    
    func loadPDFWebViewData(url : URL, webView : UIWebView , placeHolderImageView : UIImageView){
        
        var pdfData = Data()
        
        DispatchQueue.global(qos: .background).async {
            print("This is run on the background queue")
            
            let request = URLRequest(url: url,
                                     cachePolicy:NSURLRequest.CachePolicy.returnCacheDataElseLoad,
                                     timeoutInterval: 10.0)
            
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            
            let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
                if((data) != nil){
                    
                    pdfData = data!
                    
                    
                }
            })
            task.resume()
            
            DispatchQueue.main.async {
                webView.loadRequest(request as URLRequest)
                webView.scrollView.bounces = false
                webView.scrollView.isScrollEnabled = false
                webView.load(pdfData, mimeType: "application/pdf", textEncodingName:"", baseURL: (url.deletingLastPathComponent()))
                
                // hide placeholder image view
                //  placeHolderImageView.isHidden = true
                
            }
        }
        
    }
    
    func loadDocWebViewData(url : URL, webView : UIWebView , placeHolderImageView : UIImageView){
        
        var docData = Data()
        
        DispatchQueue.global(qos: .background).async {
            print("This is run on the background queue")
            
            let request = URLRequest(url: url,
                                     cachePolicy:NSURLRequest.CachePolicy.returnCacheDataElseLoad,
                                     timeoutInterval: 10.0)
            
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            
            let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
                if((data) != nil){
                    
                    docData = data!
                    
                    
                }
            })
            task.resume()
            
            DispatchQueue.main.async {
                webView.loadRequest(request as URLRequest)
                webView.scrollView.bounces = false
                webView.scrollView.isScrollEnabled = false
                webView.load(docData, mimeType: "application/docx", textEncodingName:"", baseURL: (url.deletingLastPathComponent()))
                
                // hide placeholder image view
                //  placeHolderImageView.isHidden = true
                
            }
        }
        
    }
    
    
    
    
    
    // MARK : Webview Delegate
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print(webView.tag);
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        
    }
    
    
    @objc func tapAction(sender:AnyObject){
      collectionView(self.cv, didSelectItemAt: self.cvIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var cellSize = CGSize()
        if collectionView.tag == 5000{
            
            let myString: NSString = checkNull(inputValue:(primaryTagArray.object(at: indexPath.row ) as AnyObject).value(forKey: kPrimaryName) as! NSString) as! NSString
            let size: CGSize = myString.size(attributes: [NSFontAttributeName: UIFont.init(name: "Calibri", size: 16.0)!])
            cellSize  = CGSize(width:size.width + 30,height: 50)
        }
        else if collectionView.tag == 6000{
            
            let myString: NSString = checkNull(inputValue: (secondaryTagArray.object(at: indexPath.row ) as AnyObject).value(forKey: kSecondaryName) as! NSString) as! NSString
            let size: CGSize = myString.size(attributes: [NSFontAttributeName: UIFont.init(name: "Calibri", size: 16.0)!])
            cellSize  = CGSize(width:size.width + 30,height: 50)
        }
        else{
            cellSize = CGSize(width:130,height: 94)
        }
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView.tag == 5000 || collectionView.tag == 6000 {
            
            print("Center tapped")
            
        }else{
            let galleryDetailsVC: CAGalleryDetailViewController = CAGalleryDetailViewController(nibName:"CAGalleryDetailViewController", bundle:nil)
            var currentIndex  = Int()
            currentIndex =  collectionView.tag - 3002
            if navigationBarTitleString == "Gallery" {
                galleryDetailsVC.isShowingGalleryData = true
            }else{
                galleryDetailsVC.isShowingGalleryData = false
            }
            
            if(((((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Id") as! NSArray).object(at: indexPath.row) as? String)) != nil){
                galleryDetailsVC.tagId =   (((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Id") as! NSArray).object(at: indexPath.row) as? String)!
                navigationController?.pushViewController(galleryDetailsVC, animated: true)
            }
            else{
                presentAlert(kZoddl, msgStr: "Details are uploading. Please wait.", controller: self)
            }
        }
        
    }
    
    //MARK: UIButton Action
    @IBAction func menuButtonAction(_ sender: UIButton) {
        let appDelegateShared : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegateShared.menuViewController .toggle()
    }
    
    @IBAction func filterButtonAction(_ sender: UIButton){
        let appDelegateShared : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let filterController: CAFilterPopupViewController = CAFilterPopupViewController(nibName:"CAFilterPopupViewController", bundle: nil)
        filterController.delegate = self
        filterController.modalPresentationStyle = .overCurrentContext
        filterController.modalTransitionStyle = .crossDissolve
        appDelegateShared.navController?.present(filterController, animated: true, completion: nil)
    }
    
    
    
    func catAction(_ sender: UIButton) {
        
        //        let allTagListVC: CAGalleryDocumentAllListViewController = CAGalleryDocumentAllListViewController(nibName:"CAGalleryDocumentAllListViewController", bundle:nil)
        //
        //        if(((primaryTagArray[sender.tag - 15002] as AnyObject) .value(forKey: kPrimaryTag) as? String) != nil){
        //            allTagListVC.navigationTitleString = ((primaryTagArray[sender.tag - 15002] as AnyObject) .value(forKey: kPrimaryName) as? String)!
        //            allTagListVC.selectedTagId = ((primaryTagArray[sender.tag - 15002] as AnyObject) .value(forKey: kPrimaryTag) as? String)!
        //            if navigationBarTitleString == "Gallery" {
        //                allTagListVC.isFromGallery = true
        //            }else{
        //                allTagListVC.isFromDocument = true
        //            }
        //            allTagListVC.userDefineArray = primaryTagArray
        //            allTagListVC.preDefineArray = secondaryTagArray
        //            navigationController?.pushViewController(allTagListVC, animated: true)
        //        }
        //        else{
        //            presentAlert(kZoddl, msgStr: "Details are uploading. Please wait.", controller: self)
        //        }
        
        let tagListVC: CATagListViewController = CATagListViewController(nibName:"CATagListViewController", bundle:nil)
        
        if(((primaryTagArray[sender.tag - 15002] as AnyObject) .value(forKey: kPrimaryTag)) != nil) {
            
            tagListVC.navBarTitleString = ((primaryTagArray[sender.tag - 15002] as AnyObject) .value(forKey: kPrimaryName) as? String)!
            tagListVC.selectedTagId = ((primaryTagArray[sender.tag - 15002] as AnyObject) .value(forKey: kPrimaryTag) as? String)!
            tagListVC.userDefineArray = primaryTagArray
            tagListVC.preDefineArray = secondaryTagArray
            
            if navigationBarTitleString == "Gallery" {
                tagListVC.isFromGallery = true
                tagListVC.isSeeAllFromGallery  = true
                
            } else {
                tagListVC.isFromGallery = false
                tagListVC.isFromDocument = true
                tagListVC.isSeeAllFromDocument  = true
            }
            navigationController?.pushViewController(tagListVC, animated: true)
        }
        else{
            presentAlert(kZoddl, msgStr: "Details are uploading. Please wait.", controller: self)
        }
        
    }
    
    
    
    
    func tagAction(_ sender: UIButton) {
        
        let tagListVC: CATagListViewController = CATagListViewController(nibName:"CATagListViewController", bundle:nil)
        let tag = sender.tag
        
        if(tag < 8000){
            if(((primaryTagArray[sender.tag - 7000] as AnyObject) .value(forKey: kPrimaryTag)) != nil){
                tagListVC.navBarTitleString = ((primaryTagArray[sender.tag - 7000] as AnyObject) .value(forKey: kPrimaryName) as? String)!
                tagListVC.selectedTagId = ((primaryTagArray[sender.tag - 7000] as AnyObject) .value(forKey: kPrimaryTag) as? String)!
                tagListVC.isPrimaryTag = true
                tagListVC.userDefineArray = primaryTagArray
                tagListVC.preDefineArray = secondaryTagArray
                if navigationBarTitleString == "Gallery" {
                    tagListVC.isFromGallery = true
                }
                else if navigationBarTitleString == "Document" {
                    tagListVC.isFromDocument = true
                }
                else {
                    tagListVC.isFromGallery = false
                    tagListVC.isFromDocument = false
                    
                }
                navigationController?.pushViewController(tagListVC, animated: true)
            }
            else{
                presentAlert(kZoddl, msgStr: "Details are uploading. Please wait.", controller: self)
            }
            
        }
        else{
            if(((secondaryTagArray[sender.tag - 8000] as AnyObject) .value(forKey: kTagId)) != nil){
                tagListVC.navBarTitleString = ((secondaryTagArray[sender.tag - 8000] as AnyObject) .value(forKey: kSecondaryName) as? String!)!
                tagListVC.selectedTagId = ((secondaryTagArray[sender.tag - 8000] as AnyObject) .value(forKey: kTagId) as? String)!
                tagListVC.isPrimaryTag = false
                tagListVC.userDefineArray = primaryTagArray
                tagListVC.preDefineArray = secondaryTagArray
                if navigationBarTitleString == "Gallery" {
                    tagListVC.isFromGallery = true
                }
                else if navigationBarTitleString == "Document" {
                    tagListVC.isFromDocument = true
                }
                else {
                    tagListVC.isFromGallery = false
                    tagListVC.isFromDocument = false
                }
                navigationController?.pushViewController(tagListVC, animated: true)
            }
            else{
                presentAlert(kZoddl, msgStr: "Details are uploading. Please wait.", controller: self)
            }
            
        }
        
    }
    
    
    @IBAction func documentButtonAction(_ sender: UIButton) {
        
        if navigationBarTitleString == "Gallery" {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: {
                })
            }
        }
        else {
            if(!Reachability.isConnectedToNetwork()){
                
                let actionSheetController: UIAlertController = UIAlertController(title: kZoddl, message: "Seems like you are not connected to internet. Please check your internet connection.", preferredStyle: .alert)
                
                let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default) { action -> Void in
                    if(self.refreshControl != nil){
                        self.refreshControl.endRefreshing()
                    }
                }
                actionSheetController.addAction(okAction)
                self.present(actionSheetController, animated: true, completion: nil)
            }
            else
            {
                //                let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["public.image", "public.audio", "public.movie", "public.text", "public.content","public.pages", "public.numbers", "public.pdf"], in: UIDocumentPickerMode.import)
                //
                //"com.apple.iwork.pages.pages", "com.apple.iwork.numbers.numbers", "com.apple.iwork.keynote.key", "com.microsoft.word.doc","public.text","com.adobe.pdf","com.microsoft.word.doc","com.microsoft.excel.xls"
                //let documentTypes = [kUTTypeapple]
                let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["com.apple.iwork.pages.pages", "com.apple.iwork.numbers.numbers", "com.apple.iwork.numbers.sffnumbers", "com.apple.iwork.keynote.key", "com.microsoft.word.doc", "public.text","com.adobe.pdf", "com.microsoft.word.doc","com.microsoft.excel.xls", kUTTypePDF as String,"public.pdf"], in: UIDocumentPickerMode.import)
                
                documentPicker.delegate = self
                documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                self.present(documentPicker, animated: true, completion: nil)
            }
            
        }
    }
    
    @IBAction func searchButtonAction(_ sender: Any) {
        let appDelegateShared : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let searchController: CASearchBarViewController = CASearchBarViewController(nibName:"CASearchBarViewController", bundle: nil)
        searchController.incomingController = "GalleryDocument"
        searchController.searchDelegate = self
        searchController.modalPresentationStyle = .overCurrentContext
        searchController.modalTransitionStyle = .crossDissolve
        appDelegateShared.navController?.present(searchController, animated: true, completion: nil)
    }
    
    @IBAction func addButtonAction(_ sender: Any) {
        
        let addTagPopUpVC: CAAddTagPopUpViewController = CAAddTagPopUpViewController(nibName:"CAAddTagPopUpViewController", bundle: nil)
        addTagPopUpVC.addTagDelegate = self
        addTagPopUpVC.navigationTitleString = "Add Manual"
        addTagPopUpVC.modalPresentationStyle = .overCurrentContext
        addTagPopUpVC.modalTransitionStyle = .crossDissolve
        addTagPopUpVC.imageURL = ""
        addTagPopUpVC.isManualTag = true
        if navigationBarTitleString == "Gallery" {
            addTagPopUpVC.isDocumentType = false
            
        }else{
            addTagPopUpVC.isDocumentType = true
            addTagPopUpVC.docExtension = "jpg"
        }
        self.present(addTagPopUpVC, animated: true, completion: nil)
    }
    
    //Mark Custom Delegate
    
    func addDelegateWithDetailsAndIsSubmit(details: NSString, isSubmit: Bool) {
        
        if navigationBarTitleString == "Document" {
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Document")
            
            do {
                let results = try context.fetch(fetchRequest)
                let  documentCreated = results as! [Document]
                
                for docData in documentCreated {
                    
                    var matchedPrimaryTag = NSDictionary()
                    
                    let resultPredicate = NSPredicate(format: "Prime_Name == [c]%@", (docData.primaryName!))
                    let arr = self.primaryTagArray.filtered(using: resultPredicate)
                    if(arr.count > 0){
                        print("Add in local")
                        matchedPrimaryTag = (arr.first as! NSDictionary).mutableCopy() as! NSMutableDictionary
                        self.primaryTagArray.remove(matchedPrimaryTag)
                        let imageArray = (matchedPrimaryTag.value(forKey: kPrimaryImages) as! NSArray).mutableCopy() as! NSMutableArray
                        
                        let entryAdded = NSMutableDictionary()
                        entryAdded .setValue(docData.primaryName, forKey: kPrimaryName)
                        entryAdded.setValue(docData.amount, forKey: kAmount)
                        entryAdded.setValue(docData.tagDate, forKey: kTagDate)
                        entryAdded.setValue("0", forKey: kIsUploaded)
                        entryAdded.setValue(docData.docPath, forKey: kTagImageURL)
                        entryAdded.setValue(docData.tagDescription, forKey: kTagDescription)
                        entryAdded.setValue(docData.tagType, forKey: kTagType)
                        entryAdded.setValue((docData.tagStatus as NSNumber).stringValue, forKey: kTagStatus)
                        
                        let data = docData.secondaryTag?.data(using: String.Encoding.utf8)
                        let secondaryTagArray  = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSArray
                        
                        let secondaryTagArrayWithKey = NSMutableArray()
                        
                        for (_, element) in secondaryTagArray.enumerated() {
                            let dict = NSMutableDictionary()
                            dict .setValue(element, forKey: "Secondary_Name")
                            secondaryTagArrayWithKey.add(dict)
                        }
                        entryAdded.setValue(secondaryTagArrayWithKey, forKey: kSecondaryTag)
                        imageArray.insert(entryAdded, at: 0) //  add(entryAdded)
                        matchedPrimaryTag .setValue(imageArray, forKey: kPrimaryImages)
                        self.primaryTagArray.insert(matchedPrimaryTag, at: 0)
                        
                    }
                    else
                    {
                        let newPrimaryTagAdded = NSMutableDictionary()
                        let imageArray = NSMutableArray()
                        
                        let entryAdded = NSMutableDictionary()
                        entryAdded .setValue(docData.primaryName, forKey: kPrimaryName)
                        entryAdded.setValue(docData.amount, forKey: kAmount)
                        entryAdded.setValue(docData.tagDate, forKey: kTagDate)
                        entryAdded.setValue("0", forKey: kIsUploaded)
                        entryAdded.setValue(docData.tagDescription, forKey: kTagDescription)
                        entryAdded.setValue(docData.docPath, forKey: kTagImageURL)
                        
                        let data = docData.secondaryTag?.data(using: String.Encoding.utf8)
                        let secondaryTagArray  = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSArray
                        let secondaryTagArrayWithKey = NSMutableArray()
                        
                        for (_, element) in secondaryTagArray.enumerated() {
                            let dict = NSMutableDictionary()
                            dict .setValue(element, forKey: "Secondary_Name")
                            secondaryTagArrayWithKey.add(dict)
                        }
                        entryAdded.setValue(secondaryTagArrayWithKey, forKey: kSecondaryTag)
                        imageArray.add(entryAdded)
                        
                        newPrimaryTagAdded.setValue(docData.primaryName, forKey: kPrimaryName)
                        newPrimaryTagAdded.setValue(docData.amount, forKey: kTotal)
                        newPrimaryTagAdded.setValue(imageArray, forKey: kPrimaryImages)
                        self.primaryTagArray.insert(newPrimaryTagAdded, at: 0)
                        
                    }
                    
                }
            }
            catch let err as NSError {
                print(err.debugDescription)
            }
            
            if (galleryDocumentTableView) != nil {
                self.galleryDocumentTableView.reloadData()
                let tagCell = self.galleryDocumentTableView.dequeueReusableCell(withIdentifier: "CAHomeTagCell") as? CAHomeTagCell
                tagCell?.tagCollectionView.reloadData()
            }
            
        }
        else{
            var tagMutable = NSMutableArray()
            if((kUserDefaults.value(forKey: "savedTag")) != nil){
                let tagArrayFetched = kUserDefaults.value(forKey: "savedTag") as! NSArray
                tagMutable = tagArrayFetched.mutableCopy() as! NSMutableArray
                tagMutable = tagMutable.removeUploaded()
                
                print(tagMutable)
                var matchedPrimaryTag = NSDictionary()
                
                for (index, element) in tagMutable.enumerated() {
                    print("Item \(index): \(element)")
                    let dict = element as! NSDictionary
                    let resultPredicate = NSPredicate(format: "Prime_Name == [c]%@", (dict.value(forKey: kPrimaryName) as! String))
                    let arr = self.primaryTagArray.filtered(using: resultPredicate)
                    if(arr.count > 0){
                        print(arr)
                        matchedPrimaryTag = (arr.first as! NSDictionary).mutableCopy() as! NSMutableDictionary
                        self.primaryTagArray.remove(matchedPrimaryTag)
                        let imageArray = (matchedPrimaryTag.value(forKey: kPrimaryImages) as! NSArray).mutableCopy() as! NSMutableArray
                        let arr = dict.value(forKey: kPrimaryImages) as! NSArray
                        imageArray.insert(arr.firstObject! , at: 0)
                        print(matchedPrimaryTag)
                        matchedPrimaryTag .setValue(imageArray.noDuplicates(byKey: kTagImageURL), forKey: kPrimaryImages)
                        self.primaryTagArray.insert(matchedPrimaryTag, at: 0)
                    }
                    else{
                        let newTagAdded = NSMutableDictionary()
                        newTagAdded .setValue(dict .value(forKey: kPrimaryName), forKey: kPrimaryName)
                        newTagAdded .setValue(dict .value(forKey: kAmount), forKey: kTotal)
                        let imageArray = NSMutableArray()
                        let arr = dict.value(forKey: kPrimaryImages) as! NSArray
                        imageArray.add(arr.firstObject as Any)
                        newTagAdded .setValue(imageArray, forKey: kPrimaryImages)
                        // tagMutable.add(newTagAdded)
                        self.primaryTagArray.insert(newTagAdded, at: 0)
                    }
                }
            }
            if (galleryDocumentTableView) != nil {
                self.galleryDocumentTableView.reloadData()
                let tagCell = self.galleryDocumentTableView.dequeueReusableCell(withIdentifier: "CAHomeTagCell") as? CAHomeTagCell
                tagCell?.tagCollectionView.reloadData()
            }
            
            if(Reachability.isConnectedToNetwork()){
                let myDelegate = UIApplication.shared.delegate as? AppDelegate
                myDelegate?.uploadImageToS3_withTags(tagMutable: tagMutable)
            }
        }
    }
    
    //Mark Check if Images from camera
    
    
    
    func callFilter(filterType: String) {
        
        if(filterType == "By Amount"){
            
            let sortedArray = self.primaryTagArray.sorted(by: { (Obj1, Obj2) -> Bool in
                let firstObj = Obj1 as! NSDictionary
                let secondObj = Obj2 as! NSDictionary
                let val1 = (firstObj.value(forKey: kTotal) as! NSString).doubleValue
                let val2 = (secondObj.value(forKey: kTotal) as! NSString).doubleValue
                return val1 < val2;
            })
            
            self.primaryTagArray = NSMutableArray(array: sortedArray)
            self.galleryDocumentTableView.reloadData()
        }
        else  if(filterType == "By Count"){
            let sortUsingPrice = NSSortDescriptor(key: kCount, ascending: false)
            let arr = ((primaryTagArray as NSArray).sortedArray(using: [sortUsingPrice])) as Array
            
            self.primaryTagArray = NSMutableArray(array: arr)
            self.galleryDocumentTableView.reloadData()
        }
        else  if(filterType == "By Alphabet"){
            
            let sortUsingPrice = NSSortDescriptor(key: kPrimaryName, ascending: true,
                                                  selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
            let arr = ((primaryTagArray as NSArray).sortedArray(using: [sortUsingPrice])) as Array
            self.primaryTagArray = NSMutableArray(array: arr)
            self.galleryDocumentTableView.reloadData()
            
        }
        else  if(filterType == "By Uses"){
            
            let sortedArray = self.primaryTagArray.sorted(by: { (Obj1, Obj2) -> Bool in
                let firstObj = Obj1 as! NSDictionary
                let secondObj = Obj2 as! NSDictionary
                let val1 = (firstObj.value(forKey: kLastestTimestamp) as! NSString).doubleValue
                let val2 = (secondObj.value(forKey: kLastestTimestamp) as! NSString).doubleValue
                return val1 < val2;
            })
            
            self.primaryTagArray = NSMutableArray(array: sortedArray)
            self.galleryDocumentTableView.reloadData()
            
        }
        else{
            self.primaryTagArray =   self.primaryTagArrayCopy
            self.galleryDocumentTableView.reloadData()
        }
    }
    
    // MARK: - UIDocumentPickerDelegate Methods
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        if controller.documentPickerMode == UIDocumentPickerMode.import {
            // This is what it should be
            do {
                // url.startAccessingSecurityScopedResource()
                let documentData = try NSData(contentsOf: url, options: NSData.ReadingOptions())
                let fileManager = FileManager.default
                
                let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(url.path)
                
                fileManager.createFile(atPath: paths, contents: documentData as Data, attributes: nil)
                fileManager.fileExists(atPath: paths)
                
                docScreenshotView = CADocScreenshotViewController(nibName:"CADocScreenshotViewController", bundle: nil)
                docScreenshotView.modalPresentationStyle = .overCurrentContext
                docScreenshotView.modalTransitionStyle = .crossDissolve
                docScreenshotView.urlString = url.absoluteString
                docScreenshotView.screenshotDelegate = self
                docScreenshotView.viewDidLoad()
                ServiceHelper.sharedInstanceHelper.showHud()
                documentExtension = url.pathExtension
                documentPath = url.path
                //   url.stopAccessingSecurityScopedResource()
                
            }
            catch {
                print("Unable to load data: \(error)")
                presentAlert(kZoddl, msgStr: "Unable to load data: \(error)", controller: self)
                
            }
        }
    }
    
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            self.dismiss(animated: true, completion: nil)
            
            let fileManager = FileManager.default
            var uuid = CFUUIDCreateString(nil, CFUUIDCreate(nil)) as String
            uuid = uuid + ".jpg"
            let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(uuid)
            let imageData = UIImageJPEGRepresentation(image, 0.5)
            fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
            fileManager.fileExists(atPath: paths)
            
            let addTagPopUpVC: CAAddTagPopUpViewController = CAAddTagPopUpViewController(nibName:"CAAddTagPopUpViewController", bundle: nil)
            addTagPopUpVC.addTagDelegate = self
            addTagPopUpVC.navigationTitleString = "Add Tag"
            addTagPopUpVC.modalPresentationStyle = .overCurrentContext
            addTagPopUpVC.modalTransitionStyle = .crossDissolve
            addTagPopUpVC.imageURL = uuid
            
            self.present(addTagPopUpVC, animated: true, completion: nil)
            
        }
    }
    
    
    //Mark : Get all document tags
    
    func getDocumentsData(){
        
        if(!Reachability.isConnectedToNetwork()){
            
            let actionSheetController: UIAlertController = UIAlertController(title: kZoddl, message: "Seems like you are not connected to internet. Please check your internet connection.", preferredStyle: .alert)
            
            let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default) { action -> Void in
                if(self.refreshControl != nil){
                    self.refreshControl.endRefreshing()
                }
            }
            actionSheetController.addAction(okAction)
            self.present(actionSheetController, animated: true, completion: nil)
        }
        else{
            
            let paramDict : Dictionary<String, AnyObject> = [
                kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject) ,
                ]
            self.primaryTagArray.removeAllObjects()
            
            ServiceHelper.sharedInstanceHelper.createPostRequest(method: .post, showHud: false, params: paramDict, apiName: kGetDocumentTags) { (result, error) in
                
                if(!(error != nil)){
                    if (result![kResponseCode]! as? String == "200"){
                        let resultDict:Dictionary<String, AnyObject> = result as! Dictionary
                        self.primaryTagArray = (resultDict[kAllTagList]! as! NSArray).mutableCopy() as! NSMutableArray
                        self.primaryTagArrayCopy =  self.primaryTagArray
                        self.secondaryTagArray.removeAllObjects()
                        for arr in self.primaryTagArray .value(forKey: kPrimaryImages) as! NSArray{
                            for json in arr as! NSArray{
                                print((json as! NSDictionary).value(forKey: kSecondaryTag) as Any)
                                let arr = (json as! NSDictionary).value(forKey: kSecondaryTag) as! NSArray
                                for jsonObject in arr {
                                    self.secondaryTagArray .add(jsonObject)
                                }
                                let dummyArray = NSMutableArray()
                                for dict in self.secondaryTagArray {
                                    if(!dummyArray.contains(dict)){
                                        dummyArray.add(dict)
                                    }
                                }
                                self.secondaryTagArray = dummyArray
                            }
                        }
                        self.galleryDocumentTableView.reloadData()
                        let tagCell = self.galleryDocumentTableView.dequeueReusableCell(withIdentifier: "CAHomeTagCell") as? CAHomeTagCell
                        tagCell?.tagCollectionView.reloadData()
                        self.refreshControl.endRefreshing()
                        
                        kUserDefaults.set(self.primaryTagArray, forKey: kAllPrimaryTags)
                        kUserDefaults.set(self.secondaryTagArray, forKey: kAllSecondaryTags)
                    }
                    else {
                        self.refreshControl.endRefreshing()
                        presentAlert(kZoddl, msgStr: result![kResponseMessage]! as? String, controller: self)
                    }
                    
                } else {
                    self.refreshControl.endRefreshing()
                    presentAlert("", msgStr: error?.localizedDescription, controller: self)
                }
                
            }
            
        }
        
    }
    
    
    
    //Mark : Get all gallery tags
    
    func getAllTags(){
 
        var apiName = String()
        
        if navigationBarTitleString == "Gallery" {
            apiName = "Customer_Api/gallerytag"
        }else{
            apiName = "Document_Api/gallerytag"
        }
        
        if(!Reachability.isConnectedToNetwork()){
            
            let actionSheetController: UIAlertController = UIAlertController(title: kZoddl, message: "Seems like you are not connected to internet. Please check your internet connection.", preferredStyle: .alert)
            
            let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default) { action -> Void in
                if(self.refreshControl != nil){
                    self.refreshControl.endRefreshing()
                }
            }
            actionSheetController.addAction(okAction)
            self.present(actionSheetController, animated: true, completion: nil)
        }
        else{
            
            fetchData = false
            
            let paramDict : Dictionary<String, AnyObject> = [
                kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject) ,
                ]
            self.primaryTagArray.removeAllObjects()
            
            ServiceHelper.sharedInstanceHelper.createPostRequest(method: .post, showHud: false, params: paramDict, apiName: apiName) { (result, error) in
                
                if(!(error != nil)){
                    if (result![kResponseCode]! as? String == "200"){
                        let resultDict:Dictionary<String, AnyObject> = result as! Dictionary
                        self.primaryTagArray = (resultDict[kAllTagList]! as! NSArray).mutableCopy() as! NSMutableArray
                        self.primaryTagArrayCopy =  self.primaryTagArray
                        self.secondaryTagArray.removeAllObjects()
                        for arr in self.primaryTagArray .value(forKey: kPrimaryImages) as! NSArray{
                            for json in arr as! NSArray{
                                print((json as! NSDictionary).value(forKey: kSecondaryTag) as Any)
                                let arr = (json as! NSDictionary).value(forKey: kSecondaryTag) as! NSArray
                                for jsonObject in arr {
                                    self.secondaryTagArray .add(jsonObject)
                                }
                                
                                let dummyArray = NSMutableArray()
                                for dict in self.secondaryTagArray {
                                    if(!dummyArray.contains(dict)){
                                        dummyArray.add(dict)
                                    }
                                }
                                self.secondaryTagArray = dummyArray
                            }
                        }
                        self.galleryDocumentTableView.reloadData()
                        let tagCell = self.galleryDocumentTableView.dequeueReusableCell(withIdentifier: "CAHomeTagCell") as? CAHomeTagCell
                        tagCell?.tagCollectionView.reloadData()
                        
                        let primaryIndexPath = IndexPath(item: 1, section: 0)
                        let secondaryIndexPath = IndexPath(item: 0, section: 0)
                        self.galleryDocumentTableView.reloadRows(at: [primaryIndexPath,secondaryIndexPath], with: .none)
                        self.fetchLocalData()
                        self.refreshControl.endRefreshing()
                        kUserDefaults.set(self.primaryTagArray, forKey: kAllPrimaryTags)
                        kUserDefaults.set(self.secondaryTagArray, forKey: kAllSecondaryTags)
                        
                    }
                    else {
                        self.refreshControl.endRefreshing()
                        presentAlert(kZoddl, msgStr: result![kResponseMessage]! as? String, controller: self)
                    }
                    
                } else {
                    self.refreshControl.endRefreshing()
                    presentAlert("", msgStr: error?.localizedDescription, controller: self)
                }
                
            }
            
        }
        
    }
    
    
    @objc func refreshView(notification: NSNotification){
        showHUDOnLoad = false
        if navigationBarTitleString == "Gallery" {
            self.getAllTags()
        }else{
            self.getDocumentsData()
        }
    }
    
    
    @objc func refreshGalleryData(notification: NSNotification){
        
        if navigationBarTitleString == "Gallery" {
            
            let dict = notification.object as! NSDictionary
            self.primaryTagArray = dict.value(forKey: "primaryArray") as! NSMutableArray
            imageAddedFromCamera = true
            self.galleryDocumentTableView.reloadData()
            let tagCell = self.galleryDocumentTableView.dequeueReusableCell(withIdentifier: "CAHomeTagCell") as? CAHomeTagCell
            tagCell?.tagCollectionView.reloadData()
        }else{
            
        }
    }
    
    
    
    func fetchLocalData(){
        
        var tagMutable = NSMutableArray()
        
        if((kUserDefaults.value(forKey: "savedTag")) != nil){
            let tagArrayFetched = kUserDefaults.value(forKey: "savedTag") as! NSArray
            tagMutable = tagArrayFetched.mutableCopy() as! NSMutableArray
            tagMutable = tagMutable.removeUploaded()
            
            var matchedPrimaryTag = NSDictionary()
            
            for (index, element) in tagMutable.enumerated() {
                print("Item \(index): \(element)")
                let dict = element as! NSDictionary
                let resultPredicate = NSPredicate(format: "Prime_Name == [c]%@", (dict.value(forKey: kPrimaryName) as! String))
                let arr = self.primaryTagArray.filtered(using: resultPredicate)
                if(arr.count > 0){
                    print(arr)
                    matchedPrimaryTag = (arr.first as! NSDictionary).mutableCopy() as! NSMutableDictionary
                    self.primaryTagArray.remove(matchedPrimaryTag)
                    let imageArray = (matchedPrimaryTag.value(forKey: kPrimaryImages) as! NSArray).mutableCopy() as! NSMutableArray
                    let arr = dict.value(forKey: kPrimaryImages) as! NSArray
                  //  imageArray.add(arr.firstObject as Any)
                    imageArray.insert(arr.firstObject!, at: 0)
                    print(matchedPrimaryTag)
                    matchedPrimaryTag .setValue(imageArray.noDuplicates(byKey: kTagImageURL), forKey: kPrimaryImages)
                    self.primaryTagArray.insert(matchedPrimaryTag, at: 0)
                }
                else{
                    let newTagAdded = NSMutableDictionary()
                    newTagAdded .setValue(dict .value(forKey: kPrimaryName), forKey: kPrimaryName)
                    newTagAdded .setValue(dict .value(forKey: kAmount), forKey: kTotal)
                    let imageArray = NSMutableArray()
                    let arr = dict.value(forKey: kPrimaryImages) as! NSArray
                  //  imageArray.add(arr.firstObject as Any)
                    imageArray.insert(arr.firstObject!, at: 0)
                    newTagAdded .setValue(imageArray, forKey: kPrimaryImages)
                    // tagMutable.add(newTagAdded)
                    self.primaryTagArray.insert(newTagAdded, at: 0)
                }
            }
        }
        if (galleryDocumentTableView) != nil {
            self.galleryDocumentTableView.reloadData()
            let tagCell = self.galleryDocumentTableView.dequeueReusableCell(withIdentifier: "CAHomeTagCell") as? CAHomeTagCell
            tagCell?.tagCollectionView.reloadData()
        }
        
    }
    
    func sendImageName(imageName: String) {
        
        ServiceHelper.sharedInstanceHelper.hideHud()
        
        let addTagPopUpVC: CAAddTagPopUpViewController = CAAddTagPopUpViewController(nibName:"CAAddTagPopUpViewController", bundle: nil)
        addTagPopUpVC.addTagDelegate = self
        addTagPopUpVC.navigationTitleString = "Add Tag"
        addTagPopUpVC.modalPresentationStyle = .overCurrentContext
        addTagPopUpVC.modalTransitionStyle = .crossDissolve
        addTagPopUpVC.docPathLocal = documentPath
        addTagPopUpVC.imageURL = imageName
        addTagPopUpVC.docExtension = documentExtension
        addTagPopUpVC.isDocumentType = true
        addTagPopUpVC.isManualTag = false
        
        self.present(addTagPopUpVC, animated: true, completion: nil)
    }
    
    
    func getSearchString(searchString: String, searchType: String) {

        let tagListVC: CATagListViewController = CATagListViewController(nibName:"CATagListViewController", bundle:nil)
        tagListVC.isFromSearch = true
        tagListVC.searchString = searchString
        tagListVC.navBarTitleString = searchString
        if(searchType == "image gallery"){
            tagListVC.isFromGallery = true
        }else{
            tagListVC.isFromGallery = false
        }
        self.navigationController?.pushViewController(tagListVC, animated: true)
    }
    
    
}

