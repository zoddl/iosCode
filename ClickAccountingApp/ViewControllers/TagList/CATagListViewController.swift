//
//  CATagListViewController.swift
//  ClickAccountingApp
//
//  Created by Deepak Kumar on 7/1/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit

class CATagListViewController: UIViewController , UITableViewDelegate , UITableViewDataSource , UICollectionViewDelegate, UICollectionViewDataSource, AddTagDelegate, UIDocumentPickerDelegate,FilterDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UICollectionViewDelegateFlowLayout, UIWebViewDelegate,docScreenshotDelegate,SearchDelegate
{
    var navBarTitleString : String = ""
    var pageNumber : Int = 1
    var loadMore : Bool = false
    var selectedTagId : String = ""
    var navigationTvar: String = ""
    var isFromGallery : Bool = false
    var isFromDocument : Bool = false
    var documentExtension : String = ""
    var documentPath : String = ""
    var isFromHome : Bool = false
    var isFromHomeTopTags : Bool = false

    var isSeeAllFromHome : Bool = false
    var isShowAllDataFromHome : Bool = false

    var selectedSecondary : Bool = false
    
    var selectedGalleryOrDocumentItem : Bool = false

    
    var isPrimaryTag : Bool = true
    var isPrimaryTagTypeGallery : Bool = false
    
    var isSeeAllFromGallery : Bool = false
    var isSeeAllFromDocument : Bool = false
    
    var isGalleryTypeFromHomeItem : Bool = false

    
    var isFromSearch : Bool = false
    var searchString : String = ""
    var sourceTypeFromHome : String = ""

    var tagTypeForSearch : String = ""
    var incomingTagTypeFormHome : String = ""

    @IBOutlet var navBarTitleLabel: UILabel!
    @IBOutlet var homeTableView: UITableView!
    @IBOutlet  var pickGalleryButton: UIButton!
    
    var primaryTagArray = NSMutableArray()
    var primaryTagArrayCopy = NSMutableArray()
    var secondaryTagArray = NSMutableArray()
    
    var userDefineArray = NSMutableArray()
    var preDefineArray = NSMutableArray()
    var categoryArray: [String] = ["Recent (20)","June (20)","May (20)","April (20)"]
    
    
    // MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initialMethod()
        
