//
//  SLFirmwareUpdateViewController.swift
//  Ellipse
//
//  Created by Andre Green on 8/8/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit
enum SLFirmwareUpdateStage {
    case Available
    case InProgress
}

class SLFirmwareUpdateViewController: UIViewController {
    let xPadding:CGFloat = 25.0
    
    let buttonHeight:CGFloat = 55.0
    
    var stage:SLFirmwareUpdateStage = .Available
    
    let updateText:[SLFirmwareUpdateStage:String] = [
        .Available: NSLocalizedString("Frimware update available", comment: ""),
        .InProgress: NSLocalizedString("Firmware update in progress", comment: "")
    ]
    
    // This should be passed in in the initialzer once it is implemnted on the server
    let newFeatures:[String] = [String]()
    
    lazy var updateLabel:UILabel = {
        let frame = CGRect(
            x: self.xPadding,
            y: 40.0,
            width: self.view.bounds.size.width - 2*self.xPadding,
            height: 17.0
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.font = UIFont(name: SLFont.MontserratRegular.rawValue, size: 14.0)
        label.text = self.updateText[self.stage]
        label.textColor = UIColor.whiteColor()
        
        return label
    }()
    
    lazy var progressLabel:UILabel = {
        let frame = CGRect(
            x: self.xPadding,
            y: CGRectGetMaxY(self.updateLabel.frame) + 40.0,
            width: self.view.bounds.size.width - 2*self.xPadding,
            height: 13.0
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.font = UIFont(name: SLFont.OpenSansRegular.rawValue, size: 11.0)
        label.text = NSLocalizedString("Progress", comment: "") + "..."
        label.textColor = UIColor.whiteColor()
        label.hidden = self.stage == .Available
        
        return label
    }()
    
    lazy var progressBar:SLFirmwareUpdateProgressBarView = {
        let frame = CGRect(
            x: self.xPadding,
            y: CGRectGetMaxY(self.progressLabel.frame) + 20.0,
            width: self.view.bounds.size.width - 2*self.progressBar.bounds.size.width,
            height: 10.0
        )
        
        let bar:SLFirmwareUpdateProgressBarView = SLFirmwareUpdateProgressBarView(frame: frame)
        return bar
    }()
    
    lazy var updateLaterButton:UIButton = {
        let frame = CGRectMake(
            0.0,
            self.view.bounds.size.height - self.buttonHeight,
            0.5*self.view.bounds.size.width,
            self.buttonHeight
        )
        
        let button:UIButton = UIButton(type: .System)
        button.frame = frame
        button.setTitle(NSLocalizedString("LATER", comment: ""), forState: .Normal)
        button.setTitleColor(UIColor(red: 188, green: 187, blue: 187), forState: .Normal)
        button.backgroundColor = UIColor(red: 231, green: 231, blue: 233)
        button.addTarget(self, action: #selector(updateLaterButtonPressed), forControlEvents: .TouchDown)
        
        return button
    }()
    
    lazy var updateNowButton:UIButton = {
        let frame = CGRectMake(
            0.5*self.view.bounds.size.width,
            self.view.bounds.size.height - self.buttonHeight,
            0.5*self.view.bounds.size.width,
            self.buttonHeight
        )
        
        let button:UIButton = UIButton(type: .System)
        button.frame = frame
        button.setTitle(NSLocalizedString("UPDATE NOW", comment: ""), forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.backgroundColor = UIColor(red: 87, green: 216, blue: 255)
        button.addTarget(self, action: #selector(updateNowButtonPressed), forControlEvents: .TouchDown)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.updateLabel)
        self.view.addSubview(self.progressBar)
        self.view.addSubview(self.progressBar)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(updateFirmware(_:)),
            name: kSLNotificationLockManagerFirmwareUpdateState,
            object: nil
        )
    }
    
    func setFirmwareStage(stage: SLFirmwareUpdateStage) {
        self.stage = stage
        self.updateViewsForStage()
    }
    
    func updateViewsForStage() {
        self.progressBar.hidden = self.stage == .Available
    }
    
    func updateLaterButtonPressed() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateNowButtonPressed() {
        self.updateLaterButton.enabled = false
        self.updateLaterButton.enabled = false
        self.stage = .InProgress
        self.updateLabel.text = self.updateText[self.stage]
        let lockManager:SLLockManager = SLLockManager.sharedManager() as! SLLockManager
        lockManager.updateFirmware()
    }
    
    func updateFirmware(notification: NSNotification) {
        guard let progress = notification.object as? NSNumber else {
            return
        }
        
        self.progressBar.updateBarWithRatio(progress.doubleValue)
    }
}
