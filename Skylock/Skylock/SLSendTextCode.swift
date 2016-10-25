//
//  SLConfirmTextCode.swift
//  Ellipse
//
//  Created by S Rupesh Kumar on 21/10/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import Foundation

class SLSendTextCode : NSObject{
    
    public func sendTextCode(phoneNumber:String, userToken:String,
                             callback: @escaping (UInt, [AnyHashable: Any]?) -> Void){
        
        let restManager = SLRestManager.sharedManager() as! SLRestManager
    
        
        var subRoutes:[String] = []
        
        let headers = [
            "Authorization": restManager.basicAuthorizationHeaderValueUsername(userToken, password: "")
        ]
        
        if(userToken.characters.count > 0){

            
            subRoutes = [
                phoneNumber,
                restManager.path(asString: .phoneVerificaiton)
            ]

        } else {
            
           subRoutes = [
                phoneNumber,
                restManager.path(asString: .passwordReset)
            ]

        }
        
        
        restManager.getRequestWith(
            .main,
            pathKey: .users,
            subRoutes: subRoutes,
            additionalHeaders: headers,
            completion: callback
        )
    
    }
    
}
