//
//  SLSignInViewController.swift
//  Skylock
//
//  Created by Andre Green on 5/28/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLSignInViewController: UIViewController {
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

    lazy var existingUserButton:UIButton = {
        let image = UIImage(named: "button_log_in_Onboarding")!
        let frame = CGRect(
            x: 0.5*(self.view.bounds.size.width - image.size.width),
            y: CGRectGetMaxY(self.logoView.frame) + 63.0,
            width: image.size.width,
            height: image.size.height
        )
        
        let button:UIButton = UIButton(frame: frame)
        button.setImage(image, forState: UIControlState.Normal)
        button.addTarget(
            self,
            action: #selector(existingUserButtonPressed),
            forControlEvents: UIControlEvents.TouchDown
        )
        
        return button
    }()

    lazy var signUpWithEmailButton:UIButton = {
        let image = UIImage(named: "button_sign_up_email_Onboarding")!
        let frame = CGRect(
            x: 0.5*(self.view.bounds.size.width - image.size.width),
            y: self.view.bounds.size.height - image.size.height - 24.0,
            width: image.size.width,
            height: image.size.height
        )
        
        let button:UIButton = UIButton(frame: frame)
        button.setImage(image, forState: UIControlState.Normal)
        button.addTarget(
            self,
            action: #selector(signUpWithEmailButtonPressed),
            forControlEvents: UIControlEvents.TouchDown
        )
        
        return button
    }()
    
    lazy var signUpWithFacebookButton:UIButton = {
        let image = UIImage(named: "button_sign_up_facebook_Onboarding")!
        let frame = CGRect(
            x: 0.5*(self.view.bounds.size.width - image.size.width),
            y: CGRectGetMinY(self.signUpWithEmailButton.frame) - image.size.height - 20.0,
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.view.addSubview(self.logoView)
        self.view.addSubview(self.existingUserButton)
        self.view.addSubview(self.signUpWithEmailButton)
        self.view.addSubview(self.signUpWithFacebookButton)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let mvc = SLMapViewController()
        self.presentViewController(mvc, animated: false, completion: nil)
    }
    
    func existingUserButtonPressed() {
        let createAccountVC = SLCreateAccountViewController(phase: SLCreateAccountFieldPhase.Create)
        self.presentViewController(createAccountVC, animated: true, completion: nil)
    }
    
    func signUpWithEmailButtonPressed() {
        let createAccountVC = SLCreateAccountViewController(phase: SLCreateAccountFieldPhase.Create)
        self.presentViewController(createAccountVC, animated: true, completion: nil)
    }
    
    func signUpWithFacebookButtonPressed() {
        print("sign up with facebook button pressed")
        let facebookManager:SLFacebookManger = SLFacebookManger.sharedManager() as! SLFacebookManger
        facebookManager.loginFromViewController(self) { (success) in
            if success {
                let clvc = SLConnectLockInfoViewController()
                let navController:UINavigationController = UINavigationController(rootViewController: clvc)
                self.presentViewController(navController, animated: true, completion: nil)
            }
        }
    }
}
