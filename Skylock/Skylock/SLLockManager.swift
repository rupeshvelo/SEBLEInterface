//
//  SLLockHandler.swift
//  Ellipse
//
//  Created by Andre Green on 8/15/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLLockManager: NSObject, SEBLEInterfaceManagerDelegate {
    enum SLLockManagerState {
        case ActiveSearch
    }
    
    private enum BLEService:String {
        case Security = "5E00"
        case Hardware = "5E40"
        case Configuration = "5E80"
        case Test = "5EC0"
        case Boot = "5D00"
    }
    
    private enum BLECharacteristic:String {
        case LED = "5E41"
        case Lock = "5E42"
        case HardwareInfo = "5E43"
        case Reserved = "5E44"
        case TxPower = "5E45"
        case Magnet = "5EC3"
        case Accelerometer = "5E46"
        case SignedMessage = "5E01"
        case PublicKey = "5E02"
        case ChallengeKey = "5E03"
        case ChallegeData = "5E04"
        case SecurityState = "5E05"
        case CodeVersion = "5D01"
        case WriteFirmware = "5D02"
        case FirmwareUpdateDone = "5D04"
        case ResetLock = "5E81"
        case SerialNumber = "5E83"
        case ButtonSequece = "5E84"
        case CommandStatus = "5E05"
    }
    
    static let sharedManager = SLLockManager()
    
    let dbManager:SLDatabaseManager = SLDatabaseManager.sharedManager() as! SLDatabaseManager
    
    lazy var bleManager:SEBLEInterfaceMangager = {
        let manager:SEBLEInterfaceMangager = SEBLEInterfaceMangager.sharedManager() as! SEBLEInterfaceMangager
        manager.delegate = self
        
        return manager
    }()
    
    func getCurrentLock() -> SLLock? {
        guard let locks:[SLLock] = self.dbManager.locksForCurrentUser() as? [SLLock] else {
            return nil
        }
        
        var currentLock:SLLock? = nil
        for lock in locks {
            if let isCurrentLock = lock.isCurrentLock where isCurrentLock.boolValue {
                currentLock = lock
                break
            }
        }
        
        return currentLock
    }
    
    // MARK: SEBLEInterfaceManager Delegate methods
    func bleInterfaceManagerIsPoweredOn(interfaceManager: SEBLEInterfaceMangager!) {
        interfaceManager.startScan()
    }
    
    func bleInterfaceManager(
        interfaceManger: SEBLEInterfaceMangager!,
        discoveredPeripheral peripheral: SEBLEPeripheral!,
                             withAdvertisemntData advertisementData: [NSObject : AnyObject]!
        )
    {
            
    }
    
    func bleInterfaceManager(
        interfaceManager: SEBLEInterfaceMangager!,
        disconnectedPeripheralNamed peripheralName: String!)
    {
        
    }
    
    func bleInterfaceManager(
        interfaceManager: SEBLEInterfaceMangager!,
        connectedPeripheralNamed peripheralName: String!
        )
    {
        
    }
    
    func bleInterfaceManager(
        interfaceManager: SEBLEInterfaceMangager!,
        discoveredServicesForPeripheralNamed peripheralName: String!
        )
    {
        
    }
    
    func bleInterfaceManager(
        interfaceManager: SEBLEInterfaceMangager!,
        discoveredCharacteristicsForService service: CBService!,
                                            forPeripheralNamed peripheralName: String!
        )
    {
        
    }
    
    func bleInterfaceManager(
        interfaceManager: SEBLEInterfaceMangager!,
        peripheralName: String!,
        changedUpdateStateForCharacteristic characteristicUUID: String!
        )
    {
        
    }
    
    func bleInterfaceManager(
        interfaceManager: SEBLEInterfaceMangager!,
        wroteValueToPeripheralNamed peripheralName: String!,
                                    forUUID uuid: String!,
                                            withWriteSuccess success: Bool
        )
    {
        
    }
    
    func bleInterfaceManager(
        interfaceManager: SEBLEInterfaceMangager!,
        updatedPeripheralNamed peripheralName: String!,
                               forCharacteristicUUID characteristicUUID: String!,
                                                     withData data: NSData!
        )
    {
        
    }
}
