//
//  SLSettingsViewController.swift
//  Skylock
//
//  Created by Andre Green on 7/25/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

import UIKit

class SLSettingsViewController: UIViewController {
    
    enum TouchPadLocation{
        case top
        case right
        case bottom
        case left
        case center
    }
    
    let xPadding:CGFloat = 25.0
    let titleFont = UIFont(name:"HelveticaNeue", size:13)
    let infoFont = UIFont(name:"HelveticaNeue", size:9)
    let titleColor = UIColor.color(97, green: 100, blue: 100)
    let infoColor = UIColor.color(128, green: 128, blue: 128)
    let dividerColor = UIColor.color(191, green: 191, blue: 191)
    let settingGreenColor = UIColor.color(30, green: 221, blue: 128)
    var lock: SLLock?
    var resetPinButton: UIButton?
    
    lazy var headerView: UIView = {
        var view: UIView = UIView(frame: CGRectMake(0, 0, self.view.bounds.size.width, 53))
        view.backgroundColor = self.settingGreenColor
        
        let image = UIImage(named: "icon_chevron_left_white")
        let buttonHeght: CGFloat = 2*image!.size.height
        let buttonWidth: CGFloat = 4*image!.size.width
        var button: UIButton = UIButton(frame: CGRectMake(0, 15, buttonWidth, buttonHeght))
        button.setImage(image!, forState: UIControlState.Normal)
        button.addTarget(self, action: "backButtonPushed", forControlEvents: UIControlEvents.TouchDown)
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
        var settingLabel:UILabel = UILabel(frame: CGRectMake(
            self.xPadding,
            CGRectGetMaxY(self.headerView.frame) + 22,
            self.view.bounds.size.width - 2*self.xPadding,
            26)
        )
        settingLabel.text = NSLocalizedString("Theft Alert Settings", comment: "")
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
        settingLabel.text = NSLocalizedString("Theft alerts are sent when tampering or " +
            "vibrations on a lock are detected.",
            comment: ""
        )
        settingLabel.font = self.infoFont
        settingLabel.textColor = self.infoColor
        settingLabel.numberOfLines = 2
        return settingLabel
    }()

    lazy var sliderLabelView: UIView = {
        var view: UIView = UIView(frame: CGRectMake(
            self.xPadding,
            CGRectGetMaxY(self.alertSettingsInfoLabel.frame) + 15,
            self.view.bounds.size.width - 2*self.xPadding,
            10
            )
        )
        
        let labelWidth: CGFloat = 0.33*view.bounds.size.width
        let labelFont: UIFont = UIFont(name:"HelveticaNeue", size:8)!
        let labelColor: UIColor = UIColor.color(146, green: 148, blue: 151)
        
        let lowLabel: UILabel = UILabel(frame: CGRectMake(
            0,
            0,
            labelWidth,
            view.bounds.size.height)
        )
        lowLabel.text = NSLocalizedString("low", comment: "")
        lowLabel.font = labelFont
        lowLabel.textColor = labelColor
        view.addSubview(lowLabel)
        
        let mediumLabel: UILabel = UILabel(frame: CGRectMake(
            CGRectGetMaxX(lowLabel.frame),
            0,
            labelWidth,
            view.bounds.size.height)
        )
        mediumLabel.text = NSLocalizedString("medium", comment: "")
        mediumLabel.font = labelFont
        mediumLabel.textColor = labelColor
        mediumLabel.textAlignment = NSTextAlignment.Center
        view.addSubview(mediumLabel)
        
        let highLabel: UILabel = UILabel(frame: CGRectMake(
            CGRectGetMaxX(mediumLabel.frame),
            0,
            labelWidth,
            view.bounds.size.height)
        )
        highLabel.text = NSLocalizedString("high", comment: "")
        highLabel.font = labelFont
        highLabel.textColor = labelColor
        highLabel.textAlignment = NSTextAlignment.Right
        view.addSubview(highLabel)
        
        return view
    }()
    
