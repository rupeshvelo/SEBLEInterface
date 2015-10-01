//
//  SLDirectionAPIHelper.swift
//  Skylock
//
//  Created by Andre Green on 9/16/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

import Foundation
import CoreLocation

class SLDirectionAPIHelper: NSObject {
    let startPoint: CLLocationCoordinate2D
    let endPoint: CLLocationCoordinate2D
    let token: String
    let isBiking: Bool
    
    init(start: CLLocationCoordinate2D, end:CLLocationCoordinate2D, isBiking: Bool, token: String) {
        self.startPoint = start
        self.endPoint = end
        self.token = token
        self.isBiking = isBiking
    }
    
    func getDirections(completion: ()->()) {
        let mainUrl: String = "https://api.mapbox.com/v4/directions/mapbox."
        let transportUrl: String = self.isBiking ? "cycling/" : "walking/"
        let positionUrl: String = "\(self.startPoint.longitude),\(self.startPoint.latitude);\(self.endPoint.longitude),\(self.endPoint.latitude)"
        let tokenUrl: String = ".json?access_token=" + self.token
        let url = mainUrl + transportUrl + positionUrl + tokenUrl
        SLRestManager.sharedManager().restGetRequestWithURL(url, options: nil) { (_: [NSObject : AnyObject]!) -> Void in
            
            if completion
        }
    }
}
