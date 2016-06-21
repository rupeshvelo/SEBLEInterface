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

class SLLockResetOrDeleteViewController: UIViewController {
    var type:SLLockResetOrDeleteViewControllerType
    let lock:SLLock
    
    lazy var infoLabel:UILabel = {
        let buttonImage:UIImage = UIImage(named: "button_delete_this_lock_Ellipses")!
        let labelWidth = buttonImage.size.width
        let utility = SLUtilities()
        let font = UIFont.systemFontOfSize(15)
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
                "Deleting this lock from the app resets the Ellipse to it's factory " +
                "settings and will remove the Ellipse from your account.  You'll need to do " +
                "this if you sell or give your lock to someone else. Your Ellipse " +
                "must be unlocked to perform this action.",
                comment: ""
            )
        }
        
        let labelSize:CGSize = utility.sizeForLabel(
            font,
            text: text,
            maxWidth: labelWidth,
            maxHeight: CGFloat.max,
            numberOfLines: 0
        )
        
        let frame = CGRectMake(
            0.5*(self.view.bounds.size.width - labelSize.width),
            (self.navigationController?.navigationBar.bounds.size.height)!
                + UIApplication.sharedApplication().statusBarFrame.size.height + 33.0,
            labelSize.width,
            labelSize.height
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.textColor = UIColor(white: 155.0/255.0, alpha: 1.0)
        label.text = text
        label.textAlignment = NSTextAlignment.Center
        label.font = font
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var affirmativeButton:UIButton = {
        let image:UIImage = self.type == .Reset ? UIImage(named: "button_factory_reset_Ellipses")! :
            UIImage(named: "button_delete_this_lock_Ellipses")!
        
        let frame = CGRect(
            x: 0.5*(self.view.bounds.size.width - image.size.width),
            y: CGRectGetMidY(self.view.bounds),
            width: image.size.width,
            height: image.size.height
        )
        
        let button:UIButton = UIButton(frame: frame)
        button.addTarget(self, action: #selector(affirmativeButtonPressed), forControlEvents: .TouchDown)
        button.setImage(image, forState: .Normal)
        
        return button
    }()
    
    init(
        nibName nibNameOrNil: String?,
                bundle nibBundleOrNil: NSBundle?,
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
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.navigationItem.title = NSLocalizedString("DELETE ELLIPSE", comment: "")
        
        self.view.addSubview(self.infoLabel)
        self.view.addSubview(self.affirmativeButton)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(handleLockRemoved(_:)),
            name: kSLNotificationRemoveLockForUser,
            object: nil
        )
    }
    
    func affirmativeButtonPressed() {
        let lockManager = SLLockManager.sharedManager() as! SLLockManager
        switch self.type {
        case .Delete:
            lockManager.deleteLockFromCurrentUserAccountWithMacAddress(self.lock.macAddress)
        case .Reset:
            lockManager.factoryResetCurrentLock()
        }
    }
    
    func handleLockRemoved(notifciation: NSNotification) {
        
    }
}
