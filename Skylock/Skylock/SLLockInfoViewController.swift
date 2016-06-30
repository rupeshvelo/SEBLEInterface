//
//  SLLockInfoViewController.swift
//  Skylock
//
//  Created by Andre Green on 6/29/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

class SLLockInfoViewController: UIViewController {
    let xPadding:CGFloat = 20.0
    
    let lock:SLLock
    
    let titleColor:UIColor = UIColor(red: 76, green: 79, blue: 97)
    
    lazy var showLessButton:UIButton = {
        let image:UIImage = UIImage(named: "map_lock_info_x_button")!
        let frame = CGRect(
            x: self.view.bounds.size.width - image.size.width - self.xPadding,
            y: 16.0,
            width: image.size.width,
            height: image.size.height
        )
        
        let button:UIButton = UIButton(frame: frame)
        button.setImage(image, forState: .Normal)
        button.addTarget(self, action: #selector(showLessButtonPressed), forControlEvents: .TouchDown)
        
        return button
    }()
    
    lazy var showMoreButton:UIButton = {
        let image:UIImage = UIImage(named: "map_show_more_button")!
        let frame = CGRect(
            x: self.view.bounds.size.width - image.size.width - self.xPadding,
            y: CGRectGetMidY(self.showLessButton.frame) - 0.5*image.size.height,
            width: image.size.width,
            height: image.size.height
        )
        
        let button:UIButton = UIButton(frame: frame)
        button.setImage(image, forState: .Normal)
        button.addTarget(self, action: #selector(showMoreButtonPressed), forControlEvents: .TouchDown)
        button.hidden = true
        
        return button
    }()
    
    lazy var lockNameLabel:UILabel = {
        let labelWidth = self.view.bounds.size.width - self.showLessButton.bounds.size.width - 2*self.xPadding
        let utility = SLUtilities()
        let font = UIFont.systemFontOfSize(18)
        let text = self.lock.displayName()
        
        let labelSize:CGSize = utility.sizeForLabel(
            font,
            text: self.lock.displayName(),
            maxWidth: labelWidth,
            maxHeight: CGFloat.max,
            numberOfLines: 1
        )
        
        let frame = CGRectMake(
            self.xPadding,
            CGRectGetMidY(self.showLessButton.frame) - 0.5*labelSize.height,
            labelWidth,
            labelSize.height
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.textColor = self.titleColor
        label.text = text
        label.textAlignment = .Left
        label.font = font
        label.numberOfLines = 1
        
        return label
    }()
    
    lazy var crashButton:SLLockScreenAlertButton = {
        let button:SLLockScreenAlertButton = SLLockScreenAlertButton(
            activeImageName: "map_crash_detection_on_button",
            inactiveImageName: "map_crash_detection_off_button",
            titleText: NSLocalizedString("Crash detection", comment: ""),
            textColor: self.titleColor
        )
        button.frame = CGRect(
            x: self.xPadding,
            y: CGRectGetMaxY(self.lockNameLabel.frame) + 25.0,
            width: button.bounds.size.width,
            height: button.bounds.size.height
        )
        button.addTarget(self, action: #selector(crashButtonPressed), forControlEvents: .TouchDown)
        
        return button
    }()
    
    lazy var theftButton:SLLockScreenAlertButton = {
        let button:SLLockScreenAlertButton = SLLockScreenAlertButton(
            activeImageName: "map_theft_detection_on_button",
            inactiveImageName: "map_theft_detection_off_button",
            titleText: NSLocalizedString("Theft detection", comment: ""),
            textColor: self.titleColor
        )
        button.frame = CGRect(
            x: CGRectGetMaxX(self.crashButton.frame) + 25.0,
            y: CGRectGetMinY(self.crashButton.frame),
            width: button.bounds.size.width,
            height: button.bounds.size.height
        )
        button.addTarget(self, action: #selector(theftButtonPressed), forControlEvents: .TouchDown)
        
        return button
    }()
    
    lazy var tempInfoView:UIImageView = {
        let image:UIImage = UIImage(named: "map_temp_lock_info")!
        let frame = CGRect(
            x: self.view.bounds.size.width - image.size.width - self.xPadding,
            y: CGRectGetMidY(self.crashButton.frame) - 0.5*image.size.height,
            width: image.size.width,
            height: image.size.height
        )
        
        let view:UIImageView = UIImageView(image: image)
        view.frame = frame
        
        return view
    }()
    
    lazy var getDirectionsButton:UIButton = {
        let image:UIImage = UIImage(named: "map_view_lock_info_get_directions_to_my_bike_button")!
        let frame = CGRect(
            x: 0.5*(self.view.bounds.size.width - image.size.width),
            y: self.view.bounds.size.height - image.size.height - 20.0,
            width: image.size.width,
            height: image.size.height
        )
        
        let button:UIButton = UIButton(frame: frame)
        button.setImage(image, forState: .Normal)
        button.addTarget(self, action: #selector(getDirectionsButtonPressed), forControlEvents: .TouchDown)
        
        return button
    }()
    
    init(lock:SLLock) {
        self.lock = lock
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !self.view.subviews.contains(self.showLessButton) {
            self.view.addSubview(self.showLessButton)
        }
        
        if !self.view.subviews.contains(self.showMoreButton) {
            self.view.addSubview(self.showMoreButton)
        }
        
        if !self.view.subviews.contains(self.lockNameLabel) {
            self.view.addSubview(self.lockNameLabel)
        }
        
        if !self.view.subviews.contains(self.crashButton) {
            self.view.addSubview(self.crashButton)
        }
        
        if !self.view.subviews.contains(self.theftButton) {
            self.view.addSubview(self.theftButton)
        }
        
        if !self.view.subviews.contains(self.tempInfoView) {
            self.view.addSubview(self.tempInfoView)
        }
        
        if !self.view.subviews.contains(self.getDirectionsButton) {
            self.view.addSubview(self.getDirectionsButton)
        }
    }
    
    func showLessButtonPressed() {
        
    }
    
    func showMoreButtonPressed() {
        
    }
    
    func crashButtonPressed() {
        self.crashButton.selected = !self.crashButton.selected
    }
    
    func theftButtonPressed() {
        self.theftButton.selected = !self.theftButton.selected
    }
    
    func getDirectionsButtonPressed() {
        
    }
}
