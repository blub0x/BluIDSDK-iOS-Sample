//
//  LoginViewController.swift
//  BluIDSDK Sample App
//
//  Created by developer on 26/04/21.
//

import UIKit
import CoreBluetooth
import BluIDSDK
import CoreData
import CryptoKit

class LoginViewController: UIViewController {
    
    var m_BluIDSDKClient: BluIDSDK?
    var m_onLogin: ((String) -> Void)?
    var m_onBack: (() -> Void)?
    var m_userData: UserData?
    var m_userDB = UserLoginDB()
    
    @IBOutlet weak var rememberSwitch: UISwitch!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var ErrorLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard (UIApplication.shared.delegate as? AppDelegate) != nil else {
          return
        }
        if let userLoginDetails = m_userDB.getUserDetails() {
            DispatchQueue.main.async {
                self.userNameTextField.text = userLoginDetails.userName
                self.passwordTextField.text = userLoginDetails.password
                self.rememberSwitch.isOn = userLoginDetails.remember
            }
        }
    }
    
    @IBAction func loginButton(_ sender: Any) {
        if !self.rememberSwitch.isOn {
            self.m_userDB.clear()
        } else {
            self.m_userDB.save(userDetails: UserLoginDetails(userName: self.userNameTextField.text ?? "",
                                                        password: self.passwordTextField.text ?? "",
                                                        remember: self.rememberSwitch.isOn))
        }
        let userCredentials = UserCredentials(userName: userNameTextField.text ?? "", password: passwordTextField.text ?? "")
        let progessbar = CommonUtils.showProgressBar(view: self, message: "Signing In")
            self.m_BluIDSDKClient?.login(credentials: userCredentials,onResponse: { loginError, loginData in
                CommonUtils.dismissProgressBar(progressBar: progessbar) {
                }
                self.loginResponseHandler(error: loginError, data: loginData)
            })
    }
    
    public func setBluIDSDK(sdk: BluIDSDK){
        m_BluIDSDKClient=sdk;
    }
    
    func loginResponseHandler(error: BluIDSDKError?, data: UserData?) -> Void{
        if let _error = error {
            DispatchQueue.main.async() {
                self.showError(errorTxt: "\(_error)")
            }
            return
        }
        guard let _data = data else {
            DispatchQueue.main.async() {
                self.showError(errorTxt: "Login Failed!")
            }
            return
        }
        print("userName::\(_data.userName ?? "")")
        m_BluIDSDKClient?.syncPersonCards(onComplete: { credError, personCards in
            debugPrint("\(String(describing: credError)) personCards \(String(describing: personCards?.count))")
            DispatchQueue.main.async() {
                self.ErrorLabel.text = ""
                if !self.rememberSwitch.isOn {
                    self.passwordTextField.text = ""
                    self.userNameTextField.text = ""
                }
                self.m_onLogin?(_data.userName ?? "")
            }
        })
    }
    
    @IBAction func loginPageBack(_ sender: Any) {
        m_onBack?()
    }
    @IBAction func onRemeberSwitchClicked(_ sender: UISwitch) {
    }
    
    func showError(errorTxt:String){
        self.ErrorLabel.text=errorTxt
        self.view.backgroundColor = .red
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
           // Excecute after 3 seconds
            self.view.backgroundColor = .none
        }
    }
}
