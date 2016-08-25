//
//  SLLocationManager.swift
//  Skylock
//
//  Created by Andre Green on 6/14/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import Foundation
import CoreLocation

@objc protocol SLLocationManagerDelegate:class {
    func locationManagerUpdatedUserPosition(locationManager:SLLocationManager, userLocation: CLLocation)
    func locationManagerDidAcceptedLocationAuthorization(locationManager:SLLocationManager, didAccept: Bool)
}

@objc class SLLocationManager: NSObject, CLLocationManagerDelegate {
    weak var delegate:SLLocationManagerDelegate?
    
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
    
func beginUpdatingLocation() {
        self.manager.startUpdatingLocation()
    }
    
    // MARK: CLLocationMangerDelegate methods
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        var didAccept = false
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            manager.startUpdatingLocation()
            didAccept = true
        }
        
        self.delegate?.locationManagerDidAcceptedLocationAuthorization(self, didAccept: didAccept)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.first else {
            return
        }
        
        self.delegate?.locationManagerUpdatedUserPosition(self, userLocation: userLocation)
    }
}
