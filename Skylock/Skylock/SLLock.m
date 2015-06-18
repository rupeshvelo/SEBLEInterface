//
//  SLLock.m
//  Skylock
//
//  Created by Andre Green on 6/17/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLLock.h"

@implementation SLLock

- (id)initWithName:(NSString *)name
batteryRemaining:(NSNumber *)batteryRemaining
      wifiStrength:(NSNumber *)wifiStrength
      cellStrength:(NSNumber *)cellStrength
          lastTime:(NSNumber *)lastTime
      distanceAway:(NSNumber *)distanceAway
          isLocked:(NSNumber *)isLocked
            lockId:(NSString *)lockId
{
    self = [super init];
    if (self) {
        _name = name;
        _batteryRemaining   = batteryRemaining;
        _wifiStrength       = wifiStrength;
        _cellStrength       = cellStrength;
        _lastTime           = lastTime;
        _distanceAway       = distanceAway;
        _lockId             = lockId;
    }
    
    return self;
}

- (SLLockCellSignalState)cellSignalState
{
    SLLockCellSignalState cellState = SLLockCellSignalStateNone;
    if (self.cellStrength.floatValue > 0.0 && self.cellStrength.floatValue <= 20.0) {
        cellState = SLLockCellSignalState1;
    } else if (self.cellStrength.floatValue > 20.0 && self.cellStrength.floatValue <= 40.0) {
        cellState = SLLockCellSignalState2;
    } else if (self.cellStrength.floatValue > 40.0 && self.cellStrength.floatValue <= 60.0) {
        cellState = SLLockCellSignalState3;
    } else if (self.cellStrength.floatValue > 60.0 && self.cellStrength.floatValue <= 80.0) {
        cellState = SLLockCellSignalState4;
    } else if (self.cellStrength.floatValue > 80.0 && self.cellStrength.floatValue <= 100.0) {
        cellState = SLLockCellSignalState5;
    }
    
    return cellState;
}

- (SLLockBatteryState)batteryState
{
    SLLockBatteryState batState = SLLockBatteryStateNone;
    if (self.batteryRemaining.floatValue > 0.0 && self.batteryRemaining.floatValue <= 20.0) {
        batState = SLLockBatteryState1;
    } else if (self.batteryRemaining.floatValue > 20.0 && self.batteryRemaining.floatValue <= 40.0) {
        batState = SLLockBatteryState2;
    } else if (self.batteryRemaining.floatValue > 40.0 && self.batteryRemaining.floatValue <= 60.0f) {
        batState = SLLockBatteryState3;
    } else if (self.batteryRemaining.floatValue > 60.0 && self.batteryRemaining.floatValue <= 80.0f) {
        batState = SLLockBatteryState4;
    } else if (self.batteryRemaining.floatValue > 80.0 && self.batteryRemaining.floatValue <= 100.0f) {
        batState = SLLockBatteryState3;
    }
    
    return batState;
}

- (SLLockWifiSignalState)wifiState
{
    SLLockWifiSignalState wifiState = SLLockWifiSignalStateNone;
    if (self.wifiStrength.floatValue > 0.0 && self.wifiStrength.floatValue <= 20.0) {
        wifiState = SLLockWifiSignalState1;
    } else if (self.wifiStrength.floatValue > 20.0 && self.wifiStrength.floatValue <= 40.0) {
        wifiState = SLLockWifiSignalState2;
    } else if (self.wifiStrength.floatValue > 40.0 && self.wifiStrength.floatValue <= 60.0f) {
        wifiState = SLLockWifiSignalState3;
    } else if (self.wifiStrength.floatValue > 60.0 && self.wifiStrength.floatValue <= 80.0f) {
        wifiState = SLLockWifiSignalState4;
    } else if (self.wifiStrength.floatValue > 80.0 && self.wifiStrength.floatValue <= 100.0f) {
        wifiState = SLLockWifiSignalState3;
    }
    
    return wifiState;
}
@end
