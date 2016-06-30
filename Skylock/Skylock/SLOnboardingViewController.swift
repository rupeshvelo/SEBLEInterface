//
//  SLOnboardingViewController.swift
//  Skylock
//
//  Created by Andre Green on 5/26/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLOnboardingViewController: UIViewController {
    let picName:String
    let topText:String
    let bottomText:String
    let yBottomBound:CGFloat
    let xPadding:CGFloat = 35.0
    
    init(nibName nibNameOrNil: String?,
                 bundle nibBundleOrNil: NSBundle?,
                        picName:String,
                        topText:String,
                        bottomText:String,
                        yBottomBound:CGFloat
        )
    {
        self.picName = picName
        self.topText = topText
        self.bottomText = bottomText
        self.yBottomBound = yBottomBound
        
        super.init(nibName: nibNameOrNil, bundle:nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var pictureView:UIImageView = {
        let pic:UIImage = UIImage(named: self.picName)!
        let frame = CGRect(
            x: 0.5*(self.view.bounds.size.width - pic.size.width),
            y: 0.0,
            width: pic.size.width,
            height: pic.size.height
        )
        
        let picView:UIImageView = UIImageView(frame: frame)
        picView.image = pic
        
        return picView
    }()
    
    lazy var topLabel:UILabel = {
        let labelWidth = self.view.bounds.size.width - 2*self.xPadding
        let utility = SLUtilities()
        let font = UIFont.systemFontOfSize(14)
        let labelSize:CGSize = utility.sizeForLabel(
            font,
            text: self.topText,
            maxWidth: labelWidth,
            maxHeight: CGFloat.max,
            numberOfLines: 0
        )
        
        let frame = CGRectMake(
            self.xPadding,
            CGRectGetMaxY(self.pictureView.frame) + 45.0,
            labelWidth,
            labelSize.height
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.textColor = UIColor(red: 102, green: 177, blue: 227)
        label.text = self.topText
        label.textAlignment = NSTextAlignment.Center
        label.font = font
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var bottomLabel:UILabel = {
        let labelWidth = self.view.bounds.size.width - 2*self.xPadding
        let utility = SLUtilities()
        let font = UIFont.systemFontOfSize(9)
        let labelSize:CGSize = utility.sizeForLabel(
            font,
            text: self.bottomText,
            maxWidth: labelWidth,
            maxHeight: CGFloat.max,
            numberOfLines: 0
        )
        
        let frame = CGRectMake(
            self.xPadding,
            CGRectGetMaxY(self.topLabel.frame) + 20.0,
            labelWidth,
            labelSize.height
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.textColor = UIColor(red: 155, green: 155, blue: 155)
        label.text = self.bottomText
        label.textAlignment = NSTextAlignment.Center
        label.font = font
        label.numberOfLines = 0
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.pictureView)
        self.view.addSubview(self.topLabel)
        self.view.addSubview(self.bottomLabel)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let y0:CGFloat = 0.5*(self.view.bounds.size.height - self.pictureView.bounds.size.height -
            (self.view.bounds.size.height - self.yBottomBound) - self.topLabel.bounds.size.height -
            20.0 - self.bottomLabel.bounds.size.height)
        self.topLabel.frame = CGRect(
            x: self.topLabel.frame.origin.x,
            y: CGRectGetMaxY(self.pictureView.frame) + y0,
            width: self.topLabel.bounds.size.width,
            height: self.topLabel.bounds.size.height
        )
        
        self.bottomLabel.frame = CGRect(
            x: self.bottomLabel.frame.origin.x,
            y: CGRectGetMaxY(self.topLabel.frame) + 20,
            width: self.bottomLabel.bounds.size.width,
            height: self.bottomLabel.bounds.size.height
        )
    }
}
