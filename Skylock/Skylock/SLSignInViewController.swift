//
//  SLSignInViewController.swift
//  Skylock
//
//  Created by Andre Green on 5/28/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLSignInViewController: SLBaseViewController {
    let buttonSpacer:CGFloat = 20
    
    lazy var logoView:UIImageView = {
        let image = UIImage(named: "splash_screen_logo")!
        let view = UIImageView(image: image)
        view.frame = CGRect(
            x: 0.5*(self.view.bounds.size.width - image.size.width),
            y: 97,
            width: image.size.width,
            height: image.size.height
        )
        
        return view
    }()
    
    lazy var signUpWithFacebookButton:UIButton = {
        let image = UIImage(named: "button_sign_up_facebook_Onboarding")!
        let frame = CGRect(
            x: 0.5*(self.view.bounds.size.width - image.size.width),
            y: self.view.bounds.size.height - image.size.height - self.buttonSpacer,
            width: image.size.width,
            height: image.size.height
        )
        
        let button:UIButton = UIButton(frame: frame)
        button.setImage(image, for: UIControlState.normal)
        button.addTarget(
            self,
            action: #selector(signUpWithFacebookButtonPressed),
            for: UIControlEvents.touchDown
        )
        
        return button
    }()

    lazy var existingUserButton:UIButton = {
        let frame = CGRect(
            x: self.signUpWithFacebookButton.frame.minX,
            y: self.signUpWithFacebookButton.frame.minY
                - self.signUpWithFacebookButton.bounds.size.height - self.buttonSpacer,
            width: self.signUpWithFacebookButton.bounds.size.width,
            height: self.signUpWithFacebookButton.bounds.size.height
        )
        
        let button:UIButton = UIButton(type: UIButtonType.system)
        button.frame = frame
        button.backgroundColor = UIColor.clear
        button.setTitle(NSLocalizedString("LOG IN", comment: ""), for: .normal)
        button.setTitleColor(UIColor.color(87, green: 216, blue: 255), for: .normal)
        button.titleLabel?.font = UIFont(name: SLFont.MontserratRegular.rawValue, size: 14.0)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.color(87, green: 216, blue: 255).cgColor
        button.addTarget(
            self,
            action: #selector(existingUserButtonPressed),
            for: .touchDown
        )
        
        return button
    }()

    lazy var signUpWithEmailButton:UIButton = {
        let frame = CGRect(
            x: self.signUpWithFacebookButton.frame.minX,
            y: self.existingUserButton.frame.minY
                - self.signUpWithFacebookButton.bounds.size.height - self.buttonSpacer,
            width: self.signUpWithFacebookButton.bounds.size.width,
            height: self.signUpWithFacebookButton.bounds.size.height
        )
        
        let button:UIButton = UIButton(type: UIButtonType.system)
        button.frame = frame
        button.backgroundColor = UIColor.color(87, green: 216, blue: 255)
        button.setTitle(NSLocalizedString("SIGN UP", comment: ""), for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont(name: SLFont.MontserratRegular.rawValue, size: 14.0)
        button.addTarget(
            self,
            action: #selector(signUpWithEmailButtonPressed),
            for: .touchDown
        )
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        self.view.addSubview(self.logoView)
        self.view.addSubview(self.existingUserButton)
        self.view.addSubview(self.signUpWithEmailButton)
        self.view.addSubview(self.signUpWithFacebookButton)
    }
    
    func existingUserButtonPressed() {
        let createAccountVC = SLCreateAccountViewController(phase: SLCreateAccountFieldPhase.SignIn)    
        self.present(createAccountVC, animated: true, completion: nil)
    }
    
    func signUpWithEmailButtonPressed() {
        let createAccountVC = SLCreateAccountViewController(phase: SLCreateAccountFieldPhase.Create)
        self.present(createAccountVC, animated: true, completion: nil)
    }
    
    func signUpWithFacebookButtonPressed() {
        let facebookManager:SLFacebookManger = SLFacebookManger.sharedManager() as! SLFacebookManger
        facebookManager.login(from: self) { (success) in
            if success {
                let userDefaults = UserDefaults.standard
                userDefaults.set(true, forKey: "SLUserDefaultsSignedIn")
                userDefaults.synchronize()
                
                let lockManager:SLLockManager = SLLockManager.sharedManager
                if lockManager.hasLocksForCurrentUser() {
                    let lvc = SLLockViewController()
                    self.present(lvc, animated: true, completion: nil)
                } else {
                    let clvc = SLConnectLockInfoViewController()
                    let nc:UINavigationController = UINavigationController(rootViewController: clvc)
                    nc.navigationBar.barStyle = UIBarStyle.black
                    nc.navigationBar.tintColor = UIColor.white
                    nc.navigationBar.barTintColor = UIColor(red: 130, green: 156, blue: 178)
                    self.present(nc, animated: true, completion: nil)
                }
                
                lockManager.getCurrentUsersLocksFromServer(completion: nil)
            } else {
                let texts:[SLWarningViewControllerTextProperty:String?] = [
                    .Header: NSLocalizedString("Hmmm...Login Failed", comment: ""),
                    .Info: NSLocalizedString(
                        "Sorry. We couldn't log you in through Facebook right now. " +
                        "Please try again later, or you can sign in using your phone number and email.",
                        comment: ""
                    ),
                    .CancelButton: NSLocalizedString("OK", comment: ""),
                    .ActionButton: nil
                ]
                
                self.presentWarningViewControllerWithTexts(texts: texts, cancelClosure: nil)
            }
        }
    }
}
