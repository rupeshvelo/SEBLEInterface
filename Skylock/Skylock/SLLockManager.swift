//
//  SLLockManger.swift
//  Ellipse
//
//  Created by Andre Green on 8/15/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLLockManager: NSObject, SEBLEInterfaceManagerDelegate {
    enum SLLockManagerState {
        case FindCurrentLock
        case Connecting
        case ActiveSearch
        case PublicKey
        case SignedMessage
        case BootMode
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
        case CodeVersion = "5D01"
        case WriteFirmware = "5D02"
        case FirmwareUpdateDone = "5D04"
        case ResetLock = "5E81"
        case SerialNumber = "5E83"
        case ButtonSequece = "5E84"
        case CommandStatus = "5E05"
    }
    
    static let sharedManager = SLLockManager()
    
    private let dbManager:SLDatabaseManager = SLDatabaseManager.sharedManager() as! SLDatabaseManager
    
    private var currentLock:SLLock?
    
    private var currentState:SLLockManagerState = .FindCurrentLock
    
    lazy var bleManager:SEBLEInterfaceMangager = {
        let manager:SEBLEInterfaceMangager = SEBLEInterfaceMangager.sharedManager() as! SEBLEInterfaceMangager
        manager.delegate = self
        
        return manager
    }()
    
    // MARK: Public Methods
    func startBluetoothManager() {
        self.bleManager.powerOn()
        self.bleManager.setDeviceNamesToConnectTo(Set(self.namesToConntect()))
        self.bleManager.setDeviceNameFragmentsToConnect(self.namesToConntect())
        self.bleManager.setServiceToReadFrom(Set(self.servicesToSubscribe()))
        self.bleManager.setCharacteristicsToReceiveNotificationsFrom(Set(self.characteristicsToRead()))
        self.bleManager.setServicesToNotifyWhenTheyAreDiscoverd(Set(self.servicesToNotifyWhenFound()))
    }
    
    func getCurrentLock() -> SLLock? {
        if let currentLock = self.currentLock {
            return currentLock
        }
        
        guard let locks:[SLLock] = self.dbManager.locksForCurrentUser() as? [SLLock] else {
            return nil
        }
        
        for lock in locks {
            if let isCurrentLock = lock.isCurrentLock where isCurrentLock.boolValue {
                self.currentLock = lock
                break
            }
        }
        
        return self.currentLock
    }
    
    func disconnectFromLockWithMacAddress(macAddress: String) {
        
    }
    
    func readFirmwareDataForCurrentLock() {
        
    }
    
    func readSerialNumberForCurrentLock() {
        
    }
    
    func checkLockOpenOrClosed() {
        
    }
    
    func setCurrentLockLockedOrUnlocked(shouldLock: Bool) {
        
    }
    
    func unconnectedLocksInRangeForCurrentUser() -> [SLLock] {
        guard let locks:[SLLock] = self.dbManager.locksForCurrentUser() as? [SLLock] else {
            return [SLLock]()
        }
        
        var unconnectedLocks = [SLLock]()
        for lock in locks {
            if let isDetected = lock.isDetected where isDetected.boolValue {
                unconnectedLocks.append(lock)
            }
        }
        
        return unconnectedLocks
    }
    
    func allPreviouslyConnectedLocksForCurrentUser() -> [SLLock] {
        guard let locks:[SLLock] = self.dbManager.locksForCurrentUser() as? [SLLock] else {
            return [SLLock]()
        }
        
        var unconnectedLocks = [SLLock]()
        for lock in locks {
            if let isCurrentLock = lock.isCurrentLock where !isCurrentLock.boolValue {
                unconnectedLocks.append(lock)
            }
        }
        
        return unconnectedLocks
    }
    
    func locksInActiveSearch() -> [SLLock] {
        guard let locks:[SLLock] = self.dbManager.locksForCurrentUser() as? [SLLock] else {
            return [SLLock]()
        }
        
        var activeLocks:[SLLock] = [SLLock]()
        for lock:SLLock in locks {
            if let isCurrentLock = lock.isCurrentLock, let isDetected = lock.isDetected
                where (!isCurrentLock.boolValue && isDetected.boolValue)
            {
                activeLocks.append(lock)
            }
        }
        
        return activeLocks
    }
    
    func writeTouchPadButtonPushes(touches: [UInt8]) {
        guard let lock = self.currentLock else {
            print("Cannot write button pushes. There is no current lock")
            return
        }
        let maxTouches = 16
        if touches.count > maxTouches {
            print("Error: Attempting to write \(touches.count) to lock. Only \(maxTouches) are allowed")
            return
        }
        
        var touchesToWrite:[UInt8] = [UInt8]()
        touchesToWrite += touches
        while touchesToWrite.count < maxTouches {
            touchesToWrite.append(0x00)
        }
        
        let data = NSData(bytes: &touchesToWrite, length: maxTouches)
        self.writeToLockWithMacAddress(
            lock.macAddress!,
            service: .Configuration,
            characteristic: .ButtonSequece,
            data: data
        )
    }
    
    func changeCurrentLockGivenNameTo(newName: String) {
        guard let lock = self.currentLock else {
            print("Error: can not change current lock name. Current lock is nil")
            return;
        }
        
        lock.givenName = newName;
        self.dbManager.saveLock(lock)
    }
    
    func hasLocksForCurrentUser() -> Bool {
        guard let locks = self.dbManager.locksForCurrentUser() as? [SLLock] else {
            return false
        }
        
        return locks.count > 0
    }
    
    func deleteLockFromCurrentUserAccountWithMacAddress(macAddress: String) {
        
    }
    
    func factoryResetCurrentLock() {
        
    }
    
    func updateFirmwareForCurrentLock() {
        
    }
    
    func isBlePoweredOn() -> Bool {
        return self.bleManager.isPowerOn()
    }
    
    func isInActiveSearch() -> Bool {
        return self.currentState == .ActiveSearch
    }
    
    func startActiveSearch() {
        self.currentState = .ActiveSearch
        self.bleManager.startScan()
    }
    
    // MARK: Private Methods
    private func namesToConntect() -> [String] {
        return [
            "ellipse",
            "skylock",
            "ellboot",
            "skyboot"
        ]
    }
    
    private func servicesToSubscribe() -> [String] {
        return [
            self.serviceUUID(.Security),
            self.serviceUUID(.Hardware),
            self.serviceUUID(.Configuration),
            self.serviceUUID(.Test),
            self.serviceUUID(.Boot)
        ]
    }
    
    private func servicesToNotifyWhenFound() -> [String] {
        return [
            self.serviceUUID(.Security)
        ]
    }
    
    private func characteristicsToRead() -> [String] {
        return [
            self.characteristicUUID(.HardwareInfo),
            self.characteristicUUID(.LED),
            self.characteristicUUID(.Lock),
            self.characteristicUUID(.Magnet),
            self.characteristicUUID(.Accelerometer),
            self.characteristicUUID(.PublicKey),
            self.characteristicUUID(.CommandStatus),
            self.characteristicUUID(.CodeVersion),
            self.characteristicUUID(.WriteFirmware),
            self.characteristicUUID(.FirmwareUpdateDone),
            self.characteristicUUID(.ButtonSequece),
            self.characteristicUUID(.ResetLock),
            self.characteristicUUID(.CommandStatus),
            self.characteristicUUID(.SerialNumber)
        ]
    }
    
    private func characteristicsToNotify() -> [String] {
        return [
            self.characteristicUUID(.Magnet),
            self.characteristicUUID(.Accelerometer),
            self.characteristicUUID(.CommandStatus)
        ]
    }
    
    private func serviceUUID(service: BLEService) -> String {
        return self.uuidWithSegment(service.rawValue)
    }
    
    private func characteristicUUID(characteristic: BLECharacteristic) -> String {
        return self.uuidWithSegment(characteristic.rawValue)
    }
    
    private func uuidWithSegment(segment: String) -> String {
        return "D399" + segment + "-FA57-11E4-AE59-0002A5D5C51B"
    }
    
    private func writeToLockWithMacAddress(
        macAddress: String,
        service: BLEService,
        characteristic: BLECharacteristic,
        data: NSData
        )
    {
        self.bleManager.writeToPeripheralWithKey(
            macAddress,
            serviceUUID: self.serviceUUID(service),
            characteristicUUID: self.characteristicUUID(characteristic),
            data: data
        )
    }
    
    private func readFromLockWithMacAddress(
        macAddress: String,
        service: BLEService,
        characteristic: BLECharacteristic
        )
    {
        self.bleManager.readValueForPeripheralWithKey(
            macAddress,
            forServiceUUID: self.serviceUUID(service),
            andCharacteristicUUID: self.characteristicUUID(characteristic)
        )
    }
    
    private func setCurrentlyConnectedLock() {
        if self.currentLock != nil {
            return
        }
        
        guard let locks = self.dbManager.locksForCurrentUser() as? [SLLock] else {
            return
        }
        
        for lock in locks {
            if lock.isCurrentLock!.boolValue && lock.isDetected!.boolValue {
                self.currentLock = lock
                break
            }
        }
    }
    
    func connectLock(lock: SLLock) {
        
    }
    
    func availableUnconnectedLocks() -> [SLLock] {()
        var availableLocks = [SLLock]()
        guard let locks = self.dbManager.locksForCurrentUser() as? [SLLock] else {
            return availableLocks
        }
        
        for lock in locks {
            if lock.isCurrentLock!.boolValue && lock.isDetected!.boolValue {
                availableLocks.append(lock)
            }
        }
        
        return availableLocks
    }
    
    func flashLEDsForLock(lock: SLLock) {
        
    }
    
    func connectToLockWithMacAddress(macAddress: String) {
        
    }

    
    // MARK: SEBLEInterfaceManager Delegate methods
    func bleInterfaceManagerIsPoweredOn(interfaceManager: SEBLEInterfaceMangager!) {
        guard let locks:[SLLock] = self.dbManager.locksForCurrentUser() as? [SLLock] else {
            print("Will not start BLE scan. There is no user or the user doesn't have any locks")
            return
        }
        
        for lock in locks {
            if lock.isCurrentLock!.boolValue {
                interfaceManager.startScan()
                NSNotificationCenter.defaultCenter().postNotificationName(
                    kSLNotificationLockManagerBlePoweredOn,
                    object: nil
                )
                break
            }
        }
    }
    
    func bleInterfaceManager(
        interfaceManger: SEBLEInterfaceMangager!,
        discoveredPeripheral peripheral: SEBLEPeripheral!,
                             withAdvertisemntData advertisementData: [NSObject : AnyObject]!
        )
    {
        if let name = peripheral.peripheral.name {
           print("Found lock named \(name)")
        }

        guard let name:String = advertisementData["kCBAdvDataLocalName"] as? String else {
            print("Discovered peripheral \(peripheral.description) "
                + "but cannot connectet. No local name in advertisement data"
            )
            return
        }
        
        guard let address = name.macAddress() else {
            print("Could not retreive mac address from \(peripheral.description)")
            return
        }
        
        let dbLock:SLLock? = self.dbManager.getLockWithMacAddress(address)
        let lock:SLLock = dbLock == nil ?
            self.dbManager.newLockWithName(name, andUUID: peripheral.CBUUIDAsString()) : dbLock
        self.dbManager.saveLock(lock)
        
        if self.currentState == .FindCurrentLock && lock.isCurrentLock!.boolValue {
            // Case 1: Check if lock is the current lock. This is the case that happens
            // when the app first connects to the current lock after a disconnection.
        } else if self.currentState == .ActiveSearch && !lock.isDetected!.boolValue {
            // Case 2: We are actively looking for locks. When a new lock is found 
            // We'll send out an alert to let the rest of the app know that the lock was discovered
        } else if self.currentState == .BootMode && lock.isInBootMode!.boolValue {
            // Case 3: The lock has been reset to boot mode. This is currently used for firmware update,
            // however, there are other use cases for this mode
        } else {
            // Case 4: if the lock does not pass any of the preceeding tests we should handle 
            // the case here. We may need to disconnect the peripheral in the ble manager, but
            // then again maybe not. I need to think about that for awhile.
            print("The discovered lock: \(lock.name) could not be processed")
        }
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
