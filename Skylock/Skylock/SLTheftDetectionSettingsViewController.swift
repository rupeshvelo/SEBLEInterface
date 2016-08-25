//
//  SLTheftDetectionSettingsViewController.swift
//  Skylock
//
//  Created by Andre Green on 6/10/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLTheftDetectionSettingsViewController: UIViewController {
    let lock:SLLock
    
    let xPadding:CGFloat = 25.0
    
    let user:SLUser = SLDatabaseManager.sharedManager().currentUser
    
    init(lock:SLLock) {
        self.lock = lock
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var sensitivityView:UIView = {
        let height:CGFloat = 66.0
        let frame = CGRect(
            x: 0.0,
            y: CGRectGetMidY(self.view.frame) - 0.5*height,
            width: self.view.bounds.size.width,
            height: height
        )
        
        let view:UIView = UIView(frame: frame)
        view.backgroundColor = UIColor(red: 247, green: 247, blue: 248)
        
        let labelHeight:CGFloat = 17.0
        let labelFrame = CGRect(
            x: 0.0,
            y: 0.5*(view.bounds.size.height - labelHeight),
            width: view.bounds.size.width,
            height: labelHeight
        )
        
        let label:UILabel = UILabel(frame: labelFrame)
        label.text = NSLocalizedString("SECURITY SENSITIVITY", comment: "")
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont(name: SLFont.MontserratRegular.rawValue, size: 14.0)
        label.textColor = UIColor(red: 140, green: 140, blue: 140)
        
        view.addSubview(label)
        
        return view
    }()
    
    lazy var infoView:UIView = {
        
        let yPadding:CGFloat = 24.0
        
        
        let y0 = self.navigationController!.navigationBar.bounds.size.height
            + UIApplication.sharedApplication().statusBarFrame.size.height
        let viewFrame = CGRect(
            x: 0.0,
            y: y0,
            width: self.view.bounds.size.width,
            height: CGRectGetMinY(self.sensitivityView.frame) - y0
        )
        
        let view:UIView = UIView(frame: viewFrame)
        view.backgroundColor = UIColor.whiteColor()
        
        let maxWidth = self.view.bounds.size.width - 2*self.xPadding
        let font = UIFont(name: SLFont.OpenSansRegular.rawValue, size: 14.0)!
        let text = NSLocalizedString(
            "Either theft or crash detection may be activated, but not both at the same time. " +
            "Both require that you are connected to your Ellipse with bluetooth.",
            comment: ""
        )
        let utility = SLUtilities()
        let labelSize:CGSize = utility.sizeForLabel(
            font,
            text: text,
            maxWidth: maxWidth,
            maxHeight: CGFloat.max,
            numberOfLines: 0
        )
        
        let frame = CGRectMake(
            self.xPadding,
            0.5*(view.bounds.size.height - labelSize.height),
            labelSize.width,
            labelSize.height
        )
        
        let label:UILabel = UILabel(frame:frame)
        label.text = text
        label.font = font
        label.textColor = UIColor(white: 155.0/255.0, alpha: 1.0)
        label.textAlignment = .Left
        label.numberOfLines = 0
        
        view.addSubview(label)

        return view
    }()
    
    lazy var slider:SLTouchSliderViewController = {
        let tsvc:SLTouchSliderViewController = SLTouchSliderViewController()
        return tsvc
    }()
    
    lazy var saveChangesButton:UIButton = {
        let height:CGFloat = 44.0
        let frame = CGRect(
            x: self.xPadding,
            y: self.view.bounds.size.height - 75.0 - height,
            width: self.view.bounds.size.width - 2*self.xPadding,
            height: height
        )
        
        let button:UIButton = UIButton(type: .System)
        button.frame = frame
        button.backgroundColor = UIColor(red: 87, green: 216, blue: 255)
        button.setTitle(NSLocalizedString("SAVE CHANGES", comment: ""), forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.addTarget(self, action: #selector(saveChangesButtonPressed), forControlEvents: .TouchDown)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.whiteColor()
        
        self.navigationItem.title = NSLocalizedString("THEFT DETECTION SETTINGS", comment: "")
        
        self.view.addSubview(self.sensitivityView)
        self.view.addSubview(self.infoView)
        self.view.addSubview(self.saveChangesButton)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !self.view.subviews.contains(self.slider.view) {
            let frame = CGRect(
                x: 0.0,
                y: CGRectGetMaxY(self.sensitivityView.frame) + 22.0,
                width: self.view.bounds.size.width,
                height: 36.0
            )
            self.slider.sliderValue = user.theftSensitivity == nil ? 0.0 : user.theftSensitivity!.doubleValue
            self.slider.view.frame = frame
            self.addChildViewController(self.slider)
            self.view.addSubview(self.slider.view)
            self.view.bringSubviewToFront(self.slider.view)
            self.slider.didMoveToParentViewController(self)
        }
    }
    
    func saveChangesButtonPressed() {
        user.theftSensitivity = NSNumber(double: self.slider.getSliderValue())
        let dbManager:SLDatabaseManager = SLDatabaseManager.sharedManager() as! SLDatabaseManager
        dbManager.saveUser(user, withCompletion: nil)
        self.navigationController?.popViewControllerAnimated(true)
    }
}
