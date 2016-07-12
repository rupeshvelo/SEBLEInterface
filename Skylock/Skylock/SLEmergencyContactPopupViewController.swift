//
//  SLEmergencyContactPopupViewController.swift
//  Skylock
//
//  Created by Andre Green on 4/6/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit
import Contacts


@objc protocol SLEmergencyContactPopupViewControllerDelegate:class {
    func contactPopUpViewControllerWantsExit(cpvc: SLEmergencyContactPopupViewController)
}


class SLEmergencyContactPopupViewController: UIViewController,
SLAddContactButtonViewDelegate,
SLChooseContactViewControllerDelegate
{
    enum SLAddContactButtonViewTag:Int {
        case One = 1000
        case Two = 1001
        case Three = 1002
        case Invalid = 1100
    }
    
    let xPadding: CGFloat = 15.0
    let yPadding: CGFloat = 15.0
    let yMiddleViewSpacing: CGFloat = 30.0
    let contactHandler: SLContactHandler = SLContactHandler()
    let numberOfContacts = 3
    var contacts: [CNContact?] = []
    var selectedEmergencyContactViewID: SLUserDefaultsEmergencyContactId?
    var contactButtonViews = [SLUserDefaultsEmergencyContactId:SLAddContactButtonView]()
    weak var delegate: SLEmergencyContactPopupViewControllerDelegate?
    
    lazy var emergencyContactsHeaderLabel: UILabel = {
        let utility: SLUtilities = SLUtilities()
        
        let text = NSLocalizedString("Emergency Contacts", comment: "")
        let font = UIFont(name:"Helvetica", size:18)
        let size = utility.sizeForLabel(
            font!,
            text: text,
            maxWidth: self.view.bounds.size.width - 2*self.xPadding,
            maxHeight: CGFloat.max,
            numberOfLines: 0
        )
        let frame = CGRectMake(
            0.5*(self.view.bounds.size.width - size.width),
            self.yPadding,
            size.width,
            size.height
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.text = text
        label.font = font
        label.textColor = UIColor(red: 97, green: 100, blue: 100)
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.Center
        
        return label
    }()
    
    lazy var emergencyContactsHeaderSubLabel: UILabel = {
        let utility: SLUtilities = SLUtilities()
        
        let text = NSLocalizedString("Strongly Recomended", comment: "")
        let font = UIFont(name:"Helvetica", size:12)
        let size = utility.sizeForLabel(
            font!,
            text: text,
            maxWidth: self.view.bounds.size.width - 2*self.xPadding,
            maxHeight: CGFloat.max,
            numberOfLines: 0
        )
        let frame = CGRectMake(
            0.5*(self.view.bounds.size.width - size.width),
            CGRectGetMaxY(self.emergencyContactsHeaderLabel.frame) + 5,
            size.width,
            size.height
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.text = text
        label.font = font
        label.textColor = UIColor(red: 146, green: 148, blue: 151)
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.Center
        
        return label
    }()
    
    lazy var topDividerView:UIView = {
        let frame = CGRectMake(
            0,
            CGRectGetMaxY(self.emergencyContactsHeaderSubLabel.frame) + 10,
            self.view.bounds.size.width,
            1
        )
        
        let view:UIView = UIView(frame: frame)
        view.backgroundColor = UIColor(red: 236, green: 236, blue: 236)
        
        return view
    }()
    
    lazy var topMainLabel: UILabel = {
        let utility: SLUtilities = SLUtilities()
        
        let text = NSLocalizedString(
            "Select up to 3 loved ones an Automatic agent should call " +
            "if you’re in a crash. You can edit them any time.",
            comment: ""
        )
        let font = UIFont(name:"Helvetica", size:13)
        let size = utility.sizeForLabel(
            font!,
            text: text,
            maxWidth: self.view.bounds.size.width - 2*self.xPadding,
            maxHeight: CGFloat.max,
            numberOfLines: 0
        )
        let frame = CGRectMake(
            self.xPadding,
            CGRectGetMaxY(self.topDividerView.frame) + 15,
            size.width,
            size.height
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.text = text
        label.font = font
        label.textColor = UIColor(red: 97, green: 100, blue: 100)
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.Center
        
        return label
    }()
    
    lazy var contactsView: UIView = {
        let height: CGFloat = 100.0
        let frame: CGRect = CGRect(
            x: self.xPadding,
            y: CGRectGetMaxY(self.topMainLabel.frame) + self.yMiddleViewSpacing,
            width: self.view.bounds.size.width - 2*self.xPadding,
            height: height
        )
        
        let view: UIView = UIView(frame: frame)
        view.backgroundColor = UIColor.clearColor()
        
        let buttonViewHeight:CGFloat = 90.0
        let buttonViewWidth:CGFloat = 80.0
        
        let frame1:CGRect = CGRect(
            x: 0,
            y: 0.5*(height - buttonViewHeight),
            width: buttonViewWidth,
            height: buttonViewHeight
        )
        
        let frame2:CGRect = CGRect(
            x: 0.5*(view.bounds.size.width - buttonViewWidth),
            y: frame1.origin.y,
            width: buttonViewWidth,
            height: buttonViewHeight
        )
        
        let frame3:CGRect = CGRect(
            x: view.bounds.size.width - buttonViewWidth,
            y: frame1.origin.y,
            width: buttonViewWidth,
            height: buttonViewHeight
        )
        
        let contactView1: SLAddContactButtonView = SLAddContactButtonView(
            frame: frame1,
            name: nil,
            phoneNumber: nil,
            imageData: nil
        )
        contactView1.delegate = self
        contactView1.tag = SLAddContactButtonViewTag.One.rawValue
        
        let contactView2: SLAddContactButtonView = SLAddContactButtonView(
            frame: frame2,
            name: nil,
            phoneNumber: nil,
            imageData: nil
        )
        contactView2.delegate = self
        contactView2.tag = SLAddContactButtonViewTag.Two.rawValue
        
        let contactView3: SLAddContactButtonView = SLAddContactButtonView(
            frame: frame3,
            name: nil,
            phoneNumber: nil,
            imageData: nil
        )
        contactView3.delegate = self
        contactView3.tag = SLAddContactButtonViewTag.Three.rawValue
        
        self.contactButtonViews[SLUserDefaultsEmergencyContactId.One] = contactView1
        self.contactButtonViews[SLUserDefaultsEmergencyContactId.Two] = contactView2
        self.contactButtonViews[SLUserDefaultsEmergencyContactId.Three] = contactView3
        
        view.addSubview(contactView1)
        view.addSubview(contactView2)
        view.addSubview(contactView3)
        
        return view
    }()
    
    lazy var bottomMainLabel: UILabel = {
        let utility: SLUtilities = SLUtilities()
        
        let text = NSLocalizedString(
            "Skylock will send a message to notify your contact when " +
            "you select them.",
            comment: ""
        )
        let font = UIFont(name:"Helvetica", size:13)
        let size = utility.sizeForLabel(
            font!,
            text: text,
            maxWidth: self.view.bounds.size.width - 2*self.xPadding,
            maxHeight: CGFloat.max,
            numberOfLines: 0
        )
        let frame = CGRectMake(
            0.5*(self.view.bounds.size.width - size.width),
            CGRectGetMaxY(self.contactsView.frame) + self.yMiddleViewSpacing,
            size.width,
            size.height
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.text = text
        label.font = font
        label.textColor = UIColor(red: 97, green: 100, blue: 100)
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.Center
        
        return label
    }()
    
    lazy var dismissButton: UIButton = {
        let image: UIImage = UIImage(named: "contacts_dismiss_button")!
        let frame = CGRect(
            x: self.xPadding,
            y: self.view.bounds.size.height - self.yPadding - image.size.height,
            width: image.size.width,
            height: image.size.height
        )
        
        let button: UIButton = UIButton(frame: frame)
        button.addTarget(
            self,
            action: #selector(dismissButtonPressed),
            forControlEvents: UIControlEvents.TouchDown
        )
        button.setImage(image, forState: UIControlState.Normal)
        
        return button
    }()
    
    lazy var doneButton: UIButton = {
        let image: UIImage = UIImage(named: "contacts_done_button")!
        let frame = CGRect(
            x: self.view.bounds.size.width - self.xPadding - image.size.width,
            y: CGRectGetMinY(self.dismissButton.frame),
            width: image.size.width,
            height: image.size.height
        )
        
        let button: UIButton = UIButton(frame: frame)
        button.addTarget(
            self,
            action: #selector(doneButtonPressed),
            forControlEvents: UIControlEvents.TouchDown
        )
        button.setImage(image, forState: UIControlState.Normal)
        
        return button
    }()
    
    lazy var bottomDividerView: UIView = {
        let frame = CGRectMake(
            0,
            CGRectGetMinY(self.dismissButton.frame) - 15,
            self.view.bounds.size.width,
            1
        )
        
        let view:UIView = UIView(frame: frame)
        view.backgroundColor = UIColor(red: 236, green: 236, blue: 236)
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.fetchContacts()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.addSubview(self.emergencyContactsHeaderLabel)
        self.view.addSubview(self.emergencyContactsHeaderSubLabel)
        self.view.addSubview(self.topDividerView)
        self.view.addSubview(self.topMainLabel)
        self.view.addSubview(self.contactsView)
        self.view.addSubview(self.bottomMainLabel)
        self.view.addSubview(self.dismissButton)
        self.view.addSubview(self.doneButton)
        self.view.addSubview(self.bottomDividerView)
        
        self.centerMiddleViewsVertically()
        self.updateAllButtonViews()
    }
    
    func dismissButtonPressed() {
        if let delegate = self.delegate {
            delegate.contactPopUpViewControllerWantsExit(self)
        }
    }
    
    func doneButtonPressed() {
        if let delegate = self.delegate {
            delegate.contactPopUpViewControllerWantsExit(self)
        }
    }
    
    func centerMiddleViewsVertically() {
        let height = self.topMainLabel.bounds.size.height +
            self.contactsView.bounds.size.height +
            self.bottomMainLabel.bounds.size.height + 2*self.yMiddleViewSpacing
        let middleHeight = CGRectGetMinY(self.bottomDividerView.frame) -
            CGRectGetMaxY(self.topDividerView.frame)
        let y0 = CGRectGetMaxY(self.topDividerView.frame) + 0.5*(middleHeight - height)
        
        self.topMainLabel.frame = CGRect(
            x: self.topMainLabel.frame.origin.x,
            y: y0,
            width: self.topMainLabel.bounds.size.width,
            height: self.topMainLabel.bounds.size.height
        )
        
        self.contactsView.frame = CGRect(
            x: self.contactsView.frame.origin.x,
            y: CGRectGetMaxY(self.topMainLabel.frame) + self.yMiddleViewSpacing,
            width: self.contactsView.bounds.size.width,
            height: self.contactsView.bounds.size.height
        )
        
        self.bottomMainLabel.frame = CGRect(
            x: self.bottomMainLabel.frame.origin.x,
            y: CGRectGetMaxY(self.contactsView.frame) + self.yMiddleViewSpacing,
            width: self.bottomMainLabel.bounds.size.width,
            height: self.bottomMainLabel.bounds.size.height
        )
    }
    
    func fullNameForContact(contact: CNContact) -> String {
        return contact.givenName + " " + contact.familyName
    }
    
    func fetchContacts() {
        for i in 0...self.numberOfContacts {
            do {
                let contactKey = try self.indexToEmergencyCotactId(i)
                let contactId = self.contactHandler.emergencyContactIdFromUserDefaults(contactKey)
                if let identifier = contactId {
                    let contacts: [CNContact] = try self.contactHandler.getContactsWithIds([identifier])
                    if contacts.isEmpty {
                        self.contacts.append(nil)
                    } else {
                        self.contacts.append(contacts.first)
                    }
                } else {
                    self.contacts.append(nil)
                }
            } catch SLError.ArrayIndexOutOfRange {
                print("How did we get here...list index for contacts out of range")
            } catch {
                self.contacts.append(nil)
            }
        }
    }
    
    func saveEmergencyContact(contact: CNContact) {
        if let contactId = self.selectedEmergencyContactViewID {
            self.contactHandler.saveContactToUserDefaults(
                contact,
                contactId: contactId,
                shouldSaveToServer: true
            )
        }
    }
    
    func indexToEmergencyCotactId(index: Int) throws -> SLUserDefaultsEmergencyContactId {
        let contactId: SLUserDefaultsEmergencyContactId
        switch index {
        case 0:
            contactId = .One
        case 1:
            contactId = .Two
        case 2:
            contactId = .Three
        default:
            throw SLError.ArrayIndexOutOfRange
        }
        
        return contactId
    }
    
    func buttonViewToEmergencyContactIdMap(tag: Int) throws -> SLUserDefaultsEmergencyContactId {
        let contactId:SLUserDefaultsEmergencyContactId
        switch tag {
        case SLAddContactButtonViewTag.One.rawValue:
            contactId = .One
        case SLAddContactButtonViewTag.Two.rawValue:
            contactId = .Two
        case SLAddContactButtonViewTag.Three.rawValue:
            contactId = .Three
        default:
            throw SLError.ArrayIndexOutOfRange
        }
        
        return contactId
    }
    
    func emergencyContactToButtonViewTagMap(contactId: SLUserDefaultsEmergencyContactId) -> SLAddContactButtonViewTag {
        let tag: SLAddContactButtonViewTag
        switch contactId {
        case .One:
            tag = .One
        case .Two:
            tag = .Two
        case .Three:
            tag = .Three
        }
        
        return tag
    }
    
    func removeContactViewController(cvc: SLChooseContactViewController) {
        
        UIView.animateWithDuration(0.3, animations: {
            //cvc.view.frame = CGRect(x: cvc.view.center.x, y: cvc.view.center.y, width: 0, height: 0)
            cvc.view.alpha = 0.0
        }) { (finished) in
            cvc.view.removeFromSuperview()
            cvc.removeFromParentViewController()
        }
    }
    
    func updateButtonView(buttonView: SLAddContactButtonView, contact: CNContact) {
        let name = self.fullNameForContact(contact)
        buttonView.updateName(name)
        buttonView.setImage(true)
        if contact.isKeyAvailable(CNContactPhoneNumbersKey) {
            if let phoneNumber = contact.phoneNumbers.first,
                let number = phoneNumber.value as? CNPhoneNumber
            {
                buttonView.updatePhoneNumber(number.stringValue)
            }
        }
    }
    
    func updateAllButtonViews() {
        for (index, contact) in self.contacts.enumerate() {
            if contact == nil {
                continue
            }
            
            do {
                let tag = try self.indexToEmergencyCotactId(index)
                let buttonView = self.contactButtonViews[tag]!
                self.updateButtonView(buttonView, contact: contact!)
            } catch {
                print("Error: could not get emergency contact id from index")
            }
        }
    }
    
    // MARK SLAddContactButtonViewDelegate Methods
    func addContactButtonViewTapped(addContactButtonView: SLAddContactButtonView) {
        do {
            self.selectedEmergencyContactViewID = try self.buttonViewToEmergencyContactIdMap(addContactButtonView.tag)
        } catch SLError.ArrayIndexOutOfRange {
            print("contact emergency view tag out of range")
            return
        } catch {
            print("unknown error while getting emergency contact key from view map")
            return
        }
        
        let cvc = SLChooseContactViewController()
        cvc.delegate = self
        cvc.shouldShowNavController = false
        cvc.searchBarPlaceholderText = NSLocalizedString("Add Contact", comment: "")
        cvc.cornerRadius = self.view.layer.cornerRadius
        cvc.view.frame = self.view.bounds
        cvc.view.alpha = 0.0;
        
        self.addChildViewController(cvc)
        self.view.addSubview(cvc.view)
        self.view.bringSubviewToFront(cvc.view)
        cvc.didMoveToParentViewController(self)
        
        UIView.animateWithDuration(0.3) {
            cvc.view.alpha = 1.0
        }
    }
    
    // MARK SLContactViewControllerDelegate Methods
    func contactViewControllerContactSelected(cvc: SLChooseContactViewController, contact: CNContact) {
        self.saveEmergencyContact(contact)
        self.removeContactViewController(cvc)
        
        if let contactId = self.selectedEmergencyContactViewID,
            let buttonView = self.contactButtonViews[contactId]
        {
            self.updateButtonView(buttonView, contact: contact)
        }
    }
    
    func contactViewControllerWantsExit(cvc: SLChooseContactViewController) {
        self.removeContactViewController(cvc)
    }
}
