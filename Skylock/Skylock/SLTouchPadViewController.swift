//
//  SLTouchPadViewController.swift
//  Skylock
//
//  Created by Andre Green on 8/30/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

import UIKit

protocol SLTouchPadViewControllerDelegate {
    func touchPadViewControllerWantsExit(touchPadViewController: SLTouchPadViewController)
}

class SLTouchPadViewController: UIViewController, SLTouchPadViewDelegate {
    let labelFont = UIFont(name: "HelveticaNeue", size: 12)
    let titleColor = UIColor.color(97, green: 100, blue: 100)
    let infoColor = UIColor.color(128, green: 128, blue: 128)
    var delegate: SLTouchPadViewControllerDelegate?
    
    lazy var topInfoLabel: UILabel = {
        let text: String = NSLocalizedString("Re-enter touch sequence", comment: "")
        let utility: SLUtilities = SLUtilities()
        let size: CGSize = utility.sizeForLabel(
            self.labelFont!,
            text:text,
            maxWidth:self.view.bounds.size.width,
            maxHeight: CGFloat.max,
            numberOfLines: 1
        )
        
        let label: UILabel = UILabel(frame: CGRectMake(
            0,
            0,
            self.view.bounds.size.width,
            size.height
            )
        )
        label.text = text
        label.textColor = self.titleColor
        label.font = self.labelFont
        
        return label
    }()
    
    lazy var bottomInfoLabel: UILabel = {
        let text: String = NSLocalizedString(
            "*4 touches is the weakest, 6 is moderate, 8 is safe, 10 and above is the strongest",
            comment: ""
        )
        let utility: SLUtilities = SLUtilities()
        let size: CGSize = utility.sizeForLabel(
            self.labelFont!,
            text:text,
            maxWidth:self.view.bounds.size.width,
            maxHeight: CGFloat.max,
            numberOfLines: 1
        )
        
        let label: UILabel = UILabel(frame: CGRectMake(
            0,
            self.view.bounds.size.height - size.height,
            self.view.bounds.size.width,
            size.height
            )
        )
        label.text = text
        label.textColor = self.titleColor
        label.font = self.labelFont
        
        return label
    }()
    
    lazy var savePinButton: UIButton = {
        let image: UIImage? = UIImage(named: "btn_savepin")
        let button: UIButton = UIButton(frame: CGRectMake(
            0,
            self.view.bounds.size.height - image!.size.height,
            image!.size.width,
            image!.size.height
            )
        )
        button.addTarget(self, action: "savePinButtonPressed", forControlEvents: UIControlEvents.TouchDown)
        button.setImage(image, forState: UIControlState.Normal)
        
        return button
    }()
    
    lazy var cancelPinButton: UIButton = {
        let image: UIImage? = UIImage(named: "btn_savepin")
        let button: UIButton = UIButton(frame: CGRectMake(
            self.view.bounds.size.width - image!.size.width,
            self.view.bounds.size.height - image!.size.height,
            image!.size.width,
            image!.size.height
            )
        )
        button.addTarget(self, action: "cancelPinButtonPressed", forControlEvents: UIControlEvents.TouchDown)
        //button.setImage(image, forState: UIControlState.Normal)
        button.setTitle("Cancel", forState: UIControlState.Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.backgroundColor = UIColor.redColor()
        
        return button
    }()
    
    lazy var touchPadView: SLTouchPadView = {
        let height: CGFloat = self.view.bounds.size.height - self.savePinButton.bounds.size.height -
            self.topInfoLabel.bounds.size.height - self.bottomInfoLabel.bounds.size.height
        let padView: SLTouchPadView = SLTouchPadView(frame: CGRectMake(
            CGRectGetMidX(self.view.bounds) - 0.5*height,
            0.5*(self.view.bounds.size.height - height),
            height,
            height
            )
        )
        padView.delegate = self
        return padView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.addSubview(self.topInfoLabel)
        self.view.addSubview(self.savePinButton)
        self.view.addSubview(self.cancelPinButton)
        self.view.addSubview(self.touchPadView)
    }
    
    func savePinButtonPressed() {
        self.delegate?.touchPadViewControllerWantsExit(self)
    }
    
    func cancelPinButtonPressed() {
        self.delegate?.touchPadViewControllerWantsExit(self)
    }
    
    // SLTouchPadView delegate methods
    func touchPadViewLocationSelected(touchPadViewController: SLTouchPadView, location:SLTouchPadLocation) {
        print("in touch pad view controller delegate")
    }
}
