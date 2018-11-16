//
//  ServiceHelper.swift
//  ClickAccountingApp
//
//  Created by Ratneshwar Singh on 7/7/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import Foundation
import Alamofire
import AWSS3
import AWSCore



final class ServiceHelper {
    
    let user = "clickaccounting"
    let password = "Mobi@click"
    
    //shared instance of Class
    class var sharedInstanceHelper: ServiceHelper {
        struct Static {
            static let instance = ServiceHelper()
        }
        return Static.instance
    }
    
    
    /// Create Request for webservice
    ///
    /// - Parameters:
    ///   - method: request type (post, get, put)
    ///   - params: request parameters
    ///   - apiName: api name to create url
    ///   - completionHandler: closure
    
    
    func createPostRequest(method: HTTPMethod,showHud :Bool, params: [String: AnyObject]!, apiName: String, completionHandler:@escaping (_ response: AnyObject?, _ error: NSError?) -> Void) {
        
        if showHud {
            self.showHud()
        }
        let url = kBaseURL + apiName
        let parameterDict = params as NSDictionary
        
        logInfo("Reqeust Url:\(url)")
        logInfo("Request Parameters:\(parameterDict)")
        
        
        Alamofire.request(url, method: method, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { response in
            switch response.result {
            case .success(_):
                self.hideHud()
                print(response.result.value as AnyObject?!)
                completionHandler(response.result.value as AnyObject?, nil)
            case .failure(_):
                self.hideHud()
                print(response.result.value as AnyObject? as Any)
                print(response.result.error as AnyObject? as Any)

                completionHandler(nil, response.result.error as NSError?)
            }
        }
    }
    
    func postAction()
    {
        
        let headers = [
            "content-type": "application/json",
            "cache-control": "no-cache",
            "postman-token": "5dc13c34-a410-cc81-916c-82ccae059d09"
        ]
        
        let parameters : Dictionary<String, AnyObject> = [
            kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject) ,
            ]
      //  var request = URLRequest(url: serviceUrl)
        
        
//        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {
//            return
//        }
   //     let requestString = NSString(data: httpBody, encoding: String.Encoding.utf8.rawValue)
     //   request.httpBody = requestString?.data(using: String.Encoding.utf8.rawValue)
    
        
       // let parameters = ["Authtoken": "dsfsdfsdfsd"] as [String : Any]
        
        let postData = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        
        let request = NSMutableURLRequest(url: NSURL(string: "http://13.127.139.247/Customer_Api/getUserProfile")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let httpResponse = response as? HTTPURLResponse
                if let data = data {
                    do
                    {
//                        let parsedData = try JSONSerialization.jsonObject(with: data as Data, options:[])
//                        print(parsedData)
                        let datastring = NSString(data: data , encoding: String.Encoding.utf8.rawValue)
                        print(datastring!)
                        
                    }catch {
                        print(error)
                    }
                }
            }
        })
        
        dataTask.resume()
        
