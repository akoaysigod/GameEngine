//
//  GameViewController.swift
//  MKTest
//
//  Created by Anthony Green on 12/23/15.
//  Copyright © 2015 Anthony Green. All rights reserved.
//

import Metal
import MetalKit

#if os(iOS)
  import UIKit
  public typealias ViewController = UIViewController
  public typealias Screen = UIScreen
#else
  import Cocoa
  public typealias ViewController = NSViewController
  //public typealias Screen = NSScreen
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
open class GameViewController: ViewController {
  public var scene: Scene!
  fileprivate var timestamp = 0.0

  override open func loadView() {
    view = GameView(frame: Screen.main.bounds)
  }

  override open func viewDidLoad() {
    super.viewDidLoad()
    
    let view = self.view as! GameView
    view.clearColor = Color(0.0, 0.5, 0.0).clearColor
    view.delegate = self
  }
}

extension GameViewController: MTKViewDelegate {
  public func draw(in view: MTKView) {
    (self.view as! GameView).update(time: CACurrentMediaTime())
  }

  public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {

  }
}
