//
//  CAAddTagPopUpViewController.swift
//  ClickAccountingApp
//
//  Created by Sunil Datt Joshi on 03/07/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit
import CoreData


protocol AddTagDelegate: class {
    func addDelegateWithDetailsAndIsSubmit(details: NSString, isSubmit:Bool)
}

protocol CancelAddTagDelegate: class {
    func cancelAddDelegateWithDetailsAndIsSubmit(details: NSString, isSubmit:Bool)
}

class CAAddTagPopUpViewController: UIViewController,UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var addTagTableView: UITableView!
    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var addTagView: UIView!
    @IBOutlet var doprDownTableview: UITableView!
    @IBOutlet var tagTypeLabel: UILabel!
    var tagType : String  = ""
    var imageURL : String  = ""
    
    var docExtension : String  = ""
    var docPathLocal : String  = ""

    var currentFieldSelected : String  = ""
    
    var isToCaptureImage: Bool = false
    var isManualTag: Bool = false
    
    var isDocumentType: Bool = false
    
    
    var primaryTagNameTextField = CATextField()
    
    var secondaryTagNameTextField = CATextField()
    var nextTextField = UITextField()
    var lastTextField = UITextField()
    
    
    var amountTextField = CATextField()
    var dateTextField = CATextField()
    var descriptionTextField = CATextField()
    var cameraInfo = CACameraTagInfo()
    weak var addTagDelegate: AddTagDelegate?
    weak var canceladdTagDelegate: CancelAddTagDelegate?
    
    var secondaryTagScrollView = UIScrollView()
    var origin = Int ()
    var tagCount = Int()
    
    
    var primaryTagArray = NSMutableArray()
    var secondaryTagArray = NSMutableArray()
    
    var copyPrimaryTagArray = NSMutableArray()
    var copySecondaryTagArray = NSMutableArray()
    
    
    var secondaryTagSelected = NSMutableArray()
    var navigationTitleString: String = ""
    
    var bpButton = UIButton()
    var bmButton = UIButton()
    var cmButton = UIButton()
    var cpButton = UIButton()
    var otButton = UIButton()
    
    var instanceOfDBManager = DbManager()
    
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tagCount = 2000
        
        nextTextField.delegate = self
        doprDownTableview.dataSource = self
        doprDownTableview.delegate = self
        doprDownTableview.allowsSelection = true
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        doprDownTableview.tableFooterView = customView
        
        doprDownTableview.frame =  CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 0, height: 0))
        doprDownTableview.layer.borderWidth = 0.5
        let myColor : UIColor = UIColor.lightGray
        doprDownTableview.layer.borderColor = myColor.cgColor
        
        
        primaryTagArray = (kUserDefaults.value(forKey: kAllPrimaryTags) as! NSArray).mutableCopy() as! NSMutableArray
        secondaryTagArray = (kUserDefaults.value(forKey: kAllSecondaryTags) as! NSArray).mutableCopy()  as! NSMutableArray
        
        
        
        let dummyArray = NSMutableArray()
        for dict in self.secondaryTagArray {
            if(!dummyArray.contains(dict)){
                dummyArray.add(dict)
            }
        }
        secondaryTagArray = dummyArray
        
        copyPrimaryTagArray = primaryTagArray
        copySecondaryTagArray = secondaryTagArray
        origin = 0
        self.initialMethod()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Helper Methods
    func initialMethod() {
        addTagTableView.delegate = self
        addTagTableView.dataSource = self
        navTitleLabel.text = navigationTitleString
        self.addTagView.layer.cornerRadius = 5
        
        dateTextField =  CATextField(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
        primaryTagNameTextField =  CATextField(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
        secondaryTagNameTextField =  CATextField(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
        amountTextField =  CATextField(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
        descriptionTextField =  CATextField(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
        secondaryTagScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
        secondaryTagScrollView.showsVerticalScrollIndicator = false
        secondaryTagScrollView.showsHorizontalScrollIndicator = false
        secondaryTagScrollView.bounces = false
        secondaryTagScrollView.addSubview(secondaryTagNameTextField)
        amountTextField.inputAccessoryView = addToolBarOnTextfield(textField: self.amountTextField, target: self)
        amountTextField.keyboardType = UIKeyboardType.numberPad
        secondaryTagNameTextField.returnKeyType = UIReturnKeyType.done
        primaryTagNameTextField.returnKeyType = UIReturnKeyType.done
        
        
        self.addTagTableView!.register(UINib(nibName: "CAAddTagTableViewCell", bundle: nil), forCellReuseIdentifier: "CAAddTagTableViewCell")
        
        primaryTagNameTextField.tag = 101
        secondaryTagNameTextField.tag = 102
        amountTextField.tag = 103
        dateTextField.tag = 104
        descriptionTextField.tag = 105
        
        dateTextField.delegate = self
        primaryTagNameTextField.delegate = self
        secondaryTagNameTextField.delegate = self
        amountTextField.delegate = self
        descriptionTextField.delegate = self
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.cameraInfo.dateString  = formatter.string(from: date)
        self.dateTextField.text = self.cameraInfo.dateString
        
        if(isToCaptureImage == true){
            tagTypeLabel.text = tagType.capitalized
            
            if(tagType == kBankPlus){
                tagTypeLabel.backgroundColor = RGBA(33, g: 144, b: 202, a: 1)
                
            }
            else if(tagType  == kBankMinus){
                tagTypeLabel.backgroundColor = RGBA(204, g: 232, b: 244, a: 1)
                
            }
            else if(tagType == kCashPlus){
                tagTypeLabel.backgroundColor = RGBA(52, g: 211, b: 202, a: 1)
                
            }
            else if(tagType == kCashMinus){
                tagTypeLabel.backgroundColor = RGBA(191, g: 240, b: 238, a: 1)
                
            }
            else if(tagType == kOther){
                tagTypeLabel.backgroundColor = RGBA(240, g: 244, b: 245, a: 1)
                
            }
            else{
                self.tagTypeLabel.backgroundColor = UIColor.clear
            }
            
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    //MARK: - UITableViewDataSouce Functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count = Int()
        
        if(tableView.tag == 344){
            
            if(currentFieldSelected == "Secondary"){
                count =  secondaryTagArray.count
            }else{
                count =  primaryTagArray.count
            }
        }
        else{
            count = 5
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var  cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: nil)
        
        if(tableView.tag == 344){
            cell.contentView.backgroundColor = RGBA(245.0, g: 245.0, b: 245.0, a: 1.0)
            cell.textLabel?.font = UIFont.init(name: "Calibri", size: 15.0)
            
            if(currentFieldSelected == "Secondary"){
                if(secondaryTagArray.count > 0){
                    cell.textLabel?.text = (secondaryTagArray.value(forKey: kSecondaryName) as AnyObject).object(at: indexPath.row) as? String
                }
            }
            else{
                if(primaryTagArray.count > 0){
                    cell.textLabel?.text = (primaryTagArray.value(forKey: kPrimaryName) as AnyObject).object(at: indexPath.row) as? String
                }
                
            }
            return cell
        }
        else{
            
            let addCell = tableView .dequeueReusableCell(withIdentifier: "CAAddTagTableViewCell") as! CAAddTagTableViewCell
            
            let seperatorView = UIView(frame: CGRect(x: 0, y: addCell.frame.size.height - 1.5, width: tableView.frame.size.width, height: 1.5))
            addCell.contentView .addSubview(seperatorView)
            
            if(indexPath.row == 0){
                //RGBA(17, g: 43, b: 88, a: 1)
                
                primaryTagNameTextField.placeHolderText(withColor: "Add Primary Tag Like Petrol,Income", andColor: RGBA(199, g: 199, b: 205, a: 1))
                addCell.contentView .addSubview(primaryTagNameTextField)
            }
            if(indexPath.row == 1){
                secondaryTagNameTextField.placeHolderText(withColor: "Add Secondary Tag Like Office,Personal", andColor: RGBA(199, g: 199, b: 205, a: 1))
                //   addCell.contentView .addSubview(secondaryTagNameTextField).
                addCell.contentView .addSubview(secondaryTagScrollView)
            }
            if(indexPath.row == 2){
                amountTextField.placeHolderText(withColor: "Amount", andColor: RGBA(199, g: 199, b: 205, a: 1))
                addCell.contentView .addSubview(amountTextField)
            }
            if(indexPath.row == 3){
                dateTextField.placeHolderText(withColor: "Date", andColor: RGBA(199, g: 199, b: 205, a: 1))
                addCell.contentView .addSubview(dateTextField)
                
            }
            if(indexPath.row == 4){
                descriptionTextField.placeHolderText(withColor: "Description Like My receipt from Mr Joe", andColor: RGBA(199, g: 199, b: 205, a: 1))
                addCell.contentView .addSubview(descriptionTextField)
            }
            cell =  addCell;
        }
        
        return cell
    }
    
    //MARK: UITableViewDelegate Functions
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var height:CGFloat
        if(tableView ==  doprDownTableview){
            height = 42
        }else{
            height = 52
            
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var height:CGFloat
        
        if isToCaptureImage == true || tableView.tag == 344{
            height = 0
        }else{
            height = 120
        }
        return height
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var headerView = UIView()
        
        if(tableView.tag == 344){
            headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 0))
        }
            
        else{
            headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 120))
            
            bpButton = UIButton(frame: CGRect(x: 10, y: 10, width: 80, height: 30))
            bpButton.backgroundColor = RGBA(33, g: 144, b: 202, a: 1)
            bpButton.setTitle("Bank +",for: .normal)
            bpButton.titleLabel?.font =  UIFont(name: "HelveticaNeue", size: 14.0)
            bpButton.layer.cornerRadius = 5.0
            bpButton.setImage(UIImage.init(named: "icon9"), for: .selected)
            bpButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
            bpButton.imageEdgeInsets = UIEdgeInsetsMake(0, 100, 0, 1)
            
            bmButton = UIButton(frame: CGRect(x: 10, y: 70, width: 80, height: 30))
            bmButton.backgroundColor = RGBA(204, g: 232, b: 244, a: 1)
            bmButton.setTitleColor( RGBA(33, g: 144, b: 202, a: 1), for: .normal)
            bmButton.setTitle("Bank -",for: .normal)
            bmButton.titleLabel?.font =  UIFont(name: "HelveticaNeue", size: 14.0)
            bmButton.layer.cornerRadius = 5.0
            bmButton.setImage(UIImage.init(named: "icon9"), for: .selected)
            bmButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
            bmButton.imageEdgeInsets = UIEdgeInsetsMake(0, 100, 0, 1)
            
            cpButton = UIButton(frame: CGRect(x: tableView.frame.size.width - 100, y: 10, width: 80, height: 30))
            cpButton.backgroundColor = RGBA(52, g: 211, b: 202, a: 1)
            cpButton.setTitle("Cash +",for: .normal)
            cpButton.titleLabel?.font =  UIFont(name: "HelveticaNeue", size: 14.0)
            cpButton.layer.cornerRadius = 5.0
            cpButton.setImage(UIImage.init(named: "icon9"), for: .selected)
            cpButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
            cpButton.imageEdgeInsets = UIEdgeInsetsMake(0, 100, 0, 1)
            
            cmButton = UIButton(frame: CGRect(x: tableView.frame.size.width - 100, y: 70, width: 80, height: 30))
            cmButton.backgroundColor = RGBA(191, g: 240, b: 238, a: 1)
            cmButton.setTitleColor(RGBA(52, g: 211, b: 202, a: 1), for: .normal)
            cmButton.setTitle("Cash -",for: .normal)
            cmButton.titleLabel?.font =  UIFont(name: "HelveticaNeue", size: 14.0)
            cmButton.layer.cornerRadius = 5.0
            cmButton.setImage(UIImage.init(named: "icon9"), for: .selected)
            cmButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
            cmButton.imageEdgeInsets = UIEdgeInsetsMake(0, 100, 0, 1)
            
            otButton = UIButton(frame: CGRect(x: tableView.frame.size.width/2-40, y: 40, width: 80, height: 30))
            otButton.backgroundColor = RGBA(240, g: 244, b: 245, a: 1)
            otButton.setTitle("Other",for: .normal)
            otButton.titleLabel?.font =  UIFont(name: "HelveticaNeue", size: 14.0)
            otButton.layer.cornerRadius = 5.0
            otButton.setImage(UIImage.init(named: "icon9"), for: .selected)
            otButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
            otButton.setTitleColor(UIColor.gray, for: .normal)
            otButton.imageEdgeInsets = UIEdgeInsetsMake(0, 100, 0, 1)
            
            headerView .addSubview(bpButton)
            headerView .addSubview(bmButton)
            headerView .addSubview(cpButton)
            headerView .addSubview(cmButton)
            headerView .addSubview(otButton)
            
            bpButton.addTarget(self, action: #selector(CAAddTagPopUpViewController.tagType_Clicked), for:.touchUpInside)
            bmButton.addTarget(self, action: #selector(CAAddTagPopUpViewController.tagType_Clicked), for:.touchUpInside)
            cpButton.addTarget(self, action: #selector(CAAddTagPopUpViewController.tagType_Clicked), for:.touchUpInside)
            cmButton.addTarget(self, action: #selector(CAAddTagPopUpViewController.tagType_Clicked), for:.touchUpInside)
            otButton.addTarget(self, action: #selector(CAAddTagPopUpViewController.tagType_Clicked), for:.touchUpInside)
            
            bpButton.tag = 131
            bmButton.tag = 132
            cpButton.tag = 133
            cmButton.tag = 134
            otButton.tag = 135
        }
        return headerView
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        var footerview = UIView()
        
        if(tableView.tag == 344){
            footerview = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 0))
            
        }else{
            footerview = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 70))
            
            let image = UIImage(named: "btn") as UIImage?
            let image2 = UIImage(named: "btn2") as UIImage?
            
            let submitButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 210, y: 10, width: 135, height: 37))
            submitButton.setBackgroundImage(image, for: .normal)
            submitButton.setTitle("Submit",for: .normal)
            submitButton.titleLabel?.font =  UIFont(name: "HelveticaNeue", size: 14.0)
            submitButton.layer.cornerRadius = 5.0
            submitButton.addTarget(self, action: #selector(CAAddTagPopUpViewController.submitClicked), for:.touchUpInside)
            
            let cancelButton = UIButton(frame: CGRect(x: 10, y: 10, width: 135, height: 37))
            cancelButton.setBackgroundImage(image2, for: .normal)
            cancelButton.setTitle("Cancel",for: .normal)
            cancelButton.titleLabel?.font =  UIFont(name: "HelveticaNeue", size: 14.0)
            cancelButton.layer.cornerRadius = 5.0
            cancelButton.addTarget(self, action: #selector(CAAddTagPopUpViewController.cancelClicked), for:.touchUpInside)
            
            footerview .addSubview(submitButton)
            footerview .addSubview(cancelButton)
        }
        
        
        return footerview
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        var height:CGFloat
        
        if(tableView.tag == 344){
            height = CGFloat.leastNormalMagnitude
        }
        else if isToCaptureImage == true{
            height = 50
        }else{
            height = 70
            
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.tag == 344{
            
            doprDownTableview.frame =  CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 0, height: 0))
            
            if(currentFieldSelected == "Primary"){
                primaryTagNameTextField.text = (primaryTagArray.value(forKey: kPrimaryName) as AnyObject).object(at: indexPath.row) as? String
            }
                
            else{
                
                tagCount = tagCount + 1
                var width = Int ()
                if let font = UIFont(name: "HelveticaNeue", size: 14)
                {
                    let fontAttributes = [NSFontAttributeName: font]
                    let size = ((secondaryTagArray.value(forKey: kSecondaryName) as AnyObject).object(at: indexPath.row) as? String)?.size(attributes: fontAttributes)
                    width = Int((size?.width)! + 10)
                }
                let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: width+25, height: 32))
                backgroundView.layer.cornerRadius = 16.0
                backgroundView.clipsToBounds = true
                backgroundView.backgroundColor = UIColor.blue
                let backgroundImage = UIImageView(frame: CGRect(x: 0, y: 0, width: width+25, height: 32))
                backgroundImage.image = UIImage.init(named: "btn")
                backgroundView.addSubview(backgroundImage)
                
                
                let sampleTextField =  UITextField(frame: CGRect(x: 12, y: 4, width: width, height: 25))
                sampleTextField.font = UIFont(name: "HelveticaNeue", size: 14)
                sampleTextField.textAlignment = NSTextAlignment.center
                sampleTextField.text = ((secondaryTagArray.value(forKey: kSecondaryName) as AnyObject).object(at: indexPath.row) as? String)
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
                
                let dummyView = UIView(frame: CGRect(x: origin, y: 10, width: width+25, height: 52))
                dummyView.tag = tagCount
                dummyView.addSubview(backgroundView)
                dummyView.addSubview(closeButton)
                
                secondaryTagScrollView.contentSize = CGSize(width: origin + Int(dummyView.frame.size.width) + 20, height: 52)
                
                let dict = NSMutableDictionary()
                dict .setValue(tagCount, forKey: "tagCount")
                dict .setValue(((secondaryTagArray.value(forKey: kSecondaryName) as AnyObject).object(at: indexPath.row) as? String), forKey: "data")
                secondaryTagSelected.add(dict)
                
                origin += Int(dummyView.frame.size.width + 15)
                
                secondaryTagScrollView.addSubview(dummyView)
                
                if(secondaryTagSelected.count < 3){
                    secondaryTagNameTextField.removeFromSuperview()
                    nextTextField =  UITextField(frame: CGRect(x: Int(dummyView.frame.origin.x) + Int(dummyView.frame.size.width) + 15, y: 10, width: 90, height: 25))
                    nextTextField.placeholder = "Add More"
                    nextTextField.font = UIFont(name: "HelveticaNeue", size: 14)
                    nextTextField.tag = 102
                    nextTextField.delegate = self
                    secondaryTagScrollView.addSubview(nextTextField)
                }else{
                    nextTextField.removeFromSuperview()
                }
                
                if(secondaryTagSelected.count == 3){
                    
                    lastTextField =  UITextField(frame: CGRect(x: Int(dummyView.frame.origin.x) + Int(dummyView.frame.size.width) + 15, y: 10, width: 70, height: 25))
                    lastTextField.becomeFirstResponder()
                    lastTextField.tag = 106
                    lastTextField.delegate = self
                    secondaryTagScrollView.addSubview(lastTextField)
                }
                
                DispatchQueue.main.async {
                    let secondaryIndexPath = IndexPath(item: 1, section: 0)
                    self.addTagTableView.reloadRows(at: [secondaryIndexPath], with: .none)
                }
                
            }
            
        }
    }
    
    func takeScreenshot() -> String{
        
        UIGraphicsBeginImageContext(view.frame.size)
        addTagView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let fileManager = FileManager.default
        var uuid = CFUUIDCreateString(nil, CFUUIDCreate(nil)) as String
        uuid = uuid + ".jpg"
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(uuid)
        let imageData = UIImageJPEGRepresentation(image!, 0.5)
        fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
        fileManager.fileExists(atPath: paths)
        return uuid
    }
    
    
    func submitClicked(){
        
        self.view.endEditing(true)
        
        var primaryName = String()
        if (primaryTagNameTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            primaryName = "Untagged"
        }
        else{
            primaryName = primaryTagNameTextField.text!
        }
        
        let secondaryArray = NSMutableArray()
        
        for item in secondaryTagSelected{
            let json = item as! NSDictionary
            let itemDict  = NSMutableDictionary()
            itemDict .setValue(json.value(forKey: "data"), forKey: kSecondaryName)
            secondaryArray.add(itemDict)
        }
        
        if(isToCaptureImage == false){
            if(tagType == ""){
                presentAlert(kZoddl, msgStr: "Please select tag type.", controller: self)
                return
            }else{
                if(isManualTag){
                    imageURL = self.takeScreenshot()
                }
            }
        }
        else{
            self.cameraInfo.tagType  = self.tagType
        }
        
        
        
        if (isDocumentType == true)
        {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let entityDescription =
                NSEntityDescription.entity(forEntityName: "Document",
                                           in: appDelegate.persistentContainer.viewContext)
            let documentEntry = Document(entity: entityDescription!,
                                         insertInto: appDelegate.persistentContainer.viewContext)
            
            documentEntry.primaryName = primaryName
            documentEntry.createdTime = NSDate().timeIntervalSince1970
            documentEntry.amount = amountTextField.text
            documentEntry.tagDate = dateTextField.text
            documentEntry.tagStatus = 6
            documentEntry.tagType = tagType
            documentEntry.tagDescription = descriptionTextField.text
            documentEntry.isUploaded = 0
            documentEntry.docPath = docPathLocal
            documentEntry.docType = docExtension
            documentEntry.docImageURL = imageURL
            
            if(isManualTag == true){
                documentEntry.docPath = imageURL
            }

            let appDelegateShared : AppDelegate = UIApplication.shared.delegate as! AppDelegate
            documentEntry.secondaryTag = appDelegateShared.createJsonString(secondaryArr: secondaryArray) as String
            print(documentEntry.secondaryTag as Any)
            appDelegate.saveContext()
            appDelegateShared.uploadDocumentImageToS3()
            self.addTagDelegate?.addDelegateWithDetailsAndIsSubmit(details: "yes", isSubmit: true)
        }
            
        else
        {
            let paramDict : Dictionary<String, AnyObject> = [
                kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject) ,
                kPrimaryName : primaryName as AnyObject ,
                kSecondaryTag : secondaryArray as AnyObject ,
                kAmount : amountTextField.text as AnyObject ,
                kTagDate : dateTextField.text as AnyObject,
                kTagStatus : "6" as AnyObject,
                kIsUploaded : "0" as AnyObject,
                kTagType : tagType as AnyObject,
                kTagDescription : descriptionTextField.text as AnyObject,
                kTagImageURL : imageURL as String as AnyObject,
                kCurrentTimestamp :NSDate().timeIntervalSince1970 as AnyObject
            ]
            
            var tagMutable = NSMutableArray()
            
            if((kUserDefaults.value(forKey: kLocallySavedTag)) != nil){
                let localTagTemp = kUserDefaults.value(forKey: kLocallySavedTag) as! Array<Any>
                for local in localTagTemp
                {
                    let localTag = local as! Dictionary<String, AnyObject>
                    
                    if localTag[kIsUploaded] as! String == "0"
                    {
                        tagMutable.add(localTag)
                    }
                }
                
            }
            else{
                tagMutable = NSMutableArray()
            }
            let taggAdded = NSMutableDictionary()
            taggAdded .setValue(primaryName, forKey: kPrimaryName)
            taggAdded .setValue(amountTextField.text , forKey: kAmount)
            taggAdded .setValue("0", forKey: kIsUploaded)
            taggAdded.setValue(paramDict[kCurrentTimestamp], forKey: kCurrentTimestamp)
            
            let imageArray = NSMutableArray()
            imageArray.add(paramDict)
            taggAdded.setValue(imageArray, forKey: kPrimaryImages)
            tagMutable.add(taggAdded)
            print("before removing uploaded local tags count :\(tagMutable.count)")
            tagMutable = tagMutable.removeUploaded()
            kUserDefaults.set(tagMutable, forKey: kLocallySavedTag)
            kUserDefaults.synchronize()
            print("after local tags count :\(tagMutable.count)")
            self.addTagDelegate?.addDelegateWithDetailsAndIsSubmit(details: "yes", isSubmit: true)
        }
        
        
        self.dismiss(animated: true) {
            presentAlert(kZoddl, msgStr:"Tag Added Successfully", controller: self)
        }
        
    }
    
    
    func cancelClicked(){
        self.dismiss(animated: true) {
            self.canceladdTagDelegate?.cancelAddDelegateWithDetailsAndIsSubmit(details: "Yes", isSubmit: true)
        }
    }
    
    
    //MARK: UITextField Delegate methods
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if (textField.textInputMode?.primaryLanguage == "emoji") || !((textField.textInputMode?.primaryLanguage) != nil)
        {
            return false
        }
        var str:NSString = textField.text! as NSString
        str = str.replacingCharacters(in: range, with: string) as NSString
        switch textField.tag
        {
        case 101:
            doprDownTableview.frame =  CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 0, height: 0))
            
            currentFieldSelected = "Primary"
            doprDownTableview.scrollsToTop = true
            var cellHeight = CGFloat()
            let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string) as String
            let indexPath = IndexPath(row: 0, section: 0)
            let rect = self.addTagTableView.rectForRow(at:indexPath)
            let searchPredicate = NSPredicate(format: "Prime_Name contains[cd] %@", newString)
            let filterArray = primaryTagArray.filtered(using: searchPredicate)
            primaryTagArray = NSMutableArray(array: filterArray)
            if(newString == ""){
                primaryTagArray = copyPrimaryTagArray
            }
            
            cellHeight = CGFloat(primaryTagArray.count * 52)
            doprDownTableview.frame =  CGRect(origin: CGPoint(x: 0,y :rect.origin.y + 70), size: CGSize(width: rect.size.width + 10, height: cellHeight))
            addTagTableView.isScrollEnabled = false
            
            if(cellHeight > 208){
                doprDownTableview.frame =  CGRect(origin: CGPoint(x: 0,y :rect.origin.y + 70), size: CGSize(width: rect.size.width + 10, height: 208))
                addTagTableView.isScrollEnabled = false
                
            }
            doprDownTableview.reloadData()
            
            if str.length > 30 {
                return false
            }
            break
            
        case 102:
            let newString = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
            var indexPath = IndexPath(row: 1, section: 0)
            let rect = self.addTagTableView.rectForRow(at:indexPath)
            doprDownTableview.frame =  CGRect(origin: CGPoint(x: 0,y :rect.origin.y + 80), size: CGSize(width: 0, height: 0))
            currentFieldSelected = "Secondary"
            doprDownTableview.reloadData()
            doprDownTableview.scrollsToTop = true
            var cellHeight = CGFloat()
            let searchPredicate = NSPredicate(format: "Secondary_Name contains[cd] %@", newString)
            let filterArray = secondaryTagArray.filtered(using: searchPredicate)
            secondaryTagArray = NSMutableArray(array: filterArray)
            if(newString == ""){
                secondaryTagArray = copySecondaryTagArray
                indexPath = IndexPath(row: 2, section: 0)
            }
            cellHeight = CGFloat(secondaryTagArray.count * 52)
            
            if(isToCaptureImage == true){
                doprDownTableview.frame =  CGRect(origin: CGPoint(x: 0,y :rect.origin.y + 80), size: CGSize(width: rect.size.width + 10, height: cellHeight))
                
            }else{
                doprDownTableview.frame =  CGRect(origin: CGPoint(x: 0,y :rect.origin.y + 40), size: CGSize(width: rect.size.width + 10, height: cellHeight))
            }
            
            addTagTableView.isScrollEnabled = false
            
            if(cellHeight > 208){
                doprDownTableview.frame =  CGRect(origin: CGPoint(x: 0,y :rect.origin.y + 40), size: CGSize(width: rect.size.width + 10, height: 208))
                addTagTableView.isScrollEnabled = false
            }
            doprDownTableview.reloadData()
            
            if str.length > 30 {
                return false
            }
            break
            
        case 106:
            let  char = string.cString(using: String.Encoding.utf8)!
            let isBackSpace = strcmp(char, "\\b")
            
            if (isBackSpace == -92) {
                print("Backspace was pressed")
                let subViews = secondaryTagScrollView.subviews
                subViews.last?.removeFromSuperview()
                
                DispatchQueue.main.async {
                    self.secondaryTagScrollView.reloadInputViews()
                    let secondaryIndexPath = IndexPath(item: 1, section: 0)
                    self.addTagTableView.reloadRows(at: [secondaryIndexPath], with: .none)
                }
            }
            
        case 103:
            doprDownTableview.frame =  CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 0, height: 0))
            addTagTableView.isScrollEnabled = true
            
            if str.length > 6 {
                return false
            }
            break
            
        case 104:
            doprDownTableview.frame =  CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 0, height: 0))
            addTagTableView.isScrollEnabled = true
            
            break
            
        case 105:
            doprDownTableview.frame =  CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 0, height: 0))
            addTagTableView.isScrollEnabled = true
            
            if str.length > 80 {
                return false
            }
            break
        default:
            break
        }
        return true
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        doprDownTableview.frame =  CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 0, height: 0))
        
        switch textField.tag
        {
        case 102:
            
            let trimmedString = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if(trimmedString != ""){
                
                doprDownTableview.frame =  CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 0, height: 0))
                let newString = trimmedString
                tagCount = tagCount + 1
                var width = Int ()
                if let font = UIFont(name: "HelveticaNeue", size: 14)
                {
                    let fontAttributes = [NSFontAttributeName: font]
                    let size = (textField.text! as NSString).size(attributes: fontAttributes)
                    width = Int(size.width + 10)
                }
                let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: width+25, height: 32))
                backgroundView.layer.cornerRadius = 16.0
                backgroundView.clipsToBounds = true
                backgroundView.backgroundColor = UIColor.blue
                let backgroundImage = UIImageView(frame: CGRect(x: 0, y: 0, width: width+25, height: 32))
                backgroundImage.image = UIImage.init(named: "btn")
                backgroundView.addSubview(backgroundImage)
                
                let sampleTextField =  UITextField(frame: CGRect(x: 12, y: 4, width: width, height: 25))
                sampleTextField.font = UIFont(name: "HelveticaNeue", size: 14)
                sampleTextField.textAlignment = NSTextAlignment.center
                sampleTextField.text = newString
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
                
                let dummyView = UIView(frame: CGRect(x: origin, y: 10, width: width+25, height: 52))
                dummyView.tag = tagCount
                dummyView.addSubview(backgroundView)
                dummyView.addSubview(closeButton)
                
                secondaryTagScrollView.contentSize = CGSize(width: origin + Int(dummyView.frame.size.width) + 20, height: 52)
                
                let dict = NSMutableDictionary()
                dict .setValue(tagCount, forKey: "tagCount")
                dict .setValue(newString, forKey: "data")
                secondaryTagSelected.add(dict)
                
                origin += Int(dummyView.frame.size.width + 15)
                
                secondaryTagScrollView.addSubview(dummyView)
                textField.text = ""
                
                
                if(secondaryTagSelected.count < 3){
                    secondaryTagNameTextField.removeFromSuperview()
                    nextTextField =  UITextField(frame: CGRect(x: Int(dummyView.frame.origin.x) + Int(dummyView.frame.size.width) + 15, y: 10, width: 90, height: 25))
                    nextTextField.placeholder = "Add More"
                    nextTextField.returnKeyType = UIReturnKeyType.done
                    nextTextField.font = UIFont(name: "HelveticaNeue", size: 14)
                    nextTextField.tag = 102
                    nextTextField.delegate = self
                    secondaryTagScrollView.addSubview(nextTextField)
                }
                else{
                    nextTextField.removeFromSuperview()
                    return false
                }
                
                
                if(secondaryTagSelected.count == 3){
                    
                    lastTextField =  UITextField(frame: CGRect(x: Int(dummyView.frame.origin.x) + Int(dummyView.frame.size.width) + 15, y: 10, width: 70, height: 25))
                    lastTextField.becomeFirstResponder()
                    lastTextField.tag = 106
                    lastTextField.delegate = self
                    //  secondaryTagScrollView.addSubview(lastTextField)
                }
                
                DispatchQueue.main.async {
                    let secondaryIndexPath = IndexPath(item: 1, section: 0)
                    self.addTagTableView.reloadRows(at: [secondaryIndexPath], with: .none)
                }
                
                currentFieldSelected = "Secondary"
                doprDownTableview.reloadData()
                doprDownTableview.scrollsToTop = true
                var cellHeight = CGFloat()
                let searchPredicate = NSPredicate(format: "Secondary_Name contains[cd] %@", newString!)
                let filterArray = secondaryTagArray.filtered(using: searchPredicate)
                secondaryTagArray = NSMutableArray(array: filterArray)
                if(newString == ""){
                    secondaryTagArray = copySecondaryTagArray
                }
                cellHeight = CGFloat(secondaryTagArray.count * 52)
                let indexPath = IndexPath(row: 1, section: 0)
                let rect = self.addTagTableView.rectForRow(at:indexPath)
                doprDownTableview.frame =  CGRect(origin: CGPoint(x: 0,y :rect.origin.y + 40), size: CGSize(width: rect.size.width + 10, height: cellHeight))
                addTagTableView.isScrollEnabled = false
                
                if(cellHeight > 208){
                    doprDownTableview.frame =  CGRect(origin: CGPoint(x: 0,y :rect.origin.y + 40), size: CGSize(width: rect.size.width + 10, height: 208))
                    addTagTableView.isScrollEnabled = false
                    
                }
                doprDownTableview.frame =  CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 0, height: 0))
                doprDownTableview.reloadData()
                
            }
            break
        default:
            break
        }
        if textField.returnKeyType == .next
        {
            let tf: UITextField? = (view.viewWithTag(textField.tag + 1) as? UITextField)
            tf?.becomeFirstResponder()
            
        }else{
            textField.resignFirstResponder()
            
        }
        return true
    }
    
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case 101:
            cameraInfo.tagNameString = textField.text!
            break
        case 102:
            cameraInfo.secondaryTagName = textField.text!
            break
        case 103:
            cameraInfo.amountString = textField.text!
        case 104:
            cameraInfo.dateString = textField.text!
        case 105:
            cameraInfo.descriptionString = textField.text!
            
        default:
            break
            
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField.tag {
            
        case 101:
            let indexPath = IndexPath(row: 0, section: 0)
            let rect = self.addTagTableView.rectForRow(at:indexPath)
            doprDownTableview.frame =  CGRect(origin: CGPoint(x: 0,y :textField.frame.size.height), size: CGSize(width: rect.size.width + 10, height: 0))
            currentFieldSelected = "Primary"
            doprDownTableview.scrollsToTop = true
            doprDownTableview.reloadData()
            
        case 102:
            let indexPath = IndexPath(row: 1, section: 0)
            let rect = self.addTagTableView.rectForRow(at:indexPath)
            doprDownTableview.frame =  CGRect(origin: CGPoint(x: 0,y :textField.frame.size.height), size: CGSize(width: rect.size.width + 10, height: 0))
            currentFieldSelected = "Secondary"
            doprDownTableview.scrollsToTop = true
            secondaryTagArray = copySecondaryTagArray
            doprDownTableview.reloadData()
            
        case 104:
            self.view.resignFirstResponder()
            DispatchQueue.main.async {
                self.datePickerButton()
            }
        default:
            break
        }
    }
    
    func closeTapped(_ sender: UIButton) {        
        
        print(sender.tag)
        print(secondaryTagSelected)
        
        let tag: Int = sender.tag
        var index = Int()
        
        for i in 1 ... secondaryTagSelected.count {
            print(i)
            let dict = secondaryTagSelected .object(at: i-1) as! NSDictionary
            let tagFetched = Int(dict.value(forKey: "tagCount") as! NSNumber)
            
            if(tagFetched == tag){
                index = i-1
            }
        }
        secondaryTagSelected.removeObject(at: index)
        
        
        let subView = secondaryTagScrollView.subviews
        for subview in subView{
            subview.removeFromSuperview()
        }
        
        if(secondaryTagSelected.count == 0){
            secondaryTagNameTextField = CATextField()
            origin = 0
            secondaryTagScrollView.contentSize = CGSize(width:100 , height: 52)
            secondaryTagNameTextField =  CATextField(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
            secondaryTagNameTextField.tag = 102
            secondaryTagNameTextField.returnKeyType = UIReturnKeyType.done
            secondaryTagNameTextField.delegate = self
            secondaryTagScrollView.addSubview(secondaryTagNameTextField)
        }
        
        
        
        DispatchQueue.main.async {
            let secondaryIndexPath = IndexPath(item: 1, section: 0)
            self.addTagTableView.reloadRows(at: [secondaryIndexPath], with: .none)
        }
        self.createSubViews()
    }
    
    
    
    func createSubViews(){
        
        tagCount = 2000
        var width = Int ()
        secondaryTagScrollView.contentSize =  CGSize(width:0, height: 52)
        origin = 0
        
        for (_, element) in secondaryTagSelected.enumerated() {
            tagCount = tagCount + 1
            let dict = element as! NSMutableDictionary
            let dataString = dict.value(forKey: "data") as! NSString
            dict.setValue(tagCount, forKey: "tagCount")
            
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
            
            let sampleTextField =  UITextField(frame: CGRect(x: 12, y: 4, width: width, height: 25))
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
            closeButton.addTarget(self, action: #selector(CAAddTagPopUpViewController.closeTapped(_:)), for: .touchUpInside)
            
            let dummyView = UIView(frame: CGRect(x: origin, y: 5, width: width+25, height: 52))
            dummyView.tag = tagCount
            dummyView.addSubview(backgroundView)
            dummyView.addSubview(closeButton)
            secondaryTagScrollView.addSubview(dummyView)
            
            secondaryTagScrollView.contentSize = CGSize(width: origin + Int(dummyView.frame.size.width) + 20, height: 52)
            origin += Int(dummyView.frame.size.width + 15)
            
            
            if(secondaryTagSelected.count < 3){
                secondaryTagNameTextField.removeFromSuperview()
                nextTextField =  UITextField(frame: CGRect(x: Int(dummyView.frame.origin.x) + Int(dummyView.frame.size.width) + 15, y: 10, width: 90, height: 25))
                nextTextField.placeholder = "Add More"
                nextTextField.becomeFirstResponder()
                nextTextField.font = UIFont(name: "HelveticaNeue", size: 14)
                nextTextField.tag = 102
                nextTextField.returnKeyType = UIReturnKeyType.done
                nextTextField.delegate = self
                secondaryTagScrollView.addSubview(nextTextField)
            }
            DispatchQueue.main.async {
                let secondaryIndexPath = IndexPath(item: 1, section: 0)
                self.addTagTableView.reloadRows(at: [secondaryIndexPath], with: .none)
            }
            
        }
        
    }
    
    
    
    
    //MARK: - validation Methods.
    func isallFieldsVerfield() -> Bool
    {
        var isvalid = false
        
        if cameraInfo.dateString.trimWhiteSpace().length == 0
        {
            presentAlert("", msgStr: "Please select date.", controller: self)
            isvalid = false
            
            
        }else if cameraInfo.tagNameString.trimWhiteSpace().length == 0
        {
            presentAlert("", msgStr: "Please enter primary name.", controller: self)
            isvalid = false
        }
        else if cameraInfo.secondaryTagName.trimWhiteSpace().length == 0
        {
            presentAlert("", msgStr: "Please enter secondary name.", controller: self)
            isvalid = false
        }
        else if cameraInfo.tagType.trimWhiteSpace().length == 0
        {
            presentAlert("", msgStr: "Please select tag type.", controller: self)
            isvalid = false
        }
        else if cameraInfo.tagNameString.length < 2 {
            presentAlert("", msgStr: "Tag name should be atleast two character.", controller: self)
            isvalid = false
        }
            
        else if cameraInfo.amountString.trimWhiteSpace().length == 0 {
            presentAlert("", msgStr: "Please enter amount.", controller: self)
            isvalid = false
        }
            
            
        else if  cameraInfo.descriptionString.trimWhiteSpace().length == 0 {
            presentAlert("", msgStr: "Please enter description.", controller: self)
            
            isvalid = false
        }else{
            isvalid = true
        }
        return isvalid;
    }
    
    //MARK: - UIButton Actions
    
    func datePickerButton() {
        
        let currentDate = Date()
        var dateComponents = DateComponents()
        dateComponents.year = -100
        let minDate = Calendar.current.date(byAdding: dateComponents, to: currentDate)
        
        
        DatePickerDialog().show("", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", minimumDate: minDate, maximumDate: currentDate, datePickerMode: .date) { (date) in
            if let dt = date {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                self.cameraInfo.dateString = dateFormatter.string( from: (dt))
                self.dateTextField.text = self.cameraInfo.dateString
            }
        }
    }
    
    
    
    func doneWithNumberPad() {
        amountTextField.resignFirstResponder()
    }
    
    
    func tagType_Clicked (sender : UIButton){
        
        if(sender.tag == 131){
            sender.isSelected = true
            tagType = "bank+"
            bmButton.isSelected = false
            cmButton.isSelected = false
            cpButton.isSelected = false
            otButton.isSelected = false
        }
        else if(sender.tag == 132){
            sender.isSelected = true
            tagType = "bank-"
            bpButton.isSelected = false
            cmButton.isSelected = false
            cpButton.isSelected = false
            otButton.isSelected = false
            
        }
        else if(sender.tag == 133){
            sender.isSelected = true
            tagType = "cash+"
            bpButton.isSelected = false
            bmButton.isSelected = false
            cmButton.isSelected = false
            otButton.isSelected = false
        }
        else if(sender.tag == 134){
            sender.isSelected = true
            tagType = "cash-"
            bpButton.isSelected = false
            bmButton.isSelected = false
            cpButton.isSelected = false
            otButton.isSelected = false
        }
        else if(sender.tag == 135){
            sender.isSelected = true
            tagType = "other"
            bpButton.isSelected = false
            bmButton.isSelected = false
            cmButton.isSelected = false
            cpButton.isSelected = false
        }
        
        self.cameraInfo.tagType  = tagType
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == secondaryTagScrollView {
            if scrollView.contentOffset.x>0 {
                scrollView.contentOffset.x = 0
            }
        }
    }
    
    
}




extension String {
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}
