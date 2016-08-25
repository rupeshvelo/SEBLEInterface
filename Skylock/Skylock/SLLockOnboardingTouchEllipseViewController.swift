//
//  SLLockOnboardingTouchEllipseViewController.swift
//  Skylock
//
//  Created by Andre Green on 8/4/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

class SLLockOnboardingTouchEllipseViewController: UIViewController {
    lazy var pressButtonLabel:UILabel = {
        let labelWidth = self.view.bounds.size.width
        let utility = SLUtilities()
        let font = UIFont(name: SLFont.MontserratRegular.rawValue, size: 18.0)!
        let text = NSLocalizedString(
            "Press the middle button\non your Ellipse.",
            comment: ""
        )
        
        let labelSize:CGSize = utility.sizeForLabel(
            font,
            text: text,
            maxWidth: labelWidth,
            maxHeight: CGFloat.max,
            numberOfLines: 0
        )
        
        let frame = CGRectMake(
            0.5*(self.view.bounds.size.width - labelSize.width),
            utility.statusBarAndNavControllerHeight(self) + 26.0,
            labelSize.width,
            labelSize.height
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.textColor = UIColor(white: 140.0/255.0, alpha: 1.0)
        label.text = text
        label.textAlignment = NSTextAlignment.Center
        label.font = font
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var touchPadLabel:UILabel = {
        let labelWidth = self.view.bounds.size.width
        let utility = SLUtilities()
        let font = UIFont(name: SLFont.OpenSansRegular.rawValue, size: 14.0)!
        let text = NSLocalizedString(
            "Press the middle button\non your Ellipse.",
            comment: ""
        )
        
        let labelSize:CGSize = utility.sizeForLabel(
            font,
            text: text,
            maxWidth: labelWidth,
            maxHeight: CGFloat.max,
            numberOfLines: 0
        )
        
        let frame = CGRectMake(
            0.5*(self.view.bounds.size.width - labelSize.width),
            CGRectGetMaxY(self.pressButtonLabel.frame) + 25.0,
            labelSize.width,
            labelSize.height
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.textColor = UIColor(red: 160, green: 200, blue: 224)
        label.text = text
        label.textAlignment = NSTextAlignment.Center
        label.font = font
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var touchPadView:UIImageView = {
        let image:UIImage = UIImage(named: "lock_onboarding_touch_lock")!
        let frame = CGRect(
            x: 0.5*self.view.bounds.size.width - image.size.width + 50.0,
            y: CGRectGetMaxY(self.touchPadLabel.frame) + 15.0,
            width: image.size.width,
            height: image.size.height
        )
        
        let imageView:UIImageView = UIImageView(image: image)
        imageView.frame = frame
        
        return imageView
    }()
    
    lazy var touchPadOnButton:UIButton = {
        let height:CGFloat = 47.0
        let frame = CGRect(
            x: 0.0,
            y: self.view.bounds.size.height - height,
            width: self.view.bounds.size.width,
            height: height
        )
        
        let button:UIButton = UIButton(type: .System)
        button.frame = frame
        button.setTitle(NSLocalizedString("OK, TOUCH PAD IS ON", comment: ""), forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.backgroundColor = UIColor(red: 87, green: 216, blue: 255)
        button.titleLabel?.font = UIFont(name: SLFont.MontserratRegular.rawValue, size: 13.0)
        button.addTarget(self, action: #selector(touchPadOnButtonPressed), forControlEvents: .TouchDown)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationItem.title = NSLocalizedString("WELCOME ON BOARD :)", comment: "")
        
        self.view.addSubview(self.pressButtonLabel)
        self.view.addSubview(self.touchPadLabel)
        self.view.addSubview(self.touchPadView)
        self.view.addSubview(self.touchPadOnButton)
    }
    
    func touchPadOnButtonPressed() {
        let ccvc = SLConcentricCirclesViewController()
        ccvc.onExit = {
            let psvc = SLPairingSuccessViewController()
            self.navigationController?.pushViewController(psvc, animated: true)
        }
        self.navigationController?.pushViewController(ccvc, animated: true)
    }
}
