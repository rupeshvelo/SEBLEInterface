//
//  SLDirection.swift
//  Skylock
//
//  Created by Andre Green on 9/11/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

import Foundation;
import CoreLocation;

public class SLDirection: NSObject {
    public let coordinate: CLLocationCoordinate2D
    public let directions: String
    public let distance: Double

    internal init(coordinate: CLLocationCoordinate2D, directions: String, distance: Double) {
        self.coordinate = coordinate
        self.directions = directions
        self.distance = distance
        super.init()
    }
}
