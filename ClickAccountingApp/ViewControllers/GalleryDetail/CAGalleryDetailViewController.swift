//
//  CAGalleryDetailViewController.swift
//  ClickAccountingApp
//
//  Created by Chandan Mishra on 30/06/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
import UIKit
import TOCropViewController
import SDWebImage
import QuickLook
import WebKit



class CAGalleryDetailViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,UICollectionViewDelegate, UICollectionViewDataSource, AddTagDelegate, UIDocumentPickerDelegate,UICollectionViewDelegateFlowLayout,UITextFieldDelegate, UITextViewDelegate,TOCropViewControllerDelegate,imageFilterDelegate, QLPreviewControllerDataSource, QLPreviewControllerDelegate, UIWebViewDelegate,docScreenshotDelegate  {
    
    
    @IBOutlet var headerView: UIView!
    @IBOutlet var footerView: UIView!
    @IBOutlet weak var collectionViewGallery: UICollectionView!
    @IBOutlet weak var tableViewGallery: UITableView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var cashLabel: UILabel!
    @IBOutlet weak var editTextButton: UIButton!
    @IBOutlet weak var navigationTitleLabel: UILabel!
    @IBOutlet weak var tableViewGallerySecond: UITableView!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var labelLatestBrand: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var changedateButton: UIButton!
    @IBOutlet weak var labelLatestBrandWidth: NSLayoutConstraint!
    var secondaryTagNameTextField = CATextField()
    var primaryTagNameTextField = CATextField()
    var primaryNameString : NSString  = "Untagged"
    @IBOutlet var dropDownTableview: UITableView!
    var currentFieldSelected : NSString  = ""
    var copyPrimaryTagArray = NSMutableArray()
    var copySecondaryTagArray = NSMutableArray()
    var docScreenshotView = CADocScreenshotViewController()
    @IBOutlet var docWebView: UIWebView!
    
    @IBOutlet var activityIndicatorDoc: UIActivityIndicatorView!
    @IBOutlet var cropButton: UIButton!
    
    var SGST = String()
    var CGST = String()
    var IGST = String()
    
    @IBOutlet var saveButton: UIButton!
    var inEditMode = Bool()
    var isShowingGalleryData = Bool()
    
    var GalleryInfo = CAUserInfo()
    var stringNav: String =  ""
    var tagId = String ()
    var itemDetailsDictionary = NSDictionary()
    var userDefineArray = NSMutableArray()
    var preDefineArray = NSMutableArray()
    var secondaryTagsArray = NSMutableArray()
    var secondaryTagsArrayCopy = NSMutableArray()
    var primaryTagsArray = NSMutableArray()
    var secondaryTagScrollView = UIScrollView()
    var origin = Int ()
    var tagCount = Int()
    var nextTextField = UITextField()
    var primaryFrameInSuperview  = CGRect()
    var primaryTagView = UIView()
    var bannerImageURL: String =  ""
    var bannerThumbImageURL: String =  ""
    var docURLFetched: String =  ""
    var documentExtension : String = ""
    var documentPath : String = ""
    var isImageType = Bool()
    var documentIsLoaded = Bool()
    var imageIsLoaded = Bool()
    
    let quickLookController = QLPreviewController()
    var fileURLLocalImage = URL(string: "")
    
    
    
