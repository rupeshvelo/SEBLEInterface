//
//  SLLockResetOrDeleteViewController.swift
//  Skylock
//
//  Created by Andre Green on 6/10/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

enum SLLockResetOrDeleteViewControllerType {
    case Reset
    case Delete
}

class SLLockResetOrDeleteViewController: SLBaseViewController {
    var type:SLLockResetOrDeleteViewControllerType
    
    let lock:SLLock
    
    let xPadding:CGFloat = 21.0
    
    lazy var infoLabel:UILabel = {
        let labelWidth = self.affirmativeButton.bounds.size.width
        let utility = SLUtilities()
        let font = UIFont(name: SLFont.OpenSansRegular.rawValue, size: 14.0)!
        let text:String
        if self.type == .Reset {
            text = NSLocalizedString(
                "Doing a factory reset erases all settings including Ellipse name, " +
                "pin code, sharing information and restores your Ellipse back to its factory " +
                "default settings. Your Ellipse must unlocked to perform this action.",
                comment: ""
            )
        } else {
            text = NSLocalizedString(
                "Deleting this lock from the app resets the Ellipse to its factory " +
                "settings and will remove the Ellipse from your account.  You'll need to do " +
                "this if you sell or give your lock to someone else. Your Ellipse " +
                "must be unlocked to perform this action.",
                comment: ""
            )
        }
        
        let labelSize:CGSize = utility.sizeForLabel(
            font: font,
            text: text,
            maxWidth: labelWidth,
            maxHeight: CGFloat.greatestFiniteMagnitude,
            numberOfLines: 0
        )
        
        let frame = CGRect(
            x: 0.5*(self.view.bounds.size.width - labelSize.width),
            y: (self.navigationController?.navigationBar.bounds.size.height)!
                + UIApplication.shared.statusBarFrame.size.height + 33.0,
            width: labelSize.width,
            height: labelSize.height
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.textColor = UIColor(white: 155.0/255.0, alpha: 1.0)
        label.text = text
        label.font = font
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var affirmativeButton:UIButton = {
        let width = (self.view.bounds.size.width - 2.0*self.xPadding)
        let frame = CGRect(
            x: self.xPadding,
            y: self.view.bounds.midY,
            width: width,
            height: 44.0
        )
        
        let button:UIButton = UIButton(frame: frame)
        button.addTarget(self, action: #selector(affirmativeButtonPressed), for: .touchDown)
        button.setTitle(NSLocalizedString("DELETE ELLIPSE", comment: ""), for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor(red: 87, green: 216, blue: 255)
        button.titleLabel?.font = UIFont(name: SLFont.MontserratRegular.rawValue, size: 12.0)
        
        return button
    }()
    
    init(
        nibName nibNameOrNil: String?,
                bundle nibBundleOrNil: Bundle?,
                       type: SLLockResetOrDeleteViewControllerType,
                       lock: SLLock
        )
    {
        self.lock = lock
        self.type = type
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init(type: SLLockResetOrDeleteViewControllerType, lock: SLLock) {
        self.init(nibName: nil, bundle: nil, type: type, lock: lock)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        self.navigationItem.title = NSLocalizedString("DELETE THIS ELLIPSE", comment: "")

        self.view.addSubview(self.affirmativeButton)
        self.view.addSubview(self.infoLabel)
        
        NotificationCenter.default.addObserver(
            forName: Notification.Name(rawValue: kSLNotificationLockManagerDeletedLock),
            object: self,
            queue: nil,
            using: handleLockRemoved
        )
    }
    
    func affirmativeButtonPressed() {
        let lockManager = SLLockManager.sharedManager
        switch self.type {
        case .Delete:
            self.navigationItem.hidesBackButton = true
            let message = NSLocalizedString("Deleting", comment: "") + " " + self.lock.displayName() + "..."
            lockManager.deleteLockFromCurrentUserAccountWithMacAddress(macAddress: self.lock.macAddress!)
            self.presentLoadingViewWithMessage(message: message)
        case .Reset:
            lockManager.factoryResetCurrentLock()
        }
    }
    
    func handleLockRemoved(notifciation: Notification) {
        self.dismissLoadingViewWithCompletion(completion: { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        })
    }
}