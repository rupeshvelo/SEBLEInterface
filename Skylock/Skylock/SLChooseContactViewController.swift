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
    func contactViewControllerContactSelected(cvc: SLChooseContactViewController, contact: CNContact)
    func contactViewControllerWantsExit(cvc: SLChooseContactViewController)
}

class SLChooseContactViewController:
UIViewController,
UITableViewDataSource,
UITableViewDelegate,
SLContactsLetterViewControllerDelegate
{
    var contacts:[CNContact] = [CNContact]()
    var currentText: String = ""
    let contactCellId:String = String(SLAddContactTableViewCell)
    var shouldShowNavController: Bool?
    weak var delegate: SLChooseContactViewControllerDelegate?
    var tableYOffset: CGFloat = 0.0
    var searchBarPlaceholderText: String?
    var cornerRadius: CGFloat?
    
    lazy var tableView: UITableView = {
        let frame = CGRectMake(
            0,
            CGRectGetMaxY((self.navigationController?.navigationBar.frame)!),
            self.view.bounds.size.width,
            self.view.bounds.size.height
        )
        
        let table:UITableView = UITableView.init(frame: frame, style: .Plain)
        table.dataSource = self;
        table.delegate = self;
        table.rowHeight = 44.0
        table.separatorStyle = .None
        table.registerClass(SLAddContactTableViewCell.self, forCellReuseIdentifier: self.contactCellId)
    
        return table
    }()
    
    lazy var letterViewController:SLContactsLetterViewController = {
        let view:SLContactsLetterViewController = SLContactsLetterViewController()
        view.delegate = self
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.navigationItem.title = NSLocalizedString("FIND EMERGENCY CONTACTS", comment: "")
        
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !self.view.subviews.contains(self.tableView) {
            self.view.addSubview(self.tableView)
        }
        
        self.tableView.reloadData()

    
        if !self.view.subviews.contains(self.letterViewController.view) {
            let width:CGFloat = 20.0
            let height:CGFloat = self.view.bounds.size.height -
                CGRectGetMaxY(self.navigationController!.navigationBar.frame) - 40.0
            self.letterViewController.view.frame = CGRect(
                x: self.view.bounds.size.width - width,
                y: CGRectGetMaxY(self.navigationController!.navigationBar.frame),
                width: width,
                height: height
            )
            
            self.addChildViewController(self.letterViewController)
            self.view.addSubview(self.letterViewController.view)
            self.view.bringSubviewToFront(self.letterViewController.view)
            self.letterViewController.didMoveToParentViewController(self)
        }
    }
    
    func getContactsFromCurrentText() {
        if self.currentText == "" {
            self.contacts = []
            return;
        }
        
        let contactHandler = SLContactHandler()
        do {
            self.contacts = try contactHandler.getContactsWithName(self.currentText)
        } catch {
            print("There was an exception getting CNContacts");
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let info = notification.userInfo, let frameValue = info[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardFrame: CGRect = frameValue.CGRectValue()
            let appDelegate:SLAppDelegate = UIApplication.sharedApplication().delegate as! SLAppDelegate
            let rootVC: UIViewController = appDelegate.window.rootViewController!
            let convertedFrame = self.view.convertRect(keyboardFrame, fromView: rootVC.view)
            
            self.tableYOffset = keyboardFrame.height - (keyboardFrame.origin.y - convertedFrame.origin.y)
            
            if let navController = self.navigationController {
                self.tableYOffset += navController.navigationBar.bounds.size.height +
                    UIApplication.sharedApplication().statusBarFrame.size.height
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
    
    // MARK UITableViewDelegate & DataSource Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contacts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let contact: CNContact = self.contacts[indexPath.row]
        let text = contact.givenName + " " + contact.familyName

        let cell: SLAddContactTableViewCell = tableView.dequeueReusableCellWithIdentifier(self.contactCellId, forIndexPath: indexPath) as! SLAddContactTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.updateImageWithData(contact.imageData)
        cell.textLabel!.text = text
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let delegate = self.delegate {
            let contact = self.contacts[indexPath.row]
            delegate.contactViewControllerContactSelected(self, contact: contact)
        }
    }
    
    // MARK SLContactsLetterViewControllerDelegate methods
    func contactsLetterViewController(letterViewController: SLContactsLetterViewController, letter: String) {
        print("letter pressed: \(letter)")
    }
}
