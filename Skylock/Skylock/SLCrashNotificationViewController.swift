//
//  SLCrashNotificationViewController.swift
//  Skylock
//
//  Created by Andre Green on 7/23/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

protocol SLCrashNotificationViewControllerDelegate:SLNotificationViewControllerDelegate {
    func timerExpired(cnvc: SLCrashNotificationViewController)
}

class SLCrashNotificationViewController: SLNotificationViewController {
    var countDownTime:Int = 30
    
    var timer:NSTimer?
    
    weak var crashDelegate:SLCrashNotificationViewControllerDelegate?
    
    lazy var thinkerViewController:SLThinkerViewController = {
        let text:[SLThinkerViewControllerLabelTextState:String] = [
            .ClockwiseTopMoving: NSLocalizedString("\(self.countDownTime)", comment: ""),
            .ClockwiseBottomMoving: NSLocalizedString("seconds", comment: "")
        ]
        
        let tvc:SLThinkerViewController = SLThinkerViewController(
            texts: text,
            firstBackgroundColor: UIColor.whiteColor(),
            secondBackgroundColor: UIColor(red: 102, green: 177, blue: 227),
            foregroundColor: UIColor(red: 60, green: 83, blue: 119),
            inActiveBackgroundColor: UIColor(red: 130, green: 156, blue: 178),
            textColor: UIColor.whiteColor()
        )
        
        return tvc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel.frame = CGRect(
            x: CGRectGetMinX(self.titleLabel.frame),
            y: 150.0,
            width: self.titleLabel.bounds.size.width,
            height: self.titleLabel.bounds.size.height
        )
        
        self.infoLabel.frame = CGRect(
            x: CGRectGetMinX(self.infoLabel.frame),
            y: CGRectGetMaxY(self.titleLabel.frame) + 10.0,
            width: self.infoLabel.bounds.size.width,
            height: self.infoLabel.bounds.size.height
        )
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !self.view.subviews.contains(self.thinkerViewController.view) {
            let diameter:CGFloat = 145.0
            self.thinkerViewController.view.frame = CGRect(
                x: 0.5*(self.view.bounds.size.width - diameter),
                y: CGRectGetMaxY(self.infoLabel.frame) + 20.0,
                width: diameter,
                height: diameter
            )
            
            self.addChildViewController(self.thinkerViewController)
            self.view.addSubview(self.thinkerViewController.view)
            self.view.bringSubviewToFront(self.thinkerViewController.view)
            self.thinkerViewController.didMoveToParentViewController(self)
            
            self.startCountDown()
        }
        
        self.thinkerViewController.setState(.ClockwiseMoving)
    }
    
    private func startCountDown() {
        self.timer =  NSTimer.scheduledTimerWithTimeInterval(
            1.0,
            target: self,
            selector: #selector(tickClock),
            userInfo: nil,
            repeats: true
        )
    }
    
    @objc private func tickClock() {
        self.countDownTime -= 1
        if self.countDownTime >= 0 {
            self.thinkerViewController.updateTextForState(
                .ClockwiseMoving,
                topText: "\(self.countDownTime)",
                bottomText: nil
            )
        } else {
            self.timer?.invalidate()
            self.crashDelegate?.timerExpired(self)
        }
    }
    
    override func cancelButtonPressed() {
        self.timer?.invalidate()
        super.cancelButtonPressed()
    }
}