        userDefineArray = (kUserDefaults.value(forKey: kAllPrimaryTags) as! NSArray).mutableCopy() as! NSMutableArray
        preDefineArray = (kUserDefaults.value(forKey: kAllSecondaryTags) as! NSArray).mutableCopy() as! NSMutableArray
      
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshView(notification:)), name: Notification.Name("newTagAdded"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {

        if(isSeeAllFromGallery || isSeeAllFromDocument){
            self.gettagDetailsMonthly()
        }
        else if(isFromHomeTopTags){
            self.gettagDetails()
        }
        
        else if(selectedGalleryOrDocumentItem){
            self.gettagDetails()
        }
            
        else if(isFromSearch){
            self.callSearchAPI(searchString: searchString)
        }
          else if(isShowAllDataFromHome || isFromHome){
            self.getMonthlyDataOfTagType()
        }
          
        else if(isSeeAllFromHome){
            self.getAllTagsOfParticularType()
        }
        else{
            self.gettagDetails()
        }
        
    }
    
    // MARK: - intial data load methods
    
    func initialMethod(){
        
        navBarTitleLabel.text = navBarTitleString
        navBarTitleLabel.textAlignment = NSTextAlignment.center
        self.homeTableView.delegate = self
        self.homeTableView.dataSource = self
        self.navigationController?.isNavigationBarHidden = true
        self.homeTableView!.register(UINib(nibName: "CAHomeCategoryCell", bundle: nil), forCellReuseIdentifier: "CAHomeCategoryCell")
        self.homeTableView!.register(UINib(nibName: "CAHomeTagCell", bundle: nil), forCellReuseIdentifier: "CAHomeTagCell")
        if  isFromGallery{
            pickGalleryButton.setImage(UIImage(named: "icon23"), for: .normal)
        }
        else {
            pickGalleryButton.setImage(UIImage(named: "icon24"), for: .normal)
        }
        
    }
    
    // MARK: - Memory management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - UITableView delegate Methods
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
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
            
        else
        {
            cell?.categoryCollectionView.showsHorizontalScrollIndicator = false
            cell?.categoryCollectionView.tag = indexPath.row + 3000
            cell?.categoryCollectionView.allowsSelection = true
            cell?.categoryCollectionView.delegate = self
            cell?.categoryCollectionView.dataSource = self
            cell?.categoryCollectionView.reloadData()
            
            if(primaryTagArray.count>0){
                cell?.categoryNameLabel.text = ((primaryTagArray[indexPath.row - 2] as AnyObject) .value(forKey: kSecondaryName) as? String)?.capitalized
                
                let secondaryItemAttay = ((primaryTagArray[indexPath.row - 2] as AnyObject) .value(forKey: kPrimaryImages) as? NSArray)?.count
                
                cell?.categoryNameLabel.text = (((primaryTagArray[indexPath.row - 2] as AnyObject) .value(forKey: kPrimaryName) as? String)?.capitalized)?.appending (" (").appending((secondaryItemAttay! as NSNumber).stringValue ).appending (")")
                
                navBarTitleString = (cell?.categoryNameLabel.text)!
            }
            cell?.categoryPriceLabel.isHidden = false
            print((primaryTagArray[indexPath.row - 2] as AnyObject))
            
            let amount = checkNull(inputValue:((primaryTagArray[indexPath.row - 2] as AnyObject) .value(forKey: kTotal) as AnyObject))
            //    cell?.categoryPriceLabel.text = ("Rs.").appending((amount)
            
            if(amount.isKind(of: NSNumber.self)){
                cell?.categoryPriceLabel.text = ("Rs.").appending(amount.stringValue)
            }else{
                cell?.categoryPriceLabel.text = ("Rs.").appending(amount as! String)
            }
            
            if(isPrimaryTag == false){
                cell?.categoryNameLabel.text = ((primaryTagArray[indexPath.row - 2] as AnyObject) .value(forKey: kPrimaryName) as? String)?.capitalized
            }
            
            if(isSeeAllFromGallery || isSeeAllFromDocument || isShowAllDataFromHome || isFromHome){
                
               // let secondaryItemAttay = ((primaryTagArray[indexPath.row - 2] as AnyObject) .value(forKey: kPrimaryImages) as? NSArray)?.count
                
                let date = (primaryTagArray[indexPath.row - 2] as AnyObject) .value(forKey: "Date")
                if((date) != nil){
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let newdate = dateFormatter.date(from:date as! String )
                    let date = Date()
                    let calendar = Calendar.current
                    let month = calendar.component(.month, from: newdate!)
                    let currentMonth = calendar.component(.month, from: date)
                    
                    if(month == currentMonth){
                        cell?.categoryNameLabel.text = ("Recent").appending (" (").appending((primaryTagArray[indexPath.row - 2] as AnyObject) .value(forKey: kCount) as! String ).appending (")")
                    }
                    else{
                        cell?.categoryNameLabel.text = (((primaryTagArray[indexPath.row - 2] as AnyObject) .value(forKey: kMonth) as? String)?.capitalized)?.appending (" (").appending((primaryTagArray[indexPath.row - 2] as AnyObject) .value(forKey: kCount) as! String ).appending (")")
                    }
                }
                
            }
            
            cell?.seeAllBtn.isHidden = false
            cell?.seeAllBtn.tag = indexPath.row - 2
            cell?.seeAllBtn?.addTarget(self, action: #selector(CATagListViewController.catAction(_:)), for: .touchUpInside)
            
            return cell!
        }
    }
    
    // MARK: - UICollectionView delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView.tag == 5000{
            return userDefineArray.count
        }else if collectionView.tag == 6000{
            return preDefineArray.count
        }else
        {
            var currentIndex  = Int()
            currentIndex =  collectionView.tag - 3002
            return ((self.primaryTagArray.object(at:currentIndex ) as AnyObject).value(forKey: kPrimaryImages) as! NSArray).count
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 5000{
            //user define tags name collection
            let tagCell: CATagCollectionCell? = (collectionView.dequeueReusableCell(withReuseIdentifier: "CATagCollectionCell", for: indexPath) as? CATagCollectionCell)
            tagCell?.tagBtn?.tag = indexPath.item + 7000
            tagCell?.tagBtn?.setTitle((userDefineArray[indexPath.row] as AnyObject) .value(forKey: kPrimaryName) as? String, for: .normal)
            tagCell?.tagBtn?.addTarget(self, action: #selector(CAGalleryDocumentViewController.tagAction(_:)), for: .touchUpInside)
            return tagCell!
            
        }else if collectionView.tag == 6000{
            //pre define tags name collection
            let tagCell: CATagCollectionCell? = (collectionView.dequeueReusableCell(withReuseIdentifier: "CATagCollectionCell", for: indexPath) as? CATagCollectionCell)
            tagCell?.tagBtn?.tag = indexPath.item + 8000
            tagCell?.tagBtn?.setTitle((preDefineArray[indexPath.row] as AnyObject) .value(forKey: kSecondaryName) as? String, for: .normal)
            tagCell?.tagBtn?.addTarget(self, action: #selector(CAGalleryDocumentViewController.tagAction(_:)), for: .touchUpInside)
            return tagCell!
            
        }else
            
        {
            var currentIndex  = Int()
            currentIndex =  collectionView.tag - 3002
            
            let categoryCell: CAHomeCatCell? = (collectionView.dequeueReusableCell(withReuseIdentifier: "CAHomeCatCell", for: indexPath) as? CAHomeCatCell)
            categoryCell?.categoryBtn?.tag = collectionView.tag + 20000
            categoryCell?.categoryBtn?.addTarget(self, action: #selector(CAGalleryDocumentViewController.catAction(_:)), for: .touchUpInside)
            categoryCell?.categoryImage.sd_setShowActivityIndicatorView(true)
            categoryCell?.categoryImage.sd_setIndicatorStyle(.gray)
            categoryCell?.categoryImage.contentMode = UIViewContentMode.scaleAspectFill
            categoryCell?.categoryImage.clipsToBounds = true
            
            
            let date = (((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: kTagDate) as! NSArray).object(at: indexPath.row) as? String)
            
            var dateString = NSString()
            if((date) != nil){
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let newdate = dateFormatter.date(from:date!)
                let dateformatterToString = DateFormatter()
                dateformatterToString.dateFormat = "dd MMM yyyy"
                dateString = dateformatterToString.string(from: newdate!) as NSString
                
            }
            
            
            let secondaryArr = checkNull(inputValue:(((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: kSecondaryTag) as! NSArray).object(at: indexPath.row)) as! NSArray)
            
            
            categoryCell?.tagNameLabel.text  = dateString.appending(",").appending(checkNull(inputValue: (((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: kPrimaryName) as! NSArray).object(at: indexPath.row) as? String)  as AnyObject) as! String).appending(",").appending((secondaryArr.value(forKey: kSecondaryName) as AnyObject).componentsJoined(by: ",")).appending(",").appending(checkNull(inputValue: (((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: kPrimaryDescription) as! NSArray).object(at: indexPath.row) as? String)  as AnyObject) as! String)
            
            categoryCell?.categoryTypeLabel.text =  checkNull(inputValue: (((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Tag_Type") as! NSArray).object(at: indexPath.row) as? String)  as AnyObject).capitalized
            
            categoryCell?.priceLabel.text  = ("Rs.").appending(checkNull(inputValue: (((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: kAmount) as! NSArray).object(at: indexPath.row) as? String)  as AnyObject) as! String)
            
            if((((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Image_Url") as! NSArray).object(at: indexPath.row) as? String == "")){
                categoryCell?.categoryImage.image =  UIImage(named: "icon18")
            }
                
            else{
                
                if isFromGallery == true{
                    categoryCell?.categoryImage.sd_setImage(with: URL(string: checkNull(inputValue: (((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Image_Url") as! NSArray).object(at: indexPath.row) as? String)  as AnyObject) as! String), placeholderImage: UIImage(named: "icon18"))
                    
                    categoryCell?.categoryImage.contentMode = UIViewContentMode.scaleAspectFill
                    categoryCell?.categoryImage.clipsToBounds = true
                    
                    
                    if((((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Image_Url") as! NSArray).object(at: indexPath.row) as? String == "")){
                        categoryCell?.categoryImage.image =  UIImage(named: "icon18")
                    }
                    else{
                        if(((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: kIsUploaded) as! NSArray).object(at: indexPath.row) as? String == "1"){
                            
                            categoryCell?.categoryImage.sd_setImage(with: URL(string: checkNull(inputValue: (((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Image_Url_Thumb") as! NSArray).object(at: indexPath.row) as? String)  as AnyObject) as! String), placeholderImage: UIImage(named: "icon18"))
                        }
                        else{
                            let dirPath = ((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Image_Url") as! NSArray).object(at: indexPath.row) as? String
                            let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(dirPath!)
                            categoryCell?.categoryImage.image = UIImage(contentsOfFile: paths)
                        }
                    }
                }
                    
                else{
                    categoryCell?.categoryImage.isHidden = true
                    categoryCell?.categoryImage.contentMode = UIViewContentMode.scaleAspectFit
                    
                    let webViewDisplayed = UIWebView()
                    webViewDisplayed.isUserInteractionEnabled = false
                    webViewDisplayed.tag = 3250
                    webViewDisplayed.frame = (categoryCell?.categoryImage.frame)!
                    webViewDisplayed.backgroundColor = UIColor.clear
                    webViewDisplayed.scrollView.isScrollEnabled = false
                    webViewDisplayed.isOpaque = false
                    webViewDisplayed.delegate = self
                    categoryCell?.bgView.addSubview(webViewDisplayed)
                    
                    if(((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: kIsUploaded) as! NSArray).object(at: indexPath.row) as? String == "1"){
                        
                        let tagImageURL = (((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Image_Url_Thumb") as! NSArray).object(at: indexPath.row) as? String)
                        
                        let docURL = URL(string: tagImageURL!)
                        
                        if(docURL?.pathExtension == ""){
                            
                            webViewDisplayed.isHidden  = true
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
                        }
                        else
                        {
                            webViewDisplayed.isHidden  = false
                            categoryCell?.categoryImage.image =  UIImage(named: "icon18")
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
            
            if((((((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Tag_Type") as! NSArray).object(at: indexPath.row) as? String)  as AnyObject) as! String) == kBankPlus){
                categoryCell?.categoryTypeLabel.backgroundColor = RGBA(33, g: 144, b: 202, a: 1)
            }
            else if((((((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Tag_Type") as! NSArray).object(at: indexPath.row) as? String)  as AnyObject) as! String) == kBankMinus){
                categoryCell?.categoryTypeLabel.backgroundColor = RGBA(204, g: 232, b: 244, a: 1)
                
            }
            else if((((((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Tag_Type") as! NSArray).object(at: indexPath.row) as? String)  as AnyObject) as! String) == kCashPlus){
                categoryCell?.categoryTypeLabel.backgroundColor = RGBA(52, g: 211, b: 202, a: 1)
                
            }
            else if((((((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Tag_Type") as! NSArray).object(at: indexPath.row) as? String)  as AnyObject) as! String) == kCashMinus){
                categoryCell?.categoryTypeLabel.backgroundColor = RGBA(191, g: 240, b: 238, a: 1)
                
            }
            else if((((((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Tag_Type") as! NSArray).object(at: indexPath.row) as? String)  as AnyObject) as! String) == kOther){
                categoryCell?.categoryTypeLabel.backgroundColor = UIColor.clear
                categoryCell?.categoryTypeLabel.text = ""
                
            }
            else{
                categoryCell?.categoryTypeLabel.backgroundColor = UIColor.clear
            }
            
            categoryCell?.categoryColorLabel.backgroundColor = RGBA(204, g: 232, b: 244, a: 1)
            
            
            //Approved
            if((((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Tag_Status") as! NSArray).object(at: indexPath.row) as? String) == "1" ){
                categoryCell?.categoryColorLabel.backgroundColor = RGBA(82, g: 255, b: 0, a: 1)
            }
                
                //Pending
            else if((((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Tag_Status") as! NSArray).object(at: indexPath.row) as? String) == "2"  ){
                categoryCell?.categoryColorLabel.backgroundColor = RGBA(33, g: 144, b: 202, a: 1)
            }
                
                //Declined
            else if((((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Tag_Status") as! NSArray).object(at: indexPath.row) as? String) == "3" ){
                categoryCell?.categoryColorLabel.backgroundColor = RGBA(33, g: 144, b: 202, a: 1)
            }
                //Declined Blur
            else if((((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Tag_Status") as! NSArray).object(at: indexPath.row) as? String) == "4" ){
                categoryCell?.categoryColorLabel.backgroundColor = RGBA(248, g: 114, b: 35, a: 1)
                
            }
                
                //Uploading
            else if((((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Tag_Status") as! NSArray).object(at: indexPath.row) as? String) == "6"  ){
                categoryCell?.categoryColorLabel.backgroundColor = RGBA(204, g: 232, b: 244, a: 1)
            }
            
            return categoryCell!
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var cellSize = CGSize()
        if collectionView.tag == 5000{
            let myString: NSString = (userDefineArray.object(at: indexPath.row ) as AnyObject).value(forKey: kPrimaryName) as! NSString
            let size: CGSize = myString.size(attributes: [NSFontAttributeName: UIFont.init(name: "Calibri", size: 16.0)!])
            cellSize  = CGSize(width:size.width + 30,height: 50)
            
        }
        else if collectionView.tag == 6000{
            let myString: NSString = (preDefineArray.object(at: indexPath.row ) as AnyObject).value(forKey: kSecondaryName) as! NSString
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
            var currentIndex  = Int()
            currentIndex =  collectionView.tag - 3002
            
            let galleryDetailsVC: CAGalleryDetailViewController = CAGalleryDetailViewController(nibName:"CAGalleryDetailViewController", bundle:nil)
            
            if let tagId = ((((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Id") as! NSArray).object(at: indexPath.row) as? String)){
                galleryDetailsVC.tagId =  tagId
                
                if((((self.primaryTagArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(currentIndex).value(forKey: "Type") as! NSArray).object(at: indexPath.row) as? String) == "gallery"){
                    galleryDetailsVC.isShowingGalleryData = true
                }else{
                    galleryDetailsVC.isShowingGalleryData = false
                }
                
                navigationController?.pushViewController(galleryDetailsVC, animated: true)
            }
            else{
                presentAlert(kZoddl, msgStr: "Details are uploading. Please wait.", controller: self)
            }
        }
    }
    

    
    
    
    
    @IBAction func menuButtonAction(_ sender: UIButton){
        
        if(isFromGallery == true){
            if let vc = self.navigationController?.viewControllers.filter({ $0 is CAGalleryDocumentViewController }).first {
                navigationController?.popToViewController(vc, animated: true)
            }
        }
        if(isFromDocument == true){
            if let vc = self.navigationController?.viewControllers.filter({ $0 is CAGalleryDocumentViewController }).first {
                navigationController?.popToViewController(vc, animated: true)
            }
        }
        if(isFromHome == true){
            if let vc = self.navigationController?.viewControllers.filter({ $0 is CAHomeViewController }).first {
                navigationController?.popToViewController(vc, animated: true)
            }
            
        }
        else{
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    @IBAction func searchButtonAction(_ sender: UIButton){
        let appDelegateShared : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let searchController: CASearchBarViewController = CASearchBarViewController(nibName:"CASearchBarViewController", bundle: nil)
        searchController.searchDelegate = self
        searchController.modalPresentationStyle = .overCurrentContext
        searchController.modalTransitionStyle = .crossDissolve
        appDelegateShared.navController?.present(searchController, animated: true, completion: nil)    }
    
    @IBAction func filterButtonAction(_ sender: UIButton){
        let appDelegateShared : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let filterController: CAFilterPopupViewController = CAFilterPopupViewController(nibName:"CAFilterPopupViewController", bundle: nil)
        filterController.delegate = self
        if isPrimaryTag == true {
            filterController.hideAlphabetOption = true
        }
        filterController.modalPresentationStyle = .overCurrentContext
        filterController.modalTransitionStyle = .crossDissolve
        appDelegateShared.navController?.present(filterController, animated: true, completion: nil)
    }
    
    @IBAction func addManualButtonAction(_ sender: UIButton) {
        
        let addTagPopUpVC: CAAddTagPopUpViewController = CAAddTagPopUpViewController(nibName:"CAAddTagPopUpViewController", bundle: nil)
        addTagPopUpVC.addTagDelegate = self
        addTagPopUpVC.navigationTitleString = "Add Manual"
        addTagPopUpVC.modalPresentationStyle = .overCurrentContext
        addTagPopUpVC.modalTransitionStyle = .crossDissolve
        addTagPopUpVC.imageURL = ""
        addTagPopUpVC.isManualTag = true
        if isFromGallery {
            addTagPopUpVC.isDocumentType  = false
        }else{
            addTagPopUpVC.isDocumentType  = true
            addTagPopUpVC.docExtension = "jpg"
        }
        self.present(addTagPopUpVC, animated: true, completion: nil)
    }
    
    
    @IBAction func selectDocumentButtonAction(_ sender: UIButton){
        
        if isFromGallery {
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
            let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["com.apple.iwork.pages.pages", "com.apple.iwork.numbers.numbers", "com.apple.iwork.keynote.key", "com.microsoft.word.doc","public.text","com.adobe.pdf"], in: UIDocumentPickerMode.import)
            
            documentPicker.delegate = self
            documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            self.present(documentPicker, animated: true, completion: nil)
        }
    }
    
    // MARK: - custom Methods
    func tagAction(_ sender: UIButton) {
        
        let tagListVC: CATagListViewController = CATagListViewController(nibName:"CATagListViewController", bundle:nil)
        let tag = sender.tag
        
        //Changed done 7:11 pm
       // tagListVC.isFromHome = isFromHome
        tagListVC.isFromHomeTopTags = isFromHomeTopTags
        tagListVC.isFromGallery  = isFromGallery
        tagListVC.isFromDocument  = isFromDocument
        tagListVC.isPrimaryTagTypeGallery  = isPrimaryTagTypeGallery
        
        if(tag < 8000){
            if(((userDefineArray[sender.tag - 7000] as AnyObject) .value(forKey: kPrimaryTag)) != nil){
                tagListVC.selectedTagId = ((userDefineArray[sender.tag - 7000] as AnyObject) .value(forKey: kPrimaryTag) as? String)!
                tagListVC.isPrimaryTag = true
                tagListVC.navBarTitleString = ((userDefineArray[sender.tag - 7000] as AnyObject) .value(forKey: kPrimaryName) as? String)!
            }
            isPrimaryTagTypeGallery = true
        }
        else{
            tagListVC.navBarTitleString = ((preDefineArray[sender.tag - 8000] as AnyObject) .value(forKey: kSecondaryName) as? String!)!
            tagListVC.selectedTagId = ((preDefineArray[sender.tag - 8000] as AnyObject) .value(forKey: kTagId) as? String)!
            tagListVC.isPrimaryTag = false
            selectedSecondary  = true
            tagListVC.selectedSecondary = selectedSecondary
        }
        tagListVC.userDefineArray = userDefineArray
        tagListVC.preDefineArray = preDefineArray
        navigationController?.pushViewController(tagListVC, animated: true)
    }
    
    
    func catAction(_ sender: UIButton) {
        
        if(isSeeAllFromHome){
            
            let tagListVC: CATagListViewController = CATagListViewController(nibName:"CATagListViewController", bundle:nil)
            tagListVC.userDefineArray = userDefineArray
            tagListVC.preDefineArray = preDefineArray
            tagListVC.isSeeAllFromHome = false
            tagListVC.isShowAllDataFromHome = true
            sourceTypeFromHome = (((primaryTagArray[sender.tag]) as AnyObject) .value(forKey: kSourceType) as? String)!
            kUserDefaults.set(sourceTypeFromHome, forKey: "sourceTypeFromHome")
            kUserDefaults.set(tagTypeForSearch, forKey: "tagTypeForSearch")
            kUserDefaults.set((((primaryTagArray[sender.tag]) as AnyObject) .value(forKey: kPrimaryTag) as? String), forKey: "tagIdFromHome")
            kUserDefaults.synchronize()
            tagListVC.preDefineArray = preDefineArray
            
            tagListVC.userDefineArray = userDefineArray
            navigationController?.pushViewController(tagListVC, animated: true)
        }
            
        else{
     
        let allTagListVC: CAGalleryDocumentAllListViewController = CAGalleryDocumentAllListViewController(nibName:"CAGalleryDocumentAllListViewController", bundle:nil)
       
        if(isSeeAllFromGallery || isSeeAllFromDocument){
            allTagListVC.selectedTagId = (((primaryTagArray[sender.tag]) as AnyObject) .value(forKey: kPrimaryTag) as? String)!
            allTagListVC.selectedMonth = (((primaryTagArray[sender.tag]) as AnyObject) .value(forKey: kMonth) as? String)!
            allTagListVC.isFromDocument = isSeeAllFromDocument
            allTagListVC.isFromGallery  = isSeeAllFromGallery
            kUserDefaults.set(true, forKey: "isFromHome")
            kUserDefaults.synchronize()
          //  allTagListVC.isFromHome  = isShowAllDataFromHome
            allTagListVC.selectedTagName = navBarTitleLabel.text!
            allTagListVC.navigationTitleString = navBarTitleString

        }
        else if(isFromHomeTopTags){
            allTagListVC.isFromTagList = true
            allTagListVC.selectedTagId = (((primaryTagArray[sender.tag]) as AnyObject) .value(forKey: kPrimaryTag) as? String)!
            allTagListVC.navigationTitleString = (primaryTagArray[sender.tag] as AnyObject).value(forKey: kPrimaryName) as! String
            allTagListVC.secondaryTagId =   (((primaryTagArray[sender.tag]) as AnyObject) .value(forKey: kSecondaryTag) as? String)!

            if(isFromGallery){
                allTagListVC.isFromDocument = false
            }
            else{
                allTagListVC.isFromDocument = true
            }
            
        }
            
        else if(isShowAllDataFromHome == true || isFromHome){
            allTagListVC.monthArray.add(primaryTagArray[sender.tag])
            allTagListVC.isFromHome = true
            allTagListVC.navigationTitleString = (primaryTagArray[sender.tag] as AnyObject).value(forKey: kPrimaryName) as! String
        }
            
        else if(isFromSearch){
            allTagListVC.monthArray.add(primaryTagArray[sender.tag])
            allTagListVC.isFromSearch = isFromSearch
            allTagListVC.navigationTitleString = (primaryTagArray[sender.tag] as AnyObject).value(forKey: kPrimaryName) as! String
        }
        
        else{
            allTagListVC.selectedTagId = selectedTagId
            allTagListVC.secondaryTagId =   (((primaryTagArray[sender.tag]) as AnyObject) .value(forKey: kSecondaryTag) as? String)!
            allTagListVC.isPrimaryTag = isPrimaryTag
            allTagListVC.isFromTagList = true
            
            if(isPrimaryTag == false){
                allTagListVC.secondaryTagId = selectedTagId
                allTagListVC.selectedTagId = (((primaryTagArray[sender.tag]) as AnyObject) .value(forKey: kPrimaryTag) as? String)!
            }
            
            if self.isFromGallery {
                allTagListVC.isFromGallery = true
            } else  if self.isFromDocument {
                allTagListVC.isFromDocument = true
            }else{
                allTagListVC.isFromGallery = false
                allTagListVC.isFromDocument = false
            }
            allTagListVC.navigationTitleString = navBarTitleString
        }
           
        allTagListVC.userDefineArray = userDefineArray
        allTagListVC.preDefineArray = preDefineArray
        navigationController?.pushViewController(allTagListVC, animated: true)
    }
    }
    
    //Mark Custom Delegate
    func addDelegateWithDetailsAndIsSubmit(details: NSString, isSubmit: Bool) {
        
        if(isFromDocument == true){
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Document")
            
            do {
                let results = try context.fetch(fetchRequest)
                let  documentCreated = results as! [Document]
                
                for docData in documentCreated {
                    print(docData.primaryName!)
                    print(docData.docType!)
                    var matchedPrimaryTag = NSDictionary()
                    let resultPredicate = NSPredicate(format: "Prime_Name == [c]%@", (docData.primaryName!))
                    let arr = self.primaryTagArray.filtered(using: resultPredicate)
                    if(arr.count > 0){
                        print("Add in local")
                        matchedPrimaryTag = (arr.first as! NSDictionary).mutableCopy() as! NSMutableDictionary
                        self.primaryTagArray.remove(matchedPrimaryTag)
                        let imageArray = (matchedPrimaryTag.value(forKey: kPrimaryImages) as! NSArray).mutableCopy() as! NSMutableArray
                        
                        let entryAdded = NSMutableDictionary()
                        entryAdded.setValue(docData.primaryName, forKey: kPrimaryName)
                        entryAdded.setValue(docData.amount, forKey: kAmount)
                        entryAdded.setValue(docData.tagDate, forKey: kTagDate)
                        entryAdded.setValue("0", forKey: kIsUploaded)
                        entryAdded.setValue(docData.docPath, forKey: kTagImageURL)
                        entryAdded.setValue(docData.tagDescription, forKey: kTagDescription)
                        entryAdded.setValue(docData.tagStatus, forKey: kTagStatus)
                        entryAdded.setValue(docData.tagType, forKey: kTagType)
                        
                        let data = docData.secondaryTag?.data(using: String.Encoding.utf8)
                        let secondaryTagArray  = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSArray
                        
                        let secondaryTagArrayWithKey = NSMutableArray()
                        
                        for (_, element) in secondaryTagArray.enumerated() {
                            let dict = NSMutableDictionary()
                            dict .setValue(element, forKey: "Secondary_Name")
                            secondaryTagArrayWithKey.add(dict)
                        }
                        entryAdded.setValue(secondaryTagArrayWithKey, forKey: kSecondaryTag)
                        imageArray.insert(entryAdded, at: 0)
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
                        entryAdded.setValue(docData.tagStatus, forKey: kTagStatus)
                        entryAdded.setValue(docData.tagType, forKey: kTagType)
                        
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
                        //self.primaryTagArray.insert(newPrimaryTagAdded, at: 0)
                        
                    }
                    
                }
            }
            catch let err as NSError {
                print(err.debugDescription)
            }
            
            if (homeTableView) != nil {
                self.homeTableView.reloadData()
                // self.galleryDocumentTableView.reloadData()
                let tagCell = self.homeTableView.dequeueReusableCell(withIdentifier: "CAHomeTagCell") as? CAHomeTagCell
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
                    let imageArr = dict.value(forKey: kPrimaryImages) as! NSArray
                    let firstElement = imageArr.firstObject as! NSDictionary
                    let secondarytTag =  firstElement.value(forKey: kSecondaryTag) as! NSArray
                    var secondaryTagFetched = NSDictionary()
                    var fetchedArray = NSArray()
                    
                    let resultPredicate = NSPredicate(format: "Prime_Name == [c]%@", (dict.value(forKey: kPrimaryName) as! String))
                    let currentPrimaryTag = self.primaryTagArray.filtered(using: resultPredicate)
                    if(currentPrimaryTag.count > 0){
                        if(secondarytTag.count > 0){
                            secondaryTagFetched = (firstElement.value(forKey: kSecondaryTag) as! NSArray).firstObject as! NSDictionary
                            let resultPredicate = NSPredicate(format: "Secondary_Name == [c]%@", (secondaryTagFetched.value(forKey: kSecondaryName) as! String))
                            fetchedArray = self.primaryTagArray.filtered(using: resultPredicate) as NSArray
                        }
                        
                        if(fetchedArray.count > 0){
                            matchedPrimaryTag = (fetchedArray.first as! NSDictionary).mutableCopy() as! NSMutableDictionary
                            self.primaryTagArray.remove(matchedPrimaryTag)
                            let imageArray = (matchedPrimaryTag.value(forKey: kPrimaryImages) as! NSArray).mutableCopy() as! NSMutableArray
                            let arr = dict.value(forKey: kPrimaryImages) as! NSArray
                            imageArray.add(arr.firstObject as Any)
                            print(matchedPrimaryTag)
                            matchedPrimaryTag .setValue(imageArray.noDuplicates(byKey: kTagImageURL), forKey: kPrimaryImages)
                            self.primaryTagArray.insert(matchedPrimaryTag, at: 0)
                        }
                        else{
                            if(isSeeAllFromGallery || isSeeAllFromDocument){
                                let recentDict  = (self.primaryTagArray.object(at: 0) as! NSDictionary).mutableCopy() as! NSMutableDictionary
                                let imageArray = (recentDict.value(forKey: kPrimaryImages) as! NSArray).mutableCopy() as! NSMutableArray
                                imageArray.insert(firstElement, at: 0)
                                self.primaryTagArray.removeObject(at: 0)
                                recentDict.setValue(imageArray, forKey: kPrimaryImages)
                                self.primaryTagArray.insert(recentDict, at: 0)
                            }
                            else{
                                let newTagAdded = NSMutableDictionary()
                                newTagAdded .setValue(dict .value(forKey: kPrimaryName), forKey: kPrimaryName)
                                newTagAdded .setValue(dict .value(forKey: kAmount), forKey: kTotal)
                                let imageArray = NSMutableArray()
                                let arr = dict.value(forKey: kPrimaryImages) as! NSArray
                                imageArray.add(arr.firstObject as Any)
                                newTagAdded .setValue(imageArray, forKey: kPrimaryImages)
                                self.primaryTagArray.insert(newTagAdded, at: 0)
                            }
                     
                        }
                    }
                }
            }
            if (homeTableView) != nil {
                self.homeTableView.reloadData()
                // self.galleryDocumentTableView.reloadData()
                let tagCell = self.homeTableView.dequeueReusableCell(withIdentifier: "CAHomeTagCell") as? CAHomeTagCell
                tagCell?.tagCollectionView.reloadData()
            }
            
            if(Reachability.isConnectedToNetwork()){
                let myDelegate = UIApplication.shared.delegate as? AppDelegate
                myDelegate?.uploadImageToS3_withTags(tagMutable: tagMutable)
            }
        }
    }
    
    
    
    func callFilter(filterType: String) {
        
        if(filterType == "By Amount"){
            let sortUsingPrice = NSSortDescriptor(key: kTotal, ascending: true)
            let arr = ((primaryTagArray as NSArray).sortedArray(using: [sortUsingPrice])) as Array
            self.primaryTagArray = NSMutableArray(array: arr)
            self.homeTableView.reloadData()
        }
        else  if(filterType == "By Count"){
            let sortUsingPrice = NSSortDescriptor(key: kCount, ascending: false)
            let arr = ((primaryTagArray as NSArray).sortedArray(using: [sortUsingPrice])) as Array
            self.primaryTagArray = NSMutableArray(array: arr)
            self.homeTableView.reloadData()
        }
        else  if(filterType == "By Alphabet"){
            let sortUsingPrice = NSSortDescriptor(key: kPrimaryName, ascending: true,
                                                  selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
            let arr = ((primaryTagArray as NSArray).sortedArray(using: [sortUsingPrice])) as Array
            self.primaryTagArray = NSMutableArray(array: arr)
            self.homeTableView.reloadData()
            
        }
        else  if(filterType == "By Uses"){
            let sortUsingPrice = NSSortDescriptor(key: kCount, ascending: true)
            let arr = ((primaryTagArray as NSArray).sortedArray(using: [sortUsingPrice])) as Array
            self.primaryTagArray = NSMutableArray(array: arr)
            self.homeTableView.reloadData()
        }
            
        else{
            self.primaryTagArray =   self.primaryTagArrayCopy
            self.homeTableView.reloadData()
        }
        
        
        
    }
    // MARK: - UIDocumentPickerDelegate Methods
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        if controller.documentPickerMode == UIDocumentPickerMode.import {
            // This is what it should be
            do {
                
                let documentData = try NSData(contentsOf: url, options: NSData.ReadingOptions())
                let fileManager = FileManager.default
                fileManager.createFile(atPath: url.path, contents: documentData as Data, attributes: nil)
                fileManager.fileExists(atPath: url.path)
                
                
                let addTagPopUpVC: CAAddTagPopUpViewController = CAAddTagPopUpViewController(nibName:"CAAddTagPopUpViewController", bundle: nil)
                addTagPopUpVC.addTagDelegate = self
                addTagPopUpVC.navigationTitleString = "Add Tag"
                addTagPopUpVC.modalPresentationStyle = .overCurrentContext
                addTagPopUpVC.modalTransitionStyle = .crossDissolve
                addTagPopUpVC.imageURL = url.path
                addTagPopUpVC.docExtension = url.pathExtension
                addTagPopUpVC.isDocumentType = true
                documentExtension = url.pathExtension
                documentPath = url.path
                self.present(addTagPopUpVC, animated: true, completion: nil)
                
            }
            catch {
                presentAlert(kZoddl, msgStr: error as? String, controller: self)
                
            }
        }
    }
    
    
    /// ImagePicker Delegate Method
    ///
    /// - Parameters:
    ///   - picker: imagePickerDelegate
    ///   - info: infoObj
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
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
    
    //Mark: Get details of tag
    
    @objc func refreshView(notification: NSNotification){
        
        if(isSeeAllFromGallery||isSeeAllFromDocument){
            self.gettagDetailsMonthly()
        }else{
            self.gettagDetails()

        }
    }
    
    
    func getAllTagsOfParticularType(){
        
        let paramDict : Dictionary<String, AnyObject> = [
            kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject) ,
            kTagType :tagTypeForSearch as AnyObject
        ]
        
        ServiceHelper.sharedInstanceHelper.createPostRequest(method: .post, showHud: true, params: paramDict, apiName: "Customer_Api/tagtypeseeall") { (result, error) in
            
            if(!(error != nil)){
                if (result![kResponseCode]! as? String == "200"){
                    let resultDict:Dictionary<String, AnyObject> = result as! Dictionary
                    self.primaryTagArray = (resultDict[kAPIPayload]! as! NSArray).mutableCopy() as! NSMutableArray
                    self.primaryTagArrayCopy = (resultDict[kAPIPayload]! as! NSArray).mutableCopy() as! NSMutableArray
                    self.secondaryTagArray.removeAllObjects()
                    
                    for arr in self.primaryTagArray .value(forKey: kPrimaryImages) as! NSArray{
                        for json in arr as! NSArray{
                            print((json as! NSDictionary).value(forKey: kSecondaryTag) as Any)
                            let arr = (json as! NSDictionary).value(forKey: kSecondaryTag) as! NSArray
                            for jsonObject in arr {
                                self.secondaryTagArray .add(jsonObject)
                            }
                        }
                    }
                    self.homeTableView.reloadData()
                }
                else
                {
                    presentAlert(kZoddl, msgStr: result![kResponseMessage]! as? String, controller: self)
                }
                
            } else {
                presentAlert("", msgStr: error?.localizedDescription, controller: self)
            }
        }
        
    }
    

    
    func gettagDetails(){
        
        var apiName = String()
        var paramDict  : Dictionary<String, Any> = [:]
        
        if(isFromGallery == true){
            if isPrimaryTag == true {
                paramDict = [
                    kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject) ,
                    kPrimaryTag :selectedTagId as AnyObject
                ]
                apiName = "Customer_Api/userprimarytagsearchlist"
                
            }else{
                paramDict  = [
                    kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject) ,
                    kSecondaryTag :selectedTagId as AnyObject
                ]
                apiName = "Customer_Api/usersecondarytagsearchlist"
                
            }
        }
            
        else if (isFromDocument == true){
            if isPrimaryTag == true {
                paramDict = [
                    kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject) ,
                    kPrimaryTag :selectedTagId as AnyObject
                ]
                apiName = "Document_Api/userprimarytagsearchlist"
                
            }else{
                paramDict  = [
                    kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject) ,
                    kSecondaryTag :selectedTagId as AnyObject
                ]
                apiName = "Document_Api/usersecondarytagsearchlist"
                
            }
        }
        else{
            
            if(selectedSecondary){
                paramDict = [
                    kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject) ,
                    kSecondaryTag: selectedTagId as AnyObject
                ]
                if(isPrimaryTagTypeGallery == true){
                    apiName = "Customer_Api/usersecondarytagsearchlist"
                }else{
                    apiName = "Document_Api/usersecondarytagsearchlist"
                }
                
            }else{
                paramDict = [
                    kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject) ,
                    kPrimaryTag :selectedTagId as AnyObject
                ]
                
                if(isPrimaryTagTypeGallery == true){
                    apiName = "Customer_Api/userprimarytagsearchlist"
                }else{
                    apiName = "Document_Api/userprimarytagsearchlist"
                }
            }
            
        }
        
        ServiceHelper.sharedInstanceHelper.createPostRequest(method: .post, showHud: true, params: paramDict as [String : AnyObject], apiName: apiName) { (result, error) in
            
            if(!(error != nil)){
                if (result![kResponseCode]! as? String == "200"){
                    let resultDict:Dictionary<String, AnyObject> = result as! Dictionary
                    self.primaryTagArray = (resultDict[kAPIPayload]! as! NSArray).mutableCopy() as! NSMutableArray
                    self.primaryTagArrayCopy = (resultDict[kAPIPayload]! as! NSArray).mutableCopy() as! NSMutableArray
                    self.secondaryTagArray.removeAllObjects()
                    
                    for arr in self.primaryTagArray .value(forKey: kPrimaryImages) as! NSArray{
                        for json in arr as! NSArray{
                            print((json as! NSDictionary).value(forKey: kSecondaryTag) as Any)
                            let arr = (json as! NSDictionary).value(forKey: kSecondaryTag) as! NSArray
                            for jsonObject in arr {
                                self.secondaryTagArray .add(jsonObject)
                            }
                        }
                    }
                    self.homeTableView.reloadData()
                    
                    if(self.primaryTagArray.count == 0){
                        let actionSheetController: UIAlertController = UIAlertController(title: kZoddl, message: "You have no entries associated with this tag.", preferredStyle: .alert)
                        let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default) { action -> Void in
                            
                            
                            if(self.isFromGallery == true){
                                if let vc = self.navigationController?.viewControllers.filter({ $0 is CAGalleryDocumentViewController }).first {
                                    self.navigationController?.popToViewController(vc, animated: true)
                                }
                            }
                            if(self.isFromDocument == true){
                                if let vc = self.navigationController?.viewControllers.filter({ $0 is CAGalleryDocumentViewController }).first {
                                    self.navigationController?.popToViewController(vc, animated: true)
                                }
                            }
                            if(self.isFromHome == true){
                                if let vc = self.navigationController?.viewControllers.filter({ $0 is CAHomeViewController }).first {
                                    self.navigationController?.popToViewController(vc, animated: true)
                                }
                                
                            }
                            else{
                                self.navigationController?.popViewController(animated: true)
                            }
                            
                        }
                        actionSheetController.addAction(okAction)
                        self.present(actionSheetController, animated: true, completion: nil)
                        
                    }
                    
                    //                    let tagCell = self.homeTableView.dequeueReusableCell(withIdentifier: "CAHomeTagCell") as? CAHomeTagCell
                    //                    tagCell?.tagCollectionView.reloadData()
                    //
                    //                    let primaryIndexPath = IndexPath(item: 1, section: 0)
                    //                    let secondaryIndexPath = IndexPath(item: 0, section: 0)
                    //                    self.homeTableView.reloadRows(at: [primaryIndexPath,secondaryIndexPath], with: .none)
                }
                else
                {
                    presentAlert(kZoddl, msgStr: result![kResponseMessage]! as? String, controller: self)
                }
                
            } else {
                presentAlert("", msgStr: error?.localizedDescription, controller: self)
            }
        }
        
    }
    
    
    //MARK : load webview method
    
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
    
    
    func gettagDetailsMonthly(){
        
        let paramDict : Dictionary<String, AnyObject> = [
            kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject) ,
            kPrimaryTag :self.selectedTagId as AnyObject,
            kPageNumber : self.pageNumber as AnyObject
        ]
        
        var apiName = String()
        
        if(isSeeAllFromGallery == true){
            apiName = "Customer_Api/gallerydetail"
        }else{
            apiName = "Document_Api/gallerydetail"
        }
        
        ServiceHelper.sharedInstanceHelper.createPostRequest(method: .post, showHud: true, params: paramDict, apiName: apiName) { (result, error) in
            
            if(!(error != nil)){
                if (result![kResponseCode]! as? String == "200"){
                    let resultDict:Dictionary<String, AnyObject> = result as! Dictionary
                    self.primaryTagArray = (resultDict[kAPIPayload]! as! NSArray).mutableCopy() as! NSMutableArray
                    self.primaryTagArrayCopy = (resultDict[kAPIPayload]! as! NSArray).mutableCopy() as! NSMutableArray
                    self.secondaryTagArray.removeAllObjects()
                    
                    for arr in self.primaryTagArray .value(forKey: kPrimaryImages) as! NSArray{
                        for json in arr as! NSArray{
                            print((json as! NSDictionary).value(forKey: kSecondaryTag) as Any)
                            let arr = (json as! NSDictionary).value(forKey: kSecondaryTag) as! NSArray
                            for jsonObject in arr {
                                self.secondaryTagArray .add(jsonObject)
                            }
                        }
                    }
                    self.homeTableView.reloadData()
                }
                else
                {
                    presentAlert(kZoddl, msgStr: result![kResponseMessage]! as? String, controller: self)
                }
                
            } else {
                presentAlert("", msgStr: error?.localizedDescription, controller: self)
            }
        }
        
    }
    
    
    func getTagItemDetailFromHome(){
        
        
        var typeName = String()
        
        if(isGalleryTypeFromHomeItem == true){
            typeName = "gallery"
        }else{
            typeName = "document"
        }
        
        let paramDict : Dictionary<String, AnyObject> = [
            kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject) ,
            kPrimaryTag :self.selectedTagId as AnyObject,
            kSourceType :typeName as AnyObject,
            kTagType : incomingTagTypeFormHome as AnyObject
        ]
        
        ServiceHelper.sharedInstanceHelper.createPostRequest(method: .post, showHud: true, params: paramDict, apiName: "Customer_Api/tagtypedetailbyprimarytag") { (result, error) in
            
            if(!(error != nil)){
                if (result![kResponseCode]! as? String == "200"){
                    let resultDict:Dictionary<String, AnyObject> = result as! Dictionary
                    self.primaryTagArray = (resultDict[kAPIPayload]! as! NSArray).mutableCopy() as! NSMutableArray
                    self.primaryTagArrayCopy = (resultDict[kAPIPayload]! as! NSArray).mutableCopy() as! NSMutableArray
                    self.secondaryTagArray.removeAllObjects()
                    
                    for arr in self.primaryTagArray .value(forKey: kPrimaryImages) as! NSArray{
                        for json in arr as! NSArray{
                            print((json as! NSDictionary).value(forKey: kSecondaryTag) as Any)
                            let arr = (json as! NSDictionary).value(forKey: kSecondaryTag) as! NSArray
                            for jsonObject in arr {
                                self.secondaryTagArray .add(jsonObject)
                            }
                        }
                    }
                    self.homeTableView.reloadData()
                }
                else
                {
                    presentAlert(kZoddl, msgStr: result![kResponseMessage]! as? String, controller: self)
                }
                
            } else {
                presentAlert("", msgStr: error?.localizedDescription, controller: self)
            }
        }
        
    }
    

    
    
    
    func getMonthlyDataOfTagType(){
        
        var typeName = String()
        let paramDict : Dictionary<String, AnyObject>
        if(isGalleryTypeFromHomeItem == true){
            typeName = "gallery"
        }else{
            typeName = "document"
        }
        
        if(isFromHome){
            paramDict  = [
                kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject) ,
                kPrimaryTag :self.selectedTagId as AnyObject,
                kSourceType :typeName as AnyObject,
                kTagType : incomingTagTypeFormHome as AnyObject
            ]
            
        }
        else{
            paramDict  = [
            kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject) ,
            kPrimaryTag : kUserDefaults.value(forKey: "tagIdFromHome") as AnyObject,
            kTagType : kUserDefaults.value(forKey: "tagTypeForSearch") as AnyObject,
            kSourceType : kUserDefaults.value(forKey: "sourceTypeFromHome") as AnyObject
            ]
        }
        
        ServiceHelper.sharedInstanceHelper.createPostRequest(method: .post, showHud: true, params: paramDict, apiName: "Customer_Api/tagtypedetailbymonth") { (result, error) in
            
            if(!(error != nil)){
                if (result![kResponseCode]! as? String == "200"){
                    let resultDict:Dictionary<String, AnyObject> = result as! Dictionary
                    self.primaryTagArray = (resultDict[kAPIPayload]! as! NSArray).mutableCopy() as! NSMutableArray
                    self.primaryTagArrayCopy = (resultDict[kAPIPayload]! as! NSArray).mutableCopy() as! NSMutableArray
                    self.secondaryTagArray.removeAllObjects()
                    
                    for arr in self.primaryTagArray .value(forKey: kPrimaryImages) as! NSArray{
                        for json in arr as! NSArray{
                            print((json as! NSDictionary).value(forKey: kSecondaryTag) as Any)
                            let arr = (json as! NSDictionary).value(forKey: kSecondaryTag) as! NSArray
                            for jsonObject in arr {
                                self.secondaryTagArray .add(jsonObject)
                            }
                        }
                    }
                    self.homeTableView.reloadData()
                }
                else
                {
                    presentAlert(kZoddl, msgStr: result![kResponseMessage]! as? String, controller: self)
                }
                
            } else {
                presentAlert("", msgStr: error?.localizedDescription, controller: self)
            }
        }
        
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
            
            ServiceHelper.sharedInstanceHelper.createPostRequest(method: .post, showHud: false, params: paramDict, apiName: "Customer_Api/searchuserdata") { (result, error) in
                
                if(!(error != nil)){
                    if (result![kResponseCode]! as? String == "200"){
                        let resultDict:Dictionary<String, AnyObject> = result as! Dictionary
                        print(resultDict)
                        self.primaryTagArray = (resultDict[kAllTagList]! as! NSArray).mutableCopy() as! NSMutableArray
                        self.primaryTagArrayCopy = (resultDict[kAllTagList]! as! NSArray).mutableCopy() as! NSMutableArray
                        self.secondaryTagArray.removeAllObjects()
                        
                        for arr in self.primaryTagArray .value(forKey: kPrimaryImages) as! NSArray{
                            for json in arr as! NSArray{
                                print((json as! NSDictionary).value(forKey: kSecondaryTag) as Any)
                                let arr = (json as! NSDictionary).value(forKey: kSecondaryTag) as! NSArray
                                for jsonObject in arr {
                                    self.secondaryTagArray .add(jsonObject)
                                }
                            }
                        }
                        self.homeTableView.reloadData()
                
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
    
    func getSearchString(searchString: String, searchType: String) {
        
        let tagListVC: CATagListViewController = CATagListViewController(nibName:"CATagListViewController", bundle:nil)
        tagListVC.isFromSearch = true
        tagListVC.searchString = searchString
        tagListVC.title = searchString
        if(searchType == "image gallery"){
            tagListVC.isFromGallery = true
        }else{
            tagListVC.isFromGallery = false
        }
        self.navigationController?.pushViewController(tagListVC, animated: true)
    }

}
