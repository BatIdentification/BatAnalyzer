//
//  AppDelegate.swift
//  BatIdentification
//
//  Created by Richard Beattie on 6/5/18.
//  Copyright © 2018 Richard Beattie. All rights reserved.
//

import Cocoa
import OAuth2

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationWillFinishLaunching(_ notification: Notification) {
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(self.handleURLEvent(event:reply:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    //Handles opening the app from the authorization webpage when we are requesting authorization
    
    @objc func handleURLEvent(event: NSAppleEventDescriptor, reply: NSAppleEventDescriptor) {
        
        guard let appleEventDescription = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject)) else {
            
            return
            
        }
        
        guard let appleEventUrlString = appleEventDescription.stringValue else{
            
            return
            
        }
        
        guard let appleEventURL = URL(string: appleEventUrlString) else{
            
            return
            
        }
        
        if "batidentification" == appleEventURL.scheme && "oauth" == appleEventURL.host {
            
            NotificationCenter.default.post(name: OAuth2AppDidReceiveCallbackNotification, object: appleEventURL)
            
        }else {
            NSLog("No valid URL to handle")
        }
    }

}

