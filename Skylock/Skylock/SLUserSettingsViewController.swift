//
//  SLUserSettingsViewController.swift
//  Skylock
//
//  Created by Andre Green on 7/22/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

class SLUserSettingsViewController:
UIViewController,
UITableViewDelegate,
UITableViewDataSource,
SLUserSettingTableViewCellDelegate
{
    private enum TextLocation {
        case Top
        case Bottom
    }
    
    private let settings:[[TextLocation:String]] = [
        [
            .Top: NSLocalizedString("Theft detection", comment: ""),
            .Bottom: NSLocalizedString("When a theft has been detected", comment: "")
        ],
        [
            .Top: NSLocalizedString("Crash detection", comment: ""),
            .Bottom: NSLocalizedString("When a crash has detected", comment: "")
        ],
        [
            .Top: NSLocalizedString("Auto proximity unlock", comment: ""),
            .Bottom: NSLocalizedString("When my ellipse is automatically unlocked", comment: "")
        ],
        [
            .Top: NSLocalizedString("Low battery", comment: ""),
            .Bottom: NSLocalizedString("When my ellipse battery reaches 20%", comment: "")
        ],
        [
            .Top: NSLocalizedString("Low battery", comment: ""),
            .Bottom: NSLocalizedString("When my ellipse battery reaches 20%", comment: "")
        ]
    ]
    
    lazy var tableView:UITableView = {
        let table:UITableView = UITableView(frame: self.view.bounds, style: .Plain)
        table.delegate = self
        table.dataSource = self
        table.rowHeight = 80.0
        table.backgroundColor = UIColor.whiteColor()
        table.registerClass(
            SLUserSettingTableViewCell.self,
            forCellReuseIdentifier: String(SLUserSettingTableViewCell)
        )
        
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.tableView)
    }
    
    // MARK: UITableView Delegate and Datasource methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settings.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = String(SLUserSettingTableViewCell)
        var cell:SLUserSettingTableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellId) as? SLUserSettingTableViewCell
        if cell == nil {
            cell = SLUserSettingTableViewCell(style: .Subtitle, reuseIdentifier: cellId)
        }
        cell?.delegate = self
        
        if let topText = self.settings[indexPath.row][.Top] {
            cell?.textLabel?.text = topText
        }
        
        if let bottomText = self.settings[indexPath.row][.Bottom] {
            cell?.detailTextLabel?.text = bottomText
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80.0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewFrame = CGRect(
            x: 0,
            y: 0,
            width: tableView.bounds.size.width,
            height: self.tableView(tableView, heightForHeaderInSection: 0)
        )
        
        let view:UIView = UIView(frame: viewFrame)
        
        let xPadding:CGFloat = 10.0
        let height:CGFloat = 20.0
        let textColor = UIColor(red: 140, green: 140, blue: 140)
        let labelFrame = CGRect(
            x: xPadding,
            y: 0.5*(view.bounds.size.height - height),
            width: viewFrame.size.width - 2*xPadding,
            height: height
        )
        
        let label:UILabel = UILabel(frame: labelFrame)
        label.font = UIFont.systemFontOfSize(18.0)
        label.text = NSLocalizedString("Push notifications", comment: "")
        label.textColor = textColor
        
        view.addSubview(label)
        
        let dividerViewFrame = CGRect(
            x: 0.0,
            y: view.bounds.size.height - 1,
            width: view.bounds.size.width,
            height: 1
        )
        
        let dividerView = UIView(frame: dividerViewFrame)
        dividerView.backgroundColor = textColor
        
        view.addSubview(dividerView)
        
        return view
    }
    
    // Mark: SLUserSettingsTableViewCellDelegate methods
    func userSettingsSwitchFlippedOn(cell: SLUserSettingTableViewCell, isOn: Bool) {
        for i in 0..<self.settings.count {
            let indexPath:NSIndexPath = NSIndexPath(forRow: i, inSection: 0)
            if let tableCell:SLUserSettingTableViewCell = self.tableView.cellForRowAtIndexPath(indexPath)
                as? SLUserSettingTableViewCell where tableCell == cell
            {
                print("cell at \(indexPath.row) is flipped to \(isOn)")
            }
        }
    }
}
