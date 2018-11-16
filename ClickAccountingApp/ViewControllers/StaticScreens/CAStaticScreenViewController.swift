

//
//  CAStaticScreenViewController.swift
//  ClickAccountingApp
//
//  Created by Chandan Mishra on 29/06/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit

class CAStaticScreenViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var backButton: UIButton!
    @IBOutlet weak var navTitle: UILabel!
    
    var stringNav: String = ""
    var loadURL: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.delegate = self
 
        
        if stringNav == "How It Works" {
            activityIndicator.startAnimating()
            self.backButton.setImage(UIImage(named: "icon34"), for: .normal)
            loadURL = URL(string:"http://howitworks.zoddl.com")
            let request = NSURLRequest.init(url: loadURL)
            webView.loadRequest(request as URLRequest)
        }
        else if stringNav == "FAQ's"{
            activityIndicator.startAnimating()
            self.backButton.setImage(UIImage(named: "icon34"), for: .normal)
            loadURL = URL(string: "faq.zoddl.com")!
            webView.loadRequest(URLRequest(url: URL(string: "http://faq.zoddl.com")!))
        }
        else
        {
            activityIndicator.startAnimating()
            self.backButton.setImage(UIImage(named: "icon34"), for: .normal)
           // loadURL = URL(string: kBaseURL.appending("/howitswork"))!
            loadURL = URL(string: "http://aboutus.zoddl.com")!
            let request = NSURLRequest.init(url: loadURL)
            webView.loadRequest(request as URLRequest)
        }
        navTitle.text = stringNav
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func menuButtonAction(_ sender: UIButton) {
        if stringNav == "How It Works" || stringNav == "FAQ's" {
            let appDelegateShared : AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegateShared.menuViewController .toggle()
            
        } else  {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print(error)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicator.stopAnimating()
        activityIndicator.hidesWhenStopped = true
        
    }
    
}
