//
//  SLConcentricCirclesViewController.swift
//  Skylock
//
//  Created by Andre Green on 5/30/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLConcentricCirclesViewController: UIViewController {
    let interval:Double = 3.0
    var circleIndex:Int = 0
    let startDiameter:CGFloat = 100.0
    var finalDiamter:CGFloat = 0.0
    var initialCircleFrame:CGRect = CGRectZero
    let numberOfCircles:Int = 5
    let xPadding:CGFloat = 35.0
    
    lazy var connectingEllipseLabel:UILabel = {
        let frame = CGRect(
            x: 0,
            y: UIApplication.sharedApplication().statusBarFrame.size.height + (self.navigationController?.navigationBar.bounds.size.height)! + 5.0,
            width: self.view.bounds.size.width,
            height: 20
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.text = NSLocalizedString("Connecting...", comment: "")
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor(red: 76, green: 79, blue: 97)
        label.font = UIFont.systemFontOfSize(16)
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var getHelpButton:UIButton = {
        let width:CGFloat = self.view.bounds.size.width - 2*self.xPadding
        let frame = CGRect(
            x: 0.5*(self.view.bounds.size.width - width),
            y: self.view.bounds.size.height - 50.0,
            width: width,
            height: 16
        )
        
        let button:UIButton = UIButton(frame: frame)
        button.addTarget(self, action: #selector(getHelpButtonPressed), forControlEvents: .TouchDown)
        button.setTitle(NSLocalizedString("Get help", comment: ""), forState: .Normal)
        button.setTitleColor(UIColor(red: 102, green: 177, blue: 227), forState: .Normal)
        
        return button
    }()
    
    lazy var makeSureLabel:UILabel = {
        let labelWidth = self.view.bounds.size.width - 2*self.xPadding
        let utility = SLUtilities()
        let font = UIFont.systemFontOfSize(14)
        let text = NSLocalizedString("Make sure your Ellipse is switched on and within range of your phone.", comment: "")
        let labelSize:CGSize = utility.sizeForLabel(
            font,
            text: text,
            maxWidth: labelWidth,
            maxHeight: CGFloat.max,
            numberOfLines: 0
        )
        
        let frame = CGRectMake(
            self.xPadding,
            CGRectGetMinY(self.getHelpButton.frame) - labelSize.height - 50.0,
            labelWidth,
            labelSize.height
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.textColor = UIColor(red: 76, green: 79, blue: 97)
        label.textAlignment = NSTextAlignment.Center
        label.font = font
        label.numberOfLines = 0
        label.text = text
        
        return label
    }()
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.initialCircleFrame = CGRect(
            x: 0.5*(self.view.bounds.size.width - self.startDiameter),
            y: 0.5*(self.view.bounds.size.height - self.startDiameter),
            width: self.startDiameter,
            height: self.startDiameter
        )
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(connectedLock),
            name: "kSLNotificationLockPaired",
            object: nil
        )
        
        self.finalDiamter = 1.5*pow(pow(self.view.bounds.size.width, 2) + pow(self.view.bounds.size.height, 2), 0.5)
        
        self.view.addSubview(self.connectingEllipseLabel)
        self.view.addSubview(self.getHelpButton)
        self.view.addSubview(self.makeSureLabel)
        
        self.run()
    }
    
    func run() {
        NSTimer.scheduledTimerWithTimeInterval(
            self.interval/Double(self.numberOfCircles),
            target: self,
            selector: #selector(timerFired),
            userInfo: nil,
            repeats: true
        )
    }
    
    func timerFired() {
        let circleView = self.createCircleView()
        self.view.addSubview(circleView)
        self.bringTopViewsToFront()
        self.makeAnimation(circleView)
    }
    
    func makeAnimation(circleView: UIView) {
        let scale:CGFloat = self.finalDiamter/circleView.frame.size.width
        
        UIView.animateWithDuration(
            self.interval,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveLinear,
            animations: {
                circleView.transform = CGAffineTransformScale(circleView.transform, scale, scale)
                circleView.alpha = 0.0
        }) { (finished) in
            circleView.removeFromSuperview()
        }
    }
    
    func createCircleView() -> UIView {
        let circle:UIView = UIView(frame: self.initialCircleFrame)
        circle.backgroundColor = UIColor(white: 0.8, alpha: 1)
        circle.layer.cornerRadius = 0.5*self.initialCircleFrame.size.width
        
        return circle
    }
    
    func getHelpButtonPressed() {
        print("Get help button pressed")
    }
    
    func bringTopViewsToFront() {
        self.view.bringSubviewToFront(self.connectingEllipseLabel)
        self.view.bringSubviewToFront(self.getHelpButton)
        self.view.bringSubviewToFront(self.makeSureLabel)
    }
    
    func connectedLock() {
        let psvc = SLParingSuccessViewController()
        self.navigationController?.pushViewController(psvc, animated: true)
    }
}
