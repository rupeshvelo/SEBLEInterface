//
//  SLAddContactTableViewCell.swift
//  Skylock
//
//  Created by Andre Green on 4/5/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

protocol SLAddContactTableViewCellDelegate {
    
}

enum SLAddContactTableViewCellButton {
    case Email
    case Phone
}

class SLAddContactTableViewCell:UITableViewCell {
    let buttonDivider:CGFloat = 15.0
    var imageData:NSData?
    
    lazy var emailButton: UIButton = {
        let emailImage = UIImage(named: "contact_cell_email")!
        let buttonRect = CGRectMake(
            self.bounds.size.width - emailImage.size.width - self.buttonDivider,
            0.5*(self.bounds.size.height - emailImage.size.height),
            emailImage.size.width,
            emailImage.size.height
        )
        
        let button:UIButton = UIButton(frame: buttonRect)
        button.addTarget(
            self,
            action: #selector(emailButtonPressed),
            forControlEvents: UIControlEvents.TouchDown
        )
        button.setImage(emailImage, forState: UIControlState.Normal)
        
        return button
    }()
    
    lazy var dividerView:UIView = {
        let yInset:CGFloat = 5.0
        let frame = CGRectMake(
            CGRectGetMinX(self.emailButton.frame) - self.buttonDivider,
            yInset,
            1,
            self.bounds.size.height - 2*yInset
        )
        
        let divider = UIView(frame: frame)
        divider.backgroundColor = UIColor(red: 151, green: 151, blue: 151)
        
        return divider
    }()
    
    lazy var phoneButton:UIButton = {
        let phoneImage = UIImage(named: "contact_cell_phone")!
        let frame = CGRectMake(
            CGRectGetMinX(self.dividerView.frame) - phoneImage.size.width - self.buttonDivider,
            0.5*(self.bounds.size.height - phoneImage.size.height),
            phoneImage.size.width,
            phoneImage.size.height
        )
        
        let button:UIButton = UIButton(frame: frame)
        button.addTarget(
            self,
            action: #selector(phoneButtonPressed),
            forControlEvents: UIControlEvents.TouchDown
        )
        button.setImage(phoneImage, forState: UIControlState.Normal)
        return button
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.addSubview(self.emailButton)
        self.addSubview(self.dividerView)
        self.addSubview(self.phoneButton)
        
        let anonymousContactImage:UIImage = UIImage(named: "contact_cell_anonymous_contact")!
        let profilePic:UIImage
        if let imageData = self.imageData, let image:UIImage = UIImage(data: imageData) {
            profilePic = image
        } else {
            profilePic = anonymousContactImage
        }
        
        self.imageView!.image = profilePic
        let frame = CGRectMake(
            self.imageView!.frame.origin.x,
            self.imageView!.frame.origin.y,
            anonymousContactImage.size.width,
            anonymousContactImage.size.height
        )
        let diameter = anonymousContactImage.size.width < anonymousContactImage.size.height ?
            anonymousContactImage.size.width : anonymousContactImage.size.width
        self.imageView!.layer.cornerRadius = 0.5*diameter
        self.imageView!.frame = frame
    }
    
    func updateImageWithData(imageData: NSData?) {
        self.imageData = imageData
    }
    
    func emailButtonPressed() {
        print("email button pressed")
    }
    
    func phoneButtonPressed() {
        print("phone button pressed")
    }
}
