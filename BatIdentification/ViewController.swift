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
    
    @IBOutlet weak var statusLabel: NSTextField!
    
    var running = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    @IBAction func toggleStatus(_ sender: Any) {
        
        if(running){
            
            // Stop the program from running
            running = false
            
        }else{
                
            analyzeCall()
            
        }
       
        
    }
    
    func analyzeCall(){

        statusLabel.stringValue = "Status: Getting information from BatIdentification"
        
        loader.getCallInformation() { result in

            var callResponse: BatCall?
            
            do{
                
                callResponse = try result()
                
            }catch RequestErrors.ConnectionError{
                
                self.showWarning(warning: NSLocalizedString("loader.connection", tableName: "Warnings", comment: ""))
                return
                
            }catch RequestErrors.ResponseError{
                
                self.showWarning(warning: NSLocalizedString("loader.response", tableName: "Warnings", comment: ""))
                return
                
            }catch RequestErrors.RuntimeError(let error){
                
                self.showWarning(warning: error)
                return
                
            }catch _{
                
                self.showWarning(warning: "Something went wrong, but we don't know what. Maybe try again?")
                return
                
            }
            
            guard let call = callResponse else{

                self.showWarning(warning: NSLocalizedString("call.information", tableName: "Warnings", comment: ""))
                return

            }

            self.statusLabel.stringValue = "Status: Downloading a bat call"
            
            //Download the call
            
            if(call.downloadCall()){
                
                //Change status
                self.statusLabel.stringValue = "Status: Generating anaylzation files for bat call"
                
                //Get the correct path to the downloaded file
                
                if(self.createFiles()){
                
                    self.statusLabel.stringValue = "Status: Uploading files to BatIdentification"
                    
                    let manager = FileManager.default
                    let specPath = manager.currentDirectoryPath + "/spec.png"
                    let timeExpansionPath = manager.currentDirectoryPath + "/time_expansion.wav"
                    
                    self.loader.uploadFiles(spec: specPath, time_expansion: timeExpansionPath, analysing_id: call.identifer)
                    
                    self.statusLabel.stringValue = "Status: Finished analyzing a bat call"
                    
                    var count = 5
                    
                    var timer: Timer?
                    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {_ in
                        
                        self.statusLabel.stringValue = "Status: Resuming in \(String(count))"
                        count -= 1
                        
                        if(count == 0){
                            
                            timer?.invalidate()
                            analyzeCall()
                            
                        }
                        
                    })
                    
                }
                
            }else{
                
                self.showWarning(warning: NSLocalizedString("call.download", tableName: "Warnings", comment: ""))
                
            }
            
        }
        
    }
    
    func createFiles() -> Bool{
        
        let manager = FileManager.default
        let path = manager.currentDirectoryPath + "/bat_call.wav"
        
        //Run SOX to create a spectrogram and time expansion
        let SoxController = Sox()
        let spectrogramResult = SoxController.createSpectrogram(audio: path)
        let timeExpansionResult = SoxController.createTimeExpansion(audio: path)
        
        if(!spectrogramResult || !timeExpansionResult){
            self.showWarning(warning: NSLocalizedString("call.analyze", tableName: "Warnings", comment: ""))
            return false
        }
        
        return true
        
    }
    
    private func showWarning(warning: String){
        
        self.statusLabel.stringValue = "Status: Stopped due to an error"
        running = false
        
        let identifier = NSStoryboard.SceneIdentifier(rawValue: "Warning")
        let viewController = self.storyboard?.instantiateController(withIdentifier: identifier) as! WarningViewController
        self.presentViewControllerAsModalWindow(viewController as NSViewController)
        viewController.warningLabel.stringValue = warning
        
    }
    
}

