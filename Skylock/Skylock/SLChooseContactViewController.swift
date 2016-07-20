//
//  SLContactViewController.swift
//  Skylock
//
//  Created by Andre Green on 4/5/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit
import Contacts

protocol SLChooseContactViewControllerDelegate:class {
    func contactViewControllerContactSelected(
        cvc: SLChooseContactViewController,
        contact: SLEmergencyContact,
        isSelected: Bool
    )
    func contactViewControllerWantsExit(cvc: SLChooseContactViewController)
}

class SLChooseContactViewController:
UIViewController,
UITableViewDataSource,
UITableViewDelegate,
SLContactsLetterViewControllerDelegate,
UISearchBarDelegate
{
    let letters:[String] = [
        "a",
        "b",
        "c",
        "d",
        "e",
        "f",
        "g",
        "h",
        "i",
        "j",
        "k",
        "l",
        "m",
        "n",
        "o",
        "p",
        "q",
        "r",
        "s",
        "t",
        "u",
        "v",
        "w",
        "x",
        "y",
        "z"
    ]
    
    var contacts:[String:[CNContact]] = [String:[CNContact]]()
    
    var displayedContacts:[String:[CNContact]] = [String:[CNContact]]()
    
    var currentText: String = ""
    
    let contactCellId:String = String(SLAddContactTableViewCell)
    
    var shouldShowNavController: Bool?
    
    weak var delegate: SLChooseContactViewControllerDelegate?
    
    var tableYOffset: CGFloat = 0.0
    
    var searchBarPlaceholderText: String?
    
    var cornerRadius: CGFloat?
    
    let contactHandler = SLContactHandler()
    
    var emergencyContacts = [String:SLEmergencyContact]()
    
    lazy var tableView: UITableView = {
        let frame = CGRectMake(
            0,
            CGRectGetMaxY(self.searchBar.frame),
            self.view.bounds.size.width,
            self.view.bounds.size.height - self.searchBar.bounds.size.height
        )
        
        let table:UITableView = UITableView.init(frame: frame, style: .Grouped)
        table.dataSource = self;
        table.delegate = self;
        table.rowHeight = 40.0
        table.separatorInset = UIEdgeInsetsZero
        table.registerClass(SLAddContactTableViewCell.self, forCellReuseIdentifier: self.contactCellId)

        return table
    }()
    
    lazy var letterViewController:SLContactsLetterViewController = {
        let view:SLContactsLetterViewController = SLContactsLetterViewController()
        view.delegate = self
        
        return view
    }()
    
    lazy var searchBar:UISearchBar = {
        let frame = CGRect(
            x: 0.0,
            y: UIApplication.sharedApplication().statusBarFrame.size.height
                + self.navigationController!.navigationBar.bounds.size.height,
            width: self.view.bounds.size.width,
            height: 50.0
        )
        
        let bar:UISearchBar = UISearchBar(frame: frame)
        bar.delegate = self
        bar.placeholder = NSLocalizedString("Search", comment: "")
        
        return bar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationItem.title = NSLocalizedString("FIND EMERGENCY CONTACTS", comment: "")
        
        self.getContacts()
        
        if let emergencyContacts = self.contactHandler.getActiveEmergencyContacts() {
            for contact in emergencyContacts where contact.contactId != nil {
                self.emergencyContacts[contact.contactId!] = contact
            }
        }
        
        self.view.addSubview(self.searchBar)
        self.view.addSubview(self.tableView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    
        if !self.view.subviews.contains(self.letterViewController.view) {
            let width:CGFloat = 25.0
            let height:CGFloat = self.view.bounds.size.height - CGRectGetMaxY(self.searchBar.frame) - 40.0
            self.letterViewController.view.frame = CGRect(
                x: self.view.bounds.size.width - width,
                y: CGRectGetMaxY(self.searchBar.frame),
                width: width,
                height: height
            )
            
            self.addChildViewController(self.letterViewController)
            self.view.addSubview(self.letterViewController.view)
            self.view.bringSubviewToFront(self.letterViewController.view)
            self.letterViewController.didMoveToParentViewController(self)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIKeyboardWillShowNotification,
            object: nil
        )
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(keyboardWillDisappear(_:)),
            name: UIKeyboardWillHideNotification,
            object: nil
        )
    }
    
    func getContacts() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            for letter in self.letters {
                self.contacts[letter] = [CNContact]()
            }
            
            do {
                try self.contactHandler.allContacts({ (fetchedContacts:[CNContact]) in
                    dispatch_async(dispatch_get_main_queue(), {
                        for contact in fetchedContacts {
                            if contact.givenName.characters.count > 0 &&
                                contact.givenName.substringToIndex(contact.givenName.startIndex.advancedBy(1)) != " "
                            {
                                let firstLetter = contact.givenName.substringToIndex(
                                    contact.givenName.startIndex.advancedBy(1)
                                    ).lowercaseString
                                
                                if var contacts:[CNContact] = self.contacts[firstLetter] {
                                    contacts.append(contact)
                                    self.contacts[firstLetter] = contacts
                                }
                            }
                        }
                        
                        for (letter, unsortedContacts) in self.contacts {
                            var contacts = unsortedContacts
                            contacts.sortInPlace({ (contact1, contact2) -> Bool in
                                if contact1.givenName.lowercaseString == contact2.givenName.lowercaseString {
                                    return contact1.familyName.lowercaseString < contact2.familyName.lowercaseString
                                }
                                
                                return contact1.givenName.lowercaseString < contact2.givenName.lowercaseString
                            })
                            
                            self.contacts[letter] = contacts
                        }
                        
                        self.displayedContacts = self.contacts
                        
                        self.tableView.reloadData()
                    })
                })
            } catch {
                print("error retreiving contacts")
            }
        })
    }
    
    func getContactsFromCurrentText() {
        if self.currentText == "" {
            self.displayedContacts = self.contacts
            return
        }
        
        for (letter, contacts) in self.contacts {
            var sortedContacts = [CNContact]()
            var i = contacts.count - 1
            while i >= 0 {
                let contact = contacts[i]
                let name = self.contactHandler.fullNameForContact(contact).lowercaseString
                if name.rangeOfString(self.currentText.lowercaseString) != nil {
                    sortedContacts.append(contact)
                }
                
                i -= 1
            }
            
            if sortedContacts.count == 0 {
                self.displayedContacts.removeValueForKey(letter)
            } else {
                self.displayedContacts[letter] = sortedContacts.reverse()
            }
        }
    }
    
    func keyForSection(section: Int) -> String? {
        var counter = 0
        for letter in self.letters {
            if self.displayedContacts[letter] != nil {
                if counter == section {
                    return letter
                }
                
                counter += 1
            }
        }
        
        return nil
    }
    
    func sectionForKey(key: String) -> Int? {
        if self.displayedContacts[key] == nil {
            return nil
        }
        
        let keys = self.displayedContacts.keys.sort()
        return keys.indexOf(key)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let info = notification.userInfo, let frameValue = info[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardFrame: CGRect = frameValue.CGRectValue()
            let appDelegate:SLAppDelegate = UIApplication.sharedApplication().delegate as! SLAppDelegate
            let rootVC: UIViewController = appDelegate.window.rootViewController!
            let convertedFrame = self.view.convertRect(keyboardFrame, fromView: rootVC.view)
            
            self.tableYOffset = keyboardFrame.height - (keyboardFrame.origin.y - convertedFrame.origin.y)
            
            if let navController = self.navigationController {
                self.tableYOffset += navController.navigationBar.bounds.size.height
                    + UIApplication.sharedApplication().statusBarFrame.size.height
            }
            
            self.tableView.contentInset = UIEdgeInsetsMake(
                self.tableView.contentInset.top,
                self.tableView.contentInset.left,
                self.tableView.contentInset.bottom + self.tableYOffset,
                self.tableView.contentInset.right
            )
        }
    }
    
    func keyboardWillDisappear(notification: NSNotification) {
        if let info = notification.userInfo,
            let durration:Double = info[UIKeyboardAnimationDurationUserInfoKey] as? Double,
            let curve = info[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber {
            
            UIView.animateWithDuration(
                durration,
                delay: 0,
                options: UIViewAnimationOptions(rawValue: curve.unsignedLongValue),
                animations: {
                    self.tableView.contentInset = UIEdgeInsetsMake(
                        self.tableView.contentInset.top,
                        self.tableView.contentInset.left,
                        self.tableView.contentInset.bottom - self.tableYOffset,
                        self.tableView.contentInset.right
                    )
                },
                completion: nil
            )
        }
    }

    // MARK: UITableViewDelegate & DataSource Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.displayedContacts.keys.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let key = self.keyForSection(section) else {
            return 0
        }
        
        if let contacts = self.displayedContacts[key] {
            return contacts.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var text = ""
        var isSelectedContact = false
        if let key = self.keyForSection(indexPath.section) {
            let contact:CNContact = self.displayedContacts[key]![indexPath.row]
            text = self.contactHandler.fullNameForContact(contact)
            isSelectedContact = self.emergencyContacts[contact.identifier] != nil
        }
        
        var cell: SLAddContactTableViewCell? = tableView.dequeueReusableCellWithIdentifier(
            self.contactCellId,
            forIndexPath: indexPath
            ) as? SLAddContactTableViewCell
        
        if cell == nil {
            cell = SLAddContactTableViewCell(style: .Default, reuseIdentifier: self.contactCellId)
        }
        
        cell!.selectionStyle = .None
        cell!.textLabel!.text = text
        cell!.isSelectedContact = isSelectedContact
        
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 65.0 : 26.0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view:UIView
        let labelWrapperView:UIView
        let letterLabelHeight = self.tableView(tableView, heightForHeaderInSection: 1)
        let letterHeight:CGFloat = 14.0
        let xSpacer:CGFloat = 10.0
        
        if section == 0 {
            let frame = CGRect(
                x: 0.0,
                y: 0.0,
                width: self.tableView.bounds.size.width,
                height: self.tableView(tableView, heightForHeaderInSection: section) + letterLabelHeight
            )
            
            view = UIView(frame: frame)
            view.backgroundColor = UIColor.whiteColor()
            
            let height:CGFloat = 16.0
            let labelFrame = CGRect(
                x: 0.0,
                y: 0.5*(view.bounds.size.height - height) - 0.5*self.tableView(tableView, heightForHeaderInSection: 1),
                width: view.bounds.size.width,
                height: height
            )
            
            let label:UILabel = UILabel(frame: labelFrame)
            label.font = UIFont.systemFontOfSize(14)
            label.textColor = UIColor(white: 155.0/255.0, alpha: 1.0)
            label.text = NSLocalizedString("Nominate up to 3 emergency contacts.", comment: "")
            label.textAlignment = .Center
            
            view.addSubview(label)

            let labelWrapperViewFrame = CGRect(
                x: 0.0,
                y: view.bounds.size.height - self.tableView(tableView, heightForHeaderInSection: 1),
                width: self.tableView.bounds.size.width,
                height: self.tableView(tableView, heightForHeaderInSection: 1)
            )
            labelWrapperView = UIView(frame: labelWrapperViewFrame)
            labelWrapperView.backgroundColor = UIColor(white: 242.0/255.0, alpha: 1.0)
            
            view.addSubview(labelWrapperView)
            
            let letterLabelFrame = CGRect(
                x: xSpacer,
                y: 0.5*(labelWrapperView.bounds.size.height - letterHeight),
                width: view.bounds.size.width - xSpacer,
                height: letterHeight
            )
            
            var text = ""
            if let letter = self.keyForSection(section) {
                text = letter.uppercaseString
            }
            let letterLabel:UILabel = UILabel(frame: letterLabelFrame)
            letterLabel.font = UIFont.systemFontOfSize(12.0)
            letterLabel.textColor = UIColor(white: 155.0/255.0, alpha: 1.0)
            letterLabel.text = text
            
            labelWrapperView.addSubview(letterLabel)
        } else {
            let frame = CGRect(
                x: 0.0,
                y: 0.0,
                width: self.tableView.bounds.size.width,
                height: self.tableView(tableView, heightForHeaderInSection: section)
            )
            view = UIView(frame: frame)
            view.backgroundColor = UIColor(white: 242.0/255.0, alpha: 1.0)
            
            let labelWrapperViewFrame = CGRect(
                x: 0.0,
                y: view.bounds.size.height - self.tableView(tableView, heightForHeaderInSection: 1),
                width: self.tableView.bounds.size.width,
                height: self.tableView(tableView, heightForHeaderInSection: 1)
            )
            
            labelWrapperView = UIView(frame: labelWrapperViewFrame)
            labelWrapperView.backgroundColor = UIColor(white: 242.0/255.0, alpha: 1.0)

            view.addSubview(labelWrapperView)
            
            let letterLabelFrame = CGRect(
                x: xSpacer,
                y: 0.5*(labelWrapperView.bounds.size.height - letterHeight),
                width: view.bounds.size.width - xSpacer,
                height: letterHeight
            )
            
            var text = ""
            if let letter = self.keyForSection(section) {
                text = letter.uppercaseString
            }
            let letterLabel:UILabel = UILabel(frame: letterLabelFrame)
            letterLabel.font = UIFont.systemFontOfSize(12.0)
            letterLabel.textColor = UIColor(white: 155.0/255.0, alpha: 1.0)
            letterLabel.text = text
            
            labelWrapperView.addSubview(letterLabel)
        }
    
        return view
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.000001
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let key = self.keyForSection(indexPath.section) else {
            return
        }
        
        let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as! SLAddContactTableViewCell
        cell.isSelectedContact = !cell.isSelectedContact
        cell.setNeedsDisplay()
        
        let contact = self.displayedContacts[key]![indexPath.row]
        let emergencyContact = self.contactHandler.emergencyContactFromCNContact(contact)
        self.delegate?.contactViewControllerContactSelected(
            self,
            contact: emergencyContact,
            isSelected: cell.isSelectedContact
        )
    }
    
    // MARK: SLContactsLetterViewControllerDelegate methods
    func contactsLetterViewController(letterViewController: SLContactsLetterViewController, letter: String) {
        let key = letter.lowercaseString
        guard let section = self.sectionForKey(key) else {
            return
        }
        
        guard let contacts = self.displayedContacts[key] else {
            return
        }
        
        if contacts.count == 0 {
            return
        }
        
        let indexPath = NSIndexPath(forRow: 0, inSection: section)
        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
    }
    
    // MARK: SLSearchBarDelegate methods
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }

    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        self.currentText = ""
        self.displayedContacts = self.contacts
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.currentText = searchText
        self.getContactsFromCurrentText()
        self.tableView.reloadData()
    }
}
