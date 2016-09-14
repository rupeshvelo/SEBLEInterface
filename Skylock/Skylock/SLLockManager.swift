//
//  SLLockManger.swift
//  Ellipse
//
//  Created by Andre Green on 8/15/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

enum SLLockManagerConnectionError:UInt {
    case NotAuthorized = 0
}

class SLLockManager: NSObject, SEBLEInterfaceManagerDelegate, SLLockValueDelegate {
    private enum SLLockManagerState {
        case FindCurrentLock
        case Connecting
        case ActiveSearch
        case UpdateFirmware
    }
    
    private enum SLLockManagerSecurityPhase {
        case PublicKey
        case ChallengeKey
        case SignedMessage
        case Connected
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
        case ChallengeData = "5E04"
        case FirmwareVersion = "5D01"
        case WriteFirmware = "5D02"
        case WriteFirmwareNotification = "5D03"
        case FirmwareUpdateDone = "5D04"
        case ResetLock = "5E81"
        case SerialNumber = "5E83"
        case ButtonSequece = "5E84"
        case CommandStatus = "5E05"
        
        static let allValues = [
            LED,
            Lock,
            HardwareInfo,
            Reserved,
            TxPower,
            Magnet,
            Accelerometer,
            SignedMessage,
            PublicKey,
            ChallengeKey,
            ChallengeData,
            FirmwareVersion,
            WriteFirmware,
            WriteFirmwareNotification,
            FirmwareUpdateDone,
            ResetLock,
            SerialNumber,
            ButtonSequece,
            CommandStatus
        ]
    }
    
    static let sharedManager = SLLockManager()
    
    private let dbManager:SLDatabaseManager = SLDatabaseManager.sharedManager() as! SLDatabaseManager
    
    private var currentState:SLLockManagerState = .FindCurrentLock
    
    private var securityPhase:SLLockManagerSecurityPhase = .PublicKey
    
    private var keychainHandler:SLKeychainHandler = SLKeychainHandler()
    
    private var lockValues:[String:SLLockValue] = [String:SLLockValue]()
    
    private var firmware:[String]?
    
    private var hardwareTimer:NSTimer?
    
    private var maxFirmwareLines:Int?
    
    private var afterDisconnectLockClosure:(() -> ())?
    
