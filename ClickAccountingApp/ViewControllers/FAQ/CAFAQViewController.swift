//
//  CAFAQViewController.swift
//  ClickAccountingApp
//
//  Created by Sunil Datt Joshi on 01/07/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit

class CAFAQViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,AddTagDelegate {
    
    @IBOutlet weak var faqTableView: UITableView!
    @IBOutlet weak var navigationTitleLabel: UILabel!
    
    var faqInfo = [CAContactUsInfo]()
    var questionLabel : String = "jdkfjdkljkldj?"
    var answerLabel : String = "efgefdsfdsfdsfdsfdsfds"
    var faqArray = [CAContactUsInfo]()
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialMethod()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Helper Methods
    func initialMethod() {
        
        self.navigationController?.isNavigationBarHidden = true
        self.faqTableView.allowsSelection = false
        self.faqTableView.estimatedRowHeight = 50
        self.faqTableView.rowHeight = UITableViewAutomaticDimension
        self.faqTableView.register(UINib(nibName:"CAFAQTableViewCell",bundle: nil), forCellReuseIdentifier:"CAFAQTableViewCell")
        let   dataSourceArray = [
            ["questionLabel": "Que.1  Loreum ipsum dolor sit amut, consecuter? " as AnyObject, "answerLabel": "Loreum ipsum dolor sit amut, consecuter Loreum ipsum dolor sit amut, consecuter Loreum ipsum dolor sit amut, consecuter Loreum ipsum dolor sit amut, consecuter" as AnyObject],
            
            ["questionLabel": "Que.2  Loreum ipsum dolor sit amut, consecuter? " as AnyObject, "answerLabel": "Loreum ipsum dolor sit amut, consecuter Loreum ipsum dolor sit amut, consecuter Loreum ipsum dolor sit amut, consecuter Loreum ipsum dolor sit amut, consecuter" as AnyObject],
            
            
            ["questionLabel": "Que.3  Loreum ipsum dolor sit amut, consecuter? " as AnyObject, "answerLabel": "Loreum ipsum dolor sit amut, consecuter Loreum ipsum dolor sit amut, consecuter Loreum ipsum dolor sit amut, consecuter Loreum ipsum dolor sit amut, consecuter" as AnyObject],
            
            
            ["questionLabel": "Que.4  Loreum ipsum dolor sit amut, consecuter? " as AnyObject, "answerLabel": "Loreum ipsum dolor sit amut, consecuter Loreum ipsum dolor sit amut, consecuter Loreum ipsum dolor sit amut, consecuter Loreum ipsum dolor sit amut, consecuter" as AnyObject]]
        
        self.faqArray = CAContactUsInfo.getFaqList(responseArray: dataSourceArray as! Array<Dictionary<String, String>>)
        
    }
    
    //MARK: - UITableViewDataSource Methods
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return faqArray.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell1 = tableView.dequeueReusableCell(withIdentifier: "CAFAQTableViewCell") as? CAFAQTableViewCell
        let faqInfo = faqArray[indexPath.row]
        
        let  myMutableString = NSMutableAttributedString(string: faqInfo.questionLabel)
        
        myMutableString.setAttributes([NSFontAttributeName : UIFont(name: "calibri", size: CGFloat(17.0))!
            , NSForegroundColorAttributeName : UIColor.black], range: NSRange(location:0,length:5)) // What ever range you want to give
        
        cell1?.faqQuestionLabel.attributedText = myMutableString
        cell1?.faqAnswerLabel.text =   faqInfo.answerLabel
        return cell1!
    }
    
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    //MARK: UIButton action
    @IBAction func backButtonAction(_ sender: Any) {
        let appDelegateShared : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegateShared.menuViewController .toggle()
    }
    @IBAction func addButtonAction(_ sender: Any) {
        
        let addTagPopUpVC: CAAddTagPopUpViewController = CAAddTagPopUpViewController(nibName:"CAAddTagPopUpViewController", bundle: nil)
        addTagPopUpVC.addTagDelegate = self
        addTagPopUpVC.navigationTitleString = "Add Manual"
        addTagPopUpVC.modalPresentationStyle = .overCurrentContext
        addTagPopUpVC.modalTransitionStyle = .crossDissolve
        self.present(addTagPopUpVC, animated: true, completion: nil)
       
    }
    
    @IBAction func searchButtonAction(_ sender: Any) {
        presentAlert("", msgStr: "work in progress..", controller: self)
    }
    
    //Mark Custom Delegate
    func addDelegateWithDetailsAndIsSubmit(details: NSString, isSubmit: Bool) {
        
    }
}
