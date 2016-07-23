//
//  SLUserSettingTableViewCell.swift
//  Skylock
//
//  Created by Andre Green on 7/22/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

protocol SLUserSettingTableViewCellDelegate: class {
    func userSettingsSwitchFlippedOn(cell: SLUserSettingTableViewCell, isOn: Bool)
}

class SLUserSettingTableViewCell: UITableViewCell {
    weak var delegate:SLUserSettingTableViewCellDelegate?
    
    lazy var settingSwitch:UISwitch = {
        let sSwitch:UISwitch = UISwitch()
        sSwitch.onTintColor = UIColor(red: 87, green: 216, blue: 255)
        sSwitch.tintColor = UIColor(red: 219, green: 217, blue: 217)
        sSwitch.addTarget(self, action: #selector(switchFlipped), forControlEvents: .ValueChanged)
        
        return sSwitch
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.textLabel?.font = UIFont.systemFontOfSize(16.0)
        self.textLabel?.textColor = UIColor(red: 140, green: 140, blue: 140)
        
        self.detailTextLabel?.font = UIFont.systemFontOfSize(12.0)
        self.detailTextLabel?.textColor = UIColor(red: 188, green: 187, blue: 187)
        
        self.accessoryView = self.settingSwitch
    }
    
    @objc private func switchFlipped() {
        self.delegate?.userSettingsSwitchFlippedOn(self, isOn: self.settingSwitch.on)
    }
}