//        let Url = String(format: "http://13.127.139.247/Customer_Api/getUserProfile")
//        guard let serviceUrl = URL(string: Url) else { return }
//
//        let parameterDictionary : Dictionary<String, AnyObject> = [
//            kAuthtoken :(UserDefaults.standard .value(forKey: kAuthtoken) as AnyObject) ,
//            ]
//        var request = URLRequest(url: serviceUrl)
//        request.httpMethod = "POST"
//
//
//        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {
//            return
//        }
//        let requestString = NSString(data: httpBody, encoding: String.Encoding.utf8.rawValue)
//        request.httpBody = requestString?.data(using: String.Encoding.utf8.rawValue)
//
//        let session = URLSession.shared
//        session.dataTask(with: request) { (data, response, error) in
//            if let response = response {
//                print(response)
//            }
//            if let data = data {
//                do
//                {
//                    let datastring = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
//                    print(datastring)
//
//                }catch {
//                    print(error)
//                }
//            }
//            }.resume()
    }
    
    

    //MARK:- HUD
    func showHud() {
        let attribute = RappleActivityIndicatorView.attribute(style: RappleStyleCircle, tintColor: .white, screenBG: nil, progressBG: .black, progressBarBG: .lightGray, progreeBarFill: .yellow)
        RappleActivityIndicatorView.startAnimating(attributes: attribute)
    }
    
    func hideHud() {
        RappleActivityIndicatorView.stopAnimation()
        RappleActivityIndicatorView.stopAnimation(completionIndicator: .none, completionLabel: "", completionTimeout: 1.0)
    }
    
    
    
    
    
    
    /****************************
     * Function Name : - uploadImageToS3WithThumbnail
     * Create on : - 30th Jan 2017
     * Developed By : - Abhishek Chauhan
     * Description : - This method is used for Upload image with thumbnail in 200x200 size.
     * Organisation Name :- Sirez
     * version no :- 1.0
     ****************************/
    
    
    
    func uploadImageToS3 (image : UIImage, fileName: String, completion:@escaping (_ response: AnyObject?, _ error:NSError?) -> Void) {
        
        let uuid = NSUUID()
        self.hideHud()
        
        print("inside-real-uploadImageToS3")
        
        var imageName = uuid.uuidString as NSString
        
        if (fileName != nil){
            if(fileName.length > 0){
                imageName  = fileName as NSString
            }
        }
        let uploadingFileURL  = NSHomeDirectory().appending("/tmp/") + (imageName as String)
        let imageURL : URL = URL.init(fileURLWithPath: uploadingFileURL)
        
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        try? imageData?.write(to: imageURL, options: .atomic)
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.bucket = kBucketName
        uploadRequest?.key = imageName as String
        uploadRequest?.body = imageURL
        
        let transferManager = AWSS3TransferManager.default()
        
        transferManager.upload(uploadRequest!).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
            
            if let error = task.error as NSError? {
                if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
                    switch code {
                    case .cancelled, .paused:
                        break
                    default:
                        print("Error uploading: \(String(describing: uploadRequest?.key)) Error: \(error)")
                    }
                } else {
                    print("Error uploading: \(String(describing: uploadRequest?.key)) Error: \(error)")
                }
                completion(nil, error as NSError?)
            }
            else
            {
                let uploadOutput = task.result
                print(uploadOutput as Any)
                print("Upload complete for: \(String(describing: uploadRequest?.key))")
                completion(uploadRequest, nil)
            }
            return nil
        })
    }
    
    
    
    /****************************
     * Function Name : - uploadThumbImageToS3
     * Create on : - 30th Jan 2017
     * Developed By : - Abhishek Chauhan
     * Description : - This method is used for Upload image with thumbnail in 200x200 size.
     * Organisation Name :- Sirez
     * version no :- 1.0
     ****************************/
    
    
    func uploadThumbImageToS3 (image : UIImage, fileName: String, completion:@escaping (_ response: AnyObject?, _ error:NSError?) -> Void) {
        
        let uuid = NSUUID()
        self.hideHud()
        
        var imageName = uuid.uuidString as NSString
        
        if (fileName != nil){
            if(fileName.length > 0){
                imageName  = fileName as NSString
            }
        }
        let uploadingFileURL  = NSHomeDirectory().appending("/tmp/") + (imageName as String)
        let imageURL : URL = URL.init(fileURLWithPath: uploadingFileURL)
        
        let imageData = UIImageJPEGRepresentation(image, 0.05)
        try? imageData?.write(to: imageURL, options: .atomic)
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.bucket = kBucketName
        uploadRequest?.key = imageName as String
        uploadRequest?.body = imageURL
        
        let transferManager = AWSS3TransferManager.default()
        
        transferManager.upload(uploadRequest!).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
            
            if let error = task.error as NSError? {
                if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
                    switch code {
                    case .cancelled, .paused:
                        break
                    default:
                        print("Error uploading: \(String(describing: uploadRequest?.key)) Error: \(error)")
                    }
                } else {
                    print("Error uploading: \(String(describing: uploadRequest?.key)) Error: \(error)")
                }
                self.hideHud()
                completion(nil, error as NSError?)
            }
            else
            {
                let uploadOutput = task.result
                print(uploadOutput as Any)
                print("Upload complete for: \(String(describing: uploadRequest?.key))")
                self.hideHud()
                completion(uploadRequest, nil)
            }
            return nil
        })
    }
    
    
    
    /****************************
     * Function Name : - uploadDocumentToS3
     * Create on : - 30th Jan 2017
     * Developed By : - Abhishek Chauhan
     * Description : - This method is used for Upload image with thumbnail in 200x200 size.
     * Organisation Name :- Sirez
     * version no :- 1.0
     ****************************/
    
    
    
    func uploadDocumentToS3 (documentPath: String, fileName: String, fileExtension: String, completion:@escaping (_ response: AnyObject?, _ error:NSError?) -> Void) {
        
        self.hideHud()
        print("inside- Upload Document")
        
        let uuid = NSUUID()
        var docName = uuid.uuidString as NSString
        
        if (fileName != nil){
            if(fileName.length > 0){
                docName  = fileName as NSString
            }
        }
       
        
        let docURL : URL = URL.init(fileURLWithPath: documentPath)
        let documentData = NSData(contentsOfFile: documentPath)
        try? documentData?.write(to: docURL, options: .atomic)
        
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.bucket = kBucketName
        uploadRequest?.key = (docName as String) + "." + fileExtension as String
        uploadRequest?.body = docURL
        
        let transferManager = AWSS3TransferManager.default()
        
        transferManager.upload(uploadRequest!).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
            
            if let error = task.error as NSError? {
                if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
                    switch code {
                    case .cancelled, .paused:
                        break
                    default:
                        print("Error uploading: \(String(describing: uploadRequest?.key)) Error: \(error)")
                    }
                } else {
                    print("Error uploading: \(String(describing: uploadRequest?.key)) Error: \(error)")
                }
                completion(nil, error as NSError?)
            }
            else
            {
                let uploadOutput = task.result
                print(uploadOutput as Any)
                print("Upload complete for: \(String(describing: uploadRequest?.key))")
                completion(uploadRequest, nil)
            }
            return nil
        })
    }
    
}



