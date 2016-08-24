//
//  SLWarningViewController.swift
//  Skylock
//
//  Created by Andre Green on 7/23/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

protocol SLWarningViewControllerDelegate:class {
    func warningVCTakeActionButtonPressed(wvc: SLWarningViewController)
    func warningVCCancelActionButtonPressed(wvc: SLWarningViewController)
}

class SLWarningViewController: UIViewController {
    private let headerText:String
    
    private let infoText:String
    
    private let cancelButtonTitle:String
    
    private let actionButtonTitle:String?
    
    private let padding:CGFloat = 10.0
    
    private let buttonSpacer:CGFloat = 2.0
    
    weak var delegate:SLWarningViewControllerDelegate?
    
    private lazy var headerLabel:UILabel = {
        let labelWidth = self.view.bounds.size.width - 2*self.padding
        let height:CGFloat = 24.0
        let frame = CGRectMake(self.padding, 25.0, labelWidth, height)
        
        let label:UILabel = UILabel(frame: frame)
        label.text = self.headerText
        label.textColor = SLUtilities().color(.Color76_79_97)
        label.font = UIFont.systemFontOfSize(20)
        label.textAlignment = .Center
        
        return label
    }()
    
    private lazy var infoLabel:UILabel = {
        let labelWidth = self.view.bounds.size.width - 2*self.padding
        let utility = SLUtilities()
        let font = UIFont.systemFontOfSize(10.0)
        let text = self.infoText
        let labelSize:CGSize = utility.sizeForLabel(
            font,
            text: text,
            maxWidth: labelWidth,
            maxHeight: CGFloat.max,
            numberOfLines: 0
        )
        
        let frame = CGRectMake(
            0.5*(self.view.bounds.size.width - labelSize.width),
            CGRectGetMaxY(self.headerLabel.frame) + 15.0,
            labelSize.width,
            labelSize.height
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.textColor = utility.color(.Color76_79_97)
        label.text = text
        label.textAlignment = .Center
        label.font = font
        label.numberOfLines = 0
        
        return label
    }()
    
    private lazy var cancelButton:UIButton = {
        let width = self.actionButtonTitle == nil ? self.view.bounds.size.width - 2.0*self.padding
            : 0.5*(self.view.bounds.size.width - self.buttonSpacer) - self.padding
        let height:CGFloat = 45.0
        let util = SLUtilities()
        let frame = CGRectMake(
            self.padding,
            self.view.bounds.size.height - self.padding - height,
            width,
            height
        )
        
        let button:UIButton = UIButton(type: .System)
        button.frame = frame
        button.setTitle(self.cancelButtonTitle, forState: .Normal)
        button.setTitleColor(util.color(.Color155_155_155), forState: .Normal)
        button.backgroundColor = util.color(.Color239_239_239)
        button.addTarget(self, action: #selector(cancelButtonPressed), forControlEvents: .TouchDown)
        
        return button
    }()
    
    private lazy var actionButton:UIButton = {
        let width = self.cancelButton.bounds.size.width
        let height:CGFloat = 45.0
        let util = SLUtilities()
        let frame = CGRectMake(
            self.view.bounds.size.width - self.padding - width,
            self.view.bounds.size.height - self.padding - height,
            width,
            height
        )
        
        let button:UIButton = UIButton(type: .System)
        button.frame = frame
        button.setTitle(self.actionButtonTitle, forState: .Normal)
        button.setTitleColor(util.color(.Color255_255_255), forState: .Normal)
        button.backgroundColor = util.color(.Color102_177_227)
        button.addTarget(self, action: #selector(actionButtonPressed), forControlEvents: .TouchDown)
        
        return button
    }()
    
    init(headerText: String, infoText:String, cancelButtonTitle: String, actionButtonTitle: String?) {
        self.headerText = headerText
        self.infoText = infoText
        self.cancelButtonTitle = cancelButtonTitle
        self.actionButtonTitle = actionButtonTitle
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        if !self.view.subviews.contains(self.headerLabel) {
            self.view.addSubview(self.headerLabel)
        }
        
        if !self.view.subviews.contains(self.infoLabel) {
            self.view.addSubview(self.infoLabel)
        }
        
        if !self.view.subviews.contains(self.cancelButton) {
            self.view.addSubview(self.cancelButton)
        }
        
        if !self.view.subviews.contains(self.actionButton) && self.actionButtonTitle != nil {
            self.view.addSubview(self.actionButton)
        }
    }
    
    func cancelButtonPressed() {
        self.delegate?.warningVCCancelActionButtonPressed(self)
    }
    
    func actionButtonPressed() {
        self.delegate?.warningVCTakeActionButtonPressed(self)
    }
}
