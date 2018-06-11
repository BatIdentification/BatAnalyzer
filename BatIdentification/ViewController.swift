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
        
        analyzeCall()
        
    }
    
    func analyzeCall(){

        loader.getCallInformation() { result in

            var callResponse: BatCall?
            
            do{
                
                callResponse = try result()
                
            }catch let error{
                
                print(error);
                
            }
            
            guard let call = callResponse else{

                self.showWarning()
                return

            }

            print("Got call data")
            
            //Download the call
            
            if(call.downloadCall()){
                
                //Change status
                print("Downloaded call")
                
                //Get the correct path to the downloaded file
                let manager = FileManager.default
                let path = manager.currentDirectoryPath + "/bat_call.wav"
                
                //Run SOX to create a spectrogram and time expansion
                let SoxController = Sox()
                let spectrogramResult = SoxController.createSpectrogram(audio: path)
                let timeExpansionResult = SoxController.createTimeExpansion(audio: path)
                
                if(!spectrogramResult || !timeExpansionResult){
                    self.showWarning()
                }else{
                
                    print("Made files")
                    let specPath = manager.currentDirectoryPath + "/spec.png"
                    let timeExpansionPath = manager.currentDirectoryPath + "/time_expansion.wav"
                    
                    self.loader.uploadFiles(spec: specPath, time_expansion: timeExpansionPath, analysing_id: call.identifer)
                    
                }
                
            }else{
                
                self.showWarning()
                
            }
            
        }
        
    }
    
    private func showWarning(){
        
        let identifier = NSStoryboard.SceneIdentifier(rawValue: "Warning")
        let viewController = self.storyboard?.instantiateController(withIdentifier: identifier)
        self.presentViewControllerAsModalWindow(viewController as! NSViewController)
        
    }
    
}

