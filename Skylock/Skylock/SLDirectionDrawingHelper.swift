//
//  SLDirectionDrawingHelper.swift
//  Skylock
//
//  Created by Andre Green on 9/11/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

import Foundation
import MapKit
import MapboxGL
import CoreLocation

class SLDirectionDrawingHelper: NSObject {
    let mapView: MGLMapView
    let directions: [SLDirection]
    
    init(mapView: MGLMapView, directions: [SLDirection]) {
        self.mapView = mapView;
        self.directions = directions;
    }
    
    func drawDirections(completion: () -> ()) {
        var coords: [CLLocationCoordinate2D] = []
        for direction in self.directions {
            coords.append(direction.coordinate)
        }
        
        let line: MGLPolyline = MGLPolyline(coordinates: &coords, count: UInt(coords.count))
        self.mapView.addAnnotation(line)
        
        completion()
    }
}
