//
//  File.swift
//  Ellipse
//
//  Created by S Rupesh Kumar on 21/10/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import Foundation

class SLVerifyTextCode : NSObject{
    
    public func verifyTextCode(phoneNumber:String, verifyHint:String, userToken:String,
                               completion: @escaping (_ status: UInt, _ response: [NSObject: AnyObject]?) -> ()){
        
        let restManager = SLRestManager.sharedManager() as! SLRestManager
        
        
        var subRoutes:[String] = []
        
        let headers = [
            "Authorization" as NSObject: restManager.basicAuthorizationHeaderValueUsername(userToken, password: "") as AnyObject
        ]
        
        var codeHint: [String: String] = [:]
        
        if(userToken.characters.count > 0){
            
            codeHint = ["verify_hint":verifyHint]
            
            
            subRoutes = [
                phoneNumber,
                restManager.path(asString: .phoneCodeVerification)
            ]
            
        } else {
            
            
            
            codeHint = ["password_hint":verifyHint]
            
            subRoutes = [
                phoneNumber,
                restManager.path(asString: .passwordCode)
            ]
            
        }
        
        
        restManager.postObject(
            codeHint,
            serverKey: .main,
            pathKey: .users,
            subRoutes: subRoutes,
            additionalHeaders: headers){ (status: UInt, textResponseDict:[AnyHashable:Any]?) -> () in
                    
                    completion(status, textResponseDict as [NSObject : AnyObject]?)
            }
        
        
    }
    
}
