//
//  SLSignInViewController.swift
//  Skylock
//
//  Created by Andre Green on 5/28/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLSignInViewController: UIViewController {
    let buttonSpacer:CGFloat = 20
    
    lazy var logoView:UIImageView = {
        let image = UIImage(named: "placeholder_logo_animation")!
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
        button.setImage(image, forState: UIControlState.Normal)
        button.addTarget(
            self,
            action: #selector(signUpWithFacebookButtonPressed),
            forControlEvents: UIControlEvents.TouchDown
        )
        
        return button
    }()

    lazy var existingUserButton:UIButton = {
        let frame = CGRect(
            x: CGRectGetMinX(self.signUpWithFacebookButton.frame),
            y: CGRectGetMinY(self.signUpWithFacebookButton.frame)
                - self.signUpWithFacebookButton.bounds.size.height - self.buttonSpacer,
            width: self.signUpWithFacebookButton.bounds.size.width,
            height: self.signUpWithFacebookButton.bounds.size.height
        )
        
        let button:UIButton = UIButton(type: UIButtonType.System)
        button.frame = frame
        button.backgroundColor = UIColor.clearColor()
        button.setTitle(NSLocalizedString("LOG IN", comment: ""), forState: .Normal)
        button.setTitleColor(UIColor.color(87, green: 216, blue: 255), forState: .Normal)
        button.titleLabel?.font = UIFont(name: SLFont.MontserratRegular.rawValue, size: 14.0)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.color(87, green: 216, blue: 255).CGColor
        button.addTarget(
            self,
            action: #selector(existingUserButtonPressed),
            forControlEvents: UIControlEvents.TouchDown
        )
        
        return button
    }()

    lazy var signUpWithEmailButton:UIButton = {
        let frame = CGRect(
            x: CGRectGetMinX(self.signUpWithFacebookButton.frame),
            y: CGRectGetMinY(self.existingUserButton.frame)
                - self.signUpWithFacebookButton.bounds.size.height - self.buttonSpacer,
            width: self.signUpWithFacebookButton.bounds.size.width,
            height: self.signUpWithFacebookButton.bounds.size.height
        )
        
        let button:UIButton = UIButton(type: UIButtonType.System)
        button.frame = frame
        button.backgroundColor = UIColor.color(87, green: 216, blue: 255)
        button.setTitle(NSLocalizedString("SIGN UP", comment: ""), forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.titleLabel?.font = UIFont(name: SLFont.MontserratRegular.rawValue, size: 14.0)
        button.addTarget(
            self,
            action: #selector(signUpWithEmailButtonPressed),
            forControlEvents: UIControlEvents.TouchDown
        )
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.view.addSubview(self.logoView)
        self.view.addSubview(self.existingUserButton)
        self.view.addSubview(self.signUpWithEmailButton)
        self.view.addSubview(self.signUpWithFacebookButton)
    }
    
    func existingUserButtonPressed() {
        let createAccountVC = SLCreateAccountViewController(phase: SLCreateAccountFieldPhase.SignIn)    
        self.presentViewController(createAccountVC, animated: true, completion: nil)
    }
    
    func signUpWithEmailButtonPressed() {
        let createAccountVC = SLCreateAccountViewController(phase: SLCreateAccountFieldPhase.Create)
        self.presentViewController(createAccountVC, animated: true, completion: nil)
    }
    
    func signUpWithFacebookButtonPressed() {
        let facebookManager:SLFacebookManger = SLFacebookManger.sharedManager() as! SLFacebookManger
        facebookManager.loginFromViewController(self) { (success) in
            if success {
                let userDefaults = NSUserDefaults.standardUserDefaults()
                userDefaults.setBool(true, forKey: "SLUserDefaultsSignedIn")
                userDefaults.synchronize()
                
                let lockManager:SLLockManager = SLLockManager.sharedManager() as! SLLockManager
                if lockManager.hasLocksForCurrentUser() {
                    let lvc = SLLockViewController()
                    self.presentViewController(lvc, animated: true, completion: nil)
                } else {
                    let clvc = SLConnectLockInfoViewController()
                    let nc:UINavigationController = UINavigationController(rootViewController: clvc)
                    nc.navigationBar.barStyle = UIBarStyle.Black
                    nc.navigationBar.tintColor = UIColor.whiteColor()
                    nc.navigationBar.barTintColor = UIColor(red: 130, green: 156, blue: 178)
                    self.presentViewController(nc, animated: true, completion: nil)
                }
            } else {
                // TODO: Handle error in UI
            }
        }
    }
}
