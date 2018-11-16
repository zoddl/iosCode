//
//  CALogOutPopUpViewController.swift
//  ClickAccountingApp
//
//  Created by Sunil Datt Joshi on 04/07/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit
import SDWebImage


//MARK: - Custom Protocol for logout
protocol logOutDelegate: class {
    
func callLogOut()
    
}

class CALogOutPopUpViewController: UIViewController {

    @IBOutlet weak var logOutView: UIView!
    
    weak var delegate: logOutDelegate?
    
    //MARK: - UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logOutView.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
   //MARK: - UIButton Action
    @IBAction func yesButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        let appDelegateShared : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegateShared.menuViewController = nil
        appDelegateShared.navController?.popToRootViewController(animated: true)
        delegate?.callLogOut()
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk()
    }
    
    @IBAction func noButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
