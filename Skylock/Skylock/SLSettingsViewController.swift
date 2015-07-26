//
//  SLSettingsViewController.swift
//  Skylock
//
//  Created by Andre Green on 7/25/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

import UIKit

class SLSettingsViewController: UIViewController {
    
    let xPadding:CGFloat = 25.0
    let titleFont = UIFont(name:"HelveticaNeue", size:13)
    let infoFont = UIFont(name:"HelveticaNeue", size:9)
    let titleColor = UIColor.color(97, green: 100, blue: 100)
    let infoColor = UIColor.color(128, green: 128, blue: 128)
    let settingGreenColor = UIColor.color(30, green: 221, blue: 128)
    var lock: SLLock?
    
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
        let label: UILabel = UILabel(frame:CGRectMake(
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

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.color(255, green: 255, blue: 255)
        
        


    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.addSubview(self.headerView)
        self.view.addSubview(self.alertSettingsTitleLabel)
        self.view.addSubview((self.alertSettingsInfoLabel))
        self.view .addSubview(self.sliderLabelView)
        self.view.addSubview(self.sensitivitySlider)
        self.view.addSubview(self.sensitivityInfoLabel)
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

}
