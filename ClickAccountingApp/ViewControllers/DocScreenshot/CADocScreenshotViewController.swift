//
//  CADocScreenshotViewController.swift
//  ClickAccountingApp
//
//  Created by apptology on 2/2/18.
//  Copyright © 2018 Mobiloitte. All rights reserved.
//

import UIKit

protocol docScreenshotDelegate {
    func sendImageName(imageName : String)
}


class CADocScreenshotViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet var documentView: UIWebView!
    var screenshotDelegate: docScreenshotDelegate?
    var urlString: String = ""
    let webV = UIWebView()

    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        let docURL = URL(string: urlString)
        webV.frame  = CGRect(x: 0, y: 0, width:300, height: 300)
        webV.delegate = self
        let request = NSURLRequest.init(url: docURL!)
        webV.loadRequest(request as URLRequest)
       // self.view .addSubview(webV)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func takeScreenshot(){
        
        UIGraphicsBeginImageContext(view.frame.size)
        self.view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let fileManager = FileManager.default
        var uuid = CFUUIDCreateString(nil, CFUUIDCreate(nil)) as String
        uuid = uuid + ".jpg"
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(uuid)
        let imageData = UIImageJPEGRepresentation(image!, 0.5)
        fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
        fileManager.fileExists(atPath: paths)
        screenshotDelegate?.sendImageName(imageName: uuid)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("doc loaded")
        self.takeScreenshot()
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        print("Loading data")
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print("Doc with error")
    }
    

}
