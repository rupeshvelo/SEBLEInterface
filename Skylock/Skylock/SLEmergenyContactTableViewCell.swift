//
//  SLEmergenyContactTableViewCell.swift
//  Skylock
//
//  Created by Andre Green on 7/10/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

enum SLEmergencyContactTableViewCellProperty {
    case Name
    case Pic
    case ContactId
}

protocol SLEmergenyContactTableViewCellDelegate:class {
    func removeButtonPressedOnCell(cell: SLEmergenyContactTableViewCell)
}

class SLEmergenyContactTableViewCell: UITableViewCell {
    weak var delegate:SLEmergenyContactTableViewCellDelegate?
    
    var contactId:String?
    
    lazy var removeContactButton:UIButton = {
        let image = UIImage(named: "button_remove_Emergencycontacts")!
        let frame = CGRect(
            x: CGRectGetMinX(self.textLabel!.frame),
            y: CGRectGetMaxY(self.textLabel!.frame) + 7.0,
            width: image.size.width,
            height: image.size.height
        )
        
        let button:UIButton = UIButton(frame: frame)
        button.addTarget(self, action: #selector(removeContactButtonPressed), forControlEvents: .TouchDown)
        button.setImage(image, forState: .Normal)
        
        return button
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let labelFrame = CGRect(
            x: self.textLabel!.frame.origin.x,
            y: CGRectGetMinY(self.imageView!.frame),
            width: self.textLabel!.bounds.size.width,
            height: 0.5*self.imageView!.bounds.size.height
        )
        
        self.textLabel?.frame = labelFrame
        self.textLabel?.textColor = UIColor(white: 155.0/255.0, alpha: 1.0)
        self.textLabel?.font = UIFont.systemFontOfSize(14.0)
        
        if !self.subviews.contains(self.removeContactButton) {
            let frame = CGRect(
                x: CGRectGetMinX(self.textLabel!.frame),
                y: CGRectGetMaxY(self.textLabel!.frame) + 7.0,
                width: self.removeContactButton.bounds.size.width,
                height: self.removeContactButton.bounds.size.height
            )
            
            self.removeContactButton.frame = frame
            self.addSubview(self.removeContactButton)
        }
    }
    
    func setProperties(properties: [SLEmergencyContactTableViewCellProperty: AnyObject]) {
        if let name = properties[.Name] as? String, let textLabel = self.textLabel {
            textLabel.text = name
            self.removeContactButton.enabled = true
        } else {
            self.removeContactButton.enabled = false
        }
        
        if let image = properties[.Pic] as? UIImage, let imageView = self.imageView {
            imageView.image = image
        }
        
        if let contactIdentifier = properties[.ContactId] as? String {
            self.contactId = contactIdentifier
        } else {
            self.contactId = nil
        }
    }
    
    func removeContactButtonPressed() {
        self.delegate?.removeButtonPressedOnCell(self)
    }
}
