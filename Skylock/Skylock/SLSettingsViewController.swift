//
//  SLSettingsViewController.swift
//  Skylock
//
//  Created by Andre Green on 7/25/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

import UIKit

class SLSettingsViewController: UIViewController, SLTouchPadViewControllerDelegate {
    
    private let xPadding:CGFloat = 25.0
    private let titleFont = UIFont(name:"HelveticaNeue", size:14)
    private let infoFont = UIFont(name:"HelveticaNeue", size:12)
    private let titleColor = UIColor.color(97, green: 100, blue: 100)
    private let infoColor = UIColor.color(128, green: 128, blue: 128)
    private let dividerColor = UIColor.color(191, green: 191, blue: 191)
    private let settingGreenColor = UIColor.color(30, green: 221, blue: 128)
    var lock: SLLock?
    private var resetPinButton: UIButton?
    private var pinLabel: UILabel?

    lazy var headerView: UIView = {
        var view: UIView = UIView(frame: CGRectMake(0, 0, self.view.bounds.size.width, 53))
        view.backgroundColor = self.settingGreenColor
        
        let image = UIImage(named: "icon_chevron_left_white")
        let buttonHeght: CGFloat = 2*image!.size.height
        let buttonWidth: CGFloat = 4*image!.size.width
        var button: UIButton = UIButton(frame: CGRectMake(0, 15, buttonWidth, buttonHeght))
        button.setImage(image!, forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(backButtonPushed), forControlEvents: UIControlEvents.TouchDown)
        view.addSubview(button)
        
        let label = UILabel(frame:view.bounds)
        //label.text = self.lock!.name
        label.text = "Lock Me"
        label.font = UIFont(name:"Helvetica", size:13)
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor.color(255, green: 255, blue: 255)
        label.sizeToFit()
        label.frame = CGRectMake(
            0.5*(view.bounds.size.width - label.frame.size.width),
            CGRectGetMidY(button.frame) - 0.5*label.bounds.size.height,
            label.bounds.size.width,
            label.bounds.size.height
        )
        
        view.addSubview(label)
        
        return view
    }()
    
    lazy var alertSettingsTitleLabel: UILabel = {
        let text: String = NSLocalizedString("Theft Alert Settings", comment: "")
        let utility: SLUtilities = SLUtilities()
        let size: CGSize = utility.sizeForLabel(
            self.titleFont!,
            text:text,
            maxWidth:self.view.bounds.size.width - 2*self.xPadding,
            maxHeight: CGFloat.max,
            numberOfLines: 1
        )
        var settingLabel:UILabel = UILabel(frame: CGRectMake(
            self.xPadding,
            CGRectGetMaxY(self.headerView.frame) + 22,
            self.view.bounds.size.width - 2*self.xPadding,
            size.height)
        )
        settingLabel.text = text
        settingLabel.font = self.titleFont
        settingLabel.textColor = self.titleColor
        return settingLabel
    }()

    lazy var alertSettingsInfoLabel: UILabel = {
        var settingLabel:UILabel = UILabel(frame: CGRectMake(
            self.xPadding,
            CGRectGetMaxY(self.alertSettingsTitleLabel.frame) + 10,
            self.view.bounds.size.width - 2*self.xPadding,
            28)
        )
        settingLabel.text = NSLocalizedString(
            "Theft alerts are sent when tampering or vibrations on a lock are detected.",
            comment: ""
        )
        settingLabel.font = self.infoFont
        settingLabel.textColor = self.infoColor
        settingLabel.numberOfLines = 2
        return settingLabel
    }()
    
    lazy var sensitivityControl: UISegmentedControl = {
        let segmentControl:UISegmentedControl = UISegmentedControl(items:[
            "Low",
            "Medium",
            "High"
        ])
        segmentControl.frame = CGRectMake(
                        self.xPadding,
                        CGRectGetMaxY(self.alertSettingsInfoLabel.frame) + 10,
                        self.view.bounds.size.width - 2.0*self.xPadding,
                        25
        )
        segmentControl.addTarget(
            self,
            action: #selector(segmentPressed(_:)),
            forControlEvents: UIControlEvents.ValueChanged
        )
        segmentControl.selectedSegmentIndex = 1
        segmentControl.tintColor = self.settingGreenColor
        segmentControl.backgroundColor = UIColor.color(255, green: 255, blue: 255)
        return segmentControl
    }()

