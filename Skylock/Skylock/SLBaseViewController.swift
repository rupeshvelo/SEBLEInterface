//
//  SLBaseViewController.swift
//  Ellipse
//
//  Created by Andre Green on 8/24/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLBaseViewController: UIViewController, SLWarningViewControllerDelegate {
    var warningBackgroundView:UIView?
    
    var warningViewController:SLWarningViewController?
    
    var cancelClosure:(() -> ())?
    
    lazy var loadingView:SLLoadingView = {
        let height:CGFloat = 200.0
        let frame = CGRect(
            x: 0.0,
            y: 0.5*(self.view.bounds.size.height - height),
            width: self.view.bounds.size.width,
            height: height
        )
        
        let view:SLLoadingView = SLLoadingView(frame: frame)
        view.backgroundColor = UIColor.clearColor()
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func presentWarningViewControllerWithTexts(
        texts:[SLWarningViewControllerTextProperty:String?],
        cancelClosure: (() -> ())?
        )
    {
        dispatch_async(dispatch_get_main_queue()) {
            self.addWarningBackgroundView()
            
            let width:CGFloat = 268.0
            let height:CGFloat = 211.0
            
            self.warningViewController = SLWarningViewController()
            self.warningViewController!.setTextProperties(texts)
            self.warningViewController!.view.frame = CGRect(
                x: 0.5*(self.view.bounds.size.width - width),
                y: 100.0,
                width: width,
                height: height
            )
            self.warningViewController!.delegate = self
            self.cancelClosure = cancelClosure
            
            self.addChildViewController(self.warningViewController!)
            self.view.addSubview(self.warningViewController!.view)
            self.view.bringSubviewToFront(self.warningViewController!.view)
            self.warningViewController!.didMoveToParentViewController(self.warningViewController!)
        }
    }
    
    func presentLoadingViewWithMessage(message: String) {
        self.addWarningBackgroundView()
        self.loadingView.setMessage(message)
        self.view.addSubview(self.loadingView)
        self.loadingView.rotate()
    }
    
    func dismissLoadingViewWithCompletion(completion: (() -> ())?) {
        UIView.animateWithDuration(0.2, animations: { 
            self.warningBackgroundView?.alpha = 0.0
            self.loadingView.alpha = 0.0
            }) { (finished) in
                self.warningBackgroundView?.removeFromSuperview()
                self.loadingView.removeFromSuperview()
                self.warningBackgroundView = nil
                if let completionClosure = completion {
                    completionClosure()
                }
        }
    }
    
    private func addWarningBackgroundView() {
        if self.warningBackgroundView != nil {
            return
        }
        
        self.warningBackgroundView = UIView(frame: self.view.bounds)
        self.warningBackgroundView?.backgroundColor = UIColor(white: 0.2, alpha: 0.75)
        self.view.addSubview(self.warningBackgroundView!)
    }
    
    // MARK: SLWarningViewControllerDelegate Methods
    func warningVCTakeActionButtonPressed(wvc: SLWarningViewController) {
        // This method should be overriden by child class
    }
    
    func warningVCCancelActionButtonPressed(wvc: SLWarningViewController) {
        if let background = self.warningBackgroundView {
            UIView.animateWithDuration(0.2, animations: {
                wvc.view.alpha = 0.0
                background.alpha = 0.0
            }) { (finished) in
                wvc.view.removeFromSuperview()
                wvc.removeFromParentViewController()
                wvc.view.removeFromSuperview()
                background.removeFromSuperview()
                self.warningBackgroundView = nil
                self.warningViewController = nil
                if self.cancelClosure != nil {
                    self.cancelClosure!()
                }
            }
        } else {
            print("Error: could not find background view while removing warning view controller")
            if self.cancelClosure != nil {
                self.cancelClosure!()
            }
        }
    }
}
