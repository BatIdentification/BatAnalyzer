//
//  TabViewController.swift
//  BatIdentification
//
//  Created by Richard Beattie on 6/6/18.
//  Copyright © 2018 Richard Beattie. All rights reserved.
//

import Cocoa

class TabViewController: NSTabViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        if(isFirstLaunch()){
            
            self.selectedTabViewItemIndex = 1
            
        }
    }
    
    func isFirstLaunch() -> Bool{
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        
        if(launchedBefore){
            return false
        }else{
            return true
        }
        
    }
    
    public func switchView(viewNum: NSInteger){
        
        self.selectedTabViewItemIndex = viewNum
        
    }
    
}