    var allPrimaryTags = NSMutableArray()
    var allSecondaryTags = NSMutableArray()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.getItemDetails()
        self.initialSetup()
        // Do any additional setup after loading the view.
    }
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Initial Setup
    
    func initialSetup()
    {
        docWebView.delegate = self
        tagCount = 2000
        //  navigationTitleLabel.text = stringNav
        //collectionViewGallery.showsHorizontalScrollIndicator = false
        quickLookController.dataSource = self
        quickLookController.delegate = self
        allPrimaryTags = (kUserDefaults.value(forKey: kAllPrimaryTags) as! NSArray).mutableCopy() as! NSMutableArray
        allSecondaryTags = (kUserDefaults.value(forKey: kAllSecondaryTags) as! NSArray).mutableCopy()  as! NSMutableArray
        if(isShowingGalleryData){
            cropButton.isHidden = false
        }else{
            cropButton.isHidden = true
        }
        
        let dummyArray = NSMutableArray()
        for dict in self.allSecondaryTags {
            if(!dummyArray.contains(dict)){
                dummyArray.add(dict)
            }
        }
        allSecondaryTags = dummyArray
        
        copyPrimaryTagArray = allPrimaryTags
        copySecondaryTagArray = allSecondaryTags
        
        self.imageView.layer.cornerRadius = 3
        //self.imageView.layer.masksToBounds = true
        //  self.imageView.clipsToBounds = true
        self.descriptionTextView.isUserInteractionEnabled = false
        self.cashLabel.layer.cornerRadius = 5
        self.cashLabel.layer.masksToBounds = true
        self.labelLatestBrand.layer.cornerRadius = 5.0
        self.labelLatestBrand.layer.masksToBounds = true
        
        saveButton.isHidden = true
        self.tableViewGallery.rowHeight = UITableViewAutomaticDimension
        self.tableViewGallery.estimatedRowHeight = 140
        self.tableViewGallery.tableFooterView = footerView
        self.tableViewGallery.tableHeaderView = headerView
        self.tableViewGallery.allowsSelection=false
        collectionViewGallery.dataSource = self
        collectionViewGallery.delegate = self
        
        secondaryTagScrollView = UIScrollView(frame: CGRect(x: 10, y: 0, width: self.view.frame.size.width, height: 40))
        secondaryTagScrollView.isDirectionalLockEnabled = true
        secondaryTagScrollView.bounces = false
        secondaryTagScrollView.showsVerticalScrollIndicator = false
        secondaryTagScrollView.showsHorizontalScrollIndicator = false
        secondaryTagNameTextField =  CATextField(frame: CGRect(x: 5, y: 0, width: self.view.frame.size.width - 10, height: 40))
        secondaryTagNameTextField.placeHolderText(withColor: "Add Secondary Tag", andColor: RGBA(17, g: 43, b: 88, a: 1))
        secondaryTagNameTextField.autocorrectionType = .no
        secondaryTagNameTextField.returnKeyType = UIReturnKeyType.done
        primaryTagView = UIView(frame: CGRect(x: 10, y: 0, width: self.view.frame.size.width, height: 40))
        primaryTagNameTextField =  CATextField(frame: CGRect(x: 5, y: 0, width: 300, height: 40))
        primaryTagNameTextField.placeHolderText(withColor: "Add Primary Tag", andColor: RGBA(17, g: 43, b: 88, a: 1))
        primaryTagNameTextField.autocorrectionType = .no
        
        
        // For registereing nib
        self.tableViewGallery.register(UINib(nibName: "CAGalleryViewCellTableViewCell", bundle: nil), forCellReuseIdentifier: "CAGalleryViewCellTableViewCell")
        
        self.collectionViewGallery.register(UINib(nibName: "CATagCollectionCell", bundle: nil), forCellWithReuseIdentifier: "CATagCollectionCell")
        //  headerView.register(CAGalleryCollectionViewCell.self, forCellWithReuseIdentifier: CAGalleryCollectionViewCell.reuseIdentifier)
        self.tableViewGallerySecond!.register(UINib(nibName: "CAHomeTagCell", bundle: nil), forCellReuseIdentifier: "CAHomeTagCell")
        
        if responds(to: #selector(getter: self.edgesForExtendedLayout)) {
            edgesForExtendedLayout = []
        }
        
        changedateButton.isEnabled = false
        amountTextField.isUserInteractionEnabled = false
        amountTextField.delegate = self
        amountTextField.inputAccessoryView = addToolBarOnTextfield(textField: self.amountTextField, target: self)
        amountTextField.keyboardType = UIKeyboardType.numberPad
        self.descriptionTextView.delegate = self
        self.descriptionTextView.returnKeyType = .done
        self.descriptionTextView.sizeToFit()
        
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        dropDownTableview.tableFooterView = customView
        dropDownTableview.frame =  CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 0, height: 0))
        dropDownTableview.delegate = self
        dropDownTableview.dataSource = self
        dropDownTableview.layer.cornerRadius = 5.0
        dropDownTableview.clipsToBounds = true
        dropDownTableview.layer.shadowOffset = CGSize(width: 10.0, height: 10.0)
        self.tableViewGallery.addSubview(dropDownTableview)
    }
    
    
    // MARK: - UITableView DataSource Methods
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var count = Int()
        
        if tableView == tableViewGallery
        {
            count = 3
        }else if tableView == tableViewGallerySecond
        {
            count = 2
        }
        else if tableView == dropDownTableview
        {
            if(currentFieldSelected == "Secondary"){
                count =  allSecondaryTags.count
            }else{
                count =  allPrimaryTags.count
            }
            
        }
        return count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView == tableViewGallery {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CAGalleryViewCellTableViewCell", for: indexPath) as? CAGalleryViewCellTableViewCell
            cell?.galleryGSTTextfield.tag = indexPath.row + 1000;
            cell?.galleryGSTTextfield.keyboardType = UIKeyboardType.numberPad
            cell?.galleryGSTTextfield.delegate = self
            
            if(!inEditMode){
                cell?.galleryGSTTextfield.isEnabled = false
            }
            else{
                cell?.galleryGSTTextfield.isEnabled = true
            }
            switch indexPath.row
            {
            case 0:
                cell?.galleryGSTTextfield.placeholder = "SGST"
                cell?.titleLabel.text = "SGST: "
                cell?.galleryGSTTextfield.text = SGST as String
                break
            case 1:
                cell?.galleryGSTTextfield.placeholder = "CGST"
                cell?.titleLabel.text = "CGST: "
                cell?.galleryGSTTextfield.text = CGST as String
                break
            case 2:
                cell?.galleryGSTTextfield.placeholder = "IGST"
                cell?.titleLabel.text = "IGST: "
                cell?.galleryGSTTextfield.text = IGST as String
                break
            default:
                break
            }
            
            return cell!
        }
        else if tableView.tag == 378 {
            let  cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: nil)
            cell.contentView.backgroundColor = RGBA(250.0, g: 250.0, b: 250.0, a: 1.0)
            
            if(currentFieldSelected as String == kSecondary){
                if(allSecondaryTags.count > 0){
                    cell.textLabel?.text = (allSecondaryTags.value(forKey: kSecondaryName) as AnyObject).object(at: indexPath.row) as? String
                }
            }
            else{
                if(allPrimaryTags.count > 0){
                    cell.textLabel?.text = (allPrimaryTags.value(forKey: kPrimaryName) as AnyObject).object(at: indexPath.row) as? String
                }
            }
            return cell
        }
            
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CAHomeTagCell", for: indexPath) as? CAHomeTagCell
            cell?.tagCollectionView.register(UINib(nibName: "CATagCollectionCell", bundle: nil), forCellWithReuseIdentifier: "CATagCollectionCell")
            cell?.tagCollectionView.showsHorizontalScrollIndicator = false
            cell?.tagCollectionView.tag = indexPath.row + 5000
            cell?.tagCollectionView.allowsSelection = true
            cell?.tagCollectionView.delegate = self
            cell?.tagCollectionView.dataSource = self
            cell?.tagCollectionView.reloadData()
            return cell!
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        if (tableView == tableViewGallery)
        {
            return 40
        }
        if (tableView.tag == 378)
        {
            return 32
        }
            
        else
        {
            return 61
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.tag == 378{
            dropDownTableview.frame =  CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 0, height: 0))
            if(currentFieldSelected == "Primary"){
                createPrimaryViewOnSelection ((allPrimaryTags.object(at: indexPath.row)as AnyObject).value(forKey: kPrimaryName) as! NSString)
            }
            else{
                let selectedTag = (allSecondaryTags.object(at: indexPath.row) as AnyObject).value(forKey: kSecondaryName) as! NSString
                createSecondaryView(newString: selectedTag as NSString, string: " " as NSString)
            }
        }
        else  if tableView == tableViewGallery {
            print("Tapped Outside")
        }else
        {
            
        }
    }
    
    // MARK:- UICollectionView DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if collectionView.tag == 5000
        {
            return 1
        }
        else if collectionView.tag == 5001
        {
            return 1
        }else
        {
            return 0
        }
        
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if collectionView.tag == 5000 {
            //user define tags name collection
            let tagCell: CATagCollectionCell? = (collectionView.dequeueReusableCell(withReuseIdentifier: "CATagCollectionCell", for: indexPath) as? CATagCollectionCell)
            tagCell?.tagBtn?.removeFromSuperview()
            tagCell?.addSubview(primaryTagView)
            let theAttributes:UICollectionViewLayoutAttributes! = collectionView.layoutAttributesForItem(at: indexPath)
            primaryFrameInSuperview = collectionView.convert(theAttributes.frame, to: collectionView.superview)
            
            //  tagCell?.tagBtn?.setTitle(userDefineArray.object(at: indexPath.row) as? String, for: .normal)
            //  tagCell?.tagBtn?.addTarget(self, action: #selector(CAGalleryDetailViewController.tagActionGallery(_:)), for: .touchUpInside)
            return tagCell!
            
        }
            
        else {//if collectionView.tag == 5001 {
            //pre define tags name collection
            
            let tagCell: CATagCollectionCell? = (collectionView.dequeueReusableCell(withReuseIdentifier: "CATagCollectionCell", for: indexPath) as? CATagCollectionCell)
            tagCell?.tagBtn?.removeFromSuperview()
            tagCell?.contentView .addSubview(secondaryTagScrollView)
            
            return tagCell!
            
            
            //  tagCell?.tagBtn?.tag = indexPath.item + 8000
            //  tagCell?.tagBtn?.setTitle((preDefineArray .value(forKey: kSecondaryName) as AnyObject).objectAt(indexPath.row) as? String, for: UIControlState.normal)
            //            tagCell?.tagBtn?.addTarget(self, action: #selector(CAGalleryDetailViewController.tagActionGallery(_:)), for: .touchUpInside)
            
        }
        
        /* else {
         //            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CATagCollectionCell", for: indexPath as IndexPath) as? CATagCollectionCell
         //            cell?.tagBtn?.tag = indexPath.item + 9000
         //            cell?.tagBtn?.setTitle(userDefineArray[indexPath.row], for: .normal)
         //            cell?.tagBtn?.addTarget(self, action: #selector(CAGalleryDetailViewController.tagActionGallery(_:)), for: .touchUpInside)
         return cell!
         }*/
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var cellSize = CGSize()
        if collectionView.tag == 5000{
            cellSize  = CGSize(width:self.view.frame.size.width,height: 50)
        }
        else{
            cellSize  = CGSize(width:self.view.frame.size.width,height: 50)
        }
        
        return cellSize
        
    }
    
    
    //MARK:-Textview delegates
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 80
    }
    
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if(textField.tag == 101){
            print("Done on primary tag")
            if(primaryTagNameTextField.text != ""){
                createPrimaryViewOnSelection(primaryTagNameTextField.text! as NSString)
                textField.text = ""
                
            }
        }
        
        if(textField.tag == 102){
            let newString = textField.text! as NSString
            createSecondaryView(newString: newString as NSString, string: " " as NSString)
        }
        
        self.view.endEditing(true)
        return true;
    }
    
    
    func createPrimaryViewOnSelection (_ primaryName : NSString){
        
        var primaryWidth = Int ()
        
        let tagNameString = primaryName as NSString
        self.primaryNameString = tagNameString
        
        if let font = UIFont(name: "HelveticaNeue", size: 14)
        {
            let fontAttributes = [NSFontAttributeName: font]
            let size = (tagNameString as NSString).size(attributes: fontAttributes)
            primaryWidth = Int(size.width + 10)
        }
        
        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: primaryWidth+25, height: 32))
        backgroundView.layer.cornerRadius = 16.0
        backgroundView.clipsToBounds = true
        backgroundView.backgroundColor = UIColor.blue
        let backgroundImage = UIImageView(frame: CGRect(x: 0, y: 0, width: primaryWidth+25, height: 32))
        backgroundImage.image = UIImage.init(named: "btn")
        backgroundView.addSubview(backgroundImage)
        
        let sampleTextField =  UITextField(frame: CGRect(x: 10, y: 3, width: primaryWidth, height: 25))
        sampleTextField.font = UIFont(name: "HelveticaNeue", size: 14)
        sampleTextField.textAlignment = NSTextAlignment.center
        sampleTextField.text = tagNameString as String
        sampleTextField.isUserInteractionEnabled = false
        sampleTextField.textColor = UIColor.white
        backgroundView.addSubview(sampleTextField)
        
        let closeButton =  UIButton(frame: CGRect(x: primaryWidth+12, y: 0, width: 20, height: 20))
        closeButton.setImage(UIImage.init(named: "cross"), for: UIControlState.normal)
        closeButton.contentMode = .top
        closeButton.imageView?.contentMode = .scaleAspectFit
        closeButton.addTarget(self, action: #selector(CAGalleryDetailViewController.closeTappedPrimary(_:)), for: .touchUpInside)
        
        let dummyView = UIView(frame: CGRect(x: 5, y: 5, width: primaryWidth+25, height: 52))
        dummyView.addSubview(backgroundView)
        dummyView.addSubview(closeButton)
        primaryTagView.addSubview(dummyView)
        self.primaryTagNameTextField.removeFromSuperview()
        self.collectionViewGallery.reloadData()
    }
    
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews(); self.descriptionTextView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    
    
    //Mark: UI Button Action
    
    @IBAction func editTextViewButtonAction(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        secondaryTagsArrayCopy.removeAllObjects()
        
        if  descriptionTextView.isFirstResponder{
            self.descriptionTextView.isUserInteractionEnabled=false
            descriptionTextView.resignFirstResponder()
            changedateButton.isEnabled = false
            amountTextField.isUserInteractionEnabled = false
            saveButton.isHidden = true
            editTextButton.isHidden = false
            inEditMode = false
        }else{
            saveButton.isHidden = false
            editTextButton.isHidden = true
            self.descriptionTextView.isUserInteractionEnabled=true
            changedateButton.isEnabled = true
            amountTextField.isUserInteractionEnabled = true
            descriptionTextView.becomeFirstResponder()
            createSubViews(showCloseButton : true)
            createPrimaryView( showCloseButton : true)
            inEditMode = true
        }
        self.tableViewGallery.reloadData()
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pageButtonAction(_ sender: UIButton) {
        let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["com.apple.iwork.pages.pages", "com.apple.iwork.numbers.numbers", "com.apple.iwork.keynote.key", "com.microsoft.word.doc","public.text","com.adobe.pdf"], in: UIDocumentPickerMode.import)
        
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    
    @IBAction func addButtonACtion(_ sender: UIButton) {
        
        let addTagPopUpVC: CAAddTagPopUpViewController = CAAddTagPopUpViewController(nibName:"CAAddTagPopUpViewController", bundle: nil)
        addTagPopUpVC.addTagDelegate = self
        addTagPopUpVC.navigationTitleString = "Add Manual"
        addTagPopUpVC.modalPresentationStyle = .overCurrentContext
        addTagPopUpVC.modalTransitionStyle = .crossDissolve
        
        if(isShowingGalleryData == true){
            addTagPopUpVC.isDocumentType = false
        }else{
            addTagPopUpVC.isDocumentType = true
        }
        
        self.present(addTagPopUpVC, animated: true, completion: nil)
        
    }
    
    @IBAction func saveButtonAction(_ sender: UIButton) {
        
        self.saveItemDetails()
    }
    
    @IBAction func downloadButtonAction(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(imageView.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    // MARK: Share Button Action
    
    @IBAction func shareButtonAction(_ sender: Any) {
        
        let primeName = self.itemDetailsDictionary.value(forKey: kPrimaryName) as! String
        let amount = self.itemDetailsDictionary.value(forKey: kAmount) as! String
        let description = self.itemDetailsDictionary.value(forKey: kTagDescription) as! String
        
        let sgst = self.itemDetailsDictionary.value(forKey: kSGST) as! String
        let cgst = self.itemDetailsDictionary.value(forKey: kCGST) as! String
        let igst = self.itemDetailsDictionary.value(forKey: kIGST) as! String
        let secondaryTags = (secondaryTagsArray.value(forKey: "Secondary_Name") as AnyObject).componentsJoined(by: ",")
        
        let shareText = "Primary Tag : ".appending(primeName) .appending("\n").appending("Secondary tags : ").appending(secondaryTags).appending("\n").appending("Amount : ").appending("Rs. ").appending(amount).appending("\n").appending("Description : ").appending(description).appending("\n").appending("SGST : ").appending("Rs. ").appending(sgst).appending("\n").appending("CGST : ").appending("Rs. ").appending(cgst).appending("\n").appending("IGST : ").appending("Rs. ").appending(igst)
        
        let image = imageView.image
        if let img = image {
            let vc = UIActivityViewController(activityItems: [img,shareText], applicationActivities: [])
            present(vc, animated: true, completion: nil)
        }
        
    }
    
    
    // MARK: Delete Button Action
    
    @IBAction func deleteImageAction(_ sender: Any) {
        
        let actionSheetController: UIAlertController = UIAlertController(title: kZoddl, message: "Are you sure you want to delete this entry?", preferredStyle: .alert)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
        }
        let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default) { action -> Void in
            self.deleteTagAPI()
        }
        actionSheetController.addAction(cancelAction)
        actionSheetController.addAction(okAction)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    
    // MARK: UI Button Action
    
    @IBAction func cropImage_Action(_ sender: Any) {
        
        if imageView != nil {
            let imageCropVC: TOCropViewController = TOCropViewController.init(image:imageView.image!)
            imageCropVC.delegate = self as TOCropViewControllerDelegate
            self .present(imageCropVC, animated: true, completion: {
            })
        }
    }
    
    // MARK: Crop Image Delegate
    
    func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int) {
        
        // self.saveDataForPaidUsers(uuid: imageUUID)
        
        self.imageView.isHidden = false
        self.imageView.image = image
        self.dismiss(animated: true, completion: nil)
        
        DispatchQueue.global(qos: .background).async {
            print("This is run on the background queue")
            
            ServiceHelper.sharedInstanceHelper.uploadImageToS3(image: image, fileName: "", completion: { (result, error) in
                hideHud()
                if(error == nil){
                    self.bannerImageURL = kImageBaseURL.appending((result?.value(forKey: "key")) as! String)
                    
                    ServiceHelper.sharedInstanceHelper.uploadThumbImageToS3(image: image, fileName: "", completion: { (result, error) in
                        hideHud()
                        if(error == nil){
                            self.bannerThumbImageURL = kImageBaseURL.appending((result?.value(forKey: "key")) as! String)
                            self.saveItemDetails()
                        }
                    });
                    
                }
            });
        }
        self.tableViewGallery.reloadData()
    }
    
    // MARK:
    // MARK: Delete GALLERY tag API
    
    
    func deleteTagAPI(){
        
        let paramDict : Dictionary<String, AnyObject> = [
            kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject) ,
            kPrimaryTagId :tagId as AnyObject
        ]
        
        var apiName = String()
        
        if(isShowingGalleryData == true){
            apiName = "Customer_Api/deletetag"
        }else{
            apiName = "Document_Api/deletetag"
        }
        
        
        ServiceHelper.sharedInstanceHelper.createPostRequest(method: .post, showHud: true, params: paramDict, apiName: apiName) { (result, error) in
            
            if(!(error != nil)){
                NotificationCenter.default.post(name: Notification.Name("tagDeleted"), object: nil)
                self.navigationController?.popViewController(animated: true)
            }
            
        }
        
    }
    
    
    
    // MARK: Create Tag view
    
    func createPrimaryView( showCloseButton : Bool){
        
        var primaryWidth = Int ()
        
        for (_, element) in primaryTagsArray.enumerated() {
            
            let tagNameString = element as! NSString
            primaryNameString = tagNameString
            if let font = UIFont(name: "HelveticaNeue", size: 14)
            {
                let fontAttributes = [NSFontAttributeName: font]
                let size = (tagNameString as NSString).size(attributes: fontAttributes)
                primaryWidth = Int(size.width + 10)
            }
            
            let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: primaryWidth+25, height: 32))
            backgroundView.layer.cornerRadius = 16.0
            backgroundView.clipsToBounds = true
            backgroundView.backgroundColor = UIColor.blue
            let backgroundImage = UIImageView(frame: CGRect(x: 0, y: 0, width: primaryWidth+25, height: 32))
            backgroundImage.image = UIImage.init(named: "btn")
            backgroundView.addSubview(backgroundImage)
            
            
            let sampleTextField =  UITextField(frame: CGRect(x: 10, y: 3, width: primaryWidth, height: 25))
            sampleTextField.font = UIFont(name: "HelveticaNeue", size: 14)
            sampleTextField.textAlignment = NSTextAlignment.center
            sampleTextField.text = tagNameString as String
            sampleTextField.isUserInteractionEnabled = false
            sampleTextField.textColor = UIColor.white
            backgroundView.addSubview(sampleTextField)
            
            let closeButton =  UIButton(frame: CGRect(x: primaryWidth+12, y: 0, width: 20, height: 20))
            closeButton.setImage(UIImage.init(named: "cross"), for: UIControlState.normal)
            closeButton.contentMode = .top
            closeButton.imageView?.contentMode = .scaleAspectFit
            closeButton.addTarget(self, action: #selector(CAGalleryDetailViewController.closeTappedPrimary(_:)), for: .touchUpInside)
            
            let dummyView = UIView(frame: CGRect(x: 5, y: 5, width: primaryWidth+25, height: 52))
            // dummyView.tag = tagCount
            dummyView.addSubview(backgroundView)
            if(showCloseButton){
                dummyView.addSubview(closeButton)
            }
            else{
                closeButton.setImage(UIImage.init(named: ""), for: UIControlState.normal)
                closeButton.removeFromSuperview()
            }
            primaryTagView.addSubview(dummyView)
        }
        self.collectionViewGallery.reloadData()
    }
    
    
    
    func closeTappedPrimary(_ sender: UIButton) {
        
        for view in primaryTagView.subviews{
            
            DispatchQueue.main.async {
                view.removeFromSuperview()
                //self.collectionViewGallery.reloadData()
            }
        }
        primaryTagNameTextField =  CATextField(frame: CGRect(x: 5, y: 0, width: 300, height: 40))
        primaryTagNameTextField.delegate = self
        primaryNameString = "Untagged"
        primaryTagNameTextField.placeHolderText(withColor: "Add Primary Tag", andColor: RGBA(17, g: 43, b: 88, a: 1))
        primaryTagView.addSubview(primaryTagNameTextField)
        primaryTagNameTextField.returnKeyType = UIReturnKeyType.done
        primaryTagNameTextField.tag = 101
        
    }
    
    
    //MARK:- Secondary Tag Creation
    
    func createSubViews( showCloseButton : Bool){
        tagCount = 2000
        var width = Int ()
        secondaryTagScrollView.contentSize =  CGSize(width:0, height: 42)
        origin = 0
        print(secondaryTagsArray)
        
        secondaryTagsArrayCopy.removeAllObjects()
        
        for i in 0 ..< secondaryTagsArray.count {
            
            let element = secondaryTagsArray .object(at: i) as! NSDictionary
            tagCount = tagCount + 1
            print("The element is:%@ ",element)
            
            var dict = element
            dict = dict.mutableCopy() as! NSMutableDictionary
            let dataString = dict.value(forKey: kSecondaryName) as! NSString
            dict.setValue(tagCount, forKey: "tagCount")
            self.secondaryTagsArrayCopy.add(dict)
            // self.secondaryTagsArray.remove(element)
            
            //   tagCount = Int((dict.value(forKey: kTagId) as! NSString).intValue)
            //
            //            if((dict.value(forKey: kTagId)) != nil){
            //
            //                if(self.secondaryTagsArray.count > 0){
            //                    let resultPredicate = NSPredicate(format: "Id = %@", dict.value(forKey: kTagId) as! CVarArg)
            //                    let arr = self.secondaryTagsArray.filtered(using: resultPredicate)
            //                    self.secondaryTagsArray.remove(arr.first as Any)
            //                }
            //
            //            }
            ////
            //            if((dict.value(forKey: "tagCount")) != nil){
            //                if(self.secondaryTagsArray.count > 0){
            //                    let resultPredicate = NSPredicate(format: "tagCount = %@", dict.value(forKey: "tagCount") as! CVarArg)
            //                    let arr = self.secondaryTagsArray.filtered(using: resultPredicate)
            //                    self.secondaryTagsArray.remove(arr.first as Any)
            //                }
            //
            //            }
            
            //  self.secondaryTagsArray.add(dict)
            
            if let font = UIFont(name: "HelveticaNeue", size: 14)
            {
                let fontAttributes = [NSFontAttributeName: font]
                let size = (dataString as NSString).size(attributes: fontAttributes)
                width = Int(size.width + 10)
            }
            let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: width+25, height: 32))
            backgroundView.layer.cornerRadius = 16.0
            backgroundView.clipsToBounds = true
            backgroundView.backgroundColor = UIColor.blue
            let backgroundImage = UIImageView(frame: CGRect(x: 0, y: 0, width: width+25, height: 32))
            backgroundImage.image = UIImage.init(named: "btn")
            backgroundView.addSubview(backgroundImage)
            
            
            let sampleTextField =  UITextField(frame: CGRect(x: 10, y: 3, width: width, height: 25))
            sampleTextField.font = UIFont(name: "HelveticaNeue", size: 14)
            sampleTextField.textAlignment = NSTextAlignment.center
            sampleTextField.text = dataString as String
            sampleTextField.tag = tagCount
            sampleTextField.isUserInteractionEnabled = false
            sampleTextField.textColor = UIColor.white
            backgroundView.addSubview(sampleTextField)
            
            let closeButton =  UIButton(frame: CGRect(x: width+12, y: 0, width: 20, height: 20))
            closeButton.setImage(UIImage.init(named: "cross"), for: UIControlState.normal)
            closeButton.tag = tagCount
            closeButton.contentMode = .top
            closeButton.imageView?.contentMode = .scaleAspectFit
            closeButton.addTarget(self, action: #selector(CAGalleryDetailViewController.closeTapped(_:)), for: .touchUpInside)
            
            
            
            let dummyView = UIView(frame: CGRect(x: origin+5, y: 5, width: width+25, height: 52))
            dummyView.tag = tagCount
            dummyView.addSubview(backgroundView)
            if(showCloseButton){
                dummyView.addSubview(closeButton)
            }else{
                closeButton.setImage(UIImage.init(named: ""), for: UIControlState.normal)
                closeButton.removeFromSuperview()
            }
            secondaryTagScrollView.addSubview(dummyView)
            secondaryTagScrollView.contentSize = CGSize(width: origin + Int(dummyView.frame.size.width) + 20, height: 42)
            origin += Int(dummyView.frame.size.width + 15)
            
            if(showCloseButton){
                if(secondaryTagsArray.count < 3){
                    secondaryTagNameTextField.removeFromSuperview()
                    nextTextField =  UITextField(frame: CGRect(x: Int(dummyView.frame.origin.x) + Int(dummyView.frame.size.width) + 17, y: 10, width: 70, height: 25))
                    nextTextField.placeholder = "Add More"
                    nextTextField.font = UIFont(name: "HelveticaNeue", size: 14)
                    nextTextField.tag = 102
                    nextTextField.delegate = self
                    secondaryTagScrollView.addSubview(nextTextField)
                }
            }
        }
        self.collectionViewGallery.reloadData()
        
    }
    
    //MARK:- Secondary Tag Delete Action
    
    func closeTapped(_ sender: UIButton) {
        
        print(secondaryTagsArrayCopy)
        print(secondaryTagsArray)
        
        let tag: Int = sender.tag
        var index = Int()
        
        for i in 0 ..< secondaryTagsArrayCopy.count {
            print(i)
            //  let dict = preDefineArray .object(at: i-1) as! NSDictionary
            let dict = secondaryTagsArrayCopy .object(at: i) as! NSDictionary
            let tagFetched = Int(dict.value(forKey: "tagCount") as! NSNumber)
            
            if(tagFetched == tag){
                index = i
            }
        }
        secondaryTagsArrayCopy.removeObject(at: index)
        secondaryTagsArray.removeObject(at: index)
        // preDefineArray.removeObject(at: index-1)
        
        let subView = secondaryTagScrollView.subviews
        for subview in subView{
            subview.removeFromSuperview()
        }
        
        if(secondaryTagsArray.count == 0){
            secondaryTagNameTextField = CATextField()
            origin = 0
            secondaryTagScrollView.contentSize = CGSize(width:100 , height: 42)
            secondaryTagNameTextField =  CATextField(frame: CGRect(x: 5, y: 0, width: 300, height: 40))
            secondaryTagNameTextField.tag = 102
            secondaryTagNameTextField.delegate = self
            secondaryTagNameTextField.placeHolderText(withColor: "Add Secondary Tag", andColor: RGBA(17, g: 43, b: 88, a: 1))
            secondaryTagNameTextField.returnKeyType = UIReturnKeyType.done
            secondaryTagScrollView.addSubview(secondaryTagNameTextField)
        }
        
        self.createSubViews(showCloseButton: true)
    }
    
    
    //MARK Custom Delegate
    func addDelegateWithDetailsAndIsSubmit(details: NSString, isSubmit: Bool) {
        var tagMutable = NSMutableArray()
        var matchedPrimaryTag = NSDictionary()
        var primaryTagArray = NSMutableArray()
        primaryTagArray = (kUserDefaults.value(forKey: kAllPrimaryTags) as! NSArray).mutableCopy() as! NSMutableArray
        
        if((kUserDefaults.value(forKey: "savedTag")) != nil){
            let tagArrayFetched = kUserDefaults.value(forKey: "savedTag") as! NSArray
            tagMutable = tagArrayFetched.mutableCopy() as! NSMutableArray
            tagMutable = tagMutable.removeUploaded()
            
            for (index, element) in tagMutable.enumerated() {
                print("Item \(index): \(element)")
                let dict = element as! NSDictionary
                let resultPredicate = NSPredicate(format: "Prime_Name == [c]%@", (dict.value(forKey: kPrimaryName) as! String))
                let arr = primaryTagArray.filtered(using: resultPredicate)
                if(arr.count > 0){
                    print(arr)
                    matchedPrimaryTag = (arr.first as! NSDictionary).mutableCopy() as! NSMutableDictionary
                    primaryTagArray.remove(matchedPrimaryTag)
                    let imageArray = (matchedPrimaryTag.value(forKey: kPrimaryImages) as! NSArray).mutableCopy() as! NSMutableArray
                    let arr = dict.value(forKey: kPrimaryImages) as! NSArray
                    imageArray.add(arr.firstObject as Any)
                    print(matchedPrimaryTag)
                    matchedPrimaryTag .setValue(imageArray.noDuplicates(byKey: kTagImageURL), forKey: kPrimaryImages)
                    primaryTagArray.insert(matchedPrimaryTag, at: 0)
                }
                else{
                    let newTagAdded = NSMutableDictionary()
                    newTagAdded .setValue(dict .value(forKey: kPrimaryName), forKey: kPrimaryName)
                    newTagAdded .setValue(dict .value(forKey: kAmount), forKey: kTotal)
                    let imageArray = NSMutableArray()
                    let arr = dict.value(forKey: kPrimaryImages) as! NSArray
                    imageArray.add(arr.firstObject as Any)
                    newTagAdded .setValue(imageArray, forKey: kPrimaryImages)
                    primaryTagArray.insert(newTagAdded, at: 0)
                }
            }
        }
        
        let myInPrimaryInfo = NSMutableDictionary()
        myInPrimaryInfo.setValue(primaryTagArray, forKey: "primaryArray")
        NotificationCenter.default.post(name: Notification.Name("imageAddedFromCamera"), object: myInPrimaryInfo)
        NotificationCenter.default.post(name: Notification.Name("newTagAdded"), object: nil)
        if(Reachability.isConnectedToNetwork()){
            let myDelegate = UIApplication.shared.delegate as? AppDelegate
            myDelegate?.uploadImageToS3_withTags(tagMutable: tagMutable)
        }
        
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
    
    
    func doneWithNumberPad() {
        self.amountTextField.resignFirstResponder()
    }
    
    
    // MARK: -API call to get data
    
    func getItemDetails(){
        
        let paramDict : Dictionary<String, AnyObject> = [
            kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject) ,
            kPrimaryTagId :tagId as AnyObject
        ]
        var apiName = String()
        self.activityIndicatorDoc.startAnimating()
        if(isShowingGalleryData == true){
            apiName = "Customer_Api/useritemtagdetails"
           // activityIndicatorDoc.isHidden = true
        }else{
            apiName = "Document_Api/useritemtagdetails"
           // activityIndicatorDoc.isHidden = false

        }
        
        ServiceHelper.sharedInstanceHelper.createPostRequest(method: .post, showHud: true, params: paramDict, apiName:apiName) { (result, error) in
            
            if(!(error != nil)){
                if (result![kResponseCode]! as? String == "200"){
                    let resultDict:Dictionary<String, AnyObject> = result as! Dictionary
                    self.itemDetailsDictionary = (resultDict[kAPIPayload] as! NSArray).firstObject as! NSDictionary
                   // self.imageView.sd_addActivityIndicator()
                    self.bannerImageURL = self.itemDetailsDictionary.value(forKey: kTagImageURL) as! String
                    self.bannerThumbImageURL  = self.itemDetailsDictionary.value(forKey: kTagImageThumbURL) as! String
                    if(self.isShowingGalleryData == false){
                        self.docURLFetched = self.itemDetailsDictionary.value(forKey: kTagDocThumbURL) as! String
                    }
                
                  

                    
                    if let url = URL(string:self.itemDetailsDictionary.value(forKey: kTagImageURL) as! String) {
                        self.downloadImage(url: url)
                    }
                

                    if(self.isShowingGalleryData == false){
                        
                        let docURL = URL(string: self.bannerImageURL)
                        DispatchQueue.global(qos: .background).async {
                            self.writeFileToLocal(imageURLString: self.bannerImageURL as NSString)
                        }
                        
                        if(docURL?.pathExtension == ""){
                            self.imageView.sd_setImage(with: URL(string:self.itemDetailsDictionary.value(forKey: kTagImageURL) as! String ), placeholderImage: UIImage(named: "icon18"))
                            self.docWebView.isHidden = true
                            self.activityIndicatorDoc.isHidden = true
                        }
                        else  if(docURL?.pathExtension == "pdf"){
                            self.imageView.isHidden = true
                            self.loadPDFWebViewData(url: docURL!, webView: self.docWebView, placeHolderImageView:self.imageView )
                        }
                        else  if(docURL?.pathExtension == "xls" || docURL?.pathExtension == "docx" || docURL?.pathExtension == "doc"){
                            let request = URLRequest(url: docURL!,
                                                     cachePolicy:NSURLRequest.CachePolicy.returnCacheDataElseLoad,
                                                     timeoutInterval: 10.0)
                            
                            let config = URLSessionConfiguration.default
                            let session = URLSession(configuration: config)
                            self.docWebView.backgroundColor = UIColor.white
                            let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
                                if((data) != nil){
                                    self.docWebView.loadRequest(request as URLRequest)
                                    self.imageView.isHidden = true
                                }else{
                                    self.imageView.isHidden = false

                                }
                                
                            })
                            task.resume()
                        }
                        else{
                            if let docURL = docURL{
                                let request = URLRequest(url: docURL,
                                                     cachePolicy:NSURLRequest.CachePolicy.returnCacheDataElseLoad,
                                                     timeoutInterval: 10.0)
                            
                                let config = URLSessionConfiguration.default
                                let session = URLSession(configuration: config)
                            
                                let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
                                if((data) != nil){
                                    self.docWebView.loadRequest(request as URLRequest)
                                    self.imageView.isHidden = true

                                }else{
                                    self.imageView.isHidden = false
                                }
                                
                            })
                            task.resume()
                            }
                        }
                    }
                        
                    else{
                 
                        self.imageView.sd_setImage(with: URL(string:self.itemDetailsDictionary.value(forKey: kTagImageURL) as! String ), placeholderImage: UIImage(named: "icon18")) { image, error, cacheType, url in
                            self.imageIsLoaded = true
                        }
                        
                        self.docWebView.isHidden = true
                    }
                    
                    self.descriptionTextView.text = self.itemDetailsDictionary.value(forKey: kPrimaryDescription) as! String
                    
                    if(self.descriptionTextView.text == ""){
                        self.descriptionTextView.text = "Add Description"
                        self.descriptionTextView.textColor = UIColor.lightGray
                    }else{
                        self.descriptionTextView.textColor = UIColor.black
                    }
                    
                    self.amountTextField.text  = "Rs. ".appending(self.itemDetailsDictionary.value(forKey: kAmount) as! String)
                    self.secondaryTagsArray =  (self.itemDetailsDictionary.value(forKey: kSecondaryTag) as! NSArray).mutableCopy() as! NSMutableArray
                    self.primaryTagsArray = [self.itemDetailsDictionary.value(forKey: kPrimaryName) as! String]
                    self.labelLatestBrand.text = (self.itemDetailsDictionary.value(forKey: kPrimaryName) as? String)?.capitalized
                    self.cashLabel.text = (self.itemDetailsDictionary.value(forKey: kTagType) as? String)?.capitalized
                    self.cashLabel.textColor =  UIColor.white
                    self.IGST =  self.itemDetailsDictionary.value(forKey: kIGST) as! String
                    self.CGST =  self.itemDetailsDictionary.value(forKey: kCGST) as! String
                    self.SGST =  self.itemDetailsDictionary.value(forKey: kSGST) as! String
                    
                    
                    
                    if let font = UIFont(name: "Nunito-Light", size: 17)
                    {
                        let fontAttributes = [NSFontAttributeName: font]
                        let size = (self.labelLatestBrand.text! as NSString).size(attributes: fontAttributes)
                        self.labelLatestBrandWidth.constant = size.width + 30
                    }
                    
                    self.cashLabel.textColor = UIColor.black
                    self.labelLatestBrand.textColor = UIColor.black
                    
                    let tagType = (self.itemDetailsDictionary.value(forKey: kTagType)as! String).lowercased()
                    
                    if( tagType == kBankPlus){
                        self.cashLabel.backgroundColor = RGBA(33, g: 144, b: 202, a: 1)
                        self.labelLatestBrand.backgroundColor = RGBA(33, g: 144, b: 202, a: 1)
                        
                    }
                    else if(tagType == kBankMinus){
                        self.cashLabel.backgroundColor = RGBA(204, g: 232, b: 244, a: 1)
                        self.labelLatestBrand.backgroundColor = RGBA(204, g: 232, b: 244, a: 1)
                        
                    }
                    else if(tagType  == kCashPlus){
                        self.cashLabel.backgroundColor = RGBA(52, g: 211, b: 202, a: 1)
                        self.labelLatestBrand.backgroundColor = RGBA(52, g: 211, b: 202, a: 1)
                        
                    }
                    else if(tagType  == kCashMinus){
                        self.cashLabel.backgroundColor = RGBA(191, g: 240, b: 238, a: 1)
                        self.labelLatestBrand.backgroundColor = RGBA(191, g: 240, b: 238, a: 1)
                        
                    }
                    else if(tagType == kOther){
                        self.cashLabel.backgroundColor = RGBA(240, g: 244, b: 245, a: 1)
                        self.labelLatestBrand.backgroundColor = RGBA(240, g: 244, b: 245, a: 1)
                        
                    }
                    else{
                        self.cashLabel.backgroundColor = UIColor.clear
                    }
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let tagDate = dateFormatter.date(from: (self.itemDetailsDictionary.value(forKey: kTagDate) as! String))! as NSDate
                    let dateformatterToString = DateFormatter()
                    dateformatterToString.dateFormat = "dd MMM yyyy"
                    self.dateLabel.text = dateformatterToString.string(from: tagDate as Date)
                    self.createSubViews(showCloseButton: false)
                    self.createPrimaryView(showCloseButton: false)
                    
                    self.collectionViewGallery.reloadData()
                    self.tableViewGallery.reloadData()
                    self.tableViewGallerySecond.reloadData()
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
    
    
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    func downloadImage(url: URL) {
        print("Download Started")
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            self.activityIndicatorDoc.stopAnimating()
            self.activityIndicatorDoc.hidesWhenStopped = true


            DispatchQueue.main.async() {
                self.imageView.image = UIImage(data: data)
                self.imageIsLoaded = true

            }
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
    
    
    
    
    func saveItemDetails(){
        
        self.view .endEditing(true)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        let dateTag = self.dateLabel.text
        let dateTagDate = formatter.date(from: dateTag!)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string( from: (dateTagDate)!) as String
        
        let secondaryArray = NSMutableArray()
        
        for item in secondaryTagsArray{
            let json = item as! NSDictionary
            secondaryArray.add(json.value(forKey: kSecondaryName) as Any)
        }
        
        var secondaryString  = NSString()
        
        do {
            
            let jsonData = try JSONSerialization.data(withJSONObject: secondaryArray, options: JSONSerialization.WritingOptions.prettyPrinted)
            if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
                secondaryString = JSONString as NSString
            }
            
        } catch {
            //print(error.description)
        }
        
        var amountStr = self.amountTextField.text! as NSString
        amountStr  = amountStr.substring(from: 4) as NSString
        
        let paramDict : Dictionary<String, AnyObject> = [
            kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject) ,
            kPrimaryName : primaryNameString as AnyObject ,
            kSecondaryTag : secondaryString as AnyObject ,
            kAmount : amountStr as AnyObject ,
            kTagDate : dateString as AnyObject,
            kTagId : tagId as AnyObject,
            kTagDescription : self.descriptionTextView.text as AnyObject,
            kTagImageURL : bannerImageURL as AnyObject,
            kTagImageThumbURL : bannerThumbImageURL as AnyObject,
            kSGST :self.SGST as AnyObject,
            kCGST :self.CGST as AnyObject,
            kIGST :self.IGST as AnyObject,
            kTagDocThumbURL: self.docURLFetched as AnyObject
        ]
        
        
        var apiName = String()
        
        if(isShowingGalleryData == true){
            apiName = "Customer_Api/useritemedittagdetails"
        }else{
            apiName = "Document_Api/useritemedittagdetails"
        }
        
        
        
        ServiceHelper.sharedInstanceHelper.createPostRequest(method: .post, showHud: false, params: paramDict, apiName: apiName) { (result, error) in
            
            if(!(error != nil)){
                if (result![kResponseCode]! as! String == "200"){
                    print(result as Any)
                    self.saveButton.isHidden = true
                    self.editTextButton.isHidden = false
                    
                    let subView = self.secondaryTagScrollView.subviews
                    for subview in subView{
                        subview.removeFromSuperview()
                    }
                    
                    let subViewPrimary = self.primaryTagView.subviews
                    for subviews in subViewPrimary{
                        subviews.removeFromSuperview()
                    }
                    self.primaryTagsArray.removeAllObjects()
                    self.primaryTagsArray.add(self.primaryNameString)
                    self.createSubViews(showCloseButton: false)
                    self.createPrimaryView(showCloseButton: false)
                    self.collectionViewGallery.reloadData()
                    
                }
                else {
                    presentAlert(kZoddl, msgStr: result![kResponseMessage]! as? String, controller: self)
                }
                
            } else {
                presentAlert("", msgStr: error?.localizedDescription, controller: self)
            }
        }
    }
    
    //MARK: - Open date picker
    
    @IBAction func changeDate_Clicked(_ sender: Any) {
        
        let currentDate = Date()
        var dateComponents = DateComponents()
        dateComponents.year = -100
        let minDate = Calendar.current.date(byAdding: dateComponents, to: currentDate)
        
        DatePickerDialog().show("", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", minimumDate: minDate, maximumDate: currentDate, datePickerMode: .date) { (date) in
            if let dt = date {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MMM yyyy"
                self.dateLabel.text =  dateFormatter.string( from: (dt))
            }
        }
    }
    
    
    
    //MARK: -Save Image
    
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
        
    }
    
    //MARK: - Textfield Delegates
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        
        if (textField.textInputMode?.primaryLanguage == "emoji") || !((textField.textInputMode?.primaryLanguage) != nil)
        {
            return false
        }
        
        var str:NSString = textField.text! as NSString
        str = str.replacingCharacters(in: range, with: string) as NSString
        
        if(textField == amountTextField){
            if str.length > 9 {
                return false
            }
            if str.length < 4 {
                return false
            }
        }
        
        switch textField.tag
        {
            
        case 101:
            dropDownTableview.frame =  CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 0, height: 0))
            let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string) as String
            currentFieldSelected = kPrimary as NSString
            createDropDown(inputTextField: textField, newString: newString as NSString, currentSearch:currentFieldSelected )
            
            if str.length > 30 {
                return false
            }
            
        case 102:
            dropDownTableview.frame =  CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 0, height: 0))
            let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
            currentFieldSelected = kSecondary as NSString
            createDropDown(inputTextField: textField, newString: newString as NSString, currentSearch:currentFieldSelected )
            
            if newString.length > 30 {
                return false
            }
            
            break
            
        case 1000:
            SGST = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
            break
        case 1001:
            CGST = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
            break
        case 1002:
            IGST = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
            break
            
        default:
            break
        }
        return true
    }
    
    
    
    
    //MARK: - Create Secondary View
    
    func createSecondaryView (newString : NSString , string : NSString){
        
        if( newString.length >= 0  && string == " "){
            tagCount = tagCount + 1
            var width = Int ()
            if let font = UIFont(name: "HelveticaNeue", size: 14)
            {
                let fontAttributes = [NSFontAttributeName: font]
                let size = newString.size(attributes: fontAttributes)
                width = Int(size.width + 10)
            }
            let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: width+25, height: 32))
            backgroundView.layer.cornerRadius = 16.0
            backgroundView.clipsToBounds = true
            backgroundView.backgroundColor = UIColor.blue
            let backgroundImage = UIImageView(frame: CGRect(x: 0, y: 0, width: width+25, height: 32))
            backgroundImage.image = UIImage.init(named: "btn")
            backgroundView.addSubview(backgroundImage)
            
            let sampleTextField =  UITextField(frame: CGRect(x: 10, y: 3, width: width, height: 25))
            sampleTextField.font = UIFont(name: "HelveticaNeue", size: 14)
            sampleTextField.textAlignment = NSTextAlignment.center
            sampleTextField.text = newString as String
            sampleTextField.tag = tagCount
            sampleTextField.isUserInteractionEnabled = false
            sampleTextField.textColor = UIColor.white
            backgroundView.addSubview(sampleTextField)
            
            let closeButton =  UIButton(frame: CGRect(x: width+12, y: 0, width: 20, height: 20))
            closeButton.setImage(UIImage.init(named: "cross"), for: UIControlState.normal)
            closeButton.tag = tagCount
            closeButton.contentMode = .top
            closeButton.imageView?.contentMode = .scaleAspectFit
            closeButton.addTarget(self, action: #selector(CAAddTagPopUpViewController.closeTapped(_:)), for: .touchUpInside)
            
            let dummyView = UIView(frame: CGRect(x: origin, y: 5, width: width+25, height: 52))
            dummyView.tag = tagCount
            dummyView.addSubview(backgroundView)
            dummyView.addSubview(closeButton)
            
            secondaryTagScrollView.contentSize = CGSize(width: origin + Int(dummyView.frame.size.width) + 20, height: 42)
            
            let dict = NSMutableDictionary()
            dict .setValue(tagCount, forKey: "tagCount")
            dict .setValue(newString, forKey: kSecondaryName)
            preDefineArray.add(dict)
            secondaryTagsArrayCopy.add(dict)
            secondaryTagsArray.add(dict)
            
            origin += Int(dummyView.frame.size.width + 15)
            
            secondaryTagScrollView.addSubview(dummyView)
            
            if(secondaryTagsArray.count < 3){
                secondaryTagNameTextField.removeFromSuperview()
                nextTextField =  UITextField(frame: CGRect(x: Int(dummyView.frame.origin.x) + Int(dummyView.frame.size.width) + 15, y: 10, width: 70, height: 25))
                nextTextField.placeholder = "Add More"
                nextTextField.font = UIFont(name: "HelveticaNeue", size: 14)
                nextTextField.tag = 102
                nextTextField.delegate = self
                nextTextField.returnKeyType = UIReturnKeyType.done
                nextTextField.becomeFirstResponder()
                secondaryTagScrollView.addSubview(nextTextField)
            }
            else{
                nextTextField.removeFromSuperview()
            }
            self.collectionViewGallery.reloadData()
        }
        
    }
    
    
    //MARK: - Create Dropdown View
    
    func createDropDown (inputTextField : UITextField, newString : NSString , currentSearch : NSString){
        
        dropDownTableview.frame =  CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 0, height: 0))
        dropDownTableview.scrollsToTop = true
        var cellHeight = CGFloat()
        var indexPath = IndexPath()
        
        if(currentSearch as String == kPrimary){
            let searchPredicate = NSPredicate(format: "Prime_Name contains[cd] %@", newString)
            let filterArray = allPrimaryTags.filtered(using: searchPredicate)
            allPrimaryTags = NSMutableArray(array: filterArray)
            indexPath = IndexPath(row: 0, section: 0)
            if(newString == ""){
                allPrimaryTags = copyPrimaryTagArray
            }
            cellHeight = CGFloat(allPrimaryTags.count * 32)
        }else{
            let searchPredicate = NSPredicate(format: "Secondary_Name contains[cd] %@", newString)
            let filterArray = allSecondaryTags.filtered(using: searchPredicate)
            allSecondaryTags = NSMutableArray(array: filterArray)
            indexPath = IndexPath(row: 1, section: 0)
            
            if(newString == ""){
                allSecondaryTags = copySecondaryTagArray
            }
            cellHeight = CGFloat(allSecondaryTags.count * 32)
        }
        
        
        
        let rectOfCell = tableViewGallerySecond.rectForRow(at: indexPath)
        let rectOfCellInSuperview = tableViewGallerySecond.convert(rectOfCell, to: tableViewGallerySecond.superview)
        
        dropDownTableview.frame =  CGRect(origin: CGPoint(x: 5,y :rectOfCellInSuperview.origin.y+45), size: CGSize(width: 300, height: cellHeight))
        
        if(cellHeight > 150){
            dropDownTableview.frame =  CGRect(origin: CGPoint(x: 5,y :rectOfCellInSuperview.origin.y+45), size: CGSize(width: 300, height: 150))
        }
        
        dropDownTableview.reloadData()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == secondaryTagScrollView {
            if scrollView.contentOffset.x>0 {
                scrollView.contentOffset.x = 0
            }
        }
    }
    
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    
    
    
    
    
    
    // MARK: - Open Filter View
    @IBAction func openFilter_Clicked(_ sender: Any) {
        
        let fileUrl = NSURL(string: bannerImageURL)
        if(self.isShowingGalleryData == false ){
            
            quickLookController.dataSource = self
            quickLookController.delegate = self
            
            if(documentIsLoaded){
                if QLPreviewController.canPreview((fileUrl)!) {
                    quickLookController.currentPreviewItemIndex = 0
                    present(quickLookController, animated: true, completion: nil)
                }
            }else{
                presentAlert(kZoddl, msgStr: "Downloading document. Please wait", controller: self)
            }
            
            
        }
        else{
            if(imageIsLoaded){
                let filterVC: FilterViewCotroller = FilterViewCotroller(nibName:"FilterViewCotroller", bundle: nil)
                self.tabBarController?.tabBar.isHidden = true
                filterVC.filterDelegate = self
                filterVC.imageToEdit = self.imageView.image!
                filterVC.modalPresentationStyle = .overFullScreen
                filterVC.modalTransitionStyle = .crossDissolve
                self.present(filterVC, animated: true, completion: nil)
            }
            
        }
        
    }
    
    
    func getFilterData(image: UIImage) {
        
        self.imageView.image = image
        DispatchQueue.global(qos: .background).async {
            print("Uplaoding in background")
            
            ServiceHelper.sharedInstanceHelper.uploadImageToS3(image: image, fileName: "", completion: { (result, error) in
                hideHud()
                if(error == nil){
                    self.bannerImageURL = kImageBaseURL.appending((result?.value(forKey: "key")) as! String)
                    
                    ServiceHelper.sharedInstanceHelper.uploadThumbImageToS3(image: image, fileName: "", completion: { (result, error) in
                        hideHud()
                        if(error == nil){
                            self.bannerThumbImageURL = kImageBaseURL.appending((result?.value(forKey: "key")) as! String)
                            self.saveItemDetails()
                        }
                    });
                    
                }
            });
        }
        self.tableViewGallery.reloadData()
    }
    
    
    
    
    
    func writeFileToLocal(imageURLString : NSString){
        
        if let imageURL = URL(string: imageURLString as String){
        let data = NSData(contentsOf: imageURL)
        do {
            // Get the documents directory
            let documentsDirectoryURL = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            // Give the file a name and append it to the file path
            let fileName = "Document." + imageURL.pathExtension
            fileURLLocalImage = documentsDirectoryURL.appendingPathComponent(fileName)
            // Write the pdf to disk
            try data?.write(to: fileURLLocalImage!, options: .atomic)
            documentIsLoaded = true
            
        } catch {
            // cant find the url resource
        }
        }else{
            activityIndicatorDoc.stopAnimating()
            activityIndicatorDoc.isHidden = true
        }
    }
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return fileURLLocalImage! as QLPreviewItem
    }
    
    func previewControllerWillDismiss(_ controller: QLPreviewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicatorDoc.stopAnimating()
        activityIndicatorDoc.hidesWhenStopped = true
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
    
    
    
    
}


