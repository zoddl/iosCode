//
//  AppDelegate.swift
//  ClickAccountingApp
//
//  Created by Deepak Kumar on 6/27/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit
import CoreData
import SideMenuController
import UserNotifications
import GoogleSignIn
import GoogleToolboxForMac
import Alamofire
import FBSDKCoreKit
import FBSDKLoginKit
import AWSS3
import Fabric
import Crashlytics


@available(iOS 10.0, *)
@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate  {
    
    var isReachable : Bool = false
    var menuViewController: SideMenuController!
    var window: UIWindow?
    var navController: UINavigationController?
    //Get nework reachability
    let networkRechability = NetworkReachabilityManager()
    var primaryTagArray = NSMutableArray()
    var secondaryTagArray = NSMutableArray()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FBSDKApplicationDelegate.sharedInstance() .application(application, didFinishLaunchingWithOptions: launchOptions)
        Fabric.with([Crashlytics.self])
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let mainViewController = LoginViewController(nibName: "LoginViewController", bundle: nil)
        navController = UINavigationController(rootViewController: mainViewController)
        self.navController?.isNavigationBarHidden = true
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
        
        // Override point for customization after application launch.
        registerUserForNotification()
        
        //Check network reachablity
        isReachable = (NetworkReachabilityManager()?.isReachable)!
        
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast1,identityPoolId:"us-east-1:c1f7dd1b-be90-470f-84e6-b2ca8650b15d")
        
        let configuration = AWSServiceConfiguration(region:.USEast1, credentialsProvider:credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        credentialsProvider.getIdentityId().continueWith { (task) -> Any? in
            
            print(task.result as Any)
            print(task.error as Any)
            
            return nil
        }
        
//        let uuid = UUID().uuidString
//        kUserDefaults.set(uuid, forKey: kDeviceToken)
        
        let cache = URLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: nil)
        URLCache.shared = cache
        
        
        if(isReachable){
          self.getTagsData()
        }
        UIApplication.shared.applicationIconBadgeNumber = 0
        return true
    }
    
    func getTagsData(){
        if((kUserDefaults.value(forKey: kAuthtoken)) != nil){
            self.getAllPrimaryTags()
            self.getAllSecondaryTags()
        }
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "ClickAccountingApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("data saved succesfully")
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //Google Sign In
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        var handled: Bool! = false
        
        var _: [String: AnyObject] = [UIApplicationOpenURLOptionsKey.sourceApplication.rawValue: sourceApplication as AnyObject,
                                      UIApplicationOpenURLOptionsKey.annotation.rawValue: annotation as AnyObject]
        
        if(GIDSignIn.sharedInstance().handle(url as URL!,
                                             sourceApplication: sourceApplication,
                                             annotation: annotation)){
            
            handled  = GIDSignIn.sharedInstance().handle(url as URL!,
                                                         sourceApplication: sourceApplication,
                                                         annotation: annotation)
            
        }else{
            
            handled =  FBSDKApplicationDelegate.sharedInstance() .application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        }
        
        return handled
    }
    
    
    // MARK: Add Side Panel
    func addSidePanelControllerOnNavigation() -> SideMenuController {
        
        menuViewController = SideMenuController.init(nibName: "SideMenuController", bundle: nil)
        let baseVC = CABaseContainerViewController(nibName: "CABaseContainerViewController", bundle: nil)
        baseVC.selectedTabBar = selectTabType.Tab_none
        let menuVC = CAMenuNoSubClassViewController(nibName: "CAMenuNoSubClassViewController", bundle: nil)
        let baseNavigationController: UINavigationController = UINavigationController.init(rootViewController: baseVC)
        let menuNavigationController: UINavigationController = UINavigationController.init(rootViewController: menuVC)
        
        //Hiding navigation bar
        baseNavigationController.navigationBar.isHidden = true
        menuNavigationController.navigationBar.isHidden = true
        
        menuViewController.embed(sideViewController: menuNavigationController)
        menuViewController.embed(centerViewController: baseNavigationController)
        return menuViewController
    }
    
    //MARK: Register for remote Notifications
    func registerUserForNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            logInfo("Permission granted: \(granted)")
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            logInfo("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable : Any]) {
        // Print notification payload data
            print("Push notification received: \(data)")
        
            let aps = data[AnyHashable("aps")] as? NSDictionary
            let alert = aps!["alert"] as? String
            let message = (aps?.value(forKey: "title") as! NSDictionary).value(forKey: "message")
            let notificationKey = (aps?.value(forKey: "title") as! NSDictionary).value(forKey: "key")

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let entityDescription =
            NSEntityDescription.entity(forEntityName: "NotificationTable",
                                       in: appDelegate.persistentContainer.viewContext)
        let notificationEntry = NotificationTable(entity: entityDescription!,
                                     insertInto: appDelegate.persistentContainer.viewContext)
        notificationEntry.title = alert
        notificationEntry.message =  message as? String
        notificationEntry.notificationKey  = (notificationKey as? NSNumber)?.stringValue
        saveContext()
        
        NotificationCenter.default.post(name: Notification.Name("newNotificationReceived"), object: nil)

    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenPart = deviceToken.map{data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenPart.joined()
        logInfo("deviceToken\(token)")
        print(token)
        kUserDefaults.set(token, forKey: kDeviceToken)
        kUserDefaults.synchronize()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        logInfo("Fail To Register:\(error)")
    }
    
   
    func uploadImageToS3_withTags(tagMutable: NSMutableArray){
        
        for (index, element) in tagMutable.enumerated() {
            print("Item \(index): \(element)")
            let dict = element as! NSDictionary
            let imagesArr  =  dict.value(forKey: kPrimaryImages) as! NSArray
            let dirPath = (imagesArr.firstObject as! NSDictionary).value(forKey: kTagImageURL) as! String
            
            let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(dirPath)
            let isUploaded = (imagesArr.firstObject as! NSDictionary).value(forKey: kIsUploaded) as! String
            print("isUploaded value : \(isUploaded)")
            
            if (paths != "" && isUploaded != "1") {
                
                let imageFound    = UIImage(contentsOfFile: paths)
                
                var thumbImage =  UIImage()
                
                if((imageFound) != nil){
                    
                    thumbImage = self.resizeImage(image: imageFound!, targetSize: CGSize(width:400, height: 400))
                    
                    ServiceHelper.sharedInstanceHelper.uploadThumbImageToS3(image: thumbImage, fileName: "", completion: { (resultThumb, error) in
                        
                        ServiceHelper.sharedInstanceHelper.uploadImageToS3(image: imageFound!, fileName: "", completion: { (result, error) in
                            hideHud()
                            if(error == nil){
                                var tagDictionary = NSMutableDictionary()
                                tagDictionary = dict.mutableCopy() as! NSMutableDictionary
                                tagDictionary.setValue("1", forKey: kIsUploaded)
                                var imageArrFetched = NSMutableArray()
                                imageArrFetched = (tagDictionary.value(forKey: kPrimaryImages) as! NSArray).mutableCopy() as! NSMutableArray
                                let imgDict = (imageArrFetched.firstObject as! NSDictionary).mutableCopy() as! NSMutableDictionary
                                imgDict .setValue((kImageBaseURL  + (result?.key)! as String), forKey: kTagImageURL)
                                imgDict .setValue((kImageBaseURL  + (resultThumb?.key)! as String), forKey: kTagImageThumbURL)
                                imgDict.setValue("1", forKey: kIsUploaded)
                                let imgArrNew = NSMutableArray()
                                imgArrNew.add(imgDict)
                                
                                
                                tagDictionary.setValue(imgArrNew, forKey: kPrimaryImages)
                                print(tagDictionary)
                                
                                //update the current object if uploaded
                                tagMutable.replaceObject(at: index, with: tagDictionary)
                                kUserDefaults.set(tagMutable, forKey: kLocallySavedTag)
                                kUserDefaults.synchronize()
                                
                                self.addtag(tagData: tagDictionary, index:index)
                            }
                        });
                    });
                    
                }
                //                    else{
                //                        self.addtag(tagData: dict, index:index)
                //                    }
            }
        }
        
    }
    
    func uploadImageToS3(){
        
        print("method uploadImageToS3 called")
        
        if((kUserDefaults.value(forKey: kLocallySavedTag)) != nil){
            let tagArrayFetched = kUserDefaults.value(forKey: kLocallySavedTag) as! NSArray
            var tagMutable = NSMutableArray()
            tagMutable = tagArrayFetched.mutableCopy() as! NSMutableArray
            
            print("total count image to upload: \(tagMutable.count)")
            
            for (index, element) in tagMutable.enumerated() {
                print("Item \(index): \(element)")
                let dict = element as! NSDictionary
                let imagesArr  =  dict.value(forKey: kPrimaryImages) as! NSArray
                let dirPath = (imagesArr.firstObject as! NSDictionary).value(forKey: kTagImageURL) as! String
                
                let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(dirPath)
                let isUploaded = (imagesArr.firstObject as! NSDictionary).value(forKey: kIsUploaded) as! String
                print("isUploaded value : \(isUploaded)")
                
                if (paths != "" && isUploaded != "1") {
                    
                    let imageFound    = UIImage(contentsOfFile: paths)
                    
                    if((imageFound) != nil){
                        
                        ServiceHelper.sharedInstanceHelper.uploadThumbImageToS3(image: imageFound!, fileName: "", completion: { (resultThumb, error) in
                            //    print(kImageBaseURL  + (resultThumb?.key)! as String)
                            
                            ServiceHelper.sharedInstanceHelper.uploadImageToS3(image: imageFound!, fileName: "", completion: { (result, error) in
                                hideHud()
                                if(error == nil){
                                    var tagDictionary = NSMutableDictionary()
                                    tagDictionary = dict.mutableCopy() as! NSMutableDictionary
                                    tagDictionary.setValue("1", forKey: kIsUploaded)
                                    var imageArrFetched = NSMutableArray()
                                    imageArrFetched = (tagDictionary.value(forKey: kPrimaryImages) as! NSArray).mutableCopy() as! NSMutableArray
                                    let imgDict = (imageArrFetched.firstObject as! NSDictionary).mutableCopy() as! NSMutableDictionary
                                    imgDict .setValue((kImageBaseURL  + (result?.key)! as String), forKey: kTagImageURL)
                                    imgDict .setValue((kImageBaseURL  + (resultThumb?.key)! as String), forKey: kTagImageThumbURL)
                                    imgDict.setValue("1", forKey: kIsUploaded)
                                    let imgArrNew = NSMutableArray()
                                    imgArrNew.add(imgDict)
                                    
                                    
                                    tagDictionary.setValue(imgArrNew, forKey: kPrimaryImages)
                                    print(tagDictionary)
                                    
                                    //update the current object if uploaded
                                    tagMutable.replaceObject(at: index, with: tagDictionary)
                                    kUserDefaults.set(tagMutable, forKey: kLocallySavedTag)
                                    kUserDefaults.synchronize()
                                    self.addtag(tagData: tagDictionary, index:index)
                                }
                            });
                        });
                        
                    }
                    //                    else{
                    //                        self.addtag(tagData: dict, index:index)
                    //                    }
                }
            }
            
        }
        
    }
    
    
    func createJsonString (secondaryArr : NSMutableArray) -> NSString{
        
        let secondaryArrFetched  = NSMutableArray()
        for item in secondaryArr{
            let json = item as! NSDictionary
            secondaryArrFetched.add(json.value(forKey: kSecondaryName) as Any)
        }
        
        var secondaryString  = NSString()
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject:  secondaryArrFetched as NSArray, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
                secondaryString = JSONString as NSString
            }
            
        } catch {
            //print(error.description)
        }
        return secondaryString
    }
    
    
    
    func addtag (tagData : NSDictionary, index : Int){
        
        let tagDataFirstObject = tagData.value(forKey: kPrimaryImages) as! NSArray
        let tagDataReceived = tagDataFirstObject.firstObject as! NSDictionary
        
        let secondaryArr = tagDataReceived.value(forKey: kSecondaryTag) as! NSArray
        let secondaryArrFetched  = NSMutableArray()
        for item in secondaryArr{
            let json = item as! NSDictionary
            secondaryArrFetched.add(json.value(forKey: kSecondaryName) as Any)
        }
        
        var secondaryString  = NSString()
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject:  secondaryArrFetched as NSArray, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
                secondaryString = JSONString as NSString
            }
            
        } catch {
            //print(error.description)
        }
        
        
        let paramDict : Dictionary<String, AnyObject> = [
            kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject) ,
            kPrimaryName : tagDataReceived.value(forKey: kPrimaryName) as AnyObject ,
            kSecondaryTag : secondaryString as AnyObject ,
            kAmount : tagDataReceived.value(forKey:kAmount)as AnyObject,
            kTagDate : tagDataReceived.value(forKey:kTagDate)as AnyObject ,
            kTagStatus : "6" as AnyObject,
            kTagType : tagDataReceived.value(forKey:kTagType)as AnyObject,
            kTagDescription : tagDataReceived.value(forKey:kTagDescription)as AnyObject,
            kTagImageURL : tagDataReceived.value(forKey:kTagImageURL)as AnyObject,
            kTagImageThumbURL : tagDataReceived.value(forKey:kTagImageThumbURL)as AnyObject
        ]
        
        var apiName = String()
        let arr  = tagData.value(forKey: kPrimaryImages) as! NSArray
        var dict = NSMutableDictionary()
        dict = arr.firstObject as! NSMutableDictionary
        print(dict)
        
        if(dict.value(forKey:kTagImageURL) as! String == ""){
            apiName = "Customer_Api/addmanualtag"
        }else{
            apiName = "Customer_Api/addtag"
        }
        
        ServiceHelper.sharedInstanceHelper.createPostRequest(method: .post, showHud: false, params: paramDict, apiName: apiName) { (result, error) in
            
            if(!(error != nil)){
                if (result![kResponseCode]! == "200"){
                    print(result as Any)
                    let tagArrayFetched = kUserDefaults.value(forKey: kLocallySavedTag) as! NSArray
                    var tagMutable = NSMutableArray()
                    
                    tagMutable = tagArrayFetched.mutableCopy() as! NSMutableArray
                    tagMutable = tagMutable.removeUploaded()
                    
                    for (indexTag, localTag) in tagMutable.enumerated()
                    {
                        let localTag = localTag as! Dictionary<String, AnyObject>
                        
                        if tagData[kCurrentTimestamp] as? String == localTag[kCurrentTimestamp] as? String || tagData[kIsUploaded] as? String == "1"
                        {
                            print("timestamp matched and deleted from local \(localTag[kCurrentTimestamp])")
                            tagMutable.removeObject(at: indexTag)
                            
                            kUserDefaults.set(tagMutable, forKey: kLocallySavedTag)
                            kUserDefaults.synchronize()
                            break
                        }
                        // print(localTag)
                    }
                    // tagMutable .removeAllObjects()
                    NotificationCenter.default.post(name: Notification.Name("newTagAdded"), object: nil)
                }
                else {
                    presentAlert(kZoddl, msgStr: result![kResponseMessage]!, controller: self)
                }
            } else {
                //presentAlert("", msgStr: error?.localizedDescription, controller: self)
            }
        }
    }
    
    
    
    
    func resizeImage (image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    
    
    
    //Mark : Upload Document from core data
    
    func uploadDocumentToS3(){
        
        self.printCoreDataEntries()
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Document")
        
        do {
            let results = try context.fetch(fetchRequest)
            let  documentCreated = results as! [Document]
            
            for docData in documentCreated {
                print(docData.primaryName!)
                print(docData.docType!)
                
                ServiceHelper.sharedInstanceHelper.uploadDocumentToS3(documentPath: docData.docPath!, fileName: "",fileExtension:docData.docType!, completion: { (result, error)  in
                    if(result != nil){
                        docData.docPath = (kImageBaseURL  + (result?.key)! as String)
                        self.addDocumentTag(tagData: docData)
                    }else{
                        presentAlert(kZoddl, msgStr: error?.description, controller: self)
                    }
                    
                })
            }
        }
        catch let err as NSError {
            print(err.debugDescription)
        }
    }
    
    
    
    func uploadDocumentImageToS3(){
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Document")
        
        do {
            let results = try context.fetch(fetchRequest)
            let  documentCreated = results as! [Document]
            
            for docData in documentCreated {
                
                print(docData.primaryName!)
                print(docData.docType!)
                
                let dirPath = docData.docImageURL
                let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(dirPath!)
                
                if (paths != "" && docData.isUploaded != 1) {
                    
                    let imageFound    = UIImage(contentsOfFile: paths)
                    
                    if((imageFound) != nil){
                        
                        ServiceHelper.sharedInstanceHelper.uploadThumbImageToS3(image: imageFound!, fileName: "", completion: { (resultThumb, error) in
                            
                            ServiceHelper.sharedInstanceHelper.uploadImageToS3(image: imageFound!, fileName: "", completion: { (result, error) in
                                hideHud()
                                
                                if(!(error != nil)){
                                    
                                    docData.docImageURL = (kImageBaseURL  + (result?.key)! as String)
                                    
                                    if(docData.docType == "jpg"){
                                        docData.docPath = (kImageBaseURL  + (result?.key)! as String)
                                        self.addDocumentTag(tagData: docData)
                                    }
                                    else{
                                        ServiceHelper.sharedInstanceHelper.uploadDocumentToS3(documentPath: docData.docPath!, fileName: "",fileExtension:docData.docType!, completion: { (result, error)  in
                                            if(result != nil){
                                                docData.docPath = (kImageBaseURL  + (result?.key)! as String)
                                                self.addDocumentTag(tagData: docData)
                                            }else{
//                                                presentAlert(kZoddl, msgStr: "Some files could not be loaded due to network error", controller: self)
                                            }
                                            
                                        })
                                    }
                                    
                                }
                                
                            })
                            
                        })
                    }
                    
                }
            }
            
        }
        catch let err as NSError {
            print(err.debugDescription)
        }
    }
    
    
    
    //Mark : Add document tag
    
    func addDocumentTag(tagData : Any){
        
        let tagDataFetched = tagData as! Document
        
        let paramDict : Dictionary<String, AnyObject> = [
            kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject) ,
            kPrimaryName : tagDataFetched.primaryName!  as AnyObject ,
            kSecondaryTag : tagDataFetched.secondaryTag as AnyObject ,
            kAmount : tagDataFetched.amount as AnyObject,
            kTagDate : tagDataFetched.tagDate as AnyObject ,
            kTagStatus : "6" as AnyObject,
            kTagType : tagDataFetched.tagType as AnyObject,
            kTagDescription : tagDataFetched.tagDescription as AnyObject,
            kTagImageURL : tagDataFetched.docPath as AnyObject,
            kTagImageThumbURL : tagDataFetched.docPath as AnyObject,
            kTagDocThumbURL : tagDataFetched.docPath as AnyObject
        ]
        
        
        ServiceHelper.sharedInstanceHelper.createPostRequest(method: .post, showHud: false, params: paramDict, apiName: "Document_Api/addtag") { (result, error) in
            
            if(!(error != nil)){
                if (result![kResponseCode]! == "200"){
                    self.deleteEntryFromCoreData(currentTimeStamp: tagDataFetched.createdTime)
                    NotificationCenter.default.post(name: Notification.Name("newTagAdded"), object: nil)                    
                }
                
            }
            
        }
    }
    
    
    //Mark : Delete from local core data
    
    func deleteEntryFromCoreData(currentTimeStamp : Double){
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Document")
        let predicate = NSPredicate(format: "createdTime = %lf", currentTimeStamp)
  
        
        fetchRequest.predicate = predicate
        do{
            let result = try context.fetch(fetchRequest)
            
            if result.count > 0{
                for object in result {
                    print(object)
                    print("Uploaded and removed")
                    context.delete(object as! NSManagedObject)
                }
            }
        }catch{
            
        }
    }
    
    func printCoreDataEntries(){
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Document")
        do{
            let result = try context.fetch(fetchRequest)
            
            if result.count > 0{
                for object in result {
                    print(object)
                }
            }
        }catch{
            
        }
    }
    
    func getAllPrimaryTags(){
        
        let paramDict : Dictionary<String, AnyObject> = [
            kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject) ,
            ]
        
        self.primaryTagArray.removeAllObjects()
        
        ServiceHelper.sharedInstanceHelper.createPostRequest(method: .post, showHud: true, params: paramDict, apiName: "Customer_Api/reportprimarytag") { (result, error) in
            
            if(!(error != nil)){
                if (result![kResponseCode]! == "200"){
                    let resultDict:Dictionary<String, AnyObject> = result as! Dictionary
                    self.primaryTagArray = (resultDict[kPrimaryTag]! as! NSArray).mutableCopy() as! NSMutableArray
                    kUserDefaults.set(self.primaryTagArray, forKey: kAllPrimaryTags)
                }
                else {
                }
                
            } else {
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
                if (result![kResponseCode]! == "200"){
                    let resultDict:Dictionary<String, AnyObject> = result as! Dictionary
                    self.secondaryTagArray = (resultDict[kSecondaryTag]! as! NSArray).mutableCopy() as! NSMutableArray
                    kUserDefaults.set(self.secondaryTagArray, forKey: kAllSecondaryTags)

                }
                else {
                }
                
            } else {
                presentAlert("", msgStr: error?.localizedDescription, controller: self)
            }
            
        }
    }
    
}

