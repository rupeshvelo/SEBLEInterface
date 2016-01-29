//
//  SLDirectionDrawingHelper.swift
//  Skylock
//
//  Created by Andre Green on 9/11/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation
import GoogleMaps

class SLDirectionDrawingHelper: NSObject {
    let mapView: GMSMapView
    let directions: [SLDirection]
    
    init(mapView: GMSMapView, directions: [SLDirection]) {
        self.mapView = mapView;
        self.directions = directions;
    }
    
    func drawDirections(completion: () -> ()) {
        let path = GMSMutablePath()
        for direction in self.directions where direction.start != nil {
            path.addCoordinate(direction.start!)
        }
        
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 5
        polyline.strokeColor = UIColor.redColor()
        polyline.map = self.mapView
        
        completion()
    }
}
