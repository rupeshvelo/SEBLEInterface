//
//  SLContactViewController.swift
//  Skylock
//
//  Created by Andre Green on 4/5/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit
import Contacts

protocol SLContactViewControllerDelegate {
    func contactViewControllerContactSelected(cvc: SLContactViewController, contact: CNContact)
    func contactViewControllerWantsExit(cvc: SLContactViewController)
}

class SLContactViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    var contacts:[CNContact] = [CNContact]()
    var currentText: String = ""
    let contactCellId:String = String(SLAddContactTableViewCell)
    var shouldShowNavController: Bool?
    var delegate: SLContactViewControllerDelegate?
    var tableYOffset: CGFloat = 0.0
    var searchBarPlaceholderText: String?
    var cornerRadius: CGFloat?
    
    lazy var searchBar: UISearchBar = {
        var y0: CGFloat = 0.0
        if let showNav = self.shouldShowNavController where showNav {
            if let navController = self.navigationController {
                y0 = navController.navigationBar.bounds.size.height
            }
            
            y0 += UIApplication.sharedApplication().statusBarFrame.size.height
        }
        
        let frame = CGRectMake(0, y0, self.view.bounds.size.width, 45.0)
        var bar:UISearchBar = UISearchBar(frame: frame)
        bar.delegate = self
        bar.placeholder = self.searchBarPlaceholderText == nil ? "" : self.searchBarPlaceholderText!
        bar.setShowsCancelButton(true, animated: true)
        bar.showsBookmarkButton = false;
        bar.searchBarStyle = UISearchBarStyle.Minimal
        bar.tintColor = UIColor.blackColor()

        return bar
    }()
    
    lazy var tableView: UITableView = {
        let searchBarMaxY = CGRectGetMaxY(self.searchBar.frame)
        let table:UITableView = UITableView.init(frame: CGRectMake(
            0,
            searchBarMaxY,
            self.view.bounds.size.width,
            self.view.bounds.size.height - searchBarMaxY
            ), style: UITableViewStyle.Plain
        )
        table.dataSource = self;
        table.delegate = self;
        table.rowHeight = 50
        table.separatorStyle = UITableViewCellSeparatorStyle.None
        table.registerClass(SLAddContactTableViewCell.self, forCellReuseIdentifier: self.contactCellId)
    
        return table
    }()
    
    lazy var doneButton: UIButton = {
        let height: CGFloat = 35.0
        let width: CGFloat = 100.0
        let frame = CGRectMake(0.5*(self.view.bounds.size.width - width), 0.5*(self.view.bounds.size.height - height), width, height)
        
        let button:UIButton = UIButton(frame: frame)
        button.addTarget(
            self,
            action: #selector(doneButtonPressed),
            forControlEvents: UIControlEvents.TouchDown
        )
        button.setTitle(NSLocalizedString("Done", comment: ""), forState: UIControlState.Normal)
        button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        button.layer.cornerRadius = 2.0
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.blackColor().CGColor
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        if let radius = self.cornerRadius {
            self.view.layer.cornerRadius = radius
            self.view.clipsToBounds = true
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.addSubview(self.searchBar)
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.doneButton)
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
        self.doneButton.hidden = true
        self.searchBar.showsCancelButton = true
        if let info = notification.userInfo, let frameValue = info[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardFrame: CGRect = frameValue.CGRectValue()
            let appDelegate:SLAppDelegate = UIApplication.sharedApplication().delegate as! SLAppDelegate
            let rootVC: UIViewController = appDelegate.window.rootViewController!
            let convertedFrame = self.view.convertRect(keyboardFrame, fromView: rootVC.view)
            
            self.tableYOffset = keyboardFrame.height - (keyboardFrame.origin.y - convertedFrame.origin.y)
            
            self.tableView.contentInset = UIEdgeInsetsMake(
                self.tableView.contentInset.top,
                self.tableView.contentInset.left,
                self.tableView.contentInset.bottom + self.tableYOffset,
                self.tableView.contentInset.right
            )
        }
    }
    
    func keyboardWillDisappear(notification: NSNotification) {
        self.searchBar.showsCancelButton = false
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
    
    func doneButtonPressed() {
        if let delegate = self.delegate {
            delegate.contactViewControllerWantsExit(self)
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
    
    // Mark UISeachBarDelegate methods
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if let searchText = searchBar.text {
            self.currentText = (searchText as NSString).stringByReplacingCharactersInRange(range, withString: text)
            self.getContactsFromCurrentText()
        } else {
            self.contacts = []
        }
        
        self.tableView.reloadData()
        
        return true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        self.doneButton.hidden = false
        self.contacts = []
        self.tableView.reloadData()
        
    }
}
