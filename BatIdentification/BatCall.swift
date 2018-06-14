//
//  BatCall.swift
//  BatIdentification
//
//  Created by Richard Beattie on 6/8/18.
//  Copyright © 2018 Richard Beattie. All rights reserved.
//

import Foundation

class BatCall{
    
    let url: NSURL
    let identifer: String
    
    public init(url: NSURL, identifer: String){
        
        self.url = url
        self.identifer = identifer
        
    }
    
    func downloadCall() -> Bool{
        
        let appendedURL = url.appendingPathComponent("original.wav")
        
        guard let absoluteUrl = appendedURL?.absoluteURL else{
            return false
        }
        
        guard let audioData = NSData(contentsOf: absoluteUrl) as Data? else{
            return false
        }
        
        let manager = FileManager.default
        
        let downloadPath = manager.currentDirectoryPath + "/bat_call.wav"
        
        manager.createFile(atPath: downloadPath, contents: audioData, attributes: nil)
        
        return true
        
    }
    
}
