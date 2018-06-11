//
//  ViewController.swift
//  BatIdentification
//
//  Created by Richard Beattie on 6/5/18.
//  Copyright © 2018 Richard Beattie. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    let loader = BatIdentificationLoader.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    @IBAction func toggleStatus(_ sender: Any) {
        
        downloadCall()
        
    }
    
    func downloadCall(){
        
        generateSpectrogram()
        
//        let loader = BatIdentificationLoader.shared
//
//        loader.getCallInformation() { call in
//
//            guard let call = call else{
//
//                let identifier = NSStoryboard.SceneIdentifier(rawValue: "Warning")
//                let viewController = self.storyboard?.instantiateController(withIdentifier: identifier)
//                self.presentViewControllerAsModalWindow(viewController as! ViewController)
//
//                return
//
//            }
//
//            print(call.downloadCall())
//
//        }
        
    }
    
    func generateSpectrogram(){
        
        let manager = FileManager.default
        let path = manager.currentDirectoryPath + "/bat_call.wav"
        
//        let SoxController = Sox()
//        SoxController.createSpectrogram(audio: path)
//        SoxController.createTimeExpansion(audio: path)
        
        let specPath = manager.currentDirectoryPath + "/spec.png"
        let timeExpansionPath = manager.currentDirectoryPath + "/time_expansion.wav"
        
        loader.uploadFiles(spec: specPath, time_expansion: timeExpansionPath, analysing_id: "5b1ab763bcef08.34343819")
        
    }
    
    
    
}