    lazy var sensitivityInfoLabel: UILabel = {
        let text: String = NSLocalizedString(
            "Medium sensitivity (recommended) is a balance approach to secuirty. Prolonged block motion will trigger an alert.",
            comment: ""
        )
        
        let utility: SLUtilities = SLUtilities()
        
        let labelSize: CGSize = utility.sizeForLabel(
            self.infoFont!,
            text: text,
            maxWidth: self.view.bounds.size.width - 2*self.xPadding,
            maxHeight: CGFloat.max,
            numberOfLines: 0
        )
        
        let label: UILabel = UILabel(frame: CGRectMake(
                self.xPadding,
                CGRectGetMaxY(self.sensitivityControl.frame) + 15,
                labelSize.width,
                labelSize.height
            )
        )
        label.text = text
        label.font = self.infoFont
        label.textColor = self.infoColor
        label.numberOfLines = 0
        label.sizeToFit()
        
        return label
    }()

    lazy var sharingView: UIView = {
        let view: UIView = UIView(frame: CGRectMake(
            0,
            CGRectGetMaxY(self.sensitivityInfoLabel.frame) + 20,
            self.view.bounds.size.width,
            57
            )
        )
        
        let dividerHeight: CGFloat = 1
        
        let dividerViewTop: UIView = UIView(frame: CGRectMake(0, 0, view.bounds.size.width, dividerHeight))
        dividerViewTop.backgroundColor = self.dividerColor
        view.addSubview(dividerViewTop)
        
        let button: UIButton = UIButton(frame: CGRectMake(
            0,
            CGRectGetMaxY(dividerViewTop.frame),
            view.bounds.size.width,
            view.bounds.size.height - 2*dividerHeight
            )
        )
        button.addTarget(self, action: #selector(sharingButtonPushed), forControlEvents: UIControlEvents.TouchDown)
        button.setTitle(NSLocalizedString("Sharing", comment:""), forState: UIControlState.Normal)
        button.setTitleColor(self.titleColor, forState: UIControlState.Normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: self.xPadding, bottom: 0, right: 0)
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        view.addSubview(button)
        
        let arrowImage: UIImage? = UIImage(named: "icon_chevron_right")
        let arrowView:UIImageView = UIImageView(image:arrowImage)
        arrowView.frame = CGRectMake(
            CGRectGetMaxX(button.frame) - arrowView.bounds.size.width - self.xPadding,
            CGRectGetMidY(button.frame) - 0.5*arrowView.bounds.size.height,
            arrowView.bounds.size.width,
            arrowView.bounds.size.height
        )
        
        view.addSubview(arrowView)
        
        let dividerBottomView: UIView = UIView(frame: CGRectMake(
            0,
            CGRectGetMaxY(button.frame) - dividerHeight,
            view.bounds.size.width,
            dividerHeight
            )
        )
        dividerBottomView.backgroundColor = self.dividerColor
        view.addSubview(dividerBottomView)
        
        return view
    }()
    
    lazy var pinCodeView:UIView = {
        let view: UIView = UIView(frame: CGRectMake(
            self.xPadding,
            CGRectGetMaxY(self.sensitivityInfoLabel.frame),
            self.view.bounds.size.width - 2*self.xPadding,
            125
            )
        )
        
        let dividerHeight: CGFloat = 0.5
        
        let dividerViewTop: UIView = UIView(frame: CGRectMake(0, 10, view.bounds.size.width, dividerHeight))
        dividerViewTop.backgroundColor = self.dividerColor
        view.addSubview(dividerViewTop)
        
        let text: String = NSLocalizedString("Emergency Pin Code", comment: "")
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
            "A pin code can be set to unlock the lock without a mobile device.",
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
        
        let pinImage: UIImage = UIImage(named: "btn_resetpin")!
        self.resetPinButton = UIButton(frame: CGRectMake(
            0.5*(view.bounds.size.width - pinImage.size.width),
            CGRectGetMaxY(self.pinLabel!.frame) + 15,
            pinImage.size.width,
            pinImage.size.height
            )
        )
        self.resetPinButton!.addTarget(
            self, action:
            #selector(resetPinButtonPushed),
            forControlEvents: UIControlEvents.TouchDown
        )
        self.resetPinButton!.setImage(pinImage, forState: UIControlState.Normal)
        view.addSubview(self.resetPinButton!)
        
        let dividerBottomView: UIView = UIView(frame: CGRectMake(
            0,
            view.bounds.size.height - dividerHeight,
            view.bounds.size.width,
            dividerHeight
            )
        )
        dividerBottomView.backgroundColor = self.dividerColor
        view.addSubview(dividerBottomView)
        
        return view
    }()
    
    lazy var controlView: UIView = {
        let y0: CGFloat = CGRectGetMaxY(self.pinCodeView.frame)
        var view: UIView = UIView(frame: CGRectMake(
            0,
            y0,
            self.view.bounds.size.width,
            self.view.bounds.size.height - y0
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
        
        let labelStart: CGFloat = 0.5*(view.bounds.size.height  - 3.0*labelSize.height - 2.0*labelDividerHeight)
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
        autoLockLabel.text = NSLocalizedString("Auto - Lock", comment: "")
        autoLockLabel.font = self.titleFont
        autoLockLabel.textColor = self.infoColor
        view.addSubview(autoLockLabel)
        
        let autoUnlockLabel: UILabel = UILabel(frame: CGRectMake(
            self.xPadding,
            CGRectGetMaxY(autoLockLabel.frame) + labelDividerHeight,
            labelWidth,
            labelSize.height
            )
        )
        autoUnlockLabel.text = NSLocalizedString("Auto - Unlock", comment: "")
        autoUnlockLabel.font = self.titleFont
        autoUnlockLabel.textColor = self.infoColor
        view.addSubview(autoUnlockLabel)
        
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
        
        let autoUnLockSwitch: UISwitch = UISwitch()
        autoUnLockSwitch.frame = CGRectMake(
            view.bounds.size.width - autoUnLockSwitch.bounds.size.width - self.xPadding,
            CGRectGetMidY(autoUnlockLabel.frame) - 0.5*autoUnLockSwitch.bounds.size.height,
            autoUnLockSwitch.bounds.size.width,
            autoUnLockSwitch.bounds.size.height
        )
        autoUnLockSwitch.addTarget(
            self,
            action: #selector(autoUnlockSwitchFlipped(_:)),
            forControlEvents: UIControlEvents.ValueChanged
        )
        view.addSubview(autoUnLockSwitch)
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.color(255, green: 255, blue: 255)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.addSubview(self.headerView)
        self.view.addSubview(self.alertSettingsTitleLabel)
        self.view.addSubview(self.alertSettingsInfoLabel)
        self.view.addSubview(self.sensitivityControl)
        self.view.addSubview(self.sensitivityInfoLabel)
        self.view.addSubview(self.pinCodeView)
        self.view.addSubview(self.controlView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func segmentPressed(sender: UISegmentedControl) {
        print("segment index selected \(sender.selectedSegmentIndex)")
    }
    
    func backButtonPushed() {
        print("back button pushed")
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func sharingButtonPushed() {
        print("sharing button pushed")
    }
    
    func resetPinButtonPushed() {
        let tpvc: SLTouchPadViewController = SLTouchPadViewController()
        let y0: CGFloat = CGRectGetMinY(self.view.convertRect(self.pinLabel!.frame, fromView: self.pinCodeView))
        tpvc.view.frame = CGRectMake(
            self.xPadding,
            y0,
            self.view.bounds.size.width - 2*self.xPadding,
            self.view.bounds.size.height - y0 - 20
        )
        tpvc.delegate = self
        self.addChildViewController(tpvc)
        self.view.addSubview(tpvc.view)
        tpvc.didMoveToParentViewController(self)
    }
    
    func touchPadSwitchFlipped(sender: UISwitch) {
        print("touch pad switch flipped")
    }
    
    func autoLockSwitchFlipped(sender: UISwitch) {
        print("auto lock switch flipped")
    }
    
    func autoUnlockSwitchFlipped(sender: UISwitch) {
        print("auto unlock switch flipped")
    }
    
    // SLTouchPadViewController Delegate
    func touchPadViewControllerWantsExit(touchPadViewController: SLTouchPadViewController) {
        touchPadViewController.view.removeFromSuperview()
        touchPadViewController.removeFromParentViewController()
    }
}
