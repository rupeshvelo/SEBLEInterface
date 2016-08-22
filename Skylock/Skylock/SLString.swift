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
    
    func bytesString() -> NSData? {
        let count = self.characters.count
        if count % 2 == 1 {
            print("cannot convert \(self) to bytes string. Odd number of digits.")
            return nil
        }
        
        var bytes:[UInt8] = [UInt8]()
        var index:Int = 0
        while index < count {
            let strIndex = self.startIndex.advancedBy(index)
            let subString = self.substringWithRange(strIndex..<strIndex.advancedBy(2))
            if let value = UInt8(subString, radix: 16) {
                bytes.append(value)
            }
            
            index += 2
        }
        
        return NSData(bytes: &bytes, length: bytes.count)
    }
}
