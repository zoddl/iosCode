//
//  LoginViewController.swift
//  ClickAccountingApp
//
//  Created by Deepak Kumar on 6/28/17.
//  Copyright © 2017 Mobiloitte. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleToolboxForMac
import FBSDKCoreKit
import FBSDKLoginKit


class LoginViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, GIDSignInUIDelegate, GIDSignInDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var footerView: UIView!
    @IBOutlet var headerView: UIView!
    @IBOutlet var rememberMeButton: UIButton!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var signupButton: UIButton!
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    
    var isFromSignUp: Bool = false
    
    
    var loginInfo = CAUserInfo()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialMethod()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.getTagsData()
        showRememberMe()
    }
    
    // MARK: - Helper methods
    func initialMethod() {
        
        self.navigationController?.isNavigationBarHidden = true
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.headerView.backgroundColor = UIColor.clear
        self.footerView.backgroundColor = UIColor.clear
        self.tableView.tableHeaderView = headerView
        self.tableView.tableFooterView = footerView
        
        self.tableView.allowsSelection=false;
        
        self.loginButton.layer.cornerRadius = 5
        self.signupButton.layer.cornerRadius = 5
        
        // For registereing nib
        self.tableView.register(UINib(nibName: "LoginTableViewCell", bundle: nil), forCellReuseIdentifier: "LoginTableViewCell")
        
        //Google Set up
        GIDSignIn.sharedInstance().clientID = "610475345468-034ab2pe0ggp2r9rpe6cqnq739nqo65b.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/plus.login")
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/plus.me")
        
    }
    
    func  doRememberMe() {
        if self.rememberMeButton.isSelected {
            UserDefaults.standard.set(loginInfo.emailString, forKey: kEmail)
            UserDefaults.standard.set(loginInfo.passwordString, forKey: kPassword)
            
        } else {
            UserDefaults.standard.removeObject(forKey: kEmail)
            UserDefaults.standard.removeObject(forKey: kPassword)
            
        }
    }
    
    func showRememberMe() {
        
        if  (((UserDefaults.standard.object(forKey: kEmail) as! String?) != nil) && ((UserDefaults.standard.object(forKey: kPassword) as! String?) != nil)) {
            loginInfo.emailString = (UserDefaults.standard.object(forKey: kEmail) as! String?)!
            loginInfo.passwordString = (UserDefaults.standard.object(forKey: kPassword) as! String?)!
            self.rememberMeButton.isSelected = true
            if ((UserDefaults.standard.object(forKey: kID) as! String?) != nil){
                self.goToHome()
            }
        } else {
            loginInfo.emailString = ""
            loginInfo.passwordString = ""
            self.rememberMeButton.isSelected = false
        }
    }
    
    func goToHome(){
        let appDelegateSharedManager = UIApplication.shared.delegate as! AppDelegate
        self.navigationController?.pushViewController(appDelegateSharedManager.addSidePanelControllerOnNavigation(), animated: true)
    }
    
    // MARK: - UITableViewDataSource Methods.
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LoginTableViewCell", for: indexPath) as? LoginTableViewCell
        
        cell?.backgroundColor = UIColor.clear
        cell?.loginTextField.autocorrectionType = .no
        cell?.loginTextField.delegate = self as UITextFieldDelegate
        cell?.loginTextField.keyboardType = .default
        cell?.loginTextField.returnKeyType = .next
        cell?.loginTextField.tag = indexPath.row + 100;
        
        switch indexPath.row
        {
        case 0:
            if loginInfo.emailErrorString.length != 0
            {
                cell?.errorLabel.text = loginInfo.emailErrorString
                cell?.sepratorLabel.backgroundColor = RGBA(246.0, g: 23.0, b: 0.0, a: 1.0)
            }else
            {
                cell?.errorLabel.text = ""
                cell?.sepratorLabel.backgroundColor = RGBA(17.0, g: 43.0, b: 88.0, a: 1.0)
            }
            cell?.loginImageView.image = UIImage(named: "msg")
            cell?.loginTextField.placeHolderText(withColor: "Email ID / New User Email ID", andColor: RGBA(17, g: 43, b: 88, a: 1))
            cell?.loginTextField.keyboardType = .emailAddress
            cell?.loginTextField.text = loginInfo.emailString
        default:
            if loginInfo.passwordErrorString.length != 0 {
                cell?.errorLabel.text = loginInfo.passwordErrorString
                cell?.sepratorLabel.backgroundColor = RGBA(246.0, g: 23.0, b: 0.0, a: 1.0)
            }else{
                cell?.errorLabel.text = ""
                cell?.sepratorLabel.backgroundColor = RGBA(17.0, g: 43.0, b: 88.0, a: 1.0)
            }
            cell?.loginImageView.image = UIImage(named: "password")
            cell?.loginTextField.placeHolderText(withColor: "Password / New User Password", andColor: RGBA(17.0, g: 43.0, b: 88.0, a: 1.0))
            cell?.loginTextField.returnKeyType = .done
            cell?.loginTextField.isSecureTextEntry = true
            cell?.loginTextField.text = loginInfo.passwordString
        }
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.row == 0 {
            if  loginInfo.emailErrorString.trimWhiteSpace().length == 0 {
                return 60
            }else{
                return 80
            }
            
        }
        else
        {
            if  loginInfo.passwordErrorString.trimWhiteSpace().length == 0
            {
                return 60
            }else
            {
                return 80
            }
        }
    }
    
    //MARK: - UITextFieldDelegates Methods.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        if (textField.textInputMode?.primaryLanguage == "emoji") || !((textField.textInputMode?.primaryLanguage) != nil) {
            return false
        }
        var str:NSString = textField.text! as NSString
        str = str.replacingCharacters(in: range, with: string) as NSString
        switch textField.tag {
        case 100:
            if str.length > 80
            {
                return false
            }
        case 101:
            if str.length > 16 {
                return false
            }
            break
        default:
            break
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case 100:
            loginInfo.emailString = textField.text!
            break
            
        case 101:
            loginInfo.passwordString = textField.text!
            
            break
        default:
            break;
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next {
            let tf: UITextField? = (view.viewWithTag(textField.tag + 1) as? UITextField)
            tf?.becomeFirstResponder()
        }
        else {
            view.endEditing(true)
        }
        return true
    }
    
    //MARK: - validation Methods.
    func isallFieldsVerfield() -> Bool {
        var isvalid = false
        loginInfo.emailErrorString = ""
        loginInfo.passwordErrorString = ""
        if loginInfo.emailString.trimWhiteSpace().length == 0
        {
            loginInfo.emailErrorString = "*Please enter your email ID."
            isvalid = false
            
        }else if loginInfo.emailString.isEmail() == false {
            loginInfo.emailErrorString = "*Please enter valid email ID."
            isvalid = false
            
        }else if loginInfo.passwordString.trimWhiteSpace().length == 0 {
            loginInfo.passwordErrorString = "*Please enter password."
            isvalid = false
            
        }else if loginInfo.passwordString.length < 8  {
            loginInfo.passwordErrorString = "*Password must be of atleast 8 characters."
            isvalid = false
            
        }else{
            isvalid = true
        }
        self.tableView.reloadData()
        return isvalid;
    }
    
    
    //MARK: - UIButtonAction
    
    @IBAction func rememberMeButtonAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func forgotPasswordButtonAction(_ sender: UIButton) {
        let forgotPass = CAForgotPasswordViewController()
        navigationController?.pushViewController(forgotPass, animated: true)
    }
    
    @IBAction func signUpButtonAction(_ sender: UIButton)
    {
        self.view.endEditing(true)
        if  isallFieldsVerfield() {
            callWebMethodAPIToSignUp()
        }
    }
    
    @IBAction func loginButtonAction(_ sender: UIButton) {
        
        self.view.endEditing(true)
        if  isallFieldsVerfield() {
            callWebMethodAPIToLogin(loginType: "m", socialId: "", email: loginInfo.emailString)
        }
    }
    
    @IBAction func facebookButtonAction(_ sender: UIButton) {
        
        let loginManager = FacebookManager()
        loginManager.getFacebookInfoWithCompletionHandler(self) { (result, errorreceived) in
        
            if ((errorreceived) == nil)
            {
                let userData = result! as NSDictionary
                print(userData .value(forKey: "id")!)
                print(userData .value(forKey: "name")!)
                print(userData .value(forKey: "email")!)
                self.callWebMethodAPIToLogin(loginType: "f", socialId: (userData .value(forKey: "id")! as! String), email: (userData .value(forKey: "email")! as! String))
            }
           
        };
        
        
    }
    
    
    @IBAction func gmailLoginButtonAction(_ sender: GIDSignInButton) {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().shouldFetchBasicProfile = true;
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance() .signIn()
    }
    
    // MARK: - Memory Warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK:Login  Web Service Integration
    func callWebMethodAPIToLogin( loginType: String, socialId: String, email :String) {
        
        let paramDict : Dictionary<String, AnyObject> = [
            
            // kServiceType : ((isLogin) ? "logIn" : "signUp") as AnyObject ,
            kEmail : email as AnyObject ,
            kPassword : loginInfo.passwordString as AnyObject ,
            kDeviceToken : kUserDefaults.value(forKey: kDeviceToken) as AnyObject,
            kDeviceType : kTypeIOS as AnyObject ,
            kDeviceID : UIDevice.current.identifierForVendor?.uuidString as AnyObject,
            kLoginType : loginType as AnyObject,
            kSocialId : socialId as AnyObject,
            ]
        
        
        ServiceHelper.sharedInstanceHelper.createPostRequest(method: .post, showHud: true, params: paramDict, apiName: "Customer_Api/customerlogin") { (result, error) in
            
            if(!(error != nil)){
                if (result![kResponseCode]! as? String == "200"){
                    self.doRememberMe()
                    let resultDict:Dictionary<String, AnyObject> = result as! Dictionary
                    let userDict:Dictionary<String, AnyObject> =
                        resultDict[kCustomerDetail]! as! Dictionary<String, AnyObject>
                    UserDefaults.standard.set(userDict[kID] as! String, forKey: kID)
                    if(userDict[kPaidStatus] != nil){
                        UserDefaults.standard.set(Int(userDict[kPaidStatus] as! String), forKey: kPaidStatus)
                    }
                    UserDefaults.standard.set(userDict[kAuthtoken] as! String, forKey: kAuthtoken)
                    UserDefaults.standard.synchronize()
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.getTagsData()
                    self.goToHome()
                 
                    print(userDict)
                    
                }
                else {
                    presentAlert(kZoddl, msgStr: result![kResponseMessage]! as? String, controller: self)
                }
                
            } else {
                presentAlert("", msgStr: error?.localizedDescription, controller: self)
            }
            
        }
        
    }
    
    
    
    //MARK:Sign Up  Web Service Integration
    func callWebMethodAPIToSignUp() {
        
        let paramDict : Dictionary<String, AnyObject> = [
            
            kEmail : loginInfo.emailString as AnyObject ,
            kPassword : loginInfo.passwordString as AnyObject ,
            kLoginType : "m" as AnyObject,
            ]
        
        
        ServiceHelper.sharedInstanceHelper.createPostRequest(method: .post, showHud: true, params: paramDict, apiName: "Customer_Api/customersignup") { (result, error) in
            
            if(!(error != nil)){
                if (result![kResponseCode]! as? String == "200"){
                    presentAlert("Congratulations!", msgStr: result![kResponseMessage]! as? String, controller: self)
                }
                else {
                    presentAlert(kZoddl, msgStr: result![kResponseMessage]! as? String, controller: self)
                }
                
            } else {
                presentAlert("", msgStr: error?.localizedDescription, controller: self)
            }
            
        }
        
    }
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user: GIDGoogleUser!, withError error: NSError!) {
        
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            self.callWebMethodAPIToLogin(loginType: "g", socialId: userId!, email: email!)

            
            logInfo("userID\(userId)\nIDToken:\(idToken)\nfullName:\(fullName)\ngivenName:\(givenName)\nfamilyName:\(familyName)\nemail:\(email)")
            // ...
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
}
