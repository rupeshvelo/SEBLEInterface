//
//  SLDirections.swift
//  Skylock
//
//  Created by Andre Green on 9/11/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

import Foundation
import CoreLocation

class SLDirections: NSObject {
    let startPoint: CLLocationCoordinate2D
    let endPoint: CLLocationCoordinate2D
    let key: String
    var directions: MBDirections?
    
    init(startPoint: CLLocationCoordinate2D, endPoint: CLLocationCoordinate2D, key: String) {
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.key = key
        super.init()
    }
    
    func getDirections() {
        let request = MBDirectionsRequest(sourceCoordinate: self.startPoint, destinationCoordinate: self.endPoint)
        directions = MBDirections(request: request, accessToken: self.key)
        directions!.calculateDirectionsWithCompletionHandler { (response, error) in
            if let route = response?.routes.first {
            
            } else {
                print("Error calculating route")
            }
        }
    }
    
}
