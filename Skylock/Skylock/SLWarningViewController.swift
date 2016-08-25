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

enum SLWarningViewControllerTextProperty {
    case Header
    case Info
    case CancelButton
    case ActionButton
}

class SLWarningViewController: UIViewController {
    private let padding:CGFloat = 10.0
    
    private let buttonSpacer:CGFloat = 2.0
    
    private var texts:[SLWarningViewControllerTextProperty:String?] = [SLWarningViewControllerTextProperty:String?]()
    
    weak var delegate:SLWarningViewControllerDelegate?
    
    private lazy var headerLabel:UILabel = {
        let labelWidth = self.view.bounds.size.width - 2*self.padding
        let height:CGFloat = 24.0
        let frame = CGRectMake(self.padding, 25.0, labelWidth, height)
        
        let label:UILabel = UILabel(frame: frame)
        label.text = self.getTextForProperty(.Header)
        label.textColor = SLUtilities().color(.Color76_79_97)
        label.font = UIFont.systemFontOfSize(20)
        label.textAlignment = .Center
        
        return label
    }()
    
    private lazy var infoLabel:UILabel = {
        let labelWidth = self.view.bounds.size.width - 2*self.padding
        let utility = SLUtilities()
        let font = UIFont.systemFontOfSize(10.0)
        let text = self.getTextForProperty(.Info) == nil ? "" : self.getTextForProperty(.Info)!
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
        let actionButtonTitle = self.getTextForProperty(.ActionButton)
        let width = actionButtonTitle == nil ? self.view.bounds.size.width - 2.0*self.padding
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
        button.setTitle(self.getTextForProperty(.CancelButton), forState: .Normal)
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
        button.setTitle(self.getTextForProperty(.ActionButton), forState: .Normal)
        button.setTitleColor(util.color(.Color255_255_255), forState: .Normal)
        button.backgroundColor = util.color(.Color102_177_227)
        button.addTarget(self, action: #selector(actionButtonPressed), forControlEvents: .TouchDown)
        
        return button
    }()
    
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
        
        if !self.view.subviews.contains(self.actionButton) && self.getTextForProperty(.ActionButton) != nil {
            self.view.addSubview(self.actionButton)
        }
    }
    
    private func getTextForProperty(property: SLWarningViewControllerTextProperty) -> String? {
        if let text = texts[property] {
            return text
        }
        
        return nil
    }
    
    func setTextProperties(texts: [SLWarningViewControllerTextProperty:String?]) {
        self.texts = texts
    }
    
    @objc private func cancelButtonPressed() {
        self.delegate?.warningVCCancelActionButtonPressed(self)
    }
    
    @objc private func actionButtonPressed() {
        self.delegate?.warningVCTakeActionButtonPressed(self)
    }
}
