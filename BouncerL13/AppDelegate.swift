//
//  AppDelegate.swift
//  BouncerL13
//
//  Created by iMac21.5 on 5/19/15.
//  Copyright (c) 2015 Garth MacKenzie. All rights reserved.
//

import UIKit
import CoreMotion

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    struct Motion {
        static let Manager = CMMotionManager()
    }
    
    func applicationWillResignActive(application: UIApplication) {
//  explicitly opt out of background by adding the UIApplicationExitsOnSuspend key (with the value YES) to your app’s Info.plist file. When an app opts out, it cycles between the not-running, inactive, and active states and never enters the background or suspended states. When the user presses the Home button to quit the app, the applicationWillTerminate: method of the app delegate is called and the app has approximately 5 seconds to clean up and exit
    }
    
}