    lazy var sensitivitySlider: UISlider = {
        var slider:UISlider = UISlider(frame: CGRectMake(
            self.xPadding,
            CGRectGetMaxY(self.sliderLabelView.frame) + 2,
            self.view.bounds.size.width - 2.0*self.xPadding,
            30)
        )
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.value = 50
        slider.continuous = true
        slider.tintColor = self.settingGreenColor
        slider.addTarget(self, action: "sliderValueChanged:", forControlEvents: .ValueChanged)
        return slider
    }()

    lazy var sensitivityInfoLabel: UILabel = {
        let label: UILabel = UILabel(frame:
            CGRectMake(
            self.xPadding,
            CGRectGetMaxY(self.sensitivitySlider.frame) + 20,
            self.view.bounds.size.width - 2*self.xPadding,
            self.view.bounds.size.height
            )
        )
        label.text = NSLocalizedString("Medium sensitivity (recommended) is a " +
            "balance approach to secuirty. Prolonged block motion will trigger an alert.",
            comment: ""
        )
        label.font = self.infoFont
        label.textColor = self.infoColor
        label.numberOfLines = 0
        label.sizeToFit()
        label.frame = CGRectMake(
            self.xPadding,
            CGRectGetMaxY(self.sensitivitySlider.frame) + 20,
            label.bounds.size.width,
            label.bounds.size.height
        )
        
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
        button.addTarget(self, action: "sharingButtonPushed", forControlEvents: UIControlEvents.TouchDown)
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
            CGRectGetMaxY(self.sharingView.frame),
            self.view.bounds.size.width - 2*self.xPadding,
            137
            )
        )
        
        let headerLabel: UILabel = UILabel(frame: CGRectMake(0, 20, view.bounds.size.width, 16))
        headerLabel.text = NSLocalizedString("Emergency Pin Code", comment: "")
        headerLabel.textColor = self.titleColor
        headerLabel.font = self.titleFont
        view.addSubview(headerLabel)
        
