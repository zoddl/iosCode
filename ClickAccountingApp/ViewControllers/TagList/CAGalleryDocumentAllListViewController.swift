//
//  CAGalleryDocumentAllListViewController.swift
//  ClickAccountingApp
//
//  Created by Ratneshwar Singh on 7/12/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire

class CAGalleryDocumentAllListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, AddTagDelegate, UIDocumentPickerDelegate, UICollectionViewDelegateFlowLayout,FilterDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, UIWebViewDelegate,docScreenshotDelegate,SearchDelegate {
    
    @IBOutlet weak var tagAllListTableView: UITableView!
    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var tagAllCollectionView: UICollectionView!
    @IBOutlet  var pickGalleryButton: UIButton!
    
    var isFromGallery : Bool = false
    var isFromDocument : Bool = false
    
    var isFromTagList : Bool = false
    var isPrimaryTag : Bool = false
    var isFromHome : Bool = false
    var isFromSearch : Bool = false
    
    var selectedGalleryFromHome : Bool = false
    
    var pageNumber : Int = 1
    var loadMore : Bool = false
    var documentExtension : String = ""
    var documentPath : String = ""
    
    @IBOutlet var totalAmount: UILabel!
    
    var selectedTagId : String = ""
    var secondaryTagId : String = ""
    var selectedMonth : String = ""
    
    var tagType : String = ""
    
    var navigationTitleString : String = ""
    var selectedTagName : String = ""
    
    var userDefineArray = NSMutableArray()
    var preDefineArray = NSMutableArray()
    var categoryArray: [String] = ["Recent (20)"]
    var docScreenshotView = CADocScreenshotViewController()
    
    
    var monthArray = NSMutableArray()
    var monthDetailedTagsArray = NSMutableArray()
    
