//
//  SLString.swift
//  Skylock
//
//  Created by Andre Green on 6/17/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import Foundation

extension String {
    func trimmedWhiteSpaces() -> String {
        let trimmedString:String = self.stringByTrimmingCharactersInSet(
            NSCharacterSet(charactersInString: " ")
        )
        return trimmedString
    }
    
    func macAddress() -> String? {
        let hypenParts = self.componentsSeparatedByString("-")
        if hypenParts.count == 2 {
            return hypenParts[1]
        }
        
        let spacedParts = self.componentsSeparatedByString(" ")
        if spacedParts.count == 2 {
            return spacedParts[1]
        }
        
        return nil
    }
}
