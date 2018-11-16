//
//  CACustomCameraViewController.swift
//  ClickAccountingApp
//
//  Created by Ratneshwar Singh on 6/29/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit
import AACameraView
import TOCropViewController


class CACustomCameraViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate, TOCropViewControllerDelegate, AddTagDelegate,CancelAddTagDelegate, UIDocumentPickerDelegate,docScreenshotDelegate {
    
    var imageTye : String = ""
    var imageUUID : String = ""
    
    @IBOutlet var cameraView: AACameraView!
    @IBOutlet weak var cashPlusButton: UIButton!
    @IBOutlet weak var cashMinus: UIButton!
    @IBOutlet weak var bankPlus: UIButton!
    @IBOutlet weak var bankMinus: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var captureImageView: UIImageView!
    
    var docScreenshotView = CADocScreenshotViewController()
    var documentExtension : String = ""
    var documentPath : String = ""
    var tagTypeAdded : String = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //Setting Round Corner
        cashPlusButton.layer.cornerRadius = 2.0
        cashMinus.layer.cornerRadius = 2.0
        bankPlus.layer.cornerRadius = 2.0
        bankMinus.layer.cornerRadius = 2.0
        
    NotificationCenter.default.addObserver(self, selector: #selector(self.removeImageView), name: Notification.Name("cancelEventCamera"), object: nil)
        
        //Setting shadow
        cashPlusButton.layer.shadowColor = UIColor.lightGray.cgColor
        cashMinus.layer.shadowColor = UIColor.lightGray.cgColor
        bankPlus.layer.shadowColor = UIColor.lightGray.cgColor
        bankMinus.layer.shadowColor = UIColor.lightGray.cgColor
        self.captureImageView.isHidden = true
        
        cameraView.response = {
            response in
            if let image = response as? UIImage {
                self.captureImageView.isHidden = false
                self.captureImageView.image = image
                
                let fileManager = FileManager.default
                let uuid = CFUUIDCreateString(nil, CFUUIDCreate(nil)) as String
                self.imageUUID = uuid + ".jpg"
                let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(self.imageUUID)
                let imageData = UIImageJPEGRepresentation(image, 0.15)
                fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
                fileManager.fileExists(atPath: paths)
                
                if(kUserDefaults.value(forKey: kPaidStatus) as! Int == 0){
                    let addTagPopUpVC: CAAddTagPopUpViewController = CAAddTagPopUpViewController(nibName:"CAAddTagPopUpViewController", bundle: nil)
                    addTagPopUpVC.addTagDelegate = self
                    addTagPopUpVC.canceladdTagDelegate = self
                    addTagPopUpVC.navigationTitleString = "Add Tag"
                    addTagPopUpVC.modalPresentationStyle = .overCurrentContext
                    addTagPopUpVC.modalTransitionStyle = .crossDissolve
                    addTagPopUpVC.imageURL = self.imageUUID
                    addTagPopUpVC.tagType =  self.imageTye
                    addTagPopUpVC.isToCaptureImage = true
                    self.present(addTagPopUpVC, animated: true, completion: nil)
                }
                else{
                    if self.captureImageView.image != nil {
                        let imageCropVC: TOCropViewController = TOCropViewController.init(image:self.captureImageView.image!)
                        imageCropVC.delegate = self as TOCropViewControllerDelegate
                        self .present(imageCropVC, animated: true, completion: {
                        })
                    }
                }
            }
            else if let error = response as? Error {
                self.captureImageView.isHidden = true
                print("Error: ", error.localizedDescription)
            }
        }
    }
    
    
    func removeImageView(){
        self.captureImageView.isHidden = true
    }
    
    
    func saveDataForPaidUsers(uuid : String){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string( from: Date())
        let secondaryArray = NSMutableArray()
        
        let paramDict : Dictionary<String, AnyObject> = [
            kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject) ,
            kPrimaryName : "Untagged" as AnyObject ,
            kSecondaryTag : secondaryArray as AnyObject ,
            kAmount : "" as AnyObject,
            kTagDate : dateString as AnyObject,
            kTagStatus : "6" as AnyObject,
            kIsUploaded : "0" as AnyObject,
            kTagType : "" as AnyObject,
            kTagDescription : "" as AnyObject,
            kTagImageURL : uuid as String as AnyObject,
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
        taggAdded .setValue("Untagged", forKey: kPrimaryName)
        taggAdded .setValue("" , forKey: kAmount)
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
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            // self.captureImageView.isHidden = true
            self.addDelegateWithDetailsAndIsSubmit(details: "yes", isSubmit: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // captureImageView.isHidden = true
        cameraView.startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraView.stopSession()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Button Action & Selector Methods
    @IBAction func commonButtonAction(sender: UIButton)  {
        if sender.tag == 251{
            imageTye = "cash+"
        }
        else if sender.tag == 252{
            imageTye = "cash-"
        }
        else if sender.tag == 253{
            imageTye = "bank+"
        }
        else if sender.tag == 254{
            imageTye = "bank-"
        }
        else{
            imageTye = "other"
        }
        cameraView.triggerCamera()
    }
    
    
    
    
    @IBAction func headerButtonAction(sender: UIButton) {
        switch sender.tag {
        //Gallery pick
        case 91:
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: {
                })
            }
            break;
        //Document pick
        case 92:
            let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["com.apple.iwork.pages.pages", "com.apple.iwork.numbers.numbers", "com.apple.iwork.keynote.key", "com.microsoft.word.doc","public.text","com.adobe.pdf"], in: UIDocumentPickerMode.import)
            tagTypeAdded  = "Document"
            documentPicker.delegate = self
            documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            self.present(documentPicker, animated: true, completion: nil)
            
            break;
        //Add Manual
        case 93:
            let addTagPopUpVC: CAAddTagPopUpViewController = CAAddTagPopUpViewController(nibName:"CAAddTagPopUpViewController", bundle: nil)
            addTagPopUpVC.addTagDelegate = self
            tagTypeAdded  = "gallery"
            addTagPopUpVC.navigationTitleString = "Add Manual"
            addTagPopUpVC.modalPresentationStyle = .overCurrentContext
            addTagPopUpVC.modalTransitionStyle = .crossDissolve
            self.present(addTagPopUpVC, animated: true, completion: nil)
            break;
        //Crop
        case 94:
            
            //            if captureImageView.image != nil {
            //                 let imageCropVC: TOCropViewController = TOCropViewController.init(image:captureImageView.image!)
            //                imageCropVC.delegate = self as TOCropViewControllerDelegate
            //                self .present(imageCropVC, animated: true, completion: {
            //                })
            //            }
            break;
        //Cross
        case 95:
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "crossButtonPressedOnCamera"), object: nil, userInfo: nil)
            captureImageView.isHidden = true
            break;
        //Menu Button
        case 96:
            let appDelegateShared : AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegateShared.menuViewController .toggle()
            break;
        default:
            break;
        }
    }
    
    
    /// ImagePicker Delegate Method
    ///
    /// - Parameters:
    ///   - picker: imagePickerDelegate
    ///   - info: infoObj
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            self.captureImageView.isHidden = false
            self.captureImageView.image = image
            self.dismiss(animated: true, completion: nil)
            
            let addTagPopUpVC: CAAddTagPopUpViewController = CAAddTagPopUpViewController(nibName:"CAAddTagPopUpViewController", bundle: nil)
            addTagPopUpVC.addTagDelegate = self
            addTagPopUpVC.modalPresentationStyle = .overCurrentContext
            addTagPopUpVC.modalTransitionStyle = .crossDissolve
            addTagPopUpVC.tagType = self.imageTye
            self.present(addTagPopUpVC, animated: true, completion: nil)
            
        }
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int) {
        
        self.saveDataForPaidUsers(uuid: imageUUID)
        self.captureImageView.isHidden = false
        self.captureImageView.image = image
        self.dismiss(animated: true, completion: nil)
    }
    
    //Mark Custom Delegate Return
    func addDelegateWithDetailsAndIsSubmit(details: NSString, isSubmit: Bool) {
        
        self.captureImageView.isHidden = true
        var tagMutable = NSMutableArray()
        var matchedPrimaryTag = NSDictionary()
        var primaryTagArray = NSMutableArray()
        print((kUserDefaults.value(forKey: kAllPrimaryTags) as! NSArray).mutableCopy())
        
       // primaryTagArray = (kUserDefaults.value(forKey: kAllPrimaryTags) as! NSArray).mutableCopy() as! NSMutableArray
        
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
    
    
    
    func cancelAddDelegateWithDetailsAndIsSubmit(details: NSString, isSubmit: Bool) {
        self.captureImageView.isHidden = true
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
                presentAlert(kZoddl, msgStr: "Unable to load data: \(error)", controller: self)
                
            }
        }
    }
    
    // MARK: - Get screenshot
    
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