    private var lastContentOffset: CGFloat = 0
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        SDImageCache.shared().config.shouldDecompressImages = false
        print(selectedTagName)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initialMethod()
    }
    
    
    // MARK: - Set Initial method
    
    func initialMethod() {
        
        if(isFromHome == true){
            //  self.getTagDetailsForHomePageData()
            // self.getTagDetailsCalendarBased(currentPageNumber: pageNumber)
            
        }
        else if(isFromSearch == true){
            
        }
        else{
            if(isFromTagList == true){
                self.getTagDetailsOnTagSubTags()
            }else{
                self.getTagDetailsCalendarBased(currentPageNumber: pageNumber)
            }
        }
        
        SDImageCache.shared().config.shouldCacheImagesInMemory = false
        navTitleLabel.text = navigationTitleString
        categoryLabel.text = navigationTitleString
        self.tagAllListTableView.delegate = self
        self.tagAllListTableView.dataSource = self
        self.tagAllListTableView.isScrollEnabled = false
        
        self.navigationController?.isNavigationBarHidden = true
        self.tagAllListTableView!.register(UINib(nibName: "CAHomeCategoryCell", bundle: nil), forCellReuseIdentifier: "CAHomeCategoryCell")
        self.tagAllListTableView!.register(UINib(nibName: "CAHomeTagCell", bundle: nil), forCellReuseIdentifier: "CAHomeTagCell")
        self.navigationController?.isNavigationBarHidden = true
        
        //CollectionView
        tagAllCollectionView.register(UINib(nibName: "CAHomeCatCell", bundle: nil), forCellWithReuseIdentifier: "CAHomeCatCell")
        tagAllCollectionView.register(UINib(nibName: "CATagCollectionCell", bundle: nil), forCellWithReuseIdentifier: "CATagCollectionCell")
        //        tagAllCollectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "SectionCollectionReusableView")
        //
        //        tagAllCollectionView.register(SectionCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader.self, withReuseIdentifier: "SectionCollectionReusableView")
        //
        tagAllCollectionView.register(UINib(nibName: "SectionCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "SectionCollectionReusableView")
        
        self.tagAllCollectionView.dataSource = self
        self.tagAllCollectionView.delegate = self
        if  isFromGallery{
            pickGalleryButton.setImage(UIImage(named: "icon23"), for: .normal)
        }
        else {
            pickGalleryButton.setImage(UIImage(named: "icon24"), for: .normal)
        }
        
        
        print("The user define array is: %@",userDefineArray)
        print("The user define array count is: %",userDefineArray.count)
 
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableView delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2//2 cell for tag cell others are for grid view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 || indexPath.row == 1 {
            return 53
        }
        return 140
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tagCell = tableView.dequeueReusableCell(withIdentifier: "CAHomeTagCell") as? CAHomeTagCell
        tagCell?.tagCollectionView.register(UINib(nibName: "CATagCollectionCell", bundle: nil), forCellWithReuseIdentifier: "CATagCollectionCell")
        tagCell?.tagCollectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "SectionCollectionReusableView")
        tagCell?.tagCollectionView.delegate = self
        tagCell?.tagCollectionView.dataSource = self
        tagCell?.tagCollectionView.showsHorizontalScrollIndicator = false
        if  indexPath.row == 0 {
            tagCell?.tagCollectionView.tag = 5000
            tagCell?.tagCollectionView.delegate = self
            tagCell?.tagCollectionView.dataSource = self
            tagCell?.tagCollectionView.reloadData()
            
            return tagCell!
        }else if indexPath.row == 1{
            tagCell?.tagCollectionView.tag = 6000
            tagCell?.tagCollectionView.delegate = self
            tagCell?.tagCollectionView.dataSource = self
            tagCell?.tagCollectionView.reloadData()
            
            return tagCell!
        }
        else {
            return tagCell!
        }
    }
    
    // MARK: - UICollectionView delegate Methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == tagAllCollectionView {
            return self.monthArray.count
        }
        else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count : Int = 0
        
        if collectionView.tag == 5000 {
            count = userDefineArray.count
        }
        else if collectionView.tag == 6000 {
            count = preDefineArray.count
        }
        else {
            if(monthArray.count > 0){
                count = ((self.monthArray.object(at: section) as AnyObject).value(forKey: kPrimaryImages) as! NSArray).count
            }else{
                count = 0
            }
        }
        return count
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
            
        }
            
        else{
            //posts collection
            let categoryCell: CAHomeCatCell?
            categoryCell = (collectionView.dequeueReusableCell(withReuseIdentifier: "CAHomeCatCell", for: indexPath) as? CAHomeCatCell)
            categoryCell?.categoryBtn?.tag = indexPath.item + 2000
            
            let date = ((((self.monthArray.object(at: indexPath.section) as AnyObject).value(forKey: "Images")) as! NSArray).object(at: indexPath.row)as AnyObject).value(forKey: "Tag_Send_Date")
            
            var dateString  = NSString()
            
            if((date) != nil){
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let newdate = dateFormatter.date(from:date! as! String)
                let dateformatterToString = DateFormatter()
                dateformatterToString.dateFormat = "dd MMM yyyy"
                dateString = dateformatterToString.string(from: newdate!) as NSString
            }
            
            categoryCell?.priceLabel.text = ("Rs.").appending(((((self.monthArray.object(at: indexPath.section) as AnyObject).value(forKey: "Images")) as! NSArray).object(at: indexPath.row)as AnyObject).value(forKey: kAmount) as! String)
            
            
            categoryCell?.categoryTypeLabel.text =  checkNull(inputValue: ((((self.monthArray.object(at: indexPath.section) as AnyObject).value(forKey: "Images")) as! NSArray).object(at: indexPath.row)as AnyObject).value(forKey: kTagType)
                as AnyObject).capitalized
            
            if(((((((self.monthArray.object(at: indexPath.section) as AnyObject).value(forKey: "Images")) as! NSArray).object(at: indexPath.row)as AnyObject).value(forKey: kTagType) as AnyObject) as! String) == kBankPlus){
                
                categoryCell?.categoryTypeLabel.backgroundColor = RGBA(33, g: 144, b: 202, a: 1)
            }
            else if(((((((self.monthArray.object(at: indexPath.section) as AnyObject).value(forKey: "Images")) as! NSArray).object(at: indexPath.row)as AnyObject).value(forKey: kTagType) as AnyObject) as! String) == kBankMinus){
                categoryCell?.categoryTypeLabel.backgroundColor = RGBA(204, g: 232, b: 244, a: 1)
                
            }
            else if(((((((self.monthArray.object(at: indexPath.section) as AnyObject).value(forKey: "Images")) as! NSArray).object(at: indexPath.row)as AnyObject).value(forKey: kTagType) as AnyObject) as! String) == kCashPlus){
                categoryCell?.categoryTypeLabel.backgroundColor = RGBA(52, g: 211, b: 202, a: 1)
                
            }
            else if(((((((self.monthArray.object(at: indexPath.section) as AnyObject).value(forKey: "Images")) as! NSArray).object(at: indexPath.row)as AnyObject).value(forKey: kTagType) as AnyObject) as! String) == kCashMinus){
                categoryCell?.categoryTypeLabel.backgroundColor = RGBA(191, g: 240, b: 238, a: 1)
                
            }
            else if(((((((self.monthArray.object(at: indexPath.section) as AnyObject).value(forKey: "Images")) as! NSArray).object(at: indexPath.row)as AnyObject).value(forKey: kTagType) as AnyObject) as! String) == kOther){
                categoryCell?.categoryTypeLabel.backgroundColor = UIColor.clear
                categoryCell?.categoryTypeLabel.text = ""
            }
            else{
                categoryCell?.categoryTypeLabel.backgroundColor = UIColor.clear
            }
            
            if((((((self.monthArray.object(at: indexPath.section)as AnyObject).value(forKey: kPrimaryImages)) as! NSArray).object(at: indexPath.row)as AnyObject).value(forKey: kTagImageURL) as AnyObject) as! String == ""){
                
            }
            else
            {
                if(isFromGallery == true){
                    
                    if((((((self.monthArray.object(at: indexPath.section)as AnyObject).value(forKey: kPrimaryImages)) as! NSArray).object(at: indexPath.row)as AnyObject).value(forKey: kIsUploaded) as AnyObject) as! String == "1"){
                        
                        categoryCell?.categoryImage.sd_setImage(with: URL(string: checkNull(inputValue: ((((self.monthArray.object(at: indexPath.section) as AnyObject).value(forKey: kPrimaryImages)) as! NSArray).object(at: indexPath.row)as AnyObject).value(forKey: kTagImageThumbURL)
                            as AnyObject) as! String), placeholderImage: UIImage(named: "icon18"))
                        categoryCell?.categoryImage.contentMode = UIViewContentMode.scaleAspectFill
                        categoryCell?.categoryImage.clipsToBounds = true
                        
                    }
                    else{
                        let dirPath = (((((self.monthArray.object(at: indexPath.section)as AnyObject).value(forKey: kPrimaryImages)) as! NSArray).object(at: indexPath.row)as AnyObject).value(forKey: kTagImageURL) as AnyObject) as! String
                        
                        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(dirPath)
                        
                        categoryCell?.categoryImage.image = UIImage(contentsOfFile: paths)
                    }
                }
                    
                else{
                    categoryCell?.categoryImage.isHidden = false
                    categoryCell?.categoryImage.contentMode = UIViewContentMode.scaleAspectFit
                    let webViewDisplayed = UIWebView()
                    webViewDisplayed.tag = 3250
                    webViewDisplayed.frame = (categoryCell?.categoryImage.frame)!
                    webViewDisplayed.backgroundColor = UIColor.clear
                    webViewDisplayed.scrollView.isScrollEnabled = false
                    webViewDisplayed.scrollView.bounces = false
                    webViewDisplayed.isOpaque = false
                    webViewDisplayed.delegate = self
                    categoryCell?.bgView.addSubview(webViewDisplayed)
                    
                    if((((((self.monthArray.object(at: indexPath.section)as AnyObject).value(forKey: kPrimaryImages)) as! NSArray).object(at: indexPath.row)as AnyObject).value(forKey: kIsUploaded) as AnyObject) as! String == "1"){
                        
                        let tagImageURL =  ((((self.monthArray.object(at: indexPath.section) as AnyObject).value(forKey: kPrimaryImages)) as! NSArray).object(at: indexPath.row)as AnyObject).value(forKey: kTagImageThumbURL) as! String
                        
                        let docURL = URL(string: tagImageURL)
                        
                        if(docURL?.pathExtension == ""){
                            
                            categoryCell?.categoryImage.sd_setImage(with: URL(string: checkNull(inputValue: ((((self.monthArray.object(at: indexPath.section) as AnyObject).value(forKey: kPrimaryImages)) as! NSArray).object(at: indexPath.row)as AnyObject).value(forKey: kTagImageThumbURL)
                                as AnyObject) as! String), placeholderImage: UIImage(named: "icon18"),options: [], completed: { (image, error, cacheType, imageURL) in
                                    // Perform operation.
                                    print(error as Any)
                                    
                            })
                            
                            categoryCell?.categoryImage.contentMode = UIViewContentMode.scaleAspectFill
                            categoryCell?.categoryImage.clipsToBounds = true
                            
                        }
                        else if(docURL?.pathExtension == "pdf"){
                            if((docURL) != nil){
                                self.loadPDFWebViewData(url: docURL!, webView: webViewDisplayed, placeHolderImageView:(categoryCell?.categoryImage)! )
                            }
                        }
                        else if(docURL?.pathExtension == "xls"){
                            self.loadWebViewData(url: docURL!, webView: webViewDisplayed, placeHolderImageView:  (categoryCell?.categoryImage)!)
                            webViewDisplayed.backgroundColor  = UIColor.white
                        }
                        else
                        {
                            if((docURL) != nil){
                                self.loadWebViewData(url: docURL!, webView: webViewDisplayed, placeHolderImageView:  (categoryCell?.categoryImage)!)
                            }
                        }
                        
                    }
                    else
                    {
                        let dirPath = (((((self.monthArray.object(at: indexPath.section)as AnyObject).value(forKey: kPrimaryImages)) as! NSArray).object(at: indexPath.row)as AnyObject).value(forKey: kTagImageURL) as AnyObject) as! String
                        
                        let urlString  = URL.init(fileURLWithPath: dirPath)
                        //let data = try! Data(contentsOf: urlString as URL)
                        
                        if(urlString.pathExtension == "pdf"){
                            
                            self.loadPDFWebViewData(url: urlString as URL, webView: webViewDisplayed, placeHolderImageView:  (categoryCell?.categoryImage)!)
                        }else{
                            self.loadWebViewData(url: urlString as URL, webView: webViewDisplayed, placeHolderImageView:  (categoryCell?.categoryImage)!)
                        }
                    }
                }
                
            }
            
            let secondaryArr = checkNull(inputValue:(((((self.monthArray.object(at: indexPath.section) as AnyObject).value(forKey: kPrimaryImages)) as! NSArray).object(at: indexPath.row)as AnyObject).value(forKey: kSecondaryTag) as! NSArray))
            
            categoryCell?.tagNameLabel.text  = dateString.appending(",").appending(checkNull(inputValue: (((self.monthArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(indexPath.section).value(forKey: kPrimaryName) as! NSArray).object(at: indexPath.row) as? String)  as AnyObject) as! String).appending(",").appending((secondaryArr.value(forKey: kSecondaryName) as AnyObject).componentsJoined(by: ",")).appending(",").appending(checkNull(inputValue: (((self.monthArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(indexPath.section).value(forKey: kPrimaryDescription) as! NSArray).object(at: indexPath.row) as? String)  as AnyObject) as! String)
            
            
            //Approved
            if (((((((self.monthArray.object(at: indexPath.section) as AnyObject).value(forKey: kPrimaryImages)) as! NSArray).object(at: indexPath.row)as AnyObject).value(forKey: kTagStatus)
                as AnyObject) as! String) == "1" ){
                categoryCell?.categoryColorLabel.backgroundColor = RGBA(82, g: 255, b: 0, a: 1)
            }
                
                //Pending
            else if(((((((self.monthArray.object(at: indexPath.section) as AnyObject).value(forKey: kPrimaryImages)) as! NSArray).object(at: indexPath.row)as AnyObject).value(forKey: kTagStatus)as AnyObject) as! String) == "2" ){
                categoryCell?.categoryColorLabel.backgroundColor = RGBA(33, g: 144, b: 202, a: 1)
            }
                
                //Declined
            else if(((((((self.monthArray.object(at: indexPath.section) as AnyObject).value(forKey: kPrimaryImages)) as! NSArray).object(at: indexPath.row)as AnyObject).value(forKey: kTagStatus)as AnyObject) as! String) == "3" ){
                categoryCell?.categoryColorLabel.backgroundColor = RGBA(33, g: 144, b: 202, a: 1)
            }
                //Declined Blur
            else if(((((((self.monthArray.object(at: indexPath.section) as AnyObject).value(forKey: kPrimaryImages)) as! NSArray).object(at: indexPath.row)as AnyObject).value(forKey: kTagStatus)as AnyObject) as! String) == "4" ){
                categoryCell?.categoryColorLabel.backgroundColor = RGBA(248, g: 114, b: 35, a: 1)
                
            }
                
                //Uploading
            else if(((((((self.monthArray.object(at: indexPath.section) as AnyObject).value(forKey: kPrimaryImages)) as! NSArray).object(at: indexPath.row)as AnyObject).value(forKey: kTagStatus)as AnyObject) as! String) == "6" ){
                categoryCell?.categoryColorLabel.backgroundColor = RGBA(204, g: 232, b: 244, a: 1)
            }
            
            return categoryCell!
        }
    }
    
    
    
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var cellSize = CGSize()
        if collectionView.tag == 5000{
            
            let myString: NSString = checkNull(inputValue:(userDefineArray.object(at: indexPath.row ) as AnyObject).value(forKey: kPrimaryName) as! NSString) as! NSString
            let size: CGSize = myString.size(attributes: [NSFontAttributeName: UIFont.init(name: "Calibri", size: 16.0)!])
            cellSize  = CGSize(width:size.width + 30,height: 50)
        }
        else if collectionView.tag == 6000{
            
            let myString: NSString = checkNull(inputValue: (preDefineArray.object(at: indexPath.row ) as AnyObject).value(forKey: kSecondaryName) as! NSString) as! NSString
            let size: CGSize = myString.size(attributes: [NSFontAttributeName: UIFont.init(name: "Calibri", size: 16.0)!])
            cellSize  = CGSize(width:size.width + 30,height: 50)
        }
        else{
            if (collectionView == tagAllCollectionView) {
                if windowWidth == 320 {
                    cellSize  = CGSize(width:95,height: 94)
                }
                else {
                    cellSize  = CGSize(width:110,height: 90)
                }
            }
        }
        return cellSize
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView :SectionCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "SectionCollectionReusableView", for: indexPath) as! SectionCollectionReusableView
        
        if(isFromSearch){
            headerView.loadCellData(string: navTitleLabel.text!)
        }
        
        let date = (self.monthArray.object(at: indexPath.section) as AnyObject).value(forKey: "Date")
        
        
        if((date) != nil){
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let newdate = dateFormatter.date(from:date as! String )
            let date = Date()
            let calendar = Calendar.current
            let month = calendar.component(.month, from: newdate!)
            let currentMonth = calendar.component(.month, from: date)
            let resultString = ((self.monthArray.object(at: indexPath.section) as AnyObject).value(forKey: "Count"))
            let amountString = ((self.monthArray.object(at: indexPath.section) as AnyObject).value(forKey: kTotal))
            
            if(month == currentMonth){
                
                if(indexPath.section == 0){
                    
                    if(resultString is NSNumber){
                        let resultString1 = resultString as! NSNumber
                        //   headerView.sectionTitleLabel?.text = "Recent ".appending(" (").appending(resultString1.stringValue ).appending(")")
                        headerView.loadCellData(string: "Recent ".appending(" (").appending(resultString1.stringValue ).appending(")"))
                    }else{
                        //headerView.sectionTitleLabel?.text = "Recent ".appending(" (").appending(resultString as! String).appending(")")
                        headerView.loadCellData(string: "Recent ".appending(" (").appending(resultString as! String).appending(")"))}
                    
                    if(amountString is NSNumber){
                        headerView.loadAmountData(string: "Recent ".appending(" (").appending(resultString as! String).appending(")"))
                        
                    }else{
                        totalAmount.text = "Rs. ".appending(amountString as! String)
                        headerView.loadAmountData(string: "Rs. ".appending(amountString as! String))
                        
                    }
                    
                }
                
            }
            else{
                
                if(resultString is NSNumber){
                    let resultString1 = resultString as! NSNumber
                    // headerView.sectionTitleLabel.text = ((self.monthArray.object(at: indexPath.section) as AnyObject).value(forKey: "Month") as! String).appending(" (").appending(resultString1.stringValue).appending(")")
                    headerView.loadCellData(string: ((self.monthArray.object(at: indexPath.section) as AnyObject).value(forKey: "Month") as! String).appending(" (").appending(resultString1.stringValue).appending(")"))
                }else{
                    // headerView.sectionTitleLabel?.text = ((self.monthArray.object(at: indexPath.section) as AnyObject).value(forKey: "Month") as! String).appending(" (").appending(resultString as! String).appending(")")
                    headerView.loadCellData(string: ((self.monthArray.object(at: indexPath.section) as AnyObject).value(forKey: "Month") as! String).appending(" (").appending(resultString as! String).appending(")"))
                }
                
                if(amountString is NSNumber){
                    headerView.loadAmountData(string: "Recent ".appending(" (").appending(resultString as! String).appending(")"))
                }else{
                    headerView.loadAmountData(string: "Rs. ".appending(amountString as! String))
                }
                
            }
            
        }
        else{
            let amountString = ((self.monthArray.object(at: indexPath.section) as AnyObject).value(forKey: kTotal))
            let resultString = ((self.monthArray.object(at: indexPath.section) as AnyObject).value(forKey: "Count"))
            
            if(resultString is NSNumber){
                let resultString1 = resultString as! NSNumber
                headerView.loadCellData(string: "Recent ".appending(" (").appending(resultString1.stringValue).appending(")"))
            }
            else{
                headerView.loadCellData(string: "Recent ".appending(" (").appending(resultString as! String).appending(")"))
            }
            
            if(amountString is NSNumber){
                let amountString1 = amountString as! NSNumber
                totalAmount.text = "Rs. ".appending(amountString1.stringValue)
                headerView.loadAmountData(string: "Rs. ".appending(amountString1.stringValue))
            }else{
                totalAmount.text = "Rs. ".appending(amountString as! String)
                headerView.loadAmountData(string: "Rs. ".appending(amountString as! String))
            }
            
        }
        
        return headerView as UICollectionReusableView
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView.tag == 5000 || collectionView.tag == 6000 {
            print("Center tapped")
            
        }else{
            let galleryDetailsVC: CAGalleryDetailViewController = CAGalleryDetailViewController(nibName:"CAGalleryDetailViewController", bundle:nil)
            
            if((((self.monthArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(indexPath.section).value(forKey: kPrimaryTagId) as! NSArray).object(at: indexPath.row) as? String) != nil){
                
                galleryDetailsVC.tagId =   (((self.monthArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(indexPath.section).value(forKey: kPrimaryTagId) as! NSArray).object(at: indexPath.row) as? String)!
                galleryDetailsVC.isShowingGalleryData = isFromGallery
                
                if((((self.monthArray .value(forKey: kPrimaryImages) as AnyObject).objectAt(indexPath.section).value(forKey: "Type") as! NSArray).object(at: indexPath.row) as? String) == "gallery"){
                    galleryDetailsVC.isShowingGalleryData = true
                }
                navigationController?.pushViewController(galleryDetailsVC, animated: true)
                
            }
        }
    }
    
    //MARK: Button Action & Selector Methods
    @IBAction func backButtonAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func documentGalleryButtonAction(_ sender: UIButton) {
        
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
            if(!Reachability.isConnectedToNetwork()){
                
                let actionSheetController: UIAlertController = UIAlertController(title: kZoddl, message: "Seems like you are not connected to internet. Please check your internet connection.", preferredStyle: .alert)
                
                let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default) { action -> Void in
                    
                }
                actionSheetController.addAction(okAction)
                self.present(actionSheetController, animated: true, completion: nil)
            }
            else
            {
                //                let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["public.image", "public.audio", "public.movie", "public.text", "public.content","public.pages", "public.numbers", "public.pdf"], in: UIDocumentPickerMode.import)
                //
                //
                let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["com.apple.iwork.pages.pages", "com.apple.iwork.numbers.numbers", "com.apple.iwork.keynote.key", "com.microsoft.word.doc","public.text","com.adobe.pdf"], in: UIDocumentPickerMode.import)
                
                documentPicker.delegate = self
                documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                self.present(documentPicker, animated: true, completion: nil)
            }
        }
        
    }
    
    @IBAction func addManualButtonAction(_ sender: UIButton) {
        
        let addTagPopUpVC: CAAddTagPopUpViewController = CAAddTagPopUpViewController(nibName:"CAAddTagPopUpViewController", bundle: nil)
        addTagPopUpVC.addTagDelegate = self
        addTagPopUpVC.navigationTitleString = "Add Manual"
        addTagPopUpVC.modalPresentationStyle = .overCurrentContext
        addTagPopUpVC.modalTransitionStyle = .crossDissolve
        addTagPopUpVC.isManualTag = true
        addTagPopUpVC.isDocumentType = isFromDocument
        
        if isFromGallery {
            addTagPopUpVC.isDocumentType = false
            
        }else{
            addTagPopUpVC.isDocumentType = true
            addTagPopUpVC.docExtension = "jpg"
        }
        self.present(addTagPopUpVC, animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func filterButtonAction(_ sender: UIButton) {
        
        let appDelegateShared : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let filterController: CAFilterPopupViewController = CAFilterPopupViewController(nibName:"CAFilterPopupViewController", bundle: nil)
        filterController.delegate = self
        filterController.hideAlphabetOption = true
        filterController.modalPresentationStyle = .overCurrentContext
        filterController.modalTransitionStyle = .crossDissolve
        appDelegateShared.navController?.present(filterController, animated: true, completion: nil)
        
    }
    
    @IBAction func searchButtonAction(_ sender: UIButton) {
        let appDelegateShared : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let searchController: CASearchBarViewController = CASearchBarViewController(nibName:"CASearchBarViewController", bundle: nil)
        searchController.searchDelegate = self
        searchController.modalPresentationStyle = .overCurrentContext
        searchController.modalTransitionStyle = .crossDissolve
        appDelegateShared.navController?.present(searchController, animated: true, completion: nil)
    }
    
    // MARK: - custom Methods
    func tagAction(_ sender: UIButton) {
        let tagListVC: CATagListViewController = CATagListViewController(nibName:"CATagListViewController", bundle:nil)
        let tag = sender.tag
        tagListVC.isFromGallery = isFromGallery
        tagListVC.isFromHome = isFromHome
        
        if(tag < 8000){
            if(((userDefineArray[sender.tag - 7000] as AnyObject) .value(forKey: kPrimaryTag)) != nil){
                tagListVC.navBarTitleString = ((userDefineArray[sender.tag - 7000] as AnyObject) .value(forKey: kPrimaryName) as? String)!
                tagListVC.selectedTagId = ((userDefineArray[sender.tag - 7000] as AnyObject) .value(forKey: kPrimaryTag) as? String)!
                tagListVC.isPrimaryTag = true
                tagListVC.userDefineArray = userDefineArray
                tagListVC.preDefineArray = preDefineArray
                if isFromGallery{
                    tagListVC.isFromGallery = true
                }
                else if isFromDocument  {
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
            if(((preDefineArray[sender.tag - 8000] as AnyObject) .value(forKey: kTagId)) != nil){
                tagListVC.navBarTitleString = ((preDefineArray[sender.tag - 8000] as AnyObject) .value(forKey: kSecondaryName) as? String!)!
                tagListVC.selectedTagId = ((preDefineArray[sender.tag - 8000] as AnyObject) .value(forKey: kTagId) as? String)!
                tagListVC.isPrimaryTag = false
                tagListVC.userDefineArray = userDefineArray
                tagListVC.preDefineArray = preDefineArray
                
                if isFromGallery {
                    tagListVC.isFromGallery = true
                }
                else if isFromDocument {
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
    
    //Mark Custom Delegate
    func addDelegateWithDetailsAndIsSubmit(details: NSString, isSubmit: Bool) {
        
        if(isFromGallery){
            
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
                    let resultPredicate = NSPredicate(format: "Prime_Name == [c]%@", selectedTagName)
                    let arr = self.monthArray.filtered(using: resultPredicate)
                    if(arr.count > 0){
                        matchedPrimaryTag = (arr.first as! NSDictionary).mutableCopy() as! NSMutableDictionary
                        self.monthArray.removeObject(at: 0)
                        let imageArray = (matchedPrimaryTag.value(forKey: kPrimaryImages) as! NSArray).mutableCopy() as! NSMutableArray
                        let arr = dict.value(forKey: kPrimaryImages) as! NSArray
                        imageArray.add(arr.firstObject as Any)
                        print(matchedPrimaryTag)
                        matchedPrimaryTag .setValue(imageArray.noDuplicates(byKey: kTagImageURL), forKey: kPrimaryImages)
                        self.monthArray.insert(matchedPrimaryTag, at: 0)
                    }
                }
            }
            if (tagAllCollectionView) != nil {
                self.tagAllCollectionView.reloadData()
            }
            
            if(Reachability.isConnectedToNetwork()){
                let myDelegate = UIApplication.shared.delegate as? AppDelegate
                myDelegate?.uploadImageToS3_withTags(tagMutable: tagMutable)
            }
            
        }
        else{
            
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
                    let arr = self.monthArray.filtered(using: resultPredicate)
                    if(arr.count > 0){
                        print("Add in local")
                        matchedPrimaryTag = (arr.first as! NSDictionary).mutableCopy() as! NSMutableDictionary
                        self.monthArray.remove(matchedPrimaryTag)
                        let imageArray = (matchedPrimaryTag.value(forKey: kPrimaryImages) as! NSArray).mutableCopy() as! NSMutableArray
                        
                        let entryAdded = NSMutableDictionary()
                        entryAdded .setValue(docData.primaryName, forKey: kPrimaryName)
                        entryAdded.setValue(docData.amount, forKey: kAmount)
                        entryAdded.setValue(docData.tagDate, forKey: kTagDate)
                        entryAdded.setValue("0", forKey: kIsUploaded)
                        entryAdded.setValue(docData.docPath, forKey: kTagImageURL)
                        entryAdded.setValue(docData.tagDescription, forKey: kTagDescription)
                        entryAdded.setValue((docData.tagStatus as NSNumber).stringValue, forKey: kTagStatus)
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
                        matchedPrimaryTag .setValue(imageArray, forKey: kPrimaryImages)
                        self.monthArray.insert(matchedPrimaryTag, at: 0)
                        
                    }
                }
                
            }
            catch let err as NSError {
                print(err.debugDescription)
            }
            
            
            if (tagAllListTableView) != nil {
                self.tagAllListTableView.reloadData()
                self.tagAllCollectionView.reloadData()
                let tagCell = self.tagAllListTableView.dequeueReusableCell(withIdentifier: "CAHomeTagCell") as? CAHomeTagCell
                tagCell?.tagCollectionView.reloadData()
            }
            
        }
    }
    
    
    
    func callFilter(filterType: String) {
        
    }
    
    // MARK: - UIDocumentPickerDelegate Methods
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        if controller.documentPickerMode == UIDocumentPickerMode.import {
            // This is what it should be
            do {
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
                
            }
            catch {
                print("Unable to load data: \(error)")
                presentAlert(kZoddl, msgStr: error as? String, controller: self)
                
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
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
    
    
    
    
    // MARK: - Get Detailed View
    
    func getTagDetailsCalendarBased(currentPageNumber : Int){
        
        let paramDict : Dictionary<String, AnyObject> = [
            kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject) ,
            kPrimaryTag :selectedTagId as AnyObject,
            kPageNumber : pageNumber as AnyObject,
            kMonth : selectedMonth as AnyObject
        ]
        self.showHud(text: "Loading Data")
        
        var apiName = String()
        
        
        if(isFromDocument == true){
            apiName = "Document_Api/gallerydetailbymonth"
            
        }else{
            apiName = "Customer_Api/gallerydetailbymonth"
            
        }
        
        ServiceHelper.sharedInstanceHelper.createPostRequest(method: .post, showHud: true, params: paramDict, apiName: apiName) { (result, error) in
            
            if(!(error != nil)){
                self.hideHud()
                if (result![kResponseCode]! as? String == "200"){
                    let resultDict:Dictionary<String, AnyObject> = result as! Dictionary
                    let dataFetched = (resultDict[kAPIPayload]! as! NSArray).mutableCopy() as! NSMutableArray
                    print(resultDict["Flag"] as Any)
                    if(resultDict["Flag"]?.int8Value == 1){
                        self.loadMore = true
                    }else{
                        self.loadMore = false
                    }
                    
                    if(self.pageNumber > 1){
                        
                        for (_, element) in dataFetched.enumerated() {
                            let dict = (element as! NSDictionary).mutableCopy() as! NSMutableDictionary
                            let resultPredicate = NSPredicate(format: "Month == [c]%@", dict.value(forKey: "Month") as! String)
                            let arr = self.monthArray.filtered(using: resultPredicate)
                            
                            let arrIndex = (self.monthArray.value(forKey: "Month") as AnyObject) .index(of: dict.value(forKey: "Month") as Any) as NSInteger
                            
                            print(arrIndex)
                            
                            if(arr.count > 0){
                                let imageArr1  = (dict.value(forKey: kPrimaryImages) as! NSArray).mutableCopy() as! NSMutableArray
                                let imageArrFetched = ((arr.first as! NSDictionary).value(forKey: kPrimaryImages) as! NSArray).mutableCopy() as! NSMutableArray
                                imageArrFetched.addObjects(from: imageArr1 as! [Any])
                                dict .setValue(imageArrFetched, forKey: kPrimaryImages)
                                self.monthArray.removeObject(at: arrIndex)
                                self.monthArray.insert(dict, at: arrIndex)
                            }else{
                                self.monthArray.add(dict)
                            }
                        }
                    }
                    else{
                        self.monthArray = (resultDict[kAPIPayload]! as! NSArray).mutableCopy() as! NSMutableArray
                    }
                    self.tagAllListTableView.reloadData()
                    self.tagAllCollectionView.reloadData()
                    //                    let primaryIndexPath = IndexPath(item: 1, section: 0)
                    //                    let secondaryIndexPath = IndexPath(item: 0, section: 0)
                    //                    self.tagAllListTableView.reloadRows(at: [primaryIndexPath,secondaryIndexPath], with: .none)
                    if(self.monthArray.count == 0){
                        self.navigationController?.popViewController(animated: true)
                    }
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
    
    
    // MARK: - Get Detailed Of Tags
    
    func getTagDetailsOnTagSubTags(){
        
        let paramDict : Dictionary<String, AnyObject> = [
            kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject) ,
            kPrimaryTag :selectedTagId as AnyObject,
            kSecondaryTag :secondaryTagId as AnyObject,
            kPageNumber : pageNumber as AnyObject
        ]
        
        var apiName = String()
        
        if(isFromDocument == true){
            apiName = "Document_Api/userprimarytagsearchdetails"
            
        }else{
            apiName = "Customer_Api/userprimarytagsearchdetails"
        }
        
        ServiceHelper.sharedInstanceHelper.createPostRequest(method: .post, showHud: false, params: paramDict, apiName: apiName) { (result, error) in
            
            if(!(error != nil)){
                self.hideHud()
                if (result![kResponseCode]! as? String == "200"){
                    let resultDict:Dictionary<String, AnyObject> = result as! Dictionary
                    let dataFetched = (resultDict[kAPIPayload]! as! NSArray).mutableCopy() as! NSMutableArray
                    
                    self.loadMore = (resultDict["Flag"]?.boolValue)!
                    if(self.pageNumber > 1){
                        for (index, element) in dataFetched.enumerated() {
                            let dict = (element as! NSDictionary).mutableCopy() as! NSMutableDictionary
                            let resultPredicate = NSPredicate(format: "Month == [c]%@", dict.value(forKey: "Month") as! String)
                            let arr = dataFetched.filtered(using: resultPredicate)
                            
                            if(arr.count > 0){
                                let imageArr1  = (self.monthArray.value(forKey: kPrimaryImages) as! NSArray).mutableCopy() as! NSMutableArray
                                let imageArrFetched = (arr.first as! NSDictionary).value(forKey: kPrimaryImages) as! NSArray
                                let imageLoaded = (imageArr1.firstObject as! NSArray).mutableCopy() as! NSMutableArray
                                imageLoaded.addObjects(from: imageArrFetched as! [Any])
                                dict .setValue(imageLoaded, forKey: kPrimaryImages)
                                self.monthArray.removeObject(at: index)
                                self.monthArray.insert(dict, at: index)
                            }else{
                                self.monthArray.add(dict)
                            }
                        }
                    }
                    else{
                        self.monthArray = (resultDict[kAPIPayload]! as! NSArray).mutableCopy() as! NSMutableArray
                    }
                    
                    self.tagAllCollectionView.reloadData()
                    print(self.monthArray)
                    self.monthDetailedTagsArray.removeAllObjects()
                    self.tagAllListTableView.reloadData()
                    let tagCell = self.tagAllListTableView.dequeueReusableCell(withIdentifier: "CAHomeTagCell") as? CAHomeTagCell
                    tagCell?.tagCollectionView.reloadData()
                    
                    let primaryIndexPath = IndexPath(item: 1, section: 0)
                    let secondaryIndexPath = IndexPath(item: 0, section: 0)
                    self.tagAllListTableView.reloadRows(at: [primaryIndexPath,secondaryIndexPath], with: .none)
                    
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
    
    
    // MARK: - Get Detailed Of Home page
    
    func getTagDetailsForHomePageData(){
        
        let paramDict : Dictionary<String, AnyObject> = [
            kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject) ,
            kTagType :tagType as AnyObject
        ]
        
        ServiceHelper.sharedInstanceHelper.createPostRequest(method: .post, showHud: true, params: paramDict, apiName: "Customer_Api/homedatatagtypedetail") { (result, error) in
            
            if(!(error != nil)){
                if (result![kResponseCode]! as? String == "200"){
                    let resultDict:Dictionary<String, AnyObject> = result as! Dictionary
                    print(resultDict)
                    self.monthArray = (resultDict[kAPIPayload]! as! NSArray).mutableCopy() as! NSMutableArray
                    self.tagAllCollectionView.reloadData()
                    //print(self.monthArray)
                    self.monthDetailedTagsArray.removeAllObjects()
                    self.tagAllListTableView.reloadData()
                    let tagCell = self.tagAllListTableView.dequeueReusableCell(withIdentifier: "CAHomeTagCell") as? CAHomeTagCell
                    tagCell?.tagCollectionView.reloadData()
                    
                    let primaryIndexPath = IndexPath(item: 1, section: 0)
                    let secondaryIndexPath = IndexPath(item: 0, section: 0)
                    self.tagAllListTableView.reloadRows(at: [primaryIndexPath,secondaryIndexPath], with: .none)
                    
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
    
    
    // MARK: - Scroll view delegates
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (bottomEdge >= scrollView.contentSize.height) {
            print("End Scroll")
            pageNumber = pageNumber + 1
            
            if(isFromTagList == false){
                if(loadMore){
                    self.getTagDetailsCalendarBased(currentPageNumber: pageNumber)
                }
            }
            
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.lastContentOffset > scrollView.contentOffset.y) {
            // print("Going Up")
        }
        else if (self.lastContentOffset < scrollView.contentOffset.y) {
            // print("Going Down")
        }
        //Jugadd
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
            // print("Reached End")
            
        }
        
        // update the new position acquired
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    
    func showHud(text : NSString) {
        let attribute = RappleActivityIndicatorView.attribute(style: RappleStyleCircle, tintColor: .white, screenBG: nil, progressBG: .black, progressBarBG: .lightGray, progreeBarFill: .yellow)
        RappleActivityIndicatorView.startAnimatingWithLabel(text as String, attributes: attribute)
    }
    
    func hideHud() {
        RappleActivityIndicatorView.stopAnimation()
        RappleActivityIndicatorView.stopAnimation(completionIndicator: .none, completionLabel: "", completionTimeout: 1.0)
    }
    
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print(webView.tag);
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
        if(searchType == "image gallery"){
            tagListVC.isFromGallery = true
        }else{
            tagListVC.isFromGallery = false
        }
        self.navigationController?.pushViewController(tagListVC, animated: true)
    }
    
    
}
