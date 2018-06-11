//
//  Sox.swift
//  BatIdentification
//
//  Created by Richard Beattie on 6/10/18.
//  Copyright © 2018 Richard Beattie. All rights reserved.
//

import Foundation

class Sox{
    
    private var executablePath: String?
    
    public init(){
        
        let bundle = Bundle.main
        executablePath = bundle.path(forResource: "sox", ofType: "")
        
    }
    
    public func createSpectrogram(audio: String) -> Bool{
    
        let arguments = [audio, "-n", "remix", "1", "rate", "192k", "spectrogram", "-o", "spec.png"]
        
        let result = runProcess(arguments: arguments)
        
        if(result != ""){
           return false
        }
        
        return true
    
    }
    
    public func createTimeExpansion(audio: String) -> Bool{
        
        let arguments = ["-t", "wav", "-e", "signed-integer", "-b16", "-r", "192000", "-c", "2", audio, "-t", "wav", "-e", "signed-integer", "-b16", "-r", "192000", "-c", "2", "time_expansion.wav", "sinc", "10k", "speed", "0.1"]
        
        let result = runProcess(arguments: arguments)
        
        if(result != ""){
            return false
        }
        
        return true
        
    }
    
    private func runProcess(arguments: [String]) -> String{
        
        let task = Process()
        task.launchPath = executablePath
        task.arguments = arguments
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        task.launch()
        task.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
        return output
        
    }
    
}
