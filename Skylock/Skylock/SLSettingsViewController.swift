//
//  SLSettingsViewController.swift
//  Skylock
//
//  Created by Andre Green on 7/25/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

import UIKit

class SLSettingsViewController: UIViewController {
    
    private let xPadding:CGFloat = 25.0
    private let titleFont = UIFont(name:"HelveticaNeue", size:14)
    private let infoFont = UIFont(name:"HelveticaNeue", size:12)
    private let titleColor = UIColor.color(97, green: 100, blue: 100)
    private let infoColor = UIColor.color(128, green: 128, blue: 128)
    private let dividerColor = UIColor.color(191, green: 191, blue: 191)
    private let settingGreenColor = UIColor.color(30, green: 221, blue: 128)
    var lock: SLLock?
    private var pinLabel: UILabel?
    
    lazy var controlView: UIView = {
        let y0: CGFloat = self.navigationController == nil ? 20.0 :
            self.navigationController!.navigationBar.bounds.size.height +
                UIApplication.sharedApplication().statusBarFrame.size.height + 20.0
        var view: UIView = UIView(frame: CGRectMake(
            0,
            y0,
            self.view.bounds.size.width,
            150.0
            )
        )
        
        let labelDividerHeight: CGFloat = 45.0
        let labelWidth = 0.5*view.bounds.size.width
        let utility = SLUtilities()
        let labelSize:CGSize = utility.sizeForLabel(
            self.titleFont!,
            text: "Looking for height",
            maxWidth: labelWidth,
            maxHeight: CGFloat.max,
            numberOfLines: 1
        )
        
        let labelStart: CGFloat = 0.5*(view.bounds.size.height  - 2.0*labelSize.height - labelDividerHeight)
        let touchPadLabel: UILabel = UILabel(frame: CGRectMake(
            self.xPadding,
            labelStart,
            labelWidth,
            labelSize.height
            )
        )
        touchPadLabel.text = NSLocalizedString("Capactive Touch Pad", comment: "")
        touchPadLabel.font = self.titleFont
        touchPadLabel.textColor = self.infoColor
        touchPadLabel.sizeToFit()
        view.addSubview(touchPadLabel)
        
        let autoLockLabel: UILabel = UILabel(frame: CGRectMake(
            self.xPadding,
            CGRectGetMaxY(touchPadLabel.frame) + labelDividerHeight,
            labelWidth,
            labelSize.height
            )
        )
        autoLockLabel.text = NSLocalizedString("Proximity Lock/Unlock", comment: "")
        autoLockLabel.font = self.titleFont
        autoLockLabel.textColor = self.infoColor
        view.addSubview(autoLockLabel)
        
        let touchPadSwitch: UISwitch = UISwitch()
        touchPadSwitch.frame = CGRectMake(
            view.bounds.size.width - touchPadSwitch.bounds.size.width - self.xPadding,
            CGRectGetMidY(touchPadLabel.frame) - 0.5*touchPadSwitch.bounds.size.height,
            touchPadSwitch.bounds.size.width,
            touchPadSwitch.bounds.size.height
        )
        touchPadSwitch.addTarget(
            self,
            action: #selector(touchPadSwitchFlipped(_:)),
            forControlEvents: UIControlEvents.ValueChanged
        )
        view.addSubview(touchPadSwitch)
        
        let autoLockSwitch: UISwitch = UISwitch()
        autoLockSwitch.frame = CGRectMake(
            view.bounds.size.width - autoLockSwitch.bounds.size.width - self.xPadding,
            CGRectGetMidY(autoLockLabel.frame) - 0.5*autoLockSwitch.bounds.size.height,
            autoLockSwitch.bounds.size.width,
            autoLockSwitch.bounds.size.height
        )
        autoLockSwitch.addTarget(self, action: #selector(autoLockSwitchFlipped(_:)), forControlEvents: UIControlEvents.ValueChanged)
        view.addSubview(autoLockSwitch)
        
        return view
    }()
    
    lazy var pinCodeView:UIView = {
        let view: UIView = UIView(frame: CGRectMake(
            self.xPadding,
            CGRectGetMaxY(self.controlView.frame),
            self.view.bounds.size.width - 2*self.xPadding,
            125
            )
        )
        
        let dividerHeight: CGFloat = 0.5
        
        let dividerViewTop: UIView = UIView(frame: CGRectMake(0, 10, view.bounds.size.width, dividerHeight))
        dividerViewTop.backgroundColor = self.dividerColor
        view.addSubview(dividerViewTop)
        
        let text: String = NSLocalizedString("Change Pin Code", comment: "")
        let utility: SLUtilities = SLUtilities()
        let size: CGSize = utility.sizeForLabel(
            self.titleFont!,
            text:text,
            maxWidth:self.view.bounds.size.width - 2*self.xPadding,
            maxHeight: CGFloat.max,
            numberOfLines: 1
        )
        
        let headerLabel: UILabel = UILabel(frame: CGRectMake(0, 20, view.bounds.size.width, size.height))
        headerLabel.text = text
        headerLabel.textColor = self.titleColor
        headerLabel.font = self.titleFont
        view.addSubview(headerLabel)
        
        self.pinLabel = UILabel(frame:CGRectMake(0, 0, view.bounds.size.width, CGFloat.max))
        self.pinLabel!.text = NSLocalizedString(
            "A pin code can be set to unlock Skylock without a mobile device.\n" +
            "*You must be in range of Skylock to chage the pin code",
            comment: ""
        )
        self.pinLabel!.font = self.infoFont
        self.pinLabel!.textColor = self.infoColor
        self.pinLabel!.numberOfLines = 0
        self.pinLabel!.sizeToFit()
        self.pinLabel!.frame = CGRectMake(
            0,
            CGRectGetMaxY(headerLabel.frame) + 13,
            self.pinLabel!.bounds.size.width,
            self.pinLabel!.bounds.size.height
        )
        
        view.addSubview(self.pinLabel!)
        
        let buttonImageNormal: UIImage = UIImage(named: "settings_change_pin_button")!
        let buttonImageDissabled: UIImage = UIImage(named: "settings_change_pin_button_dissabled")!
        let changePinButton:UIButton  = UIButton(frame: CGRectMake(
            0.5*(view.bounds.size.width - buttonImageNormal.size.width),
            CGRectGetMaxY(self.pinLabel!.frame) + 15,
            buttonImageNormal.size.width,
            buttonImageNormal.size.height
            )
        )
        changePinButton.addTarget(
            self, action:
            #selector(changePinButtonPressed),
            forControlEvents: UIControlEvents.TouchDown
        )
        changePinButton.setBackgroundImage(buttonImageNormal, forState: UIControlState.Normal)
        changePinButton.setBackgroundImage(buttonImageDissabled, forState: UIControlState.Disabled)
        view.addSubview(changePinButton)
        
        return view
    }()
    
    
    lazy var backButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(named: "icon_chevron_left"),
            style: UIBarButtonItemStyle.Plain,
            target: self,
            action: #selector(backButtonPushed)
        )
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.barTintColor = self.settingGreenColor
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        self.navigationItem.leftBarButtonItem = self.backButton;
        
        self.view.backgroundColor = UIColor.color(255, green: 255, blue: 255)
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.addSubview(self.controlView)
        self.view.addSubview(self.pinCodeView)
    }
    
    func backButtonPushed() {
        print("back button pushed")
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func changePinButtonPressed() {
        let touchPadViewController = SLTouchPadViewController()
        self.navigationController?.pushViewController(touchPadViewController, animated: true)
    }
    
    func touchPadSwitchFlipped(sender: UISwitch) {
        print("touch pad switch flipped")
    }
    
    func autoLockSwitchFlipped(sender: UISwitch) {
        print("auto lock switch flipped")
    }
}
