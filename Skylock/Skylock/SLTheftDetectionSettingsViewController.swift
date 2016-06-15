//
//  SLTheftDetectionSettingsViewController.swift
//  Skylock
//
//  Created by Andre Green on 6/10/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLTheftDetectionSettingsViewController: UIViewController, SLTheftDetctionSliderViewDelegate {
    let lock:SLLock
    
    init(lock:SLLock) {
        self.lock = lock
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var infoView:UIView = {
        let xPadding:CGFloat = 25.0
        let yPadding:CGFloat = 24.0
        let maxWidth = self.view.bounds.size.width - 2*xPadding
        let font = UIFont.systemFontOfSize(14.0)
        let text = NSLocalizedString(
            "Ellipse can send you an alert if it detects that someone is tampering with your bike. " +
            "You can adjust the sensitivity to suit the type of environment your bike is parked in and " +
            "how likely it is to be bumped accidently.\n\nEither theft or crash detection may be activated " +
            "at any time, but not both simultaneously.",
            comment: ""
        )
        let utility = SLUtilities()
        let labelSize:CGSize = utility.sizeForLabel(
            font,
            text: text,
            maxWidth: maxWidth,
            maxHeight: CGFloat.max,
            numberOfLines: 0
        )
        
        let frame = CGRectMake(
            xPadding,
            yPadding,
            labelSize.width,
            labelSize.height
        )
        
        let label:UILabel = UILabel(frame:frame)
        label.text = text
        label.font = font
        label.textColor = UIColor(white: 155.0/255.0, alpha: 1.0)
        label.textAlignment = .Left
        label.numberOfLines = 0
        
        let viewFrame = CGRect(
            x: 0.0,
            y: 20.0 + self.navigationController!.navigationBar.bounds.size.height + UIApplication.sharedApplication().statusBarFrame.size.height,
            width: self.view.bounds.size.width,
            height: 2*yPadding + label.bounds.size.height
        )
        
        let view:UIView = UIView(frame: viewFrame)
        view.backgroundColor = UIColor.whiteColor()
        
        view.addSubview(label)
        
        return view
    }()
    
    lazy var sliderView:SLTheftDetectionSliderView = {
        let frame = CGRect(
            x: 0.0,
            y: self.view.bounds.size.height - 200.0,
            width: self.view.bounds.size.width,
            height: 88.0
        )
        
        let slideView:SLTheftDetectionSliderView = SLTheftDetectionSliderView(frame: frame)
        slideView.delegate = self
        
        return slideView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(white: 239.0/255.0, alpha: 1.0)
        
        self.navigationItem.title = NSLocalizedString("THEFT DETECTION SETTINGS", comment: "")
        
        self.view.addSubview(self.infoView)
        self.view.addSubview(self.sliderView)
    }
    
    func sliderViewValueChanged(sliderView: SLTheftDetectionSliderView, value: Float) {
        
    }
}
