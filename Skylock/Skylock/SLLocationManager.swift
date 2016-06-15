//
//  SLLocationManager.swift
//  Skylock
//
//  Created by Andre Green on 6/14/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import Foundation
import CoreLocation

@objc protocol SLLocationManagerDelegate {
    func locationManagerUpdatedUserPosition(userLocation: CLLocation)
    func locationManagerDidAcceptedLocationAuthoriation(didAccept: Bool)
}

@objc class SLLocationManager: NSObject, CLLocationManagerDelegate {
    var delegate:SLLocationManagerDelegate?
    
    private lazy var manager:CLLocationManager = {
        let locManager:CLLocationManager = CLLocationManager()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest

        return locManager
    }()
    
    func requestAuthorization() {
        self.manager.requestAlwaysAuthorization()
    }
    
    func getCurrentLocation() -> CLLocation? {
        return self.manager.location
    }
    
    // MARK: CLLocationMangerDelegate methods
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        var didAccept = false
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            manager.startUpdatingLocation()
            didAccept = true
        }
        
        self.delegate?.locationManagerDidAcceptedLocationAuthoriation(didAccept)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.first else {
            return
        }
        
        self.delegate?.locationManagerUpdatedUserPosition(userLocation)
    }
}
