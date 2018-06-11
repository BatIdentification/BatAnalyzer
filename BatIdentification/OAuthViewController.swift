//
//  OAuthViewController.swift
//  BatIdentification
//
//  Created by Richard Beattie on 6/6/18.
//  Copyright © 2018 Richard Beattie. All rights reserved.
//

import Cocoa

let OAuth2AppDidReceiveCallbackNotification = NSNotification.Name(rawValue: "OAuth2AppDidReceiveCallback")

class OAuthViewController: NSViewController {

    @IBOutlet weak var warningLabel: NSTextField!
    var tabViewController: TabViewController!
    let loader = BatIdentificationLoader.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        tabViewController = self.parent as! TabViewController
    }
    
    @IBAction func connect(_ sender: Any) {
        
        warningLabel.stringValue = ""
        
        NotificationCenter.default.removeObserver(self, name: OAuth2AppDidReceiveCallbackNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OAuthViewController.handleRedirect(_:)), name: OAuth2AppDidReceiveCallbackNotification, object: nil)
        
        loader.getToken {
            
            status in
            
            if(status){
                
               self.tabViewController.selectedTabViewItemIndex = 0
                
            }else{
                
                 self.warningLabel.stringValue = "Sorry something went wrong there, please try again"
                
            }
            
        }
        
    }
    
    @objc func handleRedirect(_ notification: Notification) {
        print("Handling redirect")
        
        if let url = notification.object as? URL {
            do {
                try loader.oauth2.handleRedirectURL(url)
            }
            catch let error {
                print(error)
            }
        }
        else {
            print(NSError(domain: NSCocoaErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid notification: did not contain a URL"]))
        }
    }
    
}