//        let infoLabel: UILabel = UILabel(frame: CGRectMake(
//            0,
//            CGRectGetMaxX(headerLabel.frame) + 13,
//            view.bounds.size.width,
//            CGFloat.max
//            )
//        )
        let infoLabel: UILabel = UILabel(frame:CGRectMake(0, 0, view.bounds.size.width, CGFloat.max))
        infoLabel.text = NSLocalizedString("A pin code can be set to unlock the lock without" +
            " a mobile device.", comment: "")
        infoLabel.font = self.infoFont
        infoLabel.textColor = self.infoColor
        infoLabel.numberOfLines = 0
        infoLabel.sizeToFit()
        infoLabel.frame = CGRectMake(
            0,
            CGRectGetMaxY(headerLabel.frame) + 13,
            infoLabel.bounds.size.width,
            infoLabel.bounds.size.height
        )
        view.addSubview(infoLabel)
        
        
        let pinImage: UIImage = UIImage(named: "btn_resetpin")!
        self.resetPinButton = UIButton(frame: CGRectMake(
            0.5*(view.bounds.size.width - pinImage.size.width),
            CGRectGetMaxY(infoLabel.frame) + 20,
            pinImage.size.width,
            pinImage.size.height
            )
        )
        self.resetPinButton!.addTarget(self, action: "resetPinButtonPushed", forControlEvents: UIControlEvents.TouchDown)
        self.resetPinButton!.setImage(pinImage, forState: UIControlState.Normal)
        view.addSubview(self.resetPinButton!)
        
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
        
        let topDividerView: UIView = UIView(frame: CGRectMake(0, 0, view.bounds.size.width, 1))
        topDividerView.backgroundColor = self.dividerColor
        view.addSubview(topDividerView)
        
        let labelWidth = 0.5*view.bounds.size.width
        let touchPadLabel: UILabel = UILabel(frame: CGRectMake(self.xPadding, 15, labelWidth, 9))
        touchPadLabel.text = NSLocalizedString("Capactive Touch Pad", comment: "")
        touchPadLabel.font = self.infoFont
        touchPadLabel.textColor = self.infoColor
        view.addSubview(touchPadLabel)
        
        let autoLockLabel: UILabel = UILabel(frame: CGRectMake(
            self.xPadding,
            CGRectGetMidY(view.bounds) - 0.5*touchPadLabel.frame.size.height,
            labelWidth,
            9
            )
        )
        autoLockLabel.text = NSLocalizedString("Auto - Lock", comment: "")
        autoLockLabel.font = self.infoFont
        autoLockLabel.textColor = self.infoColor
        view.addSubview(autoLockLabel)
        
        let autoUnlockLabel: UILabel = UILabel(frame: CGRectMake(
            self.xPadding,
            view.bounds.size.height - CGRectGetMaxY(touchPadLabel.frame),
            labelWidth,
            9
            )
        )
        autoUnlockLabel.text = NSLocalizedString("Auto - Unlock", comment: "")
        autoUnlockLabel.font = self.infoFont
        autoUnlockLabel.textColor = self.infoColor
        view.addSubview(autoUnlockLabel)
        
        let touchPadSwitch: UISwitch = UISwitch()
        touchPadSwitch.frame = CGRectMake(
            view.bounds.size.width - touchPadSwitch.bounds.size.width - self.xPadding,
            CGRectGetMidY(touchPadLabel.frame) - 0.5*touchPadSwitch.bounds.size.height,
            touchPadSwitch.bounds.size.width,
            touchPadSwitch.bounds.size.height
        )
        touchPadSwitch.addTarget(self, action: "touchPadSwitchFlipped:", forControlEvents: UIControlEvents.ValueChanged)
        view.addSubview(touchPadSwitch)
        
        let autoLockSwitch: UISwitch = UISwitch()
        autoLockSwitch.frame = CGRectMake(
            view.bounds.size.width - autoLockSwitch.bounds.size.width - self.xPadding,
            CGRectGetMidY(autoLockLabel.frame) - 0.5*autoLockSwitch.bounds.size.height,
            autoLockSwitch.bounds.size.width,
            autoLockSwitch.bounds.size.height
        )
        autoLockSwitch.addTarget(self, action: "autoLockSwitchFlipped:", forControlEvents: UIControlEvents.ValueChanged)
        view.addSubview(autoLockSwitch)
        
        let autoUnLockSwitch: UISwitch = UISwitch()
        autoUnLockSwitch.frame = CGRectMake(
            view.bounds.size.width - autoUnLockSwitch.bounds.size.width - self.xPadding,
            CGRectGetMidY(autoUnlockLabel.frame) - 0.5*autoUnLockSwitch.bounds.size.height,
            autoUnLockSwitch.bounds.size.width,
            autoUnLockSwitch.bounds.size.height
        )
        autoUnLockSwitch.addTarget(self, action: "autoUnlockSwitchFlipped:", forControlEvents: UIControlEvents.ValueChanged)
        view.addSubview(autoUnLockSwitch)
        
        return view
    }()
    
    lazy var touchPadView:UIView = {
        let view: UIView = UIView(frame: CGRectMake(0, 0, self.pinCodeView.bounds.size.width, <#height: CGFloat#>))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.color(255, green: 255, blue: 255)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.addSubview(self.headerView)
        self.view.addSubview(self.alertSettingsTitleLabel)
        self.view.addSubview((self.alertSettingsInfoLabel))
        self.view.addSubview(self.sliderLabelView)
        self.view.addSubview(self.sensitivitySlider)
        self.view.addSubview(self.sensitivityInfoLabel)
        self.view.addSubview(self.sharingView)
        self.view.addSubview(self.pinCodeView)
        self.view.addSubview(self.controlView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sliderValueChanged(slider: UISlider!) {
        println("slider value: \(slider!.value)")
    }
    
    func backButtonPushed() {
        println("back button pushed")
    }
    
    func sharingButtonPushed() {
        println("sharing button pushed")
    }
    
    func resetPinButtonPushed() {
        println("reset pin button pushed")
    }
    
    func touchPadSwitchFlipped(sender: UISwitch) {
        println("touch pad switch flipped")
    }
    
    func autoLockSwitchFlipped(sender: UISwitch) {
        println("auto lock switch flipped")
    }
    
    func autoUnlockSwitchFlipped(sender: UISwitch) {
        println("auto unlock switch flipped")
    }
}
