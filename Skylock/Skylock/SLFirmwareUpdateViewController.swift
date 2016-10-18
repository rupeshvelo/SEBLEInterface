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
    case Finished
}

class SLFirmwareUpdateViewController: SLBaseViewController {
    let xPadding:CGFloat = 25.0
    
    let buttonHeight:CGFloat = 55.0
    
    var stage:SLFirmwareUpdateStage = .Available
    
    let updateText:[SLFirmwareUpdateStage:String] = [
        .Available: NSLocalizedString("Firmware update available", comment: ""),
        .InProgress: NSLocalizedString("Firmware update in progress", comment: ""),
        .Finished: NSLocalizedString("All Done! Restarting your Ellipse...", comment: "")
    ]
    
    // This should be passed in in the initialzer once it is implemnted on the server
    let newFeatures:[String] = [String]()
    
    override var preferredStatusBarStyle:UIStatusBarStyle {
        return .lightContent
    }
    
    lazy var updateLabel:UILabel = {
        let frame = CGRect(
            x: self.xPadding,
            y: 100.0,
            width: self.view.bounds.size.width - 2*self.xPadding,
            height: 17.0
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.font = UIFont(name: SLFont.MontserratRegular.rawValue, size: 14.0)
        label.text = self.updateText[self.stage]
        label.textColor = UIColor.white
        
        return label
    }()
    
    lazy var progressLabel:UILabel = {
        let frame = CGRect(
            x: self.xPadding,
            y: self.updateLabel.frame.maxY + 20.0,
            width: self.view.bounds.size.width - 2*self.xPadding,
            height: 17.0
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.font = UIFont(name: SLFont.OpenSansRegular.rawValue, size: 11.0)
        label.text = NSLocalizedString("Progress", comment: "") + "..."
        label.textColor = UIColor.white
        label.isHidden = self.stage == .Available
        
        return label
    }()
    
    lazy var progressBar:SLFirmwareUpdateProgressBarView = {
        let frame = CGRect(
            x: self.xPadding,
            y: self.progressLabel.frame.maxY + 5.0,
            width: self.view.bounds.size.width - 2*self.xPadding,
            height: 10.0
        )
        
        let bar:SLFirmwareUpdateProgressBarView = SLFirmwareUpdateProgressBarView(frame: frame)
        bar.isHidden = true
        
        return bar
    }()
    
    lazy var updateLaterButton:UIButton = {
        let frame = CGRect(
            x: 0.0,
            y: self.view.bounds.size.height - self.buttonHeight,
            width: 0.5*self.view.bounds.size.width,
            height: self.buttonHeight
        )
        
        let button:UIButton = UIButton(type: .system)
        button.frame = frame
        button.setTitle(NSLocalizedString("LATER", comment: ""), for: .normal)
        button.setTitleColor(UIColor(red: 188, green: 187, blue: 187), for: .normal)
        button.backgroundColor = UIColor(red: 231, green: 231, blue: 233)
        button.addTarget(self, action: #selector(updateLaterButtonPressed), for: .touchDown)
        
        return button
    }()
    
    lazy var updateNowButton:UIButton = {
        let frame = CGRect(
            x: 0.5*self.view.bounds.size.width,
            y: self.view.bounds.size.height - self.buttonHeight,
            width: 0.5*self.view.bounds.size.width,
            height: self.buttonHeight
        )
        
        let button:UIButton = UIButton(type: .system)
        button.frame = frame
        button.setTitle(NSLocalizedString("UPDATE NOW", comment: ""), for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor(red: 87, green: 216, blue: 255)
        button.addTarget(self, action: #selector(updateNowButtonPressed), for: .touchDown)
        
        return button
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 60, green: 83, blue: 119)
        
        self.view.addSubview(self.updateLabel)
        self.view.addSubview(self.progressLabel)
        self.view.addSubview(self.progressBar)
        self.view.addSubview(self.updateLaterButton)
        self.view.addSubview(self.updateNowButton)
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: kSLNotificationLockManagerFirmwareUpdateState),
            object: nil,
            queue: nil,
            using: updateFirmware
        )
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: kSLNotificationLockManagerEndedFirmwareUpdate),
            object: nil,
            queue: nil,
            using: firmwareUpdateComplete
        )
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: kSLNotificationLockManagerDisconnectedLock),
            object: nil,
            queue: nil,
            using: disconnectedLock
        )
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: kSLNotificationLockPaired),
            object: nil,
            queue: nil,
            using: lockPaired
        )
    }
    
    func setFirmwareStage(stage: SLFirmwareUpdateStage) {
        self.stage = stage
        self.updateViewsForStage()
    }
    
    func updateViewsForStage() {
        self.progressBar.isHidden = self.stage == .Available
    }
    
    func updateLaterButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateNowButtonPressed() {
        self.stage = .InProgress
        self.updateLabel.text = self.updateText[self.stage]
        self.progressLabel.isHidden = false
        self.progressBar.isHidden = false
        self.updateNowButton.isHidden = true
        self.updateLaterButton.isHidden = true
        SLLockManager.sharedManager.updateFirmwareForCurrentLock()
    }
    
    func updateFirmware(notification: Notification) {
        guard let progress = notification.object as? NSNumber else {
            return
        }
        
        self.progressBar.updateBarWithRatio(ratio: progress.doubleValue)
    }
    
    func firmwareUpdateComplete(notification: Notification) {
        self.updateLabel.text = self.updateText[.Finished]
    }
    
    func disconnectedLock(notification: Notification) {
        //self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func lockPaired(notification: Notification) {
        let texts:[SLWarningViewControllerTextProperty:String?] = [
            .Header: NSLocalizedString("Firmware Updated!", comment: ""),
            .Info: NSLocalizedString("The firmware on your ellipse has been updated.", comment: ""),
            .CancelButton: NSLocalizedString("OK", comment: ""),
            .ActionButton: nil
        ]
        
        self.presentWarningViewControllerWithTexts(texts: texts) {
            if let navController = self.navigationController {
                navController.popViewController(animated: true)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
