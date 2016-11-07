//
//  SLConfirmTextCode.swift
//  Ellipse
//
//  Created by S Rupesh Kumar on 21/10/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import Foundation

class SLSendTextCode : NSObject{
    public func sendTextCode(
        phoneNumber:String,
        userToken:String?,
        callback: @escaping (UInt, [AnyHashable: Any]?) -> Void)
    {
        
        let restManager = SLRestManager.sharedManager() as! SLRestManager
        var headers:[String:String]?
        if let token = userToken {
            headers = [
                "Authorization": restManager.basicAuthorizationHeaderValueUsername(token, password: "")
            ]
        }
        
        restManager.getRequestWith(
            .main,
            pathKey: .users,
            subRoutes: [phoneNumber],
            additionalHeaders: headers,
            completion: callback
        )
    }
}
