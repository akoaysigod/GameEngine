//
//  GameViewController.swift
//  MKTest
//
//  Created by Anthony Green on 12/23/15.
//  Copyright © 2015 Anthony Green. All rights reserved.
//

import Metal
//tmp typealias stuff I think
#if os(iOS)
  import UIKit
  public typealias VC = UIViewController
#else
  import Cocoa
  public typealias VC = NSViewController
#endif

/**
 The `GameViewController` is a controller for stuff. It probably won't do much but it's required for iOS. Pretty much just 
 set up the `GameView` and `Scene` from here. After that???
 
 A basic setup in viewDidLoad() would look something like 
 
 ````
 super.viewDidLoad()

 let view = self.view as! GameView
 scene = Scene(size: view.bounds.size)
 view.presentScene(scene)
 ````
 */
public class GameViewController: VC {
  public var scene: Scene!

  override public func loadView() {
    view = GameView(frame: Screen.main.nativeBounds)
  }
}
