//
//  WarningViewController.swift
//  BatIdentification
//
//  Created by Richard Beattie on 6/8/18.
//  Copyright © 2018 Richard Beattie. All rights reserved.
//

import Cocoa

class WarningViewController: NSViewController {

    @IBOutlet weak var warningLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here
        
    }
    @IBAction func dismissWarning(_ sender: Any) {
        
        self.dismiss(self)
        
    }
    
    @IBAction func restartProgram(_ sender: Any) {
        
        let url = URL(fileURLWithPath: Bundle.main.resourcePath!)
        let path = url.deletingLastPathComponent().deletingLastPathComponent().absoluteString
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = [path]
        task.launch()
        exit(0)
        
    }
}
