//
//  AppDelegate.swift
//  Example-macOS
//
//  Created by Anthony Green on 12/24/16.
//  Copyright © 2016 Anthony Green. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  var window: NSWindow?

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    //self.window = NSWindow(frame: Screen.main.bounds)
    //self.window?.makeKeyAndVisible()

    //self.window?.rootViewController = TestGameViewController()
    // Insert code here to initialize your application
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }


}