    private var afterUserDisconnectLockClosure:(() -> ())?
    
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
        self.bleManager.setCharacteristicsToReadFrom(Set(self.characteristicsToRead()))
        self.bleManager.setCharacteristicsToReceiveNotificationsFrom(Set(self.characteristicsToNotify()))
        self.bleManager.setServicesToNotifyWhenTheyAreDiscoverd(Set(self.servicesToNotifyWhenFound()))
    }
    
    func getCurrentLock() -> SLLock? {
        guard let locks:[SLLock] = self.dbManager.locksForCurrentUser() as? [SLLock] else {
            return nil
        }
        
        for lock in locks
            where (lock.isCurrentLock!.boolValue && self.bleManager.hasConnectedPeripheralWithKey(lock.macAddress!))
        {
            return lock
        }
        
        return nil
    }
    
    func disconnectFromCurrentLock(completion:(() -> ())?) {
        guard let lock = self.getCurrentLock() else {
            print("Error: could not disconnect from current lock. No current lock in database")
            return
        }
        
        lock.isCurrentLock = false
        lock.isConnecting = false
        lock.hasConnected = true
        self.dbManager.saveLock(lock)
        
        self.afterUserDisconnectLockClosure = completion
        
        self.bleManager.disconnectFromPeripheralWithKey(lock.macAddress!)
    }
    
    func deleteAllNeverConnectedAndNotConnectingLocks() {
        guard let locks:[SLLock] = self.dbManager.allLocks() as? [SLLock] else {
            return
        }
        
        print("there are \(locks.count) locks")
        for lock in locks {
            if lock.isConnecting!.boolValue {
                // If the lock is currently conneting let's continue on our search.
                // This check is here primarily for clarity.
                continue
            } else if self.bleManager.hasConnectedPeripheralWithKey(lock.macAddress!) {
                // The lock is the currently connected lock. Let's continue our search
                continue
            } else if lock.hasConnected!.boolValue && !lock.isConnecting!.boolValue {
                // This is the case where the lock has previously connected but is
                // not currently connecting. We'll try to remove it from the 
                // bluetooth managers not connected peripherals in case it has 
                // been detected there.
                self.bleManager.removeNotConnectPeripheralForKey(lock.macAddress!)
            } else if !lock.hasConnected!.boolValue && !lock.isConnecting!.boolValue {
                // In this case, the lock was deteted durring a scan, but was never 
                // connected. We can get rid of these locks from the blue tooth manager
                // and the database.
                self.bleManager.removeNotConnectPeripheralForKey(lock.macAddress!)
                self.dbManager.deleteLock(lock, withCompletion: nil)
            } else {
                print(
                    "No cases were hit for lock: \(lock.displayName()) "
                    + "durring deletion of never connected and not connecting locks"
                )
            }
        }
    }
    
    func readFirmwareDataForCurrentLock() {
        guard let macAddress = self.getCurrentLock()?.macAddress else {
            print("Error: could not read firmware. No current lock in database.")
            return
        }
        
        self.readFromLockWithMacAddress(macAddress, service: .Configuration, characteristic: .FirmwareVersion)
    }
    
    func readSerialNumberForCurrentLock() {
        guard let macAddress = self.getCurrentLock()?.macAddress else {
            print("Error: could not read serial number. No current lock in database.")
            return
        }
        
        self.readFromLockWithMacAddress(macAddress, service: .Configuration, characteristic: .SerialNumber)
    }
    
    func checkCurrentLockOpenOrClosed() {
        guard let lock = self.getCurrentLock() else {
            print("Error: could not check if lock is open or closed. No current lock in database.")
            return
        }
        
        self.readFromLockWithMacAddress(lock.macAddress!, service: .Hardware, characteristic: .Lock)
    }
    
    func toggleLockOpenedClosedShouldLock(shouldLock: Bool) {
        guard let lock = self.getCurrentLock() else {
            print("Error: could not open or close lock. No current lock in databse for user.")
            return
        }
        
        var value:UInt8 = shouldLock ? 0x01 : 0x00
        let data = NSData(bytes: &value, length: sizeofValue(value))
        self.writeToLockWithMacAddress(lock.macAddress!, service: .Hardware, characteristic: .Lock, data: data)
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
    
    func allLocksForCurrentUser() -> [SLLock] {
        guard let locks:[SLLock] = self.dbManager.locksForCurrentUser() as? [SLLock] else {
            return [SLLock]()
        }
        
        return locks
    }
    
    func locksInActiveSearch() -> [SLLock] {
        guard let locks:[SLLock] = self.dbManager.allLocks() as? [SLLock] else {
            return [SLLock]()
        }
        
        guard let user = self.dbManager.currentUser else {
            return [SLLock]()
        }
        
        var activeLocks:[SLLock] = [SLLock]()
        for lock:SLLock in locks where self.bleManager.hasNonConnectedPeripheralWithKey(lock.macAddress) {
            if let lockUser = lock.user {
                if lockUser.userId! == user.userId! {
                    activeLocks.append(lock)
                }
            } else {
                activeLocks.append(lock)
            }
        }
        
        return activeLocks
    }
    
    func availableUnconnectedLocks() -> [SLLock] {()
        var availableLocks = [SLLock]()
        guard let locks = self.dbManager.locksForCurrentUser() as? [SLLock] else {
            return availableLocks
        }
        
        guard let user = self.dbManager.getCurrentLockForCurrentUser() else {
            return availableLocks
        }
        
        for lock in locks {
            if !self.bleManager.hasConnectedPeripheralWithKey(lock.macAddress!) && lock.user == user {
                availableLocks.append(lock)
            }
        }
        
        return availableLocks
    }
    
    func writeTouchPadButtonPushes(touches: [UInt8]) {
        guard let lock = self.getCurrentLock() else {
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
        guard let lock = self.getCurrentLock() else {
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
        guard let lock = self.dbManager.getLockWithMacAddress(macAddress) else {
            print("Error: could not delete lock: \(macAddress). No lock in database with that address")
            return
        }
        
        self.deleteLockFromServerWithMacAddress(macAddress) { (success) in
            if success {
                if self.bleManager.hasConnectedPeripheralWithKey(macAddress) {
                    lock.isSetForDeletion = true
                    self.dbManager.saveLock(lock)
                    
                    var value:UInt8 = 0xBC
                    let data = NSData(bytes: &value, length: sizeofValue(value))
                    
                    self.startBleScan()
                    
                    self.writeToLockWithMacAddress(
                        macAddress,
                        service: .Configuration,
                        characteristic: .ResetLock,
                        data: data
                    )
                } else {
                    self.dbManager.deleteLock(lock, withCompletion: nil)
                    self.bleManager.removePeripheralForKey(macAddress)
                    self.bleManager.removeNotConnectPeripheralForKey(macAddress)
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(
                        kSLNotificationLockManagerDeletedLock,
                        object: macAddress
                    )
                }
            } else {
                // TODO: send notificaiton that the deletion was not successful
            }
        }
    }
    
    func factoryResetCurrentLock() {
        guard let macAddress = self.getCurrentLock()?.macAddress else {
            print("Error: could not reset current lock. No current lock in databsase")
            return
        }
        
        var value:UInt8 = 0xBB
        let data = NSData(bytes: &value, length: sizeofValue(value))
        
        self.stopGettingHardwareInfo()
        
        self.writeToLockWithMacAddress(
            macAddress,
            service: .Configuration,
            characteristic: .ResetLock,
            data: data
        )
    }
    
    func updateFirmwareForCurrentLock() {
        self.getFirmwareFromServer { (success) in
            if success {
                guard let lock = self.getCurrentLock() else {
                    print("Error: could not update firmware for current lock. No current lock in databsase")
                    return
                }
                
                self.currentState = .UpdateFirmware
                
                lock.isInBootMode = true
                self.dbManager.saveLock(lock)
                
                self.factoryResetCurrentLock()
                self.startBleScan()
            } else {
                // TODO: Should handle this failure in UI
                print("Error: failed to retrieve firmware from server")
            }
        }
    }
    
    func isBlePoweredOn() -> Bool {
        return self.bleManager.isPowerOn()
    }
    
    func isInActiveSearch() -> Bool {
        return self.currentState == .ActiveSearch
    }
    
    func startActiveSearch() {
        self.currentState = .ActiveSearch
        self.startBleScan()
    }
    
    func endActiveSearch() {
        self.currentState = .FindCurrentLock
        self.bleManager.stopScan()
        let locks = self.locksInActiveSearch()
        for lock in locks where !lock.isConnecting!.boolValue {
            self.bleManager.removeNotConnectPeripheralForKey(lock.macAddress!)
        }
    }
    
    func connectToLockWithMacAddress(macAddress: String) {
        print("Attempting to connect to lock with address: \(macAddress)")
        guard let lock = self.dbManager.getLockWithMacAddress(macAddress) else {
            print("Error: Could not connect to lock \(macAddress). It is not in database.")
            return
        }
        
        self.securityPhase = lock.isInFactoryMode() ? .PublicKey : .SignedMessage
        
        if self.getCurrentLock() == nil {
            // There is no current lock. Let's just connect the lock that
            // the user has asked to connect.
            self.connectToLockWithMacAddressHelper(macAddress)
            self.endActiveSearch()
            self.deleteAllNeverConnectedAndNotConnectingLocks()
        } else {
            // If there is a current lock, we'll need to disconnect from it before
            // connecting the new lock.
            self.afterDisconnectLockClosure = { [unowned self] in
                self.connectToLockWithMacAddressHelper(macAddress)
            }
            self.disconnectFromCurrentLock(nil)
        }
        
        self.currentState = .FindCurrentLock
    }
    
    func deleteLockWithMacAddress(macAddress: String) {
        guard let lock = self.dbManager.getLockWithMacAddress(macAddress) else {
            print("Error: No matching lock with mac address \(macAddress) to delete")
            return
        }
        
        if self.bleManager.hasConnectedPeripheralWithKey(lock.macAddress!) {
            // Lock is the current connected lock
            lock.isSetForDeletion = true
            self.dbManager.saveLock(lock)
            self.bleManager.removePeripheralForKey(macAddress)
            return
        }
        
        // Lock is not current lock. Let's check to see if the user has connected to the lock
        guard let locks = self.dbManager.locksForCurrentUser() as? [SLLock] else {
            print("Error: no locks for user matches mac address: \(macAddress)")
            return
        }
        
        for dbLock in locks {
            if dbLock.macAddress == macAddress {
                self.dbManager.deleteLock(dbLock, withCompletion: { (success: Bool) in
                    if success {
                        NSNotificationCenter.defaultCenter().postNotificationName(
                            kSLNotificationLockManagerDeletedLock,
                            object: macAddress
                        )
                    } else {
                        // TODO: handle case where the lock deletion is a failure.
                        print("Error: could not delete lock with mac address: \(macAddress). Something went wrong")
                    }
                })
                break
            }
        }
        
        // TODO: handle case where the lock deletion is a failure.
        print(
            "Error: could not delete lock with mac address: \(macAddress). "
                + "There is no matching lock in the database."
        )
    }
    
    func flashLEDsForCurrentLock() {
        guard let macAddress = self.getCurrentLock()?.macAddress else {
            print("Error: could not flash LEDs for current user. No current lock in database.")
            return
        }
        
        self.flashLEDsForLockMacAddress(macAddress)
    }
    
    func removeAllUnconnectedLocks() {
        guard let locks = self.dbManager.allLocks() as? [SLLock] else {
            print("Error: could not retrieve current locks for user.")
            return
        }
        
        
        for lock in locks where !self.bleManager.hasConnectedPeripheralWithKey(lock.macAddress) {
            self.bleManager.removeNotConnectPeripheralForKey(lock.macAddress)
        }
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
            self.serviceUUID(.Security),
            self.serviceUUID(.Boot)
        ]
    }
    
    private func characteristicsToRead() -> [String] {
        var charsToRead = [String]()
        for uuid in BLECharacteristic.allValues {
            charsToRead.append(self.characteristicUUID(uuid))
        }
        
        return charsToRead
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
    
    private func startBleScan() {
        if self.bleManager.delegate == nil {
            self.bleManager.delegate = self
        }
        
        self.bleManager.startScan()
    }
    
    // MARK: Private methods and private helper methods
    private func connectToLockWithMacAddressHelper(macAddress: String) {
        print("Attempting to connect to lock with address: \(macAddress). Lock manager state: \(self.currentState)")
        
        guard let lock = self.dbManager.getLockWithMacAddress(macAddress) else {
            print("Error: connecting to lock with mac address \(macAddress). No lock with that address in db")
            return
        }
        
        if self.currentState == .UpdateFirmware {
            print("In update firmware mode. Will attept to connect to lock with address: \(macAddress)")
            lock.isConnecting = true;
            self.dbManager.saveLock(lock)
            self.bleManager.connectToPeripheralWithKey(macAddress)
            return
        }
        
        guard let user = self.dbManager.currentUser else {
            print("Error: connecting to lock with mac address \(macAddress). No current user in database")
            return
        }
        
        self.currentState = .Connecting
        
        print("Attempting to connect to lock: \(lock.description)")
        
        let signedMessage = self.keychainHandler.getItemForUsername(
            user.userId!,
            additionalSeviceInfo: macAddress,
            handlerCase: .SignedMessage
        )
        
        let publicKey = self.keychainHandler.getItemForUsername(
            user.userId!,
            additionalSeviceInfo: macAddress,
            handlerCase: .PublicKey
        )
        
        lock.isConnecting = true
        self.dbManager.saveLock(lock)
        
        if  !lock.hasConnected!.boolValue || signedMessage == nil || publicKey == nil {
            self.getSignedMessageAndPublicKeyFromServerForMacAddress(macAddress, completion: { (success: Bool) in
                if success {
                    if self.bleManager.notConnectedPeripheralForKey(macAddress) == nil {
                        print(
                            "Error: connecting lock. No not connected peripheral " +
                                "in ble manager with key: \(macAddress)."
                        )
                        return
                    }
                    
                    self.securityPhase = lock.isInFactoryMode() ? .PublicKey : .SignedMessage
                    self.bleManager.connectToPeripheralWithKey(macAddress)
                } else {
                    // TODO: Handle failure
                }
            })
        } else {
            self.bleManager.connectToPeripheralWithKey(macAddress)
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(
            kSLNotificationLockManagerStartedConnectingLock,
            object: nil
        )
    }
    
    private func getSignedMessageAndPublicKeyFromServerForMacAddress(
        macAddress: String,
        completion: ((success: Bool) -> ())?
        )
    {
        guard let user = self.dbManager.currentUser else {
            print("Error: could not get singed message and public key. No user in database")
            return
        }
        
        guard let restToken = self.keychainHandler.getItemForUsername(
            user.userId!,
            additionalSeviceInfo: nil,
            handlerCase: .RestToken
            ) else
        {
            print("Error: could not get singed message and public key. No rest token for user: \(user.fullName()).")
            let info = [
                "lock": self.dbManager.getLockWithMacAddress(macAddress),
                "code": NSNumber(unsignedInteger: SLLockManagerConnectionError.NotAuthorized.rawValue)
            ]
            NSNotificationCenter.defaultCenter().postNotificationName(
                kSLNotificationLockManagerErrorConnectingLock,
                object: info
            )
            return
        }

        let restManager = SLRestManager.sharedManager() as SLRestManager
        let authValue = restManager.basicAuthorizationHeaderValueUsername(restToken, password: "")
        
        restManager.postObject(
            ["mac_id": macAddress],
            serverKey: .Main,
            pathKey: .Keys,
            subRoutes: [user.userId!, "keys"],
            additionalHeaders: ["Authorization": authValue]
        ) { (status:UInt, response:[NSObject : AnyObject]!) in
            // TODO: Check what the status is if there is an error and present the correct UI.
            guard let signedMessage = response?["signed_message"] as? String else {
                print("Error: no signed message in response from server.")
                let info = [
                    "lock": self.dbManager.getLockWithMacAddress(macAddress),
                    "code": NSNumber(unsignedInteger: SLLockManagerConnectionError.NotAuthorized.rawValue)
                ]
                NSNotificationCenter.defaultCenter().postNotificationName(
                    kSLNotificationLockManagerErrorConnectingLock,
                    object: info
                )
                return
            }
            
            guard let publicKey = response?["public_key"] as? String else {
                print("Error: no public key in response from server.")
                let info = [
                    "lock": self.dbManager.getLockWithMacAddress(macAddress),
                    "code": NSNumber(unsignedInteger: SLLockManagerConnectionError.NotAuthorized.rawValue)
                ]
                NSNotificationCenter.defaultCenter().postNotificationName(
                    kSLNotificationLockManagerErrorConnectingLock,
                    object: info
                )
                return
            }
            
            self.keychainHandler.setItemForUsername(
                user.userId!,
                inputValue: signedMessage,
                additionalSeviceInfo: macAddress,
                handlerCase: .SignedMessage
            )
            
            self.keychainHandler.setItemForUsername(
                user.userId!,
                inputValue: publicKey,
                additionalSeviceInfo: macAddress,
                handlerCase: .PublicKey
            )
            
            if completion != nil {
                completion!(success: true)
            }
        }
    }
    
    private func flashLEDsForLockMacAddress(macAddress: String) {
        var value:UInt8 = 0x4F
        let data = NSData(bytes: &value, length: sizeofValue(value))
        self.writeToLockWithMacAddress(
            macAddress,
            service: .Hardware,
            characteristic: .LED,
            data: data
        )
        
        NSTimer.scheduledTimerWithTimeInterval(
            2.5,
            target: self,
            selector: #selector(turnLEDsOff(_:)),
            userInfo: ["macAddress": macAddress],
            repeats: false
        )
    }
    
    @objc private func turnLEDsOff(timer: NSTimer) {
        guard let macAddress = timer.userInfo?["macAddress"] as? String else {
            print("Error: can't turn of LEDs. Timer has no user info or no macAddress entry")
            timer.invalidate()
            return
        }
        
        var value:UInt8 = 0x00
        let data = NSData(bytes: &value, length: sizeofValue(value))
        self.writeToLockWithMacAddress(
            macAddress,
            service: .Hardware,
            characteristic: .LED,
            data: data
        )
    }
    
    private func stopGettingHardwareInfo() {
        self.hardwareTimer?.invalidate()
        self.hardwareTimer = nil
    }
    
    private func startGettingHardwareInfo() {
        self.hardwareTimer = NSTimer.scheduledTimerWithTimeInterval(
            2.0,
            target: self,
            selector: #selector(getHardwareInfo(_:)),
            userInfo: nil,
            repeats: true
        )
    }
    
    @objc private func getHardwareInfo(timer: NSTimer) {
        print("Hardware timer is firing.")
        guard let macAddress = self.getCurrentLock()?.macAddress else {
            print("Error: getting hardware data. No current lock or no mac address for current lock")
            return
        }
        
        self.readFromLockWithMacAddress(macAddress, service: .Hardware, characteristic: .HardwareInfo)
    }
    
    private func getFirmwareFromServer(completion: ((success: Bool) -> ())?) {
        let restManager:SLRestManager = SLRestManager.sharedManager() as SLRestManager
        restManager.getRequestWithServerKey(
            .Main,
            pathKey: .FirmwareUpdate,
            subRoutes: nil,
            additionalHeaders: nil
        ) { (status: UInt, response: [NSObject : AnyObject]!) in
            if status != 200 {
                if let completionClosure = completion {
                    completionClosure(success: false)
                }
            }
            // The firmware should be in the format of an array of dictionaries with
            // entries of ["boot_loader": "8373739393003fme"] for example.
            // TODO: This should be changed so the server sends the payload as an array
            // of string values.
            guard let firmware = response?["firmware"] as? [[String:AnyObject]] else {
                print("Error getting firmware from server payload.")
                if let completionClosure = completion {
                    completionClosure(success: false)
                }
                
                return
            }
            
            self.firmware = [String]()
            self.maxFirmwareLines = firmware.count
            // Doing this in reverse order so on writing to the lock
            // we can just pop the last value off the firmware array.
            // This is an 0(1) vs 0(n) which would be the runtime each
            // time we got an item from the front of the array.
            for firmwareDictionary in firmware.reverse() {
                if let entry = firmwareDictionary["boot_loader"] as? String {
                    self.firmware?.append(entry)
                }
            }
            
            if let completionClosure = completion {
                completionClosure(success: true)
            }
        }
    }
    
    private func deleteLockFromServerWithMacAddress(macAddress: String, completion: ((success: Bool) -> ())?) {
        guard let user = self.dbManager.currentUser else {
            print("Error: could not delete lock from server. No current user in database")
            if completion != nil {
                completion!(success: false)
            }
            return
        }
        
        guard let restToken = self.keychainHandler.getItemForUsername(
            user.userId!,
            additionalSeviceInfo: nil,
            handlerCase: .RestToken
            ) else
        {
            print("Error: keychain handler does not have a rest token for user \(user.fullName()).")
            if completion != nil {
                completion!(success: false)
            }
            return
        }
        
        let restManager = SLRestManager.sharedManager() as SLRestManager
        let authValue = restManager.basicAuthorizationHeaderValueUsername(restToken, password: "")
        let additionalHeaders = ["Authorization": authValue]
        let subRoutes = [user.userId!, "deletelock"]
        
        restManager.postObject(
        ["mac_id": macAddress],
        serverKey: .Main,
        pathKey: .Users,
        subRoutes: subRoutes,
        additionalHeaders: additionalHeaders
        ) { (status: UInt, response:[NSObject : AnyObject]!) in
            if completion != nil {
                completion!(success: status == 201)
            }
        }
    }
    
    private func writeFirmwareForLockWithMacAddress(macAddress: String) {
        if self.firmware == nil {
            print("Error: cannot write firmware. The firmware array in nil")
            return
        }
        
        print("Writing firmware for lock: \(macAddress). There are \(self.firmware!.count) items left to write.")
        if let maxLines = self.maxFirmwareLines {
            let percentageComplete:Double = 1.0 - Double(self.firmware!.count)/Double(maxLines)
            NSNotificationCenter.defaultCenter().postNotificationName(
                kSLNotificationLockManagerFirmwareUpdateState,
                object: NSNumber(double: percentageComplete)
            )
        }
        
        if self.firmware!.isEmpty {
            var value:UInt8 = 0x00
            let data = NSData(bytes: &value, length: sizeofValue(value))
            self.writeToLockWithMacAddress(macAddress, service: .Boot, characteristic: .FirmwareUpdateDone, data: data)
            return
        }
        
        if let data = self.firmware!.popLast()?.bytesString() {
            self.writeToLockWithMacAddress(macAddress, service: .Boot, characteristic: .WriteFirmware, data: data)
        }
    }
    
    private func setTxPowerForLockWithMacAddress(macAddress: String) {
        var value:UInt8 = 0x04
        let data = NSData(bytes: &value, length: sizeofValue(value))
        self.writeToLockWithMacAddress(macAddress, service: .Hardware, characteristic: .TxPower, data: data)
    }
    
    // MARK: Update handlers
    private func handleCommandStatusUpdateForLockMacAddress(macAddress: String, data: NSData) {
        guard let lock = self.dbManager.getLockWithMacAddress(macAddress) else {
            print(
                "Error: Could not handle command status update for lock with mac address: \(macAddress). " +
                "No lock found in database with matching mac address"
            )
            return
        }

        let bytes:[UInt8] = Array(UnsafeBufferPointer(start: UnsafePointer<UInt8>(data.bytes), count: data.length))
        guard let value:UInt8 = bytes.first else {
            print("Error reading security state data. The updated data has zero bytes")
            return
        }
        
        print("Command status updated with value: \(value)")
        
        if value == 0 {
            // This is the case for a successful write to most characteristics. All possible
            // characteristic writes should be handled here.
            if self.securityPhase == .PublicKey {
                // Public Key has been written succesfully
                self.securityPhase = .ChallengeKey
                self.handleChallengeKeyConnectionPhaseForMacAddress(macAddress)
            } else if self.securityPhase == .ChallengeKey {
                // Challege key has been written succesfully
                self.securityPhase = .SignedMessage
                self.handleSignedMessageConnectionPhaseForMacAddress(macAddress)
            } else if securityPhase == .Connected {
                // The security between the lock and the phone has been established.
                // We can get hardware updates to this section of code. For example, 
                // the lock/unlock state in the command status will be updated here.
                print("Lock has been open/closed successfully")
            }
        } else if value == 1 {
            // TODO: Handle this case for/when sharing is implemented
            // Wrote signed message successfully. Security state is guest request
            print("Wrote signed message successfully. Security state is guest request")
        } else if value == 2 {
            // Wrote signed message successfully. Security state is owner request
            // We now need to get the challege data from the lock.
            self.readFromLockWithMacAddress(macAddress, service: .Security, characteristic: .ChallengeData)
        } else if value == 3 {
            //                                                                                                                                                                                                                                                                                                                                                          data written successfully. Now guest verified
            // TODO: This should be update when sharing is implemented
            print("Challege data written successfully. Now guest verified")
        } else if value == 4 {
            // Challege data written successfully. Now owner verified. The owner is now
            // "paired" to the lock.
            guard let user = self.dbManager.currentUser else {
                print(
                    "Error: Could not handle command status update for lock with mac address: \(macAddress). " +
                    "No user found in database"
                )
                return
            }
            
            if lock.isInFactoryMode() {
                lock.switchLockNameToProvisioned()
            }
            
            lock.isCurrentLock = true
            lock.hasConnected = true
            lock.isConnecting = false
            lock.user = user
            self.dbManager.saveLock(lock)
            
            self.securityPhase = .Connected
            self.bleManager.stopScan()
            self.bleManager.removeNotConnectPeripherals()
            
            self.flashLEDsForLockMacAddress(macAddress)
            self.startGettingHardwareInfo()
            self.setTxPowerForLockWithMacAddress(macAddress)
            self.removeAllUnconnectedLocks()
            
            // TODO: Set TxPower here
            NSNotificationCenter.defaultCenter().postNotificationName(
                kSLNotificationLockPaired,
                object: lock
            )
        } else if value == 129 {
            // If the value is 129, it signals that "Access denied because of invalid security state."
            // If there is no signed message, or public key this could occur. To fix this we can
            // refetch the keys from the server and try writing this again.
            print("Error: command status got invalid security state error.")
            let info = [
                "lock": lock,
                "code": NSNumber(unsignedInteger: SLLockManagerConnectionError.NotAuthorized.rawValue)
            ]
            
            NSNotificationCenter.defaultCenter().postNotificationName(
                kSLNotificationLockManagerErrorConnectingLock,
                object: info
            )
        } else if value == 130 {
            // If there is a lock/unlock error, the error is being sent to the sercurity service.
            // Although this is not very good encapsulation (the lock/unlock characteristic is
            // under the hardware characteristic), this is the way it was setup in the firmware.
            // As a result, it is necassary to deal with it here.
            // TODO: handle this error in UI
            print("Error: command status updated that the lock did not open/close correctly")
        }
    }
    
    private func handleHardwareServiceForMacAddress(macAddress: String, data: NSData) {
        if data.length != 13 {
            print("Error: handling hardware service. Data is wrong number of bytes: \(data.length). Should be 13")
            return
        }
        
        guard let lock = self.dbManager.getLockWithMacAddress(macAddress) else {
            print("Error: handling hardware service. No lock in database with address: \(macAddress)")
            return
        }
        
        let values:[Int8] = Array(UnsafeBufferPointer(start: UnsafePointer<Int8>(data.bytes), count: data.length))
        
        var batteryVoltage:Int16 = Int16(values[0])
        batteryVoltage += Int16(Int32(values[1]) << CHAR_BIT)

        lock.batteryVoltage = NSNumber(short: batteryVoltage)
        lock.temperature = NSNumber(char: values[2])
        lock.rssiStrength = NSNumber(char: values[3])
        
        self.dbManager.saveLock(lock)
    
        NSNotificationCenter.defaultCenter().postNotificationName(
            kSLNotificationLockManagerUpdatedHardwareValues,
            object: lock.macAddress!
        )
        
        // TODO: move this somewhere more appropriate. I'm just hacking it in here for now
        guard let user = self.dbManager.currentUser else {
            print("Error no current user. Could not check auto lock/unlock")
            return
        }
        
        print("Lock rssi: \(lock.rssiStrength)")
        var value:UInt8?
        if lock.isLocked!.boolValue && user.isAutoUnlockOn!.boolValue && lock.rssiStrength.floatValue >= -65.0 {
            value = 0x00
        } else if !lock.isLocked!.boolValue && user.isAutoLockOn!.boolValue && lock.rssiStrength.floatValue <= -70.0 {
            value = 0x01
        }
        
        if var lockValue = value {
            let lockData = NSData(bytes: &lockValue, length: sizeofValue(lockValue))
            self.writeToLockWithMacAddress(macAddress, service: .Hardware, characteristic: .Lock, data: lockData)
        }
    }
    
    private func handleLockStateForLockMacAddress(macAddress: String, data: NSData) {
        let values:[UInt8] = Array(UnsafeBufferPointer(start: UnsafePointer<UInt8>(data.bytes), count: data.length))
        guard let value = values.first else {
            print("Error: in handling lock state. Data returned is empty")
            return
        }
        
        guard let position:SLLockPosition = SLLockPosition(rawValue: UInt(value)) else {
            print("Error: in handling lock state. The value does not match a case in SLLockManagerLockPosition enum")
            return
        }
        
        guard let lock = self.dbManager.getLockWithMacAddress(macAddress) else {
            print("Error: could not update lock state. No lock with mac address: \(macAddress) in database")
            return
        }
        
        
        let notification:String
        var isLocked = false
        switch position {
        case .Invalid:
            notification = kSLNotificationLockPositionInvalid
        case .Locked:
            notification = kSLNotificationLockPositionLocked
            isLocked = true
        // TODO: the middle case should be handled on its own.
        case .Unlocked, .Middle:
            notification = kSLNotificationLockPositionOpen
        }
        
        lock.isLocked = NSNumber(bool: isLocked)
        lock.lockPosition = NSNumber(unsignedInteger: position.rawValue)
        self.dbManager.saveLock(lock)
        
        NSNotificationCenter.defaultCenter().postNotificationName(notification, object: lock)
    }
    
    private func handleAccelerometerForLockMacAddress(macAddress: String, data: NSData) {
        
        var xmav:UInt16 = 0
        var ymav:UInt16 = 0
        var zmav:UInt16 = 0
        var xvar:UInt16 = 0
        var yvar:UInt16 = 0
        var zvar:UInt16 = 0
        
        let values:[UInt8] = Array(UnsafeBufferPointer(start: UnsafePointer<UInt8>(data.bytes), count: data.length))
        for i in 0..<values.count {
            switch i {
            case 0, 1:
                xmav += UInt16(values[i]) << UInt16(Int32((i % 2))*CHAR_BIT)
            case 2, 3:
                ymav += UInt16(values[i]) << UInt16(Int32((i % 2))*CHAR_BIT)
            case 4, 5:
                zmav += UInt16(values[i]) << UInt16(Int32((i % 2))*CHAR_BIT)
            case 6, 7:
                xvar += UInt16(values[i]) << UInt16(Int32((i % 2))*CHAR_BIT)
            case 8, 9:
                yvar += UInt16(values[i]) << UInt16(Int32((i % 2))*CHAR_BIT)
            case 10, 11:
                zvar += UInt16(values[i]) << UInt16(Int32((i % 2))*CHAR_BIT)
            default:
                continue
            }
        }
        
        let accelerometerValues:[NSNumber: NSNumber] = [
            NSNumber(unsignedInteger: SLAccelerometerData.XMav.rawValue): NSNumber(unsignedShort: xmav),
            NSNumber(unsignedInteger: SLAccelerometerData.YMav.rawValue): NSNumber(unsignedShort: ymav),
            NSNumber(unsignedInteger: SLAccelerometerData.ZMav.rawValue): NSNumber(unsignedShort: zmav),
            NSNumber(unsignedInteger: SLAccelerometerData.XVar.rawValue): NSNumber(unsignedShort: xvar),
            NSNumber(unsignedInteger: SLAccelerometerData.YVar.rawValue): NSNumber(unsignedShort: yvar),
            NSNumber(unsignedInteger: SLAccelerometerData.ZVar.rawValue): NSNumber(unsignedShort: zvar)
        ]
        
        var lockValue:SLLockValue
        if let value = self.lockValues[macAddress] {
            lockValue = value
        } else {
            lockValue = SLLockValue(maxCount: 3, andMacAddress: macAddress)
            lockValue.delegate = self
            self.lockValues[macAddress] = lockValue
        }
        
        lockValue.updateValuesWithValues(accelerometerValues)
    }
    
    private func handleChallengeDataForLockMacAddress(macAddress: String, data: NSData) {
        if data.length != 32 {
            print("Error: challenge data from lock is not 32 bytes")
            NSNotificationCenter.defaultCenter().postNotificationName(
                kSLNotificationLockManagerErrorConnectingLock,
                object: nil
            )
            return
        }
        
        guard let user = self.dbManager.currentUser else {
            print(
                "Error: could not write challege data for lock with address: \(macAddress). "
                    + "Could not retrieve user from the database"
            )
            NSNotificationCenter.defaultCenter().postNotificationName(
                kSLNotificationLockManagerErrorConnectingLock,
                object: nil
            )
            return
        }
        
        guard let challengeKey = self.keychainHandler.getItemForUsername(
            user.userId!,
            additionalSeviceInfo: macAddress,
            handlerCase: .ChallengeKey
            ) else
        {
            print(
                "Error: could not write challege data for lock with address: \(macAddress). "
                + "Could not retrieve challege key from the keychain"
            )
            NSNotificationCenter.defaultCenter().postNotificationName(
                kSLNotificationLockManagerErrorConnectingLock,
                object: nil
            )
            return
        }
        
        var challengeString:String = ""
        let values:[UInt8] = Array(UnsafeBufferPointer(start: UnsafePointer<UInt8>(data.bytes), count: data.length))
        for value in values {
            var byteString = String(value, radix: 16, uppercase: false)
            if byteString.characters.count == 1 {
                byteString = "0" + byteString
            }
            
            challengeString += byteString
        }
        
        print("challenge string: " + challengeString)
        let challegeDataString = challengeKey + challengeString
        print("challenge string length: \(challegeDataString.characters.count)")
        guard let unhashedChallegeData = (challegeDataString).bytesString() else {
            print(
                "Error: could not write challege data for lock with address: \(macAddress). "
                    + "Could not convert challenge string to data."
            )
            return
        }
        
        let cryptoHandler = SLCryptoHandler()
        let challengeData = cryptoHandler.SHA256WithData(unhashedChallegeData)
        print("challenge data is \(challengeData.length) bytes long")
        self.writeToLockWithMacAddress(
            macAddress,
            service: .Security,
            characteristic: .ChallengeData,
            data: challengeData
        )
    }
    
    private func handleLEDStateForLockMacAddress(macAddress: String, data: NSData) {
        print("Handling LED state update. This is currently not being used")
    }
    
    private func handleLockSequenceWriteForMacAddress(macAddress: String, data: NSData) {
        NSNotificationCenter.defaultCenter().postNotificationName(kSLNotificationLockSequenceWritten, object: nil)
    }
    
    private func handleReadFirmwareVersionForMacAddress(macAddress: String, data: NSData) {
        let values:[UInt8] = Array(UnsafeBufferPointer(start: UnsafePointer<UInt8>(data.bytes), count: data.length))
        var numbers = [NSNumber]()
        for value in values {
            numbers.append(NSNumber(unsignedChar: value))
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(
            kSLNotificationLockManagerReadFirmwareVersion,
            object: numbers
        )
    }
    
    private func handleReadSerialNumberForMacAddress(macAddress: String, data: NSData) {
        let values:[UInt8] = Array(UnsafeBufferPointer(start: UnsafePointer<UInt8>(data.bytes), count: data.length))
        var serialNumber = ""
        for value in values {
            let digit = String(Character(UnicodeScalar(value)))
            if digit != "\0" {
                serialNumber += digit
            }
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(
            kSLNotificationLockManagerReadSerialNumber,
            object: serialNumber
        )
    }
    
    // MARK: Notification handlers
    private func handlePublicKeyConnectionPhaseForMacAddress(macAddress: String) {
        guard let user = self.dbManager.currentUser else {
            print("Error: could not enter public key connection phase. No user.")
            let info = [
                "lock": self.dbManager.getLockWithMacAddress(macAddress),
                "code": NSNumber(unsignedInteger: SLLockManagerConnectionError.NotAuthorized.rawValue)
            ]
            NSNotificationCenter.defaultCenter().postNotificationName(
                kSLNotificationLockManagerErrorConnectingLock,
                object: info
            )
            return
        }
        
        guard let publicKey = self.keychainHandler.getItemForUsername(
            user.userId!,
            additionalSeviceInfo: macAddress,
            handlerCase: .PublicKey
            ) else
        {
            print("Error: could not enter public key connection phase. No user public key in keychain.")
            return
        }
        
        guard let data = publicKey.bytesString() else {
            print("Error: could not enter public key connection phase. Could not converte public key to bytes.")
            return
        }
        
        self.writeToLockWithMacAddress(
            macAddress,
            service: .Security,
            characteristic: .PublicKey,
            data: data
        )
    }
    
    private func handleChallengeKeyConnectionPhaseForMacAddress(macAddress: String) {
        guard let user = self.dbManager.currentUser else {
            print("Error: could not enter challenge key connection phase. No user.")
            return
        }
        
        guard let restToken = self.keychainHandler.getItemForUsername(
            user.userId!,
            additionalSeviceInfo: nil,
            handlerCase: .RestToken
            ) else
        {
            print("Error: keychain handler does not have a rest token for user \(user.fullName()).")
            return
        }
        
        let restManager = SLRestManager.sharedManager() as SLRestManager
        let authValue = restManager.basicAuthorizationHeaderValueUsername(restToken, password: "")
        let additionalHeaders = ["Authorization": authValue]
        let subRoutes = [user.userId!, "challenge_key"]
        
        restManager.getRequestWithServerKey(
            .Main,
            pathKey: .ChallengeKey,
            subRoutes: subRoutes,
            additionalHeaders: additionalHeaders
        ) { (status:UInt, response:[NSObject:AnyObject]!) in
            // TODO: check what the status should be here and take the necassary actions.
            guard let challengeKey = response?["challenge_key"] as? String else {
                // TODO: handle this error
                print("Error while getting challenge key. No challege key returned by server.")
                return
            }
            
            guard let challengeKeyData = challengeKey.bytesString() else {
                print("Error: Could not convert challege key to data")
                return
            }
            
            self.keychainHandler.setItemForUsername(
                user.userId!,
                inputValue: challengeKey,
                additionalSeviceInfo: macAddress,
                handlerCase: .ChallengeKey
            )
            
            self.writeToLockWithMacAddress(
                macAddress,
                service: .Security,
                characteristic: .ChallengeKey,
                data: challengeKeyData
            )
        }
    }
    
    private func handleSignedMessageConnectionPhaseForMacAddress(macAddress: String) {
        guard let user = self.dbManager.currentUser else {
            print("Error: could not enter signed message connection phase. No user.")
            return
        }
        
        guard let signedMessage = self.keychainHandler.getItemForUsername(
            user.userId!,
            additionalSeviceInfo: macAddress,
            handlerCase: .SignedMessage
            ) else
        {
            print("Error: No signed message in keychain for \(user.fullName())")
            return
        }
        
        guard let data = signedMessage.bytesString() else {
            print("Error: could not converted signed messsage to bytes")
            return
        }
        
        self.writeToLockWithMacAddress(macAddress, service: .Security, characteristic: .SignedMessage, data: data)
    }
    
    func handleFirmwareUpdateCompletion(macAddress: String, success: Bool) {
        guard let lock = self.dbManager.getLockWithMacAddress(macAddress) else {
            print("Error: could not handle firmware completion. No lock with address: \(macAddress) in database")
            return
        }
        
        lock.isInBootMode = false
        self.dbManager.saveLock(lock)
        
        self.currentState = .FindCurrentLock
        self.startBleScan()
        
        NSNotificationCenter.defaultCenter().postNotificationName(
            kSLNotificationLockManagerEndedFirmwareUpdate,
            object: macAddress
        )
    }
    
    // MARK: Write handlers
    private func handleLockResetForMacAddress(macAddress: String, success: Bool) {
        if success {
            print("Successfully wrote reset value to lock with address: \(macAddress)")
        } else {
            print("Error: could not reset lock with mac address: \(macAddress). Write failed")
        }
    }
    
    // MARK: SEBLEInterfaceManager Delegate methods
    func bleInterfaceManagerIsPoweredOn(interfaceManager: SEBLEInterfaceMangager!) {
        guard let locks:[SLLock] = self.dbManager.locksForCurrentUser() as? [SLLock] else {
            print("Will not start BLE scan. There is no user or the user doesn't have any locks")
            return
        }
        
        for lock in locks where lock.isCurrentLock!.boolValue {
            interfaceManager.startScan()
            NSNotificationCenter.defaultCenter().postNotificationName(
                kSLNotificationLockManagerBlePoweredOn,
                object: nil
            )
            break
        }
    }
    
    func bleInterfaceManagerIsPoweredOff(interfaceManager: SEBLEInterfaceMangager!) {
        print("BLE interface manager has powered down")
    }
    
    func bleInterfaceManager(
        interfaceManger: SEBLEInterfaceMangager!,
        discoveredPeripheral peripheral: SEBLEPeripheral!,
                             withAdvertisemntData advertisementData: [NSObject : AnyObject]!
        )
    {
        if let lockName = peripheral.peripheral.name {
           print("Found lock named \(lockName)")
        }
        
        guard let lockName = advertisementData["kCBAdvDataLocalName"] as? String else {
            print(
                "Discovered peripheral \(peripheral.description) but cannot connect. " +
                "No local name in advertisement data."
            )
            return
        }
        
        guard let user = self.dbManager.currentUser else {
            print("Error: discovered peripheral \(lockName), but there is no current user.")
            return
        }
        
        guard let macAddress = lockName.macAddress() else {
            print("Could not retreive mac address from \(peripheral.description)")
            return
        }
        
        let hasBeenDetected = self.bleManager.hasNonConnectedPeripheralWithKey(macAddress)
        self.bleManager.setNotConnectedPeripheral(peripheral, forKey: macAddress)
        let lock:SLLock
        if let dbLock = self.dbManager.getLockWithMacAddress(macAddress) {
            lock = dbLock
            lock.name = lockName
            self.dbManager.saveLock(lock)
        } else {
            lock = self.dbManager.newLockWithName(lockName, andUUID: peripheral.CBUUIDAsString())
        }
        
        if let lockUser = lock.user, let lockUserId = lockUser.userId, let currentUserId = user.userId
            where lockUserId != currentUserId
        {
                print("Discoved lock \(lockName), but it does not belong to the current user \(user.userId)")
                return
        }
        
        print("Discoved lock \(lock.description). Lock manager is in state \(self.currentState)")
        
        if lock.isSetForDeletion!.boolValue {
            self.dbManager.deleteLock(lock, withCompletion: nil)
            self.bleManager.removePeripheralForKey(macAddress)
            self.bleManager.removeNotConnectPeripheralForKey(macAddress)
            self.bleManager.stopScan()
            self.stopGettingHardwareInfo()
            self.currentState = .FindCurrentLock
            NSNotificationCenter.defaultCenter().postNotificationName(
                kSLNotificationLockManagerDeletedLock,
                object: macAddress
            )
        } else if self.currentState == .FindCurrentLock && lock.isCurrentLock!.boolValue {
            // Case 1: Check if lock is the current lock. This is the case that happens
            // when the app first connects to the current lock after a disconnection.
            self.connectToLockWithMacAddress(macAddress)
        } else if self.currentState == .ActiveSearch && !hasBeenDetected {
            // Case 2: We are actively looking for locks. When a new lock is found 
            // We'll send out an alert to let the rest of the app know that the lock was discovered
            NSNotificationCenter.defaultCenter().postNotificationName(
                kSLNotificationLockManagerDiscoverdLock,
                object: lock
            )
        } else if self.currentState == .UpdateFirmware && lock.isInBootMode!.boolValue {
            // Case 3: The lock has been reset to boot mode. This is currently used for firmware update,
            // however, there are other use cases for this mode.
            self.connectToLockWithMacAddress(macAddress)
        } else {
            // Case 4: If the lock does not pass any of the preceeding tests, we should handle
            // the case here. We may need to disconnect the peripheral in the ble manager, but
            // then again maybe not. I need to think about that for awhile.
            print("The discovered lock: \(lockName) could not be processed")
        }
    }
    
    func bleInterfaceManager(
        interfaceManager: SEBLEInterfaceMangager!,
        connectedPeripheralNamed peripheralName: String!
        )
    {
        let macAddress = peripheralName.macAddress()
        guard let peripheral = self.bleManager.notConnectedPeripheralForKey(macAddress) else {
            print("Ble Manager does not have a not connect peripheral named: \(peripheralName)")
            return
        }
        
        self.bleManager.removeNotConnectPeripheralForKey(macAddress)
        self.bleManager.setConnectedPeripheral(peripheral, forKey: macAddress)
        self.bleManager.discoverServices(nil, forPeripheralWithKey: macAddress)
    }
    
    func bleInterfaceManager(
        interfaceManager: SEBLEInterfaceMangager!,
        discoveredServicesForPeripheralNamed peripheralName: String!
        )
    {
        print("Discovered services for " + peripheralName)
        self.bleManager.discoverServicesForPeripheralKey(peripheralName.macAddress())
    }
    
    func bleInterfaceManager(
        interfaceManager: SEBLEInterfaceMangager!,
        discoveredCharacteristicsForService service: CBService!,
                                            forPeripheralNamed peripheralName: String!
        )
    {
        print("Discovered characteristics for service \(service.description)")
        guard let macAddress = peripheralName.macAddress() else {
            print("Error: Discovered characteristics for \(peripheralName), but there is no mac address")
            return
        }
        
        self.bleManager.discoverCharacteristicsForService(service, forPeripheralKey: macAddress)
        
        let serviceUUID = service.UUID.UUIDString
        if self.serviceUUID(.Boot) == serviceUUID {
            guard let lock = self.dbManager.getLockWithMacAddress(macAddress) else {
                print("Could not find characteristics for boot service for lock: " + peripheralName)
                return
            }
            
            if lock.isInBootMode!.boolValue {
                print("Lock with address \(macAddress) is in boot mode")
                self.getFirmwareFromServer({ (success) in
                    if success {
                        self.bleManager.stopScan()
                        self.writeFirmwareForLockWithMacAddress(lock.macAddress!)
                    } else {
                        print("Error: could not write firmware to server upon boot service discovery.")
                    }
                })
            }
        }
    }
    
    func bleInterfaceManager(
        interfaceManager: SEBLEInterfaceMangager!,
        peripheralName: String!,
        changedUpdateStateForCharacteristic characteristicUUID: String!
        )
    {
        guard let macAddress = peripheralName.macAddress() else {
            print("Error: Notification state updated for \(peripheralName), but there is no mac address.")
            return
        }
        
        if characteristicUUID == self.characteristicUUID(.CommandStatus) {
            switch self.securityPhase {
            case .PublicKey:
                self.handlePublicKeyConnectionPhaseForMacAddress(macAddress)
            case .ChallengeKey:
                self.handleChallengeKeyConnectionPhaseForMacAddress(macAddress)
            case .SignedMessage:
                self.handleSignedMessageConnectionPhaseForMacAddress(macAddress)
            default:
                print(
                    "Changed notification state for uuid: \(characteristicUUID) "
                    + "case not handled for security state: \(self.securityPhase)"
                )
            }
        } else {
            print("Warning: changed notification state for uuid: \(characteristicUUID), but the case is not handled.")
        }
    }
    
    func bleInterfaceManager(
        interfaceManager: SEBLEInterfaceMangager!,
        wroteValueToPeripheralNamed peripheralName: String!,
                                    forUUID uuid: String!,
                                            withWriteSuccess success: Bool
        )
    {
        guard let macAddress = peripheralName.macAddress() else {
            print("Error: wrote value to \(peripheralName), but there is no mac address.")
            return
        }
        
        switch uuid {
        case self.characteristicUUID(.Lock):
            self.bleManager.readValueForPeripheralWithKey(
                macAddress,
                forServiceUUID: self.serviceUUID(.Hardware),
                andCharacteristicUUID: self.characteristicUUID(.Lock)
            )
        case self.characteristicUUID(.LED):
            self.bleManager.readValueForPeripheralWithKey(
                macAddress,
                forServiceUUID: self.serviceUUID(.Hardware),
                andCharacteristicUUID: self.characteristicUUID(.LED)
            )
        case self.characteristicUUID(.ButtonSequece):
            self.bleManager.readValueForPeripheralWithKey(
                macAddress,
                forServiceUUID: self.serviceUUID(.Configuration),
                andCharacteristicUUID: self.characteristicUUID(.ButtonSequece)
            )
        case self.characteristicUUID(.ResetLock):
            self.handleLockResetForMacAddress(macAddress, success: success)
        case self.characteristicUUID(.CommandStatus):
            print("handle command status")
        case self.characteristicUUID(.WriteFirmware):
            self.writeFirmwareForLockWithMacAddress(macAddress)
        case self.characteristicUUID(.FirmwareUpdateDone):
            self.handleFirmwareUpdateCompletion(macAddress, success: success)
        case self.characteristicUUID(.TxPower):
            print("handle power update")
        default:
            print("Write to \(uuid) was a \(success ? "success": "failure") but the case is not handled")
        }
    }
    
    func bleInterfaceManager(
        interfaceManager: SEBLEInterfaceMangager!,
        updatedPeripheralNamed peripheralName: String!,
                               forCharacteristicUUID characteristicUUID: String!,
                                                     withData data: NSData!
        )
    {
        guard let macAddress = peripheralName.macAddress() else {
            print(
                "Error: updated characteristc \(characteristicUUID) for "
                + "\(peripheralName), but there is no mac address"
            )
            return
        }
        
        switch characteristicUUID {
        case self.characteristicUUID(.CommandStatus):
            self.handleCommandStatusUpdateForLockMacAddress(macAddress, data: data)
        case self.characteristicUUID(.HardwareInfo):
            self.handleHardwareServiceForMacAddress(macAddress, data: data)
        case self.characteristicUUID(.Lock):
            self.handleLockStateForLockMacAddress(macAddress, data: data)
        case self.characteristicUUID(.Accelerometer):
            self.handleAccelerometerForLockMacAddress(macAddress, data: data)
        case self.characteristicUUID(.ChallengeData):
            self.handleChallengeDataForLockMacAddress(macAddress, data: data)
        case self.characteristicUUID(.LED):
            self.handleLEDStateForLockMacAddress(macAddress, data: data)
        case self.characteristicUUID(.ButtonSequece):
            self.handleLockSequenceWriteForMacAddress(macAddress, data: data)
        case self.characteristicUUID(.FirmwareVersion):
            self.handleReadFirmwareVersionForMacAddress(macAddress, data: data)
        case self.characteristicUUID(.SerialNumber):
            self.handleReadSerialNumberForMacAddress(macAddress, data: data)
        case self.characteristicUUID(.Magnet):
            print("need to write a method to handle the magnet update")
        default:
            print("No matching case updating peripheral: \(peripheralName) for uuid: \(characteristicUUID)")
        }
    }
    
    func bleInterfaceManager(
        interfaceManager: SEBLEInterfaceMangager!,
        disconnectedPeripheralNamed peripheralName: String!)
    {
        guard let macAddress = peripheralName.macAddress() else {
            print("Could not get mac address from periphreal name: " + peripheralName)
            return
        }
        
        self.stopGettingHardwareInfo()
        self.currentState = .FindCurrentLock
        self.bleManager.removeConnectedPeripheralForKey(macAddress)
        self.bleManager.removeNotConnectPeripheralForKey(macAddress)
        
        NSNotificationCenter.defaultCenter().postNotificationName(
            kSLNotificationLockManagerDisconnectedLock,
            object: macAddress
        )
        
        if self.afterDisconnectLockClosure != nil {
            self.afterDisconnectLockClosure!()
            self.afterDisconnectLockClosure = nil
        }
        
        self.afterUserDisconnectLockClosure == nil ? self.startBleScan() : self.afterUserDisconnectLockClosure!()
    }
    
    // MARK: SLLockValueDelegate Methods
    func lockValueMeanUpdated(lockValue: SLLockValue!, mean meanValues: [NSObject : AnyObject]!) {
        print("Updated values for lock: \(lockValue.getMacAddress()). Values \(meanValues.description)")
        
        guard let lock = self.dbManager.getLockWithMacAddress(lockValue.getMacAddress()) else {
            print("Error: could not update mean values for lock: \(lockValue.getMacAddress()). No matching lock in db")
            return
        }
    
        lock.updateAccelerometerValues(meanValues)
        
        let notificationManager:SLNotificationManager = SLNotificationManager.sharedManager() as! SLNotificationManager
        notificationManager.checkIfLockNeedsNotification(lock)
    }
}
