//
//  SLSavePassword.swift
//  Ellipse
//
//  Created by S Rupesh Kumar on 21/10/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import Foundation

class SLSavePassword : NSObject{
    
    public func savePassword(phoneNumber:String, password:String,
                             completion: @escaping (_ status: UInt, _ response: [NSObject : AnyObject]?) -> ()){
        
        let restManager = SLRestManager.sharedManager() as! SLRestManager
        
        
        let subRoutes:[String] = [
            phoneNumber,
            restManager.path(asString: .newPassword)
        ]
        
        
        
        restManager.postObject(
            ["password":password],
            serverKey: .main,
            pathKey: .users,
            subRoutes: subRoutes,
            additionalHeaders: nil) { (status: UInt, textResponseDict:[AnyHashable: Any]?) -> () in
                    
                    completion(status, textResponseDict as [NSObject : AnyObject]?)
            }
        
    }
    
}